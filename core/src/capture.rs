//! Capture package as defined by contracts/schemas/capture.schema.json.
//! Port of TelegramaCore/Capture.swift: evidence fields change only through methods that
//! refuse changes once the capture is confirmed.
use std::collections::BTreeMap;

use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};

use crate::template::{DocumentType, FormTemplate, Severity};
use crate::validation::{validate, ValidationInput, ValidationIssue};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ValueOrigin {
    #[serde(rename = "manual")]
    Manual,
    #[serde(rename = "ocr-accepted")]
    OcrAccepted,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CellValue {
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub value: Option<i64>,
    pub origin: ValueOrigin,
}

#[derive(Debug, Clone, PartialEq, Eq, Default, Serialize, Deserialize)]
pub struct Mesa {
    #[serde(default)]
    pub distrito: String,
    #[serde(default)]
    pub seccion: String,
    #[serde(default)]
    pub circuito: String,
    #[serde(default)]
    pub mesa: String,
}

impl Mesa {
    pub fn get(&self, field: &str) -> Option<&str> {
        match field {
            "distrito" => Some(&self.distrito),
            "seccion" => Some(&self.seccion),
            "circuito" => Some(&self.circuito),
            "mesa" => Some(&self.mesa),
            _ => None,
        }
    }

    pub fn set(&mut self, field: &str, value: String) {
        match field {
            "distrito" => self.distrito = value,
            "seccion" => self.seccion = value,
            "circuito" => self.circuito = value,
            "mesa" => self.mesa = value,
            _ => {}
        }
    }
}

/// `sample` marks bundled demo images (F-17), never real evidence.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum PageSource {
    Scanner,
    Photos,
    Sample,
}

/// One immutable page image, referenced by file name and SHA-256 of its bytes.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Page {
    pub file: String,
    pub sha256: String,
    pub captured_at: String,
    pub source: PageSource,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum CaptureStatus {
    Draft,
    Confirmed,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct AppInfo {
    pub platform: String,
    pub version: String,
}

#[derive(Debug, Clone, PartialEq, thiserror::Error)]
pub enum CaptureError {
    #[error("la captura ya está confirmada")]
    AlreadyConfirmed,
    #[error("la captura tiene errores")]
    HasErrors(Vec<ValidationIssue>),
    #[error("hay avisos: escribí una justificación")]
    WarningsNeedJustification,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Capture {
    pub schema_version: u32,
    pub id: String,
    pub template_id: String,
    pub template_version: u32,
    document_type: DocumentType,
    mesa: Mesa,
    pages: Vec<Page>,
    header: BTreeMap<String, CellValue>,
    cells: BTreeMap<String, BTreeMap<String, CellValue>>,
    status: CaptureStatus,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    warning_justification: Option<String>,
    pub created_at: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    confirmed_at: Option<String>,
    pub app: AppInfo,
}

impl Capture {
    pub fn new(id: String, template: &FormTemplate, document_type: DocumentType, created_at: String, app: AppInfo) -> Self {
        Self {
            schema_version: 1,
            id,
            template_id: template.id.clone(),
            template_version: template.version,
            document_type,
            mesa: Mesa::default(),
            pages: Vec::new(),
            header: BTreeMap::new(),
            cells: BTreeMap::new(),
            status: CaptureStatus::Draft,
            warning_justification: None,
            created_at,
            confirmed_at: None,
            app,
        }
    }

    pub fn from_json(json: &str) -> Result<Self, serde_json::Error> {
        serde_json::from_str(json)
    }

    /// Pretty, sorted-key JSON like the Swift encoder, so hashes of the package are stable.
    pub fn to_json(&self) -> String {
        let value = serde_json::to_value(self).expect("capture serializes");
        serde_json::to_string_pretty(&value).expect("json value serializes")
    }

    pub fn is_locked(&self) -> bool {
        self.status == CaptureStatus::Confirmed
    }
    pub fn status(&self) -> CaptureStatus {
        self.status
    }
    pub fn document_type(&self) -> DocumentType {
        self.document_type
    }
    pub fn mesa(&self) -> &Mesa {
        &self.mesa
    }
    pub fn pages(&self) -> &[Page] {
        &self.pages
    }
    pub fn warning_justification(&self) -> Option<&str> {
        self.warning_justification.as_deref()
    }
    pub fn confirmed_at(&self) -> Option<&str> {
        self.confirmed_at.as_deref()
    }

    pub fn header_value(&self, field: &str) -> Option<i64> {
        self.header.get(field).and_then(|c| c.value)
    }
    pub fn cell_value(&self, category: &str, row: &str) -> Option<i64> {
        self.cells.get(category).and_then(|c| c.get(row)).and_then(|c| c.value)
    }
    pub fn header_origin(&self, field: &str) -> Option<ValueOrigin> {
        self.header.get(field).map(|c| c.origin)
    }
    pub fn cell_origin(&self, category: &str, row: &str) -> Option<ValueOrigin> {
        self.cells.get(category).and_then(|c| c.get(row)).map(|c| c.origin)
    }

    fn unlocked(&self) -> Result<(), CaptureError> {
        if self.is_locked() {
            Err(CaptureError::AlreadyConfirmed)
        } else {
            Ok(())
        }
    }

    pub fn set_document_type(&mut self, t: DocumentType) -> Result<(), CaptureError> {
        self.unlocked()?;
        self.document_type = t;
        Ok(())
    }

    pub fn set_mesa_field(&mut self, field: &str, value: String) -> Result<(), CaptureError> {
        self.unlocked()?;
        self.mesa.set(field, value);
        Ok(())
    }

    pub fn set_mesa(&mut self, mesa: Mesa) -> Result<(), CaptureError> {
        self.unlocked()?;
        self.mesa = mesa;
        Ok(())
    }

    pub fn append_page(&mut self, page: Page) -> Result<(), CaptureError> {
        self.unlocked()?;
        self.pages.push(page);
        Ok(())
    }

    pub fn set_header(&mut self, field: &str, value: Option<i64>, origin: ValueOrigin) -> Result<(), CaptureError> {
        self.unlocked()?;
        self.header.insert(field.into(), CellValue { value, origin });
        Ok(())
    }

    pub fn set_cell(&mut self, category: &str, row: &str, value: Option<i64>, origin: ValueOrigin) -> Result<(), CaptureError> {
        self.unlocked()?;
        self.cells.entry(category.into()).or_default().insert(row.into(), CellValue { value, origin });
        Ok(())
    }

    pub fn validation_input(&self) -> ValidationInput {
        let mut mesa = BTreeMap::new();
        for f in ["distrito", "seccion", "circuito", "mesa"] {
            mesa.insert(f.to_string(), self.mesa.get(f).map(str::to_string));
        }
        ValidationInput {
            mesa,
            header: self.header.iter().map(|(k, v)| (k.clone(), v.value)).collect(),
            cells: self
                .cells
                .iter()
                .map(|(c, rows)| (c.clone(), rows.iter().map(|(r, v)| (r.clone(), v.value)).collect()))
                .collect(),
        }
    }

    pub fn validate(&self, template: &FormTemplate) -> Vec<ValidationIssue> {
        validate(&self.validation_input(), template)
    }

    /// Locks the capture. Errors block; warnings require a written justification.
    pub fn confirm(&mut self, template: &FormTemplate, justification: Option<&str>, at: String) -> Result<(), CaptureError> {
        self.unlocked()?;
        let issues = self.validate(template);
        let errors: Vec<_> = issues.iter().filter(|i| i.severity == Severity::Error).cloned().collect();
        if !errors.is_empty() {
            return Err(CaptureError::HasErrors(errors));
        }
        if issues.iter().any(|i| i.severity == Severity::Warning) {
            let note = justification.map(str::trim).unwrap_or("");
            if note.is_empty() {
                return Err(CaptureError::WarningsNeedJustification);
            }
            self.warning_justification = Some(note.to_string());
        }
        self.status = CaptureStatus::Confirmed;
        self.confirmed_at = Some(at);
        Ok(())
    }
}

/// Lowercase hex SHA-256 of the exact stored bytes.
pub fn sha256_hex(data: &[u8]) -> String {
    Sha256::digest(data).iter().map(|b| format!("{b:02x}")).collect()
}

/// ISO-8601 UTC timestamp with seconds precision, like Swift's `.iso8601` strategy.
pub fn iso8601_now() -> String {
    let secs = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_secs() as i64)
        .unwrap_or(0);
    iso8601_from_unix(secs)
}

pub fn iso8601_from_unix(secs: i64) -> String {
    let days = secs.div_euclid(86_400);
    let rem = secs.rem_euclid(86_400);
    // Civil-from-days (Howard Hinnant's algorithm).
    let z = days + 719_468;
    let era = z.div_euclid(146_097);
    let doe = z - era * 146_097;
    let yoe = (doe - doe / 1460 + doe / 36_524 - doe / 146_096) / 365;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = doy - (153 * mp + 2) / 5 + 1;
    let m = if mp < 10 { mp + 3 } else { mp - 9 };
    let y = yoe + era * 400 + i64::from(m <= 2);
    format!("{y:04}-{m:02}-{d:02}T{:02}:{:02}:{:02}Z", rem / 3600, rem % 3600 / 60, rem % 60)
}
