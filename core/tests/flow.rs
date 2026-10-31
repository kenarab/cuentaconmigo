//! contracts/vectors/capture-flow.json against the Rust interpreter.
use std::path::PathBuf;

use cc_core::flow::FlowMachine;
use cc_core::FormTemplate;
use serde_json::Value;

fn read(path: &str) -> String {
    let repo = PathBuf::from(env!("CARGO_MANIFEST_DIR")).parent().unwrap().to_path_buf();
    std::fs::read_to_string(repo.join(path)).unwrap()
}

/// Every key in `expected` must match `actual`; nested objects recurse, arrays exactly.
fn partial_match(expected: &Value, actual: &Value) -> bool {
    match (expected, actual) {
        (Value::Object(e), Value::Object(a)) => e.iter().all(|(k, v)| partial_match(v, a.get(k).unwrap_or(&Value::Null))),
        (Value::Object(_), _) => false,
        _ => expected == actual,
    }
}

fn expand(events: &[Value], preludes: &Value, out: &mut Vec<Value>) {
    for e in events {
        if let Some(name) = e.get("prelude").and_then(Value::as_str) {
            expand(preludes[name].as_array().expect("known prelude"), preludes, out);
        } else {
            out.push(e.clone());
        }
    }
}

#[test]
fn capture_flow_vectors() {
    let data: Value = serde_json::from_str(&read("contracts/vectors/capture-flow.json")).unwrap();
    let flow_json = read(&format!("contracts/flows/{}.flow.json", data["flow"].as_str().unwrap()));
    let template = FormTemplate::from_json(&read(&format!("contracts/templates/{}.json", data["template"].as_str().unwrap()))).unwrap();
    let preludes = &data["preludes"];
    let cases = data["cases"].as_array().unwrap();
    let mut failures = Vec::new();
    for c in cases {
        let name = c["name"].as_str().unwrap();
        let mut m = FlowMachine::from_json(&flow_json, template.clone(), c.get("presentation").and_then(Value::as_str)).unwrap();
        let mut events = Vec::new();
        if let Some(p) = c.get("prelude") {
            expand(&[serde_json::json!({ "prelude": p })], preludes, &mut events);
        }
        expand(c["events"].as_array().unwrap(), preludes, &mut events);
        let mut last = None;
        for e in &events {
            let (event, payload) = match e {
                Value::String(s) => (s.clone(), Value::Null),
                other => (other["type"].as_str().unwrap().to_string(), other.get("payload").cloned().unwrap_or(Value::Null)),
            };
            last = Some(m.send(&event, &payload));
        }
        let mut problems = Vec::new();
        if m.state() != c["expectState"].as_str().unwrap() {
            problems.push(format!("state {} != {}", m.state(), c["expectState"]));
        }
        let effects: Vec<String> = last.as_ref().map(|r| r.effects.clone()).unwrap_or_default();
        let want: Vec<String> = c["expectEffects"].as_array().unwrap().iter().map(|v| v.as_str().unwrap().to_string()).collect();
        if effects != want {
            problems.push(format!("effects {effects:?} != {want:?}"));
        }
        if let Some(ig) = c.get("expectIgnored").and_then(Value::as_bool) {
            if last.as_ref().map(|r| r.ignored) != Some(ig) {
                problems.push(format!("ignored != {ig}"));
            }
        }
        if let Some(ctx) = c.get("expectContext") {
            if !partial_match(ctx, m.context()) {
                problems.push(format!("context mismatch: want {ctx} got {}", m.context()));
            }
        }
        if !problems.is_empty() {
            failures.push(format!("{name}: {}", problems.join("; ")));
        }
    }
    assert!(failures.is_empty(), "{}/{} cases failed:\n{}", failures.len(), cases.len(), failures.join("\n"));
    println!("capture-flow: {}/{} pass", cases.len(), cases.len());
}
