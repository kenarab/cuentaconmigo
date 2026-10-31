//! CuentaConmigo shared core (sdd/specs/shared-core/SPEC.md).
//!
//! One implementation of the app's logic for every platform. The shared contracts in
//! /contracts are the source of truth; tests run their conformance vectors.
pub mod capture;
pub mod digits;
pub mod flow;
pub mod nomina;
pub mod server;
pub mod store;
pub mod template;
pub mod validation;

pub use capture::{iso8601_now, sha256_hex, AppInfo, Capture, CaptureError, CaptureStatus, CellValue, Mesa, Page, PageSource, ValueOrigin};
pub use template::{Category, DocumentType, Field, FormTemplate, Row, Rules, Severity};
pub use validation::{validate, ValidationInput, ValidationIssue};
