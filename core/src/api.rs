//! Public API for every platform, exported with UniFFI (Swift and Kotlin bindings are
//! generated, never hand-written). Platforms only draw screens and reach hardware:
//! camera/scanner, keychain (through `SecretStore`), on-device OCR and sharing.
use std::sync::{Arc, Mutex, OnceLock};

use serde_json::Value;

use crate::capture::{AppInfo, Capture, PageSource, ValueOrigin};
use crate::flow::FlowMachine;
use crate::nomina::{Nomina, Place};
use crate::server::{Readings, ServerClient};
use crate::store::Store;
use crate::template::{DocumentType, FormTemplate, Severity};

const TEMPLATE_2023: &str = include_str!("../../contracts/templates/generales-2023.json");
const TEMPLATE_2015: &str = include_str!("../../contracts/templates/balotaje-2015.json");
const CAPTURE_FLOW: &str = include_str!("../../contracts/flows/capture.flow.json");
const NOMINA_2025: &str = include_str!("../../data/establecimientos/nomina-2025.json");
const TOKEN_KEY: &str = "scrutinyDeviceToken";
const URL_KEY: &str = "scrutinyServerURL";

/// Flat error: platforms get the Spanish text as the exception message.
#[derive(Debug, uniffi::Error, thiserror::Error)]
#[uniffi(flat_error)]
pub enum CoreError {
    #[error("{0}")]
    Failed(String),
}

impl CoreError {
    fn msg(m: impl ToString) -> Self {
        CoreError::Failed(m.to_string())
    }
}

/// Platform keychain (iOS Keychain, Android Keystore-backed preferences).
#[uniffi::export(with_foreign)]
pub trait SecretStore: Send + Sync {
    fn get(&self, key: String) -> Option<String>;
    fn set(&self, key: String, value: Option<String>);
}

#[derive(Debug, Clone, uniffi::Record)]
pub struct MesaRecord {
    pub distrito: String,
    pub seccion: String,
    pub circuito: String,
    pub mesa: String,
}

#[derive(Debug, Clone, uniffi::Record)]
pub struct OptionRecord {
    pub id: String,
    pub label: String,
}

#[derive(Debug, Clone, uniffi::Record)]
pub struct FieldRecord {
    pub id: String,
    pub label: String,
    pub required: bool,
}

#[derive(Debug, Clone, uniffi::Record)]
pub struct TemplateRecord {
    pub id: String,
    pub title: String,
    pub fictitious: bool,
    pub document_types: Vec<OptionRecord>,
    pub mesa_fields: Vec<FieldRecord>,
    pub header_fields: Vec<FieldRecord>,
    pub categories: Vec<OptionRecord>,
    /// Rows shared by every category (agrupaciones and special votes).
    pub rows: Vec<OptionRecord>,
}

#[derive(Debug, Clone, uniffi::Record)]
pub struct CaptureSummary {
    pub id: String,
    pub template_id: String,
    pub document_type: String,
    pub document_label: String,
    pub mesa: MesaRecord,
    pub locked: bool,
    pub sent: bool,
    pub page_count: u32,
    pub created_at: String,
}

#[derive(Debug, Clone, uniffi::Record)]
pub struct PageRecord {
    pub file: String,
    pub sha256: String,
    pub path: String,
    pub source: String,
    pub captured_at: String,
}

/// A value by path: `header.votantes` or `cells.presidente.agrupacion-134`.
#[derive(Debug, Clone, uniffi::Record)]
pub struct ValueRecord {
    pub path: String,
    pub value: Option<i64>,
    pub from_ocr: bool,
}

#[derive(Debug, Clone, uniffi::Record)]
pub struct IssueRecord {
    pub code: String,
    pub is_error: bool,
    pub path: String,
    /// Ready-to-show Spanish text (rioplatense).
    pub message: String,
}

#[derive(Debug, Clone, uniffi::Record)]
pub struct CaptureDetail {
    pub summary: CaptureSummary,
    pub pages: Vec<PageRecord>,
    pub values: Vec<ValueRecord>,
    pub issues: Vec<IssueRecord>,
    pub justification: Option<String>,
    pub confirmed_at: Option<String>,
    pub receipts: Vec<String>,
}

#[derive(Debug, Clone, uniffi::Record)]
pub struct TableRecord {
    pub mesa: i64,
    pub circuito: String,
}

#[derive(Debug, Clone, uniffi::Record)]
pub struct PlaceRecord {
    pub codigo: String,
    pub nombre: String,
    pub direccion: String,
    pub localidad: String,
    pub tables: Vec<TableRecord>,
}

/// status: "read" | "empty" | "unreadable"; text is "?" when unreadable (show an empty box).
#[derive(Debug, Clone, uniffi::Record)]
pub struct ReadingRecord {
    pub path: String,
    pub value: Option<i64>,
    pub confidence: f64,
    pub status: String,
    pub text: String,
}

#[derive(Debug, Clone, uniffi::Record)]
pub struct ReadingsRecord {
    pub aligned: bool,
    pub fields: Vec<ReadingRecord>,
    /// Cells the person must fill: unreadable plus not located.
    pub pending: Vec<String>,
}

#[derive(Debug, Clone, uniffi::Record)]
pub struct FlowStep {
    pub state: String,
    pub screen: Option<String>,
    pub effects: Vec<String>,
    pub ignored: bool,
    /// Full flow context as JSON (the presentation renders from it).
    pub context_json: String,
}

#[derive(Debug, Clone, uniffi::Record)]
pub struct FlowEvent {
    pub event: String,
    pub enabled: bool,
    pub needs_payload: bool,
}

fn place_record(p: &Place) -> PlaceRecord {
    PlaceRecord {
        codigo: p.codigo.clone(),
        nombre: p.nombre.clone(),
        direccion: p.direccion.clone(),
        localidad: p.localidad.clone(),
        tables: p.tables().into_iter().map(|(mesa, circuito)| TableRecord { mesa, circuito }).collect(),
    }
}

fn doc_type(s: &str) -> Result<DocumentType, CoreError> {
    serde_json::from_value(Value::String(s.into())).map_err(|_| CoreError::msg(format!("tipo de documento desconocido: {s}")))
}

fn doc_type_id(t: DocumentType) -> String {
    serde_json::to_value(t).ok().and_then(|v| v.as_str().map(str::to_string)).unwrap_or_default()
}

fn issue_message(code: &str, path: &str, t: &FormTemplate) -> String {
    let label = |p: &str| -> String {
        let parts: Vec<&str> = p.split('.').collect();
        match parts.as_slice() {
            ["mesa", f] => t.mesa_fields.iter().find(|x| x.id == *f).map(|x| x.label.clone()).unwrap_or(f.to_string()),
            ["header", f] => t.header_fields.iter().find(|x| x.id == *f).map(|x| x.label.clone()).unwrap_or(f.to_string()),
            ["cells", c] => t.categories.iter().find(|x| x.id == *c).map(|x| x.label.clone()).unwrap_or(c.to_string()),
            ["cells", c, r] => format!(
                "{} · {}",
                t.categories.iter().find(|x| x.id == *c).map(|x| x.label.as_str()).unwrap_or(c),
                t.rows.iter().find(|x| x.id == *r).map(|x| x.label.as_str()).unwrap_or(r)
            ),
            _ => p.to_string(),
        }
    };
    match code {
        "missing_mesa" => format!("Falta {}.", label(path)),
        "missing_value" => format!("Falta el valor de {}.", label(path)),
        "negative_value" => format!("{}: no puede ser negativo.", label(path)),
        "votantes_exceed_electores" => "Hay más votantes que electores habilitados.".into(),
        "category_total_mismatch" => format!("{}: la suma no coincide con el total de votantes.", label(path)),
        other => other.into(),
    }
}

#[derive(uniffi::Object)]
pub struct Core {
    store: Store,
    templates: Vec<FormTemplate>,
    nomina: OnceLock<Nomina>,
    secrets: Arc<dyn SecretStore>,
    app: AppInfo,
    default_url: Option<String>,
    app_code: Option<String>,
    lock: Mutex<()>,
}

impl Core {
    fn template_for(&self, id: &str) -> &FormTemplate {
        self.templates.iter().find(|t| t.id == id).unwrap_or(&self.templates[0])
    }
    fn nomina(&self) -> &Nomina {
        self.nomina.get_or_init(|| Nomina::from_json(NOMINA_2025).expect("embedded polling-place list"))
    }
    fn load(&self, id: &str) -> Result<Capture, CoreError> {
        self.store.load(id).map_err(CoreError::msg)
    }
    fn client(&self) -> Option<ServerClient> {
        self.server_url().map(|u| ServerClient::new(&u, self.secrets.get(TOKEN_KEY.into())))
    }
    fn summary(&self, c: &Capture) -> CaptureSummary {
        let m = c.mesa();
        CaptureSummary {
            id: c.id.clone(),
            template_id: c.template_id.clone(),
            document_type: doc_type_id(c.document_type()),
            document_label: c.document_type().label().into(),
            mesa: MesaRecord { distrito: m.distrito.clone(), seccion: m.seccion.clone(), circuito: m.circuito.clone(), mesa: m.mesa.clone() },
            locked: c.is_locked(),
            sent: self.store.was_sent(&c.id),
            page_count: c.pages().len() as u32,
            created_at: c.created_at.clone(),
        }
    }
}

#[uniffi::export]
impl Core {
    /// `data_dir`: app-private folder. `default_server_url` and `app_enroll_code` come
    /// from the build (sdd/specs/server-location/SPEC.md).
    #[uniffi::constructor]
    pub fn new(
        data_dir: String,
        platform: String,
        app_version: String,
        default_server_url: Option<String>,
        app_enroll_code: Option<String>,
        secrets: Arc<dyn SecretStore>,
    ) -> Result<Arc<Self>, CoreError> {
        let templates = [TEMPLATE_2023, TEMPLATE_2015]
            .iter()
            .map(|t| FormTemplate::from_json(t))
            .collect::<Result<Vec<_>, _>>()
            .map_err(CoreError::msg)?;
        Ok(Arc::new(Self {
            store: Store::open(data_dir).map_err(CoreError::msg)?,
            templates,
            nomina: OnceLock::new(),
            secrets,
            app: AppInfo { platform, version: app_version },
            default_url: default_server_url.filter(|u| !u.is_empty()),
            app_code: app_enroll_code.filter(|c| !c.is_empty()),
            lock: Mutex::new(()),
        }))
    }

    // ------------------------------------------------------------ templates
    pub fn template(&self, template_id: Option<String>) -> TemplateRecord {
        let t = template_id.as_deref().map(|id| self.template_for(id)).unwrap_or(&self.templates[0]);
        let field = |f: &crate::template::Field| FieldRecord { id: f.id.clone(), label: f.label.clone(), required: f.is_required() };
        TemplateRecord {
            id: t.id.clone(),
            title: t.title.clone(),
            fictitious: t.fictitious,
            document_types: t.document_types.iter().map(|d| OptionRecord { id: doc_type_id(*d), label: d.label().into() }).collect(),
            mesa_fields: t.mesa_fields.iter().map(field).collect(),
            header_fields: t.header_fields.iter().map(field).collect(),
            categories: t.categories.iter().map(|c| OptionRecord { id: c.id.clone(), label: c.label.clone() }).collect(),
            rows: t.rows.iter().map(|r| OptionRecord { id: r.id.clone(), label: r.label.clone() }).collect(),
        }
    }

    pub fn template_ids(&self) -> Vec<String> {
        self.templates.iter().map(|t| t.id.clone()).collect()
    }

    // -------------------------------------------------------------- captures
    pub fn list_captures(&self) -> Vec<CaptureSummary> {
        self.store.list().iter().map(|c| self.summary(c)).collect()
    }

    pub fn new_capture(&self, document_type: String, template_id: Option<String>) -> Result<String, CoreError> {
        let _g = self.lock.lock().unwrap();
        let t = template_id.as_deref().map(|id| self.template_for(id)).unwrap_or(&self.templates[0]);
        let c = self.store.create(t, doc_type(&document_type)?, self.app.clone()).map_err(CoreError::msg)?;
        Ok(c.id)
    }

    pub fn capture(&self, id: String) -> Result<CaptureDetail, CoreError> {
        let c = self.load(&id)?;
        let t = self.template_for(&c.template_id);
        let mut values = Vec::new();
        for f in &t.header_fields {
            values.push(ValueRecord {
                path: format!("header.{}", f.id),
                value: c.header_value(&f.id),
                from_ocr: c.header_origin(&f.id) == Some(ValueOrigin::OcrAccepted),
            });
        }
        for cat in &t.categories {
            for row in &t.rows {
                values.push(ValueRecord {
                    path: format!("cells.{}.{}", cat.id, row.id),
                    value: c.cell_value(&cat.id, &row.id),
                    from_ocr: c.cell_origin(&cat.id, &row.id) == Some(ValueOrigin::OcrAccepted),
                });
            }
        }
        let issues = c
            .validate(t)
            .into_iter()
            .map(|i| IssueRecord {
                message: issue_message(&i.code, &i.path, t),
                is_error: i.severity == Severity::Error,
                code: i.code,
                path: i.path,
            })
            .collect();
        Ok(CaptureDetail {
            summary: self.summary(&c),
            pages: c
                .pages()
                .iter()
                .map(|p| PageRecord {
                    file: p.file.clone(),
                    sha256: p.sha256.clone(),
                    path: self.store.page_path(&c.id, p).to_string_lossy().into(),
                    source: serde_json::to_value(p.source).ok().and_then(|v| v.as_str().map(str::to_string)).unwrap_or_default(),
                    captured_at: p.captured_at.clone(),
                })
                .collect(),
            values,
            issues,
            justification: c.warning_justification().map(str::to_string),
            confirmed_at: c.confirmed_at().map(str::to_string),
            receipts: self.store.receipts(&c.id),
        })
    }

    pub fn set_document_type(&self, id: String, document_type: String) -> Result<(), CoreError> {
        let _g = self.lock.lock().unwrap();
        let mut c = self.load(&id)?;
        c.set_document_type(doc_type(&document_type)?).map_err(CoreError::msg)?;
        self.store.save(&c).map_err(CoreError::msg)
    }

    pub fn set_mesa(&self, id: String, mesa: MesaRecord) -> Result<(), CoreError> {
        let _g = self.lock.lock().unwrap();
        let mut c = self.load(&id)?;
        c.set_mesa(crate::capture::Mesa { distrito: mesa.distrito, seccion: mesa.seccion, circuito: mesa.circuito, mesa: mesa.mesa })
            .map_err(CoreError::msg)?;
        self.store.save(&c).map_err(CoreError::msg)
    }

    /// `path`: `header.<field>` or `cells.<category>.<row>`. `None` clears the value.
    pub fn set_value(&self, id: String, path: String, value: Option<i64>, from_ocr: bool) -> Result<(), CoreError> {
        let _g = self.lock.lock().unwrap();
        let mut c = self.load(&id)?;
        let origin = if from_ocr { ValueOrigin::OcrAccepted } else { ValueOrigin::Manual };
        let parts: Vec<&str> = path.split('.').collect();
        match parts.as_slice() {
            ["header", f] => c.set_header(f, value, origin),
            ["cells", cat, row] => c.set_cell(cat, row, value, origin),
            _ => return Err(CoreError::msg(format!("ruta inválida: {path}"))),
        }
        .map_err(CoreError::msg)?;
        self.store.save(&c).map_err(CoreError::msg)
    }

    /// Stores an image once (never overwritten) and returns its page. `source`:
    /// "scanner", "photos" or "sample".
    pub fn add_page(&self, id: String, jpeg: Vec<u8>, source: String) -> Result<PageRecord, CoreError> {
        let _g = self.lock.lock().unwrap();
        let mut c = self.load(&id)?;
        let source = match source.as_str() {
            "scanner" => PageSource::Scanner,
            "sample" => PageSource::Sample,
            _ => PageSource::Photos,
        };
        let p = self.store.add_page(&mut c, &jpeg, source).map_err(CoreError::msg)?;
        Ok(PageRecord {
            path: self.store.page_path(&c.id, &p).to_string_lossy().into(),
            source: serde_json::to_value(p.source).ok().and_then(|v| v.as_str().map(str::to_string)).unwrap_or_default(),
            file: p.file,
            sha256: p.sha256,
            captured_at: p.captured_at,
        })
    }

    /// Locks the capture. Errors block; warnings need a written justification.
    pub fn confirm(&self, id: String, justification: Option<String>) -> Result<(), CoreError> {
        let _g = self.lock.lock().unwrap();
        let mut c = self.load(&id)?;
        // Same rule as the flow's `hasPages` guard: evidence needs at least one image.
        if c.pages().is_empty() {
            return Err(CoreError::msg("Agregá al menos una imagen del documento."));
        }
        let t = self.template_for(&c.template_id).clone();
        c.confirm(&t, justification.as_deref(), crate::capture::iso8601_now()).map_err(CoreError::msg)?;
        self.store.save(&c).map_err(CoreError::msg)
    }

    /// Drafts and unsent captures only; sent captures are kept as proof.
    pub fn delete_capture(&self, id: String) -> Result<(), CoreError> {
        let _g = self.lock.lock().unwrap();
        self.store.delete(&id).map_err(CoreError::msg)
    }

    pub fn export_paths(&self, id: String) -> Result<Vec<String>, CoreError> {
        let c = self.load(&id)?;
        Ok(self.store.export_paths(&c).iter().map(|p| p.to_string_lossy().into()).collect())
    }

    pub fn normalize_digits(&self, text: String) -> Option<i64> {
        crate::digits::normalize(&text)
    }

    // ---------------------------------------------------- polling places
    pub fn districts(&self) -> Vec<OptionRecord> {
        self.nomina().distritos.iter().map(|d| OptionRecord { id: d.id.clone(), label: d.nombre.clone() }).collect()
    }

    pub fn sections(&self, district: String) -> Vec<OptionRecord> {
        self.nomina()
            .district(&district)
            .map(|d| d.secciones.iter().map(|s| OptionRecord { id: s.id.clone(), label: s.nombre.clone() }).collect())
            .unwrap_or_default()
    }

    pub fn places(&self, district: String, section: String, query: String) -> Vec<PlaceRecord> {
        self.nomina().search(&district, &section, &query).into_iter().map(place_record).collect()
    }

    pub fn locate(&self, district: String, section: String, mesa: i64) -> Option<PlaceRecord> {
        self.nomina().locate(&district, &section, mesa).map(|(p, _)| place_record(p))
    }

    // ------------------------------------------------------------- server
    pub fn server_url(&self) -> Option<String> {
        self.secrets.get(URL_KEY.into()).or_else(|| self.default_url.clone())
    }

    pub fn is_connected(&self) -> bool {
        self.secrets.get(TOKEN_KEY.into()).is_some()
    }

    /// Enrolls with the given server and code (manual setup in Settings).
    pub fn connect(&self, url: String, code: String) -> Result<(), CoreError> {
        let token = ServerClient::new(&url, None).enroll(&code, &self.app.platform, &self.app.version).map_err(CoreError::msg)?;
        self.secrets.set(URL_KEY.into(), Some(url));
        self.secrets.set(TOKEN_KEY.into(), Some(token));
        Ok(())
    }

    /// Enrolls silently with the build's server and app code. Returns whether connected.
    pub fn connect_if_needed(&self) -> bool {
        if self.is_connected() {
            return true;
        }
        match (self.server_url(), self.app_code.clone()) {
            (Some(url), Some(code)) => self.connect(url, code).is_ok(),
            _ => false,
        }
    }

    pub fn disconnect(&self) {
        self.secrets.set(TOKEN_KEY.into(), None);
    }

    /// Sends the package and missing images; keeps the receipt. After this the capture
    /// can no longer be deleted.
    pub fn send_capture(&self, id: String) -> Result<String, CoreError> {
        if !self.connect_if_needed() {
            return Err(CoreError::msg("El teléfono no está conectado al servidor."));
        }
        let c = self.load(&id)?;
        let pages: Vec<(String, Vec<u8>)> = c
            .pages()
            .iter()
            .filter_map(|p| std::fs::read(self.store.page_path(&c.id, p)).ok().map(|b| (p.sha256.clone(), b)))
            .collect();
        let receipt = self.client().unwrap().upload(&c.to_json(), &pages).map_err(CoreError::msg)?;
        self.store.append_receipt(&c.id, &receipt).map_err(CoreError::msg)?;
        Ok(receipt)
    }

    /// Per-cell readings of one page (nothing stored on the server).
    pub fn read_cells(&self, id: String, page_index: u32, template_id: Option<String>) -> Result<ReadingsRecord, CoreError> {
        if !self.connect_if_needed() {
            return Err(CoreError::msg("El teléfono no está conectado al servidor."));
        }
        let c = self.load(&id)?;
        let page = c.pages().get(page_index as usize).ok_or_else(|| CoreError::msg("No hay esa página."))?;
        let jpeg = std::fs::read(self.store.page_path(&c.id, page)).map_err(CoreError::msg)?;
        let tid = template_id.unwrap_or_else(|| c.template_id.clone());
        let r: Readings = self.client().unwrap().readings(&tid, &jpeg).map_err(CoreError::msg)?;
        Ok(ReadingsRecord {
            aligned: r.alignment.get("ok").and_then(Value::as_bool).unwrap_or(false),
            fields: r
                .fields
                .iter()
                .map(|f| ReadingRecord {
                    path: f.reference.clone(),
                    value: f.value,
                    confidence: f.confidence,
                    status: f.status().to_string(),
                    text: f.text.clone().unwrap_or_else(|| if f.status() == "read" { f.value.map(|v| v.to_string()).unwrap_or_default() } else if f.status() == "empty" { String::new() } else { "?".into() }),
                })
                .collect(),
            pending: if r.pending.is_empty() { r.not_found.clone() } else { r.pending.clone() },
        })
    }

    /// Fills only empty fields with readings that were read ("?" cells stay empty for the
    /// person). Values are marked as OCR-accepted suggestions. Returns how many were filled.
    pub fn apply_readings(&self, id: String, readings: ReadingsRecord) -> Result<u32, CoreError> {
        let _g = self.lock.lock().unwrap();
        let mut c = self.load(&id)?;
        let t = self.template_for(&c.template_id).clone();
        let mut filled = 0;
        for f in readings.fields.iter().filter(|f| f.status == "read") {
            let Some(v) = f.value else { continue };
            let parts: Vec<&str> = f.path.split('.').collect();
            let applied = match parts.as_slice() {
                ["header", h] if t.header_fields.iter().any(|x| x.id == *h) && c.header_value(h).is_none() => {
                    c.set_header(h, Some(v), ValueOrigin::OcrAccepted).is_ok()
                }
                ["cells", cat, row]
                    if t.categories.iter().any(|x| x.id == *cat) && t.rows.iter().any(|x| x.id == *row) && c.cell_value(cat, row).is_none() =>
                {
                    c.set_cell(cat, row, Some(v), ValueOrigin::OcrAccepted).is_ok()
                }
                _ => false,
            };
            filled += u32::from(applied);
        }
        self.store.save(&c).map_err(CoreError::msg)?;
        Ok(filled)
    }

    /// OCR numbers detected by the server for a sent capture (empty until finished).
    pub fn ocr_numbers(&self, id: String) -> Result<Vec<i64>, CoreError> {
        let (finished, numbers) = self.client().ok_or_else(|| CoreError::msg("Sin servidor"))?.ocr(&id).map_err(CoreError::msg)?;
        Ok(if finished { numbers } else { vec![] })
    }

    // --------------------------------------------------------------- flow
    /// A capture flow session for presentation "f1", "f2" or "f3".
    pub fn flow(&self, presentation: String, template_id: Option<String>) -> Result<Arc<FlowSession>, CoreError> {
        let t = template_id.as_deref().map(|id| self.template_for(id)).unwrap_or(&self.templates[0]).clone();
        let m = FlowMachine::from_json(CAPTURE_FLOW, t, Some(&presentation)).map_err(CoreError::msg)?;
        Ok(Arc::new(FlowSession { machine: Mutex::new(m) }))
    }
}

#[derive(uniffi::Object)]
pub struct FlowSession {
    machine: Mutex<FlowMachine>,
}

#[uniffi::export]
impl FlowSession {
    /// `payload_json`: event payload as JSON text ("" or "null" for none).
    pub fn send(&self, event: String, payload_json: String) -> FlowStep {
        let payload: Value = if payload_json.trim().is_empty() { Value::Null } else { serde_json::from_str(&payload_json).unwrap_or(Value::Null) };
        let r = self.machine.lock().unwrap().send(&event, &payload);
        FlowStep { state: r.state, screen: r.screen, effects: r.effects, ignored: r.ignored, context_json: r.context.to_string() }
    }

    pub fn state(&self) -> String {
        self.machine.lock().unwrap().state().to_string()
    }

    pub fn screen(&self) -> Option<String> {
        self.machine.lock().unwrap().screen()
    }

    pub fn context_json(&self) -> String {
        self.machine.lock().unwrap().context().to_string()
    }

    pub fn available_events(&self) -> Vec<FlowEvent> {
        self.machine
            .lock()
            .unwrap()
            .available_events()
            .into_iter()
            .map(|e| FlowEvent { event: e.event, enabled: e.enabled, needs_payload: e.needs_payload })
            .collect()
    }
}
