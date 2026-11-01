//! Statechart interpreter for contracts/flows/*.json (semantics: contracts/flows/README.md).
//! Port of contracts/flows/flow-machine.js; passes contracts/vectors/capture-flow.json.
//!
//! The machine never runs effects: `send` returns their names and the platform adapter
//! (SwiftUI, Compose) performs them. Guards and actions are pure functions of the
//! context, the event payload and the template.
use serde_json::{json, Map, Value};

use crate::template::{FormTemplate, Severity};
use crate::validation::{validate, ValidationInput, ValidationIssue};

#[derive(Debug, Clone, PartialEq)]
pub struct SendResult {
    pub state: String,
    pub screen: Option<String>,
    pub context: Value,
    pub effects: Vec<String>,
    pub ignored: bool,
}

#[derive(Debug, Clone, PartialEq)]
pub struct AvailableEvent {
    pub event: String,
    pub enabled: bool,
    pub needs_payload: bool,
}

#[derive(Debug, Clone, PartialEq, thiserror::Error)]
#[error("flujo inválido: {0:?}")]
pub struct FlowError(pub Vec<String>);

pub struct FlowMachine {
    flow: Value,
    template: FormTemplate,
    state: String,
    context: Value,
}

// ------------------------------------------------------------------ helpers
fn is_int(v: &Value) -> bool {
    v.is_i64() || v.is_u64() || v.as_f64().is_some_and(|f| f.fract() == 0.0)
}
fn as_int(v: &Value) -> Option<i64> {
    if is_int(v) {
        v.as_i64().or_else(|| v.as_f64().map(|f| f as i64))
    } else {
        None
    }
}
fn is_obj(v: &Value) -> bool {
    v.is_object()
}
fn obj(v: &Value) -> Option<&Map<String, Value>> {
    v.as_object()
}

/// Strips origins: context {value, origin} entries -> plain validation input.
pub fn plain_values(context: &Value) -> ValidationInput {
    let mut input = ValidationInput::default();
    if let Some(m) = context.get("mesa").and_then(Value::as_object) {
        for (k, v) in m {
            input.mesa.insert(k.clone(), v.as_str().map(str::to_string));
        }
    }
    if let Some(h) = context.get("header").and_then(Value::as_object) {
        for (k, v) in h {
            input.header.insert(k.clone(), v.get("value").and_then(as_int));
        }
    }
    if let Some(c) = context.get("cells").and_then(Value::as_object) {
        for (cat, rows) in c {
            let entry = input.cells.entry(cat.clone()).or_default();
            if let Some(rows) = rows.as_object() {
                for (row, v) in rows {
                    entry.insert(row.clone(), v.get("value").and_then(as_int));
                }
            }
        }
    }
    input
}

pub fn validate_context(context: &Value, template: &FormTemplate) -> Vec<ValidationIssue> {
    validate(&plain_values(context), template)
}

const ORIGINS: [&str; 2] = ["manual", "ocr-accepted"];

/// A value entry in a setValues payload: int, null (clear) or {value, origin}.
fn is_value_entry(e: &Value) -> bool {
    if e.is_null() || is_int(e) {
        return true;
    }
    let Some(o) = obj(e) else { return false };
    let value_ok = o.get("value").is_some_and(|v| v.is_null() || is_int(v));
    let origin_ok = match o.get("origin") {
        None => true,
        Some(Value::String(s)) => ORIGINS.contains(&s.as_str()),
        Some(_) => false,
    };
    value_ok && origin_ok
}

fn to_stored_value(e: &Value) -> Option<Value> {
    if e.is_null() {
        return None;
    }
    if let Some(n) = as_int(e) {
        return Some(json!({"value": n, "origin": "manual"}));
    }
    let v = e.get("value")?;
    let n = as_int(v)?;
    let origin = e.get("origin").and_then(Value::as_str).unwrap_or("manual");
    Some(json!({"value": n, "origin": origin}))
}

fn valid_values_payload(p: &Value, t: &FormTemplate) -> bool {
    let Some(p) = obj(p) else { return false };
    if !p.contains_key("header") && !p.contains_key("cells") {
        return false;
    }
    if let Some(h) = p.get("header") {
        let Some(h) = obj(h) else { return false };
        if !h.iter().all(|(id, v)| t.header_fields.iter().any(|f| &f.id == id) && is_value_entry(v)) {
            return false;
        }
    }
    if let Some(c) = p.get("cells") {
        let Some(c) = obj(c) else { return false };
        for (cat, rows) in c {
            if !t.categories.iter().any(|x| &x.id == cat) {
                return false;
            }
            let Some(rows) = obj(rows) else { return false };
            if !rows.iter().all(|(row, v)| t.rows.iter().any(|r| &r.id == row) && is_value_entry(v)) {
                return false;
            }
        }
    }
    true
}

fn valid_pages(pages: Option<&Value>) -> bool {
    pages.and_then(Value::as_array).is_some_and(|a| {
        !a.is_empty() && a.iter().all(|p| p.get("id").and_then(Value::as_str).is_some_and(|s| !s.is_empty()))
    })
}

fn valid_mesa(m: Option<&Value>) -> bool {
    m.and_then(Value::as_object).is_some_and(|m| m.values().all(|v| v.is_null() || v.is_string()))
}

/// Minimal blind double entry (AS-5 a): the second person types votantes and each
/// category total; both are compared with the first entry. Incomplete categories are null.
pub fn compute_mismatches(context: &Value, t: &FormTemplate) -> Value {
    let first = plain_values(context);
    let second = context.get("second").filter(|s| !s.is_null()).cloned().unwrap_or(json!({"votantes": null, "totals": {}}));
    let mut out = Vec::new();
    let v1 = first.header.get("votantes").copied().flatten();
    let v2 = second.get("votantes").and_then(as_int);
    if v1 != v2 {
        out.push(json!({"path": "header.votantes", "first": v1, "second": v2}));
    }
    for cat in &t.categories {
        let rows = first.cells.get(&cat.id);
        let mut sum = 0i64;
        let mut complete = true;
        for row in &t.rows {
            match rows.and_then(|r| r.get(&row.id)).copied().flatten() {
                Some(v) => sum += v,
                None => complete = false,
            }
        }
        let s1 = complete.then_some(sum);
        let s2 = second.get("totals").and_then(|x| x.get(&cat.id)).and_then(as_int);
        if s1 != s2 {
            out.push(json!({"path": format!("cells.{}", cat.id), "first": s1, "second": s2}));
        }
    }
    Value::Array(out)
}

// ------------------------------------------------------------------- guards
fn guard(name: &str, c: &Value, p: &Value, flow: &Value, t: &FormTemplate) -> Option<bool> {
    let issues = || validate_context(c, t);
    Some(match name {
        "payloadHasPresentation" => p
            .get("presentation")
            .and_then(Value::as_str)
            .is_some_and(|s| flow.get("presentations").and_then(|x| x.get(s)).is_some()),
        "payloadDocumentTypeAllowed" => p
            .get("documentType")
            .and_then(Value::as_str)
            .is_some_and(|s| t.document_types.iter().any(|d| serde_json::to_value(d).ok().as_ref().and_then(Value::as_str) == Some(s))),
        "payloadHasMesa" => is_obj(p) && valid_mesa(p.get("mesa")),
        "payloadHasPages" => is_obj(p) && valid_pages(p.get("pages")),
        "payloadHasPageId" => p.get("id").and_then(Value::as_str).is_some_and(|id| {
            c["pages"].as_array().is_some_and(|a| a.iter().any(|pg| pg.get("id").and_then(Value::as_str) == Some(id)))
        }),
        "payloadHasSample" => p.get("sample").filter(|s| is_obj(s)).is_some_and(|s| {
            s.get("id").and_then(Value::as_str).is_some_and(|id| !id.is_empty())
                && valid_mesa(s.get("mesa"))
                && valid_pages(s.get("pages"))
        }),
        "payloadHasValues" => valid_values_payload(p, t),
        "payloadHasJustification" => p.get("justification").is_some_and(|j| j.is_null() || j.is_string()),
        "payloadHasSecondValues" => {
            let Some(o) = obj(p) else { return Some(false) };
            if !o.contains_key("votantes") && !o.contains_key("totals") {
                return Some(false);
            }
            if let Some(v) = o.get("votantes") {
                if !(v.is_null() || is_int(v)) {
                    return Some(false);
                }
            }
            match o.get("totals") {
                None => true,
                Some(tot) => obj(tot).is_some_and(|tot| {
                    tot.iter().all(|(cat, v)| t.categories.iter().any(|x| &x.id == cat) && (v.is_null() || is_int(v)))
                }),
            }
        }
        "documentTypeChosen" => !c["documentType"].is_null(),
        "mesaComplete" => t
            .mesa_fields
            .iter()
            .all(|f| c["mesa"].get(&f.id).and_then(Value::as_str).is_some_and(|s| !s.trim().is_empty())),
        "hasPages" => c["pages"].as_array().is_some_and(|a| !a.is_empty()),
        "noErrors" => !issues().iter().any(|i| i.severity == Severity::Error),
        "noWarnings" => !issues().iter().any(|i| i.severity == Severity::Warning),
        "justificationGiven" => c["justification"].as_str().is_some_and(|s| s.trim().chars().count() >= 5),
        "doubleEntryPending" => c["doubleEntry"] == "pending",
        "presentationSupportsDoubleEntry" => c["presentation"]
            .as_str()
            .and_then(|pres| flow.get("presentations").and_then(|x| x.get(pres)))
            .is_some_and(|x| x.get("supportsDoubleEntry") == Some(&Value::Bool(true))),
        "secondComplete" => {
            let s = &c["second"];
            let nn = |v: Option<&Value>| v.and_then(as_int).is_some_and(|n| n >= 0);
            !s.is_null() && nn(s.get("votantes")) && t.categories.iter().all(|cat| nn(s.get("totals").and_then(|x| x.get(&cat.id))))
        }
        "entriesMatch" => !c["second"].is_null() && c["mismatches"].as_array().is_some_and(Vec::is_empty),
        _ => return None,
    })
}

// ------------------------------------------------------------------ actions
fn merge_mesa(c: &mut Value, mesa: &Value) {
    if !c["mesa"].is_object() {
        c["mesa"] = json!({});
    }
    if let Some(m) = mesa.as_object() {
        let target = c["mesa"].as_object_mut().unwrap();
        for (k, v) in m {
            if v.is_null() {
                target.remove(k);
            } else {
                target.insert(k.clone(), v.clone());
            }
        }
    }
}

fn append_pages(c: &mut Value, pages: &[Value]) {
    if !c["pages"].is_array() {
        c["pages"] = json!([]);
    }
    let list = c["pages"].as_array_mut().unwrap();
    for page in pages {
        let id = page.get("id");
        if !list.iter().any(|p| p.get("id") == id) {
            list.push(page.clone());
        }
    }
}

fn clear_second(c: &mut Value) {
    c["second"] = Value::Null;
    c["mismatches"] = json!([]);
    c["doubleEntry"] = json!("none");
}

fn action(name: &str, c: &mut Value, p: &Value, t: &FormTemplate) -> bool {
    match name {
        "setPresentation" => c["presentation"] = p["presentation"].clone(),
        "setDocumentType" => c["documentType"] = p["documentType"].clone(),
        "setMesa" => merge_mesa(c, &p["mesa"]),
        "appendPages" => append_pages(c, p["pages"].as_array().map(Vec::as_slice).unwrap_or(&[])),
        "removePage" => {
            let id = p["id"].clone();
            if let Some(a) = c["pages"].as_array_mut() {
                a.retain(|pg| pg.get("id") != Some(&id));
            }
        }
        "useSample" => {
            let s = &p["sample"];
            merge_mesa(c, &s["mesa"]);
            let pages: Vec<Value> = s["pages"]
                .as_array()
                .map(|a| {
                    a.iter()
                        .map(|pg| {
                            let mut pg = pg.clone();
                            pg["source"] = json!("sample");
                            pg
                        })
                        .collect()
                })
                .unwrap_or_default();
            append_pages(c, &pages);
            let label = s.get("label").filter(|l| l.is_string()).cloned().unwrap_or_else(|| s["id"].clone());
            c["sample"] = json!({"id": s["id"], "label": label});
        }
        "setValues" => {
            if let Some(h) = p.get("header").and_then(Value::as_object) {
                if !c["header"].is_object() {
                    c["header"] = json!({});
                }
                for (id, e) in h {
                    match to_stored_value(e) {
                        Some(v) => c["header"][id] = v,
                        None => {
                            c["header"].as_object_mut().unwrap().remove(id);
                        }
                    }
                }
            }
            if let Some(cells) = p.get("cells").and_then(Value::as_object) {
                if !c["cells"].is_object() {
                    c["cells"] = json!({});
                }
                for (cat, rows) in cells {
                    if !c["cells"][cat].is_object() {
                        c["cells"][cat] = json!({});
                    }
                    for (row, e) in rows.as_object().into_iter().flatten() {
                        match to_stored_value(e) {
                            Some(v) => c["cells"][cat][row] = v,
                            None => {
                                c["cells"][cat].as_object_mut().unwrap().remove(row);
                            }
                        }
                    }
                }
            }
        }
        // Editing the first entry after a match voids the match; a pending comparison survives.
        "invalidateDoubleEntry" => {
            if c["doubleEntry"] == "matched" {
                clear_second(c)
            }
        }
        "setJustification" => c["justification"] = p["justification"].clone(),
        "lock" => c["locked"] = json!(true),
        "clearSecond" => clear_second(c),
        "setSecondValues" => {
            if c["second"].is_null() {
                c["second"] = json!({"votantes": null, "totals": {}});
            }
            if let Some(o) = p.as_object() {
                if let Some(v) = o.get("votantes") {
                    c["second"]["votantes"] = v.clone();
                }
                if let Some(tot) = o.get("totals").and_then(Value::as_object) {
                    for (cat, v) in tot {
                        c["second"]["totals"][cat] = v.clone();
                    }
                }
            }
        }
        "computeMismatches" => c["mismatches"] = compute_mismatches(c, t),
        "markDoubleEntryMatched" => c["doubleEntry"] = json!("matched"),
        "markDoubleEntryPending" => c["doubleEntry"] = json!("pending"),
        _ => return false,
    }
    true
}

// ---------------------------------------------------------------- structure
fn node_at<'a>(flow: &'a Value, parts: &[&str]) -> Option<&'a Value> {
    let mut node = flow;
    for p in parts {
        node = node.get("states")?.get(*p)?;
    }
    Some(node)
}

/// Resolves a target to a leaf path, descending through `initial`.
fn enter_target(flow: &Value, target: &str) -> Result<String, String> {
    let mut parts: Vec<String> = target.split('.').map(str::to_string).collect();
    let refs: Vec<&str> = parts.iter().map(String::as_str).collect();
    let mut node = node_at(flow, &refs).ok_or_else(|| format!("unknown state \"{target}\""))?;
    while let Some(states) = node.get("states").and_then(Value::as_object) {
        let initial = node
            .get("initial")
            .and_then(Value::as_str)
            .filter(|i| states.contains_key(*i))
            .ok_or_else(|| format!("compound state \"{}\" has no valid initial", parts.join(".")))?;
        parts.push(initial.to_string());
        node = &states[initial];
    }
    Ok(parts.join("."))
}

fn candidates(handlers: &Value) -> Vec<&Value> {
    match handlers.as_array() {
        Some(a) => a.iter().collect(),
        None => vec![handlers],
    }
}

fn str_list(v: Option<&Value>) -> Vec<String> {
    v.and_then(Value::as_array)
        .map(|a| a.iter().filter_map(Value::as_str).map(str::to_string).collect())
        .unwrap_or_default()
}

const KNOWN_ACTIONS: [&str; 15] = [
    "setPresentation", "setDocumentType", "setMesa", "appendPages", "removePage", "useSample", "setValues",
    "invalidateDoubleEntry", "setJustification", "lock", "clearSecond", "setSecondValues", "computeMismatches",
    "markDoubleEntryMatched", "markDoubleEntryPending",
];

/// Static checks: every target, guard, action and effect name must exist.
pub fn check_flow(flow: &Value, template: &FormTemplate) -> Vec<String> {
    let mut problems = Vec::new();
    let effects: Option<Vec<String>> = flow.get("effects").and_then(Value::as_object).map(|m| m.keys().cloned().collect());
    fn walk(node: &Value, path: &str, flow: &Value, t: &FormTemplate, effects: &Option<Vec<String>>, out: &mut Vec<String>) {
        if let Some(on) = node.get("on").and_then(Value::as_object) {
            for (event, handlers) in on {
                for tr in candidates(handlers) {
                    let at = format!("{}.on.{event}", if path.is_empty() { "(root)" } else { path });
                    if let Some(target) = tr.get("target").and_then(Value::as_str) {
                        if let Err(e) = enter_target(flow, target) {
                            out.push(format!("{at}: {e}"));
                        }
                    }
                    for g in str_list(tr.get("guard")) {
                        let name = g.trim_start_matches('!');
                        if guard(name, &json!({}), &Value::Null, flow, t).is_none() {
                            out.push(format!("{at}: unknown guard \"{g}\""));
                        }
                    }
                    let actions = str_list(tr.get("actions"));
                    for a in &actions {
                        if !KNOWN_ACTIONS.contains(&a.as_str()) {
                            out.push(format!("{at}: unknown action \"{a}\""));
                        }
                    }
                    let effs = str_list(tr.get("effects"));
                    if let Some(known) = effects {
                        for e in &effs {
                            if !known.contains(e) {
                                out.push(format!("{at}: unknown effect \"{e}\""));
                            }
                        }
                    }
                    if tr.get("target").is_none() && actions.is_empty() && effs.is_empty() {
                        out.push(format!("{at}: transition does nothing"));
                    }
                }
            }
        }
        if let Some(states) = node.get("states").and_then(Value::as_object) {
            for (id, child) in states {
                let p = if path.is_empty() { id.clone() } else { format!("{path}.{id}") };
                if child.get("states").is_some() && child.get("initial").is_none() {
                    out.push(format!("{p}: compound state without initial"));
                }
                walk(child, &p, flow, t, effects, out);
            }
        }
    }
    match flow.get("initial").and_then(Value::as_str) {
        Some(initial) if flow.get("states").is_some() => {
            if let Err(e) = enter_target(flow, initial) {
                problems.push(format!("initial: {e}"));
            }
            walk(flow, "", flow, template, &effects, &mut problems);
        }
        _ => problems.push("flow needs states and initial".into()),
    }
    problems
}

impl FlowMachine {
    /// `presentation` overrides the flow's initial context; `state`/`context` restore a snapshot.
    pub fn new(
        flow: Value,
        template: FormTemplate,
        presentation: Option<&str>,
        state: Option<&str>,
        context: Option<Value>,
    ) -> Result<Self, FlowError> {
        let problems = check_flow(&flow, &template);
        if !problems.is_empty() {
            return Err(FlowError(problems));
        }
        let initial = state.map(str::to_string).unwrap_or_else(|| flow["initial"].as_str().unwrap_or_default().to_string());
        let state = enter_target(&flow, &initial).map_err(|e| FlowError(vec![e]))?;
        let mut context = context.unwrap_or_else(|| flow.get("context").cloned().unwrap_or(json!({})));
        if let Some(p) = presentation {
            context["presentation"] = json!(p);
        }
        Ok(Self { flow, template, state, context })
    }

    pub fn from_json(flow_json: &str, template: FormTemplate, presentation: Option<&str>) -> Result<Self, FlowError> {
        let flow: Value = serde_json::from_str(flow_json).map_err(|e| FlowError(vec![e.to_string()]))?;
        Self::new(flow, template, presentation, None, None)
    }

    pub fn state(&self) -> &str {
        &self.state
    }
    pub fn context(&self) -> &Value {
        &self.context
    }
    pub fn template(&self) -> &FormTemplate {
        &self.template
    }

    pub fn screen(&self) -> Option<String> {
        let parts: Vec<&str> = self.state.split('.').collect();
        (1..=parts.len())
            .rev()
            .find_map(|d| node_at(&self.flow, &parts[..d]).and_then(|n| n.get("screen")).and_then(Value::as_str))
            .map(str::to_string)
    }

    pub fn issues(&self) -> Vec<ValidationIssue> {
        validate_context(&self.context, &self.template)
    }

    fn guards_pass(&self, list: &[String], payload: &Value) -> bool {
        list.iter().all(|entry| {
            let (negate, name) = match entry.strip_prefix('!') {
                Some(n) => (true, n),
                None => (false, entry.as_str()),
            };
            let result = guard(name, &self.context, payload, &self.flow, &self.template).unwrap_or(false);
            result != negate
        })
    }

    /// Looks for a handler from the leaf to the root; the first candidate whose guards
    /// pass wins. Ignored events change nothing.
    pub fn send(&mut self, event: &str, payload: &Value) -> SendResult {
        let parts: Vec<String> = self.state.split('.').map(str::to_string).collect();
        for depth in (0..=parts.len()).rev() {
            let refs: Vec<&str> = parts[..depth].iter().map(String::as_str).collect();
            let Some(node) = node_at(&self.flow, &refs) else { continue };
            let Some(handlers) = node.get("on").and_then(|o| o.get(event)) else { continue };
            for tr in candidates(handlers) {
                if !self.guards_pass(&str_list(tr.get("guard")), payload) {
                    continue;
                }
                let mut next = self.context.clone();
                for a in str_list(tr.get("actions")) {
                    action(&a, &mut next, payload, &self.template);
                }
                if let Some(target) = tr.get("target").and_then(Value::as_str) {
                    self.state = enter_target(&self.flow, target).expect("targets checked at creation");
                }
                self.context = next;
                return SendResult {
                    state: self.state.clone(),
                    screen: self.screen(),
                    context: self.context.clone(),
                    effects: str_list(tr.get("effects")),
                    ignored: false,
                };
            }
        }
        SendResult { state: self.state.clone(), screen: self.screen(), context: self.context.clone(), effects: vec![], ignored: true }
    }

    /// Events reachable from the current leaf, with whether they would pass now (no payload).
    pub fn available_events(&self) -> Vec<AvailableEvent> {
        let parts: Vec<&str> = self.state.split('.').collect();
        let mut out: Vec<AvailableEvent> = Vec::new();
        for depth in (0..=parts.len()).rev() {
            let Some(on) = node_at(&self.flow, &parts[..depth]).and_then(|n| n.get("on")).and_then(Value::as_object) else {
                continue;
            };
            for (event, handlers) in on {
                let cands = candidates(handlers);
                let needs_payload = cands.iter().any(|t| str_list(t.get("guard")).iter().any(|g| g.trim_start_matches('!').starts_with("payload")));
                let enabled = cands.iter().any(|t| self.guards_pass(&str_list(t.get("guard")), &Value::Null));
                match out.iter_mut().find(|e| &e.event == event) {
                    Some(e) => e.enabled |= enabled,
                    None => out.push(AvailableEvent { event: event.clone(), enabled, needs_payload }),
                }
            }
        }
        out
    }
}
