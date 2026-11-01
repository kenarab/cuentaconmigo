//! Client for the scrutiny server (contracts/api/scrutiny-v1.openapi.json).
//! Port of ios/CuentaConmigo/Services/ScrutinyClient.swift. Results from the server
//! are suggestions (origin "ocr"/"ocr-server"); people confirm the values.
use std::io::Read;
use std::time::Duration;

use serde::Deserialize;
use serde_json::{json, Value};

#[derive(Debug, Clone, PartialEq, thiserror::Error)]
pub enum ServerError {
    #[error("No se pudo conectar con el servidor. Revisá la conexión.")]
    Network,
    #[error("{0}")]
    Problem(String),
    #[error("respuesta inesperada del servidor")]
    Decode,
}

/// One per-cell reading (form-layouts SPEC). `text` is "?" when the cell has writing
/// that could not be read: the app shows an empty box to fill.
#[derive(Debug, Clone, PartialEq, Deserialize)]
pub struct Reading {
    #[serde(rename = "ref")]
    pub reference: String,
    pub value: Option<i64>,
    #[serde(default)]
    pub confidence: f64,
    #[serde(default)]
    pub status: Option<String>,
    #[serde(default)]
    pub text: Option<String>,
}

impl Reading {
    /// Normalized status for servers that predate `status`.
    pub fn status(&self) -> &str {
        match self.status.as_deref() {
            Some(s) => s,
            None if self.value.is_some() => "read",
            None => "unreadable",
        }
    }
}

#[derive(Debug, Clone, PartialEq, Deserialize)]
pub struct Readings {
    #[serde(rename = "layoutId")]
    pub layout_id: Option<String>,
    #[serde(default)]
    pub fields: Vec<Reading>,
    #[serde(default)]
    pub pending: Vec<String>,
    #[serde(default, rename = "notFound")]
    pub not_found: Vec<String>,
    #[serde(default)]
    pub alignment: Value,
}

pub struct ServerClient {
    base: String,
    token: Option<String>,
    agent: ureq::Agent,
}

impl ServerClient {
    pub fn new(base_url: &str, token: Option<String>) -> Self {
        let agent = ureq::AgentBuilder::new().timeout(Duration::from_secs(60)).build();
        Self { base: base_url.trim_end_matches('/').to_string(), token, agent }
    }

    /// Paths are appended to the base, which may carry a prefix (/cuentaconmigo).
    fn url(&self, path: &str) -> String {
        format!("{}/{}", self.base, path.trim_start_matches('/'))
    }

    fn request(&self, method: &str, path: &str) -> ureq::Request {
        let mut r = self.agent.request(method, &self.url(path));
        if let Some(t) = &self.token {
            r = r.set("Authorization", &format!("Bearer {t}"));
        }
        r
    }

    fn handle(result: Result<ureq::Response, ureq::Error>) -> Result<Value, ServerError> {
        match result {
            Ok(resp) => {
                let mut body = String::new();
                resp.into_reader().take(10_000_000).read_to_string(&mut body).map_err(|_| ServerError::Decode)?;
                serde_json::from_str(&body).map_err(|_| ServerError::Decode)
            }
            Err(ureq::Error::Status(code, resp)) => {
                let problem: Value = resp.into_string().ok().and_then(|t| serde_json::from_str(&t).ok()).unwrap_or(Value::Null);
                let title = problem.get("title").and_then(Value::as_str);
                let detail = problem.get("detail").and_then(Value::as_str).filter(|d| !d.is_empty());
                Err(ServerError::Problem(match (title, detail) {
                    (Some(t), Some(d)) => format!("{t}: {d}"),
                    (Some(t), None) => t.to_string(),
                    _ => format!("El servidor respondió {code}."),
                }))
            }
            Err(ureq::Error::Transport(_)) => Err(ServerError::Network),
        }
    }

    pub fn health(&self) -> Result<Value, ServerError> {
        Self::handle(self.request("GET", "v1/health").call())
    }

    /// Enrolls the device with a code; no personal data is sent. Returns the device token.
    pub fn enroll(&self, code: &str, platform: &str, app_version: &str) -> Result<String, ServerError> {
        let body = json!({"enrollmentCode": code, "platform": platform, "appVersion": app_version});
        let v = Self::handle(
            self.request("POST", "v1/devices/enroll").set("Content-Type", "application/json").send_string(&body.to_string()),
        )?;
        v.get("deviceToken").and_then(Value::as_str).map(str::to_string).ok_or(ServerError::Decode)
    }

    /// Two-step upload: the package, then only the images the server is missing.
    /// Returns the hash-chained receipt as JSON text, to keep with the capture.
    pub fn upload(&self, capture_json: &str, pages: &[(String, Vec<u8>)]) -> Result<String, ServerError> {
        let reply = Self::handle(
            self.request("POST", "v1/captures").set("Content-Type", "application/json").send_string(capture_json),
        )?;
        let missing: Vec<String> = reply
            .get("missingBlobs")
            .and_then(Value::as_array)
            .map(|a| a.iter().filter_map(Value::as_str).map(str::to_string).collect())
            .unwrap_or_default();
        for sha in missing {
            if let Some((_, bytes)) = pages.iter().find(|(s, _)| *s == sha) {
                Self::handle(
                    self.request("PUT", &format!("v1/blobs/{sha}")).set("Content-Type", "image/jpeg").send_bytes(bytes),
                )?;
            }
        }
        reply.get("receipt").map(Value::to_string).ok_or(ServerError::Decode)
    }

    /// OCR numbers detected on the capture's pages; `finished` once every page is done.
    pub fn ocr(&self, capture_id: &str) -> Result<(bool, Vec<i64>), ServerError> {
        let v = Self::handle(self.request("GET", &format!("v1/captures/{capture_id}/ocr")).call())?;
        let results = v.get("results").and_then(Value::as_array).cloned().unwrap_or_default();
        let finished = results.iter().all(|r| matches!(r.get("status").and_then(Value::as_str), Some("done" | "failed")));
        let mut numbers: Vec<i64> = Vec::new();
        for n in results.iter().flat_map(|r| r.get("numbers").and_then(Value::as_array).cloned().unwrap_or_default()) {
            if let Some(n) = n.as_i64() {
                if !numbers.contains(&n) {
                    numbers.push(n);
                }
            }
        }
        Ok((finished, numbers))
    }

    /// Per-cell readings aligned to the form layout. Nothing is stored on the server.
    pub fn readings(&self, template_id: &str, jpeg: &[u8]) -> Result<Readings, ServerError> {
        let v = Self::handle(
            self.request("POST", &format!("v1/readings?templateId={template_id}"))
                .set("Content-Type", "image/jpeg")
                .send_bytes(jpeg),
        )?;
        serde_json::from_value(v).map_err(|_| ServerError::Decode)
    }
}
