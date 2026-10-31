//! Storage rules, polling-place list and the server client (against a local server
//! when CC_TEST_SERVER is set, e.g. http://127.0.0.1:8740).
use std::path::PathBuf;

use cc_core::nomina::Nomina;
use cc_core::server::ServerClient;
use cc_core::store::{Store, StoreError};
use cc_core::*;

fn repo() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).parent().unwrap().to_path_buf()
}
fn template() -> FormTemplate {
    FormTemplate::from_json(&std::fs::read_to_string(repo().join("contracts/templates/generales-2023.json")).unwrap()).unwrap()
}
fn app() -> AppInfo {
    AppInfo { platform: "test".into(), version: "0".into() }
}

#[test]
fn pages_are_immutable_and_sent_captures_stay() {
    let dir = std::env::temp_dir().join(format!("cc-store-{}", std::process::id()));
    let store = Store::open(&dir).unwrap();
    let mut c = store.create(&template(), DocumentType::Telegrama, app()).unwrap();
    let page = store.add_page(&mut c, b"\xff\xd8\xffJPEG", PageSource::Photos).unwrap();
    assert_eq!(page.file, "page-1.jpg");
    assert_eq!(page.sha256, sha256_hex(b"\xff\xd8\xffJPEG"));
    assert_eq!(store.load(&c.id).unwrap().pages().len(), 1);
    assert_eq!(store.list().len(), 1);

    // A draft can be deleted.
    store.delete(&c.id).unwrap();
    assert!(store.list().is_empty());

    // A sent capture cannot.
    let c2 = store.create(&template(), DocumentType::Acta, app()).unwrap();
    store.append_receipt(&c2.id, r#"{"index":1}"#).unwrap();
    assert!(matches!(store.delete(&c2.id), Err(StoreError::SentCannotBeDeleted)));
    assert_eq!(store.receipts(&c2.id), vec![r#"{"index":1}"#.to_string()]);
    assert!(store.export_paths(&c2).iter().any(|p| p.ends_with("receipts.jsonl")));
    std::fs::remove_dir_all(dir).ok();
}

#[test]
fn polling_place_list_queries() {
    let n = Nomina::from_json(&std::fs::read_to_string(repo().join("data/establecimientos/nomina-2025.json")).unwrap()).unwrap();
    assert_eq!(n.distritos.len(), 24);
    let caba = n.district("01").unwrap();
    let comuna1 = &caba.secciones[0];
    let all = n.search("01", &comuna1.id, "");
    assert!(!all.is_empty());
    let first = all[0];
    let (mesa, circuito) = first.tables()[0].clone();
    let (found, c) = n.locate("01", &comuna1.id, mesa).unwrap();
    assert_eq!(found.codigo, first.codigo);
    assert_eq!(c, circuito);
    assert!(n.search("01", &comuna1.id, &mesa.to_string()).iter().any(|p| p.codigo == first.codigo));
    let word = first.nombre.split_whitespace().last().unwrap().to_lowercase();
    assert!(!n.search("01", &comuna1.id, &word).is_empty());
}

#[test]
fn server_round_trip_when_available() {
    let Ok(base) = std::env::var("CC_TEST_SERVER") else { return };
    let code = std::env::var("CC_TEST_CODE").unwrap_or_else(|_| "0000".into());
    let anon = ServerClient::new(&base, None);
    assert_eq!(anon.health().unwrap()["status"], "ok");
    let token = anon.enroll(&code, "test", "0").unwrap();
    let client = ServerClient::new(&base, Some(token));

    let dir = std::env::temp_dir().join(format!("cc-srv-{}", std::process::id()));
    let store = Store::open(&dir).unwrap();
    let mut c = store.create(&template(), DocumentType::Telegrama, app()).unwrap();
    // Sample telegrams are git-ignored (personal data): point CC_TEST_JPEG at one.
    let Ok(jpeg_path) = std::env::var("CC_TEST_JPEG") else { return };
    let jpeg = std::fs::read(jpeg_path).unwrap();
    store.add_page(&mut c, &jpeg, PageSource::Sample).unwrap();
    let pages = vec![(c.pages()[0].sha256.clone(), jpeg.clone())];
    let receipt = client.upload(&c.to_json(), &pages).unwrap();
    assert!(receipt.contains("chainHash"));
    store.append_receipt(&c.id, &receipt).unwrap();
    assert!(store.was_sent(&c.id));

    let readings = client.readings("balotaje-2015", &jpeg).unwrap();
    assert!(!readings.fields.is_empty());
    assert!(readings.fields.iter().all(|f| matches!(f.status(), "read" | "empty" | "unreadable")));
    let mut done = false;
    for _ in 0..30 {
        let (finished, _) = client.ocr(&c.id).unwrap();
        if finished {
            done = true;
            break;
        }
        std::thread::sleep(std::time::Duration::from_secs(1));
    }
    assert!(done);
    std::fs::remove_dir_all(dir).ok();
}
