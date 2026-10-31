//! Shared conformance vectors in /contracts (same files the Swift core runs).
use std::collections::HashSet;
use std::path::PathBuf;

use cc_core::*;
use serde::Deserialize;

fn repo() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).parent().unwrap().to_path_buf()
}

fn read(path: &str) -> String {
    std::fs::read_to_string(repo().join(path)).unwrap_or_else(|e| panic!("{path}: {e}"))
}

fn template(id: &str) -> FormTemplate {
    FormTemplate::from_json(&read(&format!("contracts/templates/{id}.json"))).unwrap()
}

#[test]
fn validation_vectors() {
    #[derive(Deserialize)]
    struct Case {
        name: String,
        input: ValidationInput,
        expected: Vec<ValidationIssue>,
    }
    #[derive(Deserialize)]
    struct File {
        cases: Vec<Case>,
    }
    let file: File = serde_json::from_str(&read("contracts/vectors/validation.json")).unwrap();
    let t = template("demo-2027");
    assert!(!file.cases.is_empty());
    for c in file.cases {
        let got: HashSet<_> = validate(&c.input, &t).into_iter().collect();
        let want: HashSet<_> = c.expected.into_iter().collect();
        assert_eq!(got, want, "{}", c.name);
    }
}

#[test]
fn digit_vectors() {
    #[derive(Deserialize)]
    struct Case {
        input: String,
        expected: Option<i64>,
    }
    #[derive(Deserialize)]
    struct File {
        cases: Vec<Case>,
    }
    let file: File = serde_json::from_str(&read("contracts/vectors/digits.json")).unwrap();
    assert!(!file.cases.is_empty());
    for c in file.cases {
        assert_eq!(cc_core::digits::normalize(&c.input), c.expected, "input: {:?}", c.input);
    }
}

#[test]
fn example_capture_round_trips() {
    let json = read("contracts/examples/capture.example.json");
    let capture = Capture::from_json(&json).unwrap();
    // Like the Swift test: explicit nulls and absent keys are equivalent.
    fn strip_nulls(v: serde_json::Value) -> serde_json::Value {
        match v {
            serde_json::Value::Object(m) => serde_json::Value::Object(
                m.into_iter().filter(|(_, v)| !v.is_null()).map(|(k, v)| (k, strip_nulls(v))).collect(),
            ),
            serde_json::Value::Array(a) => serde_json::Value::Array(a.into_iter().map(strip_nulls).collect()),
            other => other,
        }
    }
    let original = strip_nulls(serde_json::from_str(&json).unwrap());
    let again = strip_nulls(serde_json::from_str(&capture.to_json()).unwrap());
    assert_eq!(original, again);
    assert!(capture.validate(&template("demo-2027")).is_empty());
}

#[test]
fn real_templates_decode() {
    for id in ["generales-2023", "balotaje-2015", "demo-2027"] {
        let t = template(id);
        assert_eq!(t.id, id);
        let ids: HashSet<_> = t.rows.iter().map(|r| &r.id).collect();
        assert_eq!(ids.len(), t.rows.len());
    }
}

#[test]
fn confirm_locks_and_needs_justification_for_warnings() {
    let t = template("demo-2027");
    let app = AppInfo { platform: "test".into(), version: "0".into() };
    let mut c = Capture::new("ID".into(), &t, DocumentType::Telegrama, "2027-10-24T21:00:00Z".into(), app);
    for (f, v) in [("distrito", "99"), ("seccion", "001"), ("circuito", "0001"), ("mesa", "00042")] {
        c.set_mesa_field(f, v.into()).unwrap();
    }
    c.set_header("votantes", Some(70), ValueOrigin::Manual).unwrap();
    for cat in &t.categories {
        for row in &t.rows {
            c.set_cell(&cat.id, &row.id, Some(10), ValueOrigin::Manual).unwrap();
        }
    }
    assert_eq!(c.confirm(&t, None, "2027-10-24T21:10:00Z".into()), Ok(()));
    assert!(c.is_locked());
    assert_eq!(c.set_header("votantes", Some(1), ValueOrigin::Manual), Err(CaptureError::AlreadyConfirmed));

    let app = AppInfo { platform: "test".into(), version: "0".into() };
    let mut w = Capture::new("ID2".into(), &t, DocumentType::Telegrama, "2027-10-24T21:00:00Z".into(), app);
    for (f, v) in [("distrito", "99"), ("seccion", "001"), ("circuito", "0001"), ("mesa", "00042")] {
        w.set_mesa_field(f, v.into()).unwrap();
    }
    w.set_header("votantes", Some(71), ValueOrigin::Manual).unwrap();
    for cat in &t.categories {
        for row in &t.rows {
            w.set_cell(&cat.id, &row.id, Some(10), ValueOrigin::Manual).unwrap();
        }
    }
    assert_eq!(w.confirm(&t, None, "x".into()), Err(CaptureError::WarningsNeedJustification));
    assert_eq!(w.confirm(&t, Some("  el papel dice eso "), "x".into()), Ok(()));
    assert_eq!(w.warning_justification(), Some("el papel dice eso"));
}

#[test]
fn sha256_and_dates() {
    assert_eq!(sha256_hex(b"test"), "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08");
    assert_eq!(cc_core::capture::iso8601_from_unix(0), "1970-01-01T00:00:00Z");
    assert_eq!(cc_core::capture::iso8601_from_unix(1_824_412_503), "2027-10-24T21:15:03Z");
}
