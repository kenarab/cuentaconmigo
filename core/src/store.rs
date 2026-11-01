//! Local evidence store (port of ios/CuentaConmigo/Model/CaptureStore.swift).
//!
//! Each capture lives in its own folder: `capture.json` (contracts/schemas/capture.schema.json),
//! page JPEGs written once and never overwritten, and `receipts.jsonl` with the server's
//! hash-chained receipts. Captures sent to the server cannot be deleted (owner's decision).
//! The platform adds file protection / backup exclusion on the root folder.
use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};

use crate::capture::{iso8601_now, sha256_hex, AppInfo, Capture, CaptureError, Page, PageSource};
use crate::template::{DocumentType, FormTemplate};

#[derive(Debug, thiserror::Error)]
pub enum StoreError {
    #[error("no se pudo guardar: {0}")]
    Io(#[from] std::io::Error),
    #[error("captura ilegible: {0}")]
    Json(#[from] serde_json::Error),
    #[error(transparent)]
    Capture(#[from] CaptureError),
    #[error("la captura no existe")]
    NotFound,
    #[error("una captura enviada no se puede borrar: es prueba de lo que se mandó")]
    SentCannotBeDeleted,
}

pub struct Store {
    root: PathBuf,
}

impl Store {
    pub fn open(root: impl Into<PathBuf>) -> Result<Self, StoreError> {
        let root = root.into().join("Captures");
        fs::create_dir_all(&root)?;
        Ok(Self { root })
    }

    pub fn folder(&self, id: &str) -> PathBuf {
        self.root.join(id)
    }
    fn json_path(&self, id: &str) -> PathBuf {
        self.folder(id).join("capture.json")
    }
    pub fn page_path(&self, id: &str, page: &Page) -> PathBuf {
        self.folder(id).join(&page.file)
    }
    pub fn receipts_path(&self, id: &str) -> PathBuf {
        self.folder(id).join("receipts.jsonl")
    }

    pub fn create(&self, template: &FormTemplate, document_type: DocumentType, app: AppInfo) -> Result<Capture, StoreError> {
        let id = uuid::Uuid::new_v4().to_string().to_uppercase();
        let capture = Capture::new(id, template, document_type, iso8601_now(), app);
        fs::create_dir_all(self.folder(&capture.id))?;
        self.save(&capture)?;
        Ok(capture)
    }

    pub fn save(&self, capture: &Capture) -> Result<(), StoreError> {
        let path = self.json_path(&capture.id);
        let tmp = path.with_extension("json.tmp");
        fs::write(&tmp, capture.to_json())?;
        fs::rename(tmp, path)?;
        Ok(())
    }

    pub fn load(&self, id: &str) -> Result<Capture, StoreError> {
        let text = fs::read_to_string(self.json_path(id)).map_err(|_| StoreError::NotFound)?;
        Ok(Capture::from_json(&text)?)
    }

    /// Newest first; unreadable folders are skipped.
    pub fn list(&self) -> Vec<Capture> {
        let mut out: Vec<Capture> = fs::read_dir(&self.root)
            .into_iter()
            .flatten()
            .flatten()
            .filter_map(|e| fs::read_to_string(e.path().join("capture.json")).ok())
            .filter_map(|t| Capture::from_json(&t).ok())
            .collect();
        out.sort_by(|a, b| b.created_at.cmp(&a.created_at));
        out
    }

    /// Writes a new page once; an existing file is never overwritten.
    pub fn add_page(&self, capture: &mut Capture, jpeg: &[u8], source: PageSource) -> Result<Page, StoreError> {
        if capture.is_locked() {
            return Err(CaptureError::AlreadyConfirmed.into());
        }
        let page = Page {
            file: format!("page-{}.jpg", capture.pages().len() + 1),
            sha256: sha256_hex(jpeg),
            captured_at: iso8601_now(),
            source,
        };
        let mut f = fs::OpenOptions::new().write(true).create_new(true).open(self.page_path(&capture.id, &page))?;
        f.write_all(jpeg)?;
        f.sync_all()?;
        capture.append_page(page.clone())?;
        self.save(capture)?;
        Ok(page)
    }

    pub fn was_sent(&self, id: &str) -> bool {
        self.receipts_path(id).exists()
    }

    /// Receipts of every submission, appended and never removed.
    pub fn append_receipt(&self, id: &str, receipt_json: &str) -> Result<(), StoreError> {
        let mut f = fs::OpenOptions::new().append(true).create(true).open(self.receipts_path(id))?;
        writeln!(f, "{}", receipt_json.trim())?;
        Ok(())
    }

    pub fn receipts(&self, id: &str) -> Vec<String> {
        fs::read_to_string(self.receipts_path(id))
            .map(|t| t.lines().filter(|l| !l.trim().is_empty()).map(str::to_string).collect())
            .unwrap_or_default()
    }

    /// Unsent captures (drafts or confirmed) can be deleted; sent ones are kept as proof.
    pub fn delete(&self, id: &str) -> Result<(), StoreError> {
        if self.was_sent(id) {
            return Err(StoreError::SentCannotBeDeleted);
        }
        let folder = self.folder(id);
        if !folder.exists() {
            return Err(StoreError::NotFound);
        }
        fs::remove_dir_all(folder)?;
        Ok(())
    }

    /// Files to share: package, pages and receipts (when sent).
    pub fn export_paths(&self, capture: &Capture) -> Vec<PathBuf> {
        let mut out = vec![self.json_path(&capture.id)];
        out.extend(capture.pages().iter().map(|p| self.page_path(&capture.id, p)));
        if self.was_sent(&capture.id) {
            out.push(self.receipts_path(&capture.id));
        }
        out
    }

    pub fn root(&self) -> &Path {
        &self.root
    }
}
