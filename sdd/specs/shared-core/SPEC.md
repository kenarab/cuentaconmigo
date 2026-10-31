# SPEC · Núcleo compartido en Rust (iOS y Android)

Estado: **en implementación** (decisión del autor AA-7, 31/10/2026). Rama
`claude/shared-core-claude`, worktree `../cuentaconmigo-shared-core-claude`. El autor
suspendió los otros desarrollos para esta tarea. Relacionada con
[app-architecture](../app-architecture/SPEC.md), [mobile-platform](../mobile-platform/SPEC.md),
[telegram-capture](../telegram-capture/SPEC.md), [scrutiny-backend](../scrutiny-backend/SPEC.md)
y [server-location](../server-location/SPEC.md).

## 1. Objetivo

El mismo código para todas las plataformas, con la menor duplicación posible. Una API
interna amplia vive en un núcleo Rust, y cada plataforma implementa sólo sus pantallas y
el acceso a su hardware. Los contratos de `contracts/` son la fuente de verdad: el núcleo
pasa sus vectores, así que toda plataforma que lo use es conforme por construcción.

## 2. Qué va en el núcleo y qué no

| Núcleo `core/` (crate `cc_core`) | Cada plataforma |
| --- | --- |
| Plantillas, modelo de captura (JSON de `capture.schema.json`), validación, normalización de dígitos, SHA-256, confirmación y bloqueo | Pantallas: SwiftUI (iOS) y Jetpack Compose (Android) |
| Flujo F-1/F-2/F-3: intérprete del statechart `contracts/flows/capture.flow.json` | Cámara y escáner de documentos (VisionKit / ML Kit) |
| Guardado: carpeta por captura, imágenes inmutables, `receipts.jsonl`, regla de borrado (las enviadas no se borran) | Llavero para el token (Keychain / Android Keystore) |
| Cliente del servidor `/v1`: alta, envío en dos pasos, OCR, lecturas por casillero con `"?"`, comprobantes | OCR en el teléfono (Vision / ML Kit), si se usa |
| Nómina de establecimientos y consultas de las listas en cascada | Permisos, notificaciones, compartir archivos |
| Telegramas de ejemplo (manifiesto) | Empaquetado: xcframework / AAR |

Interfaz: **UniFFI**, con macros procedurales. Genera los bindings en Swift y en Kotlin;
no se escriben a mano. La red se resuelve en Rust con `ureq` y TLS `rustls`, sin
depender del sistema.

## 3. Plan por fases (cada fase cierra con pruebas)

| Fase | Contenido | Aceptación |
| --- | --- | --- |
| 1 | Crate `cc_core`: tipos, JSON compatible con el schema, validación, dígitos, SHA-256, confirmación | `cargo test`: `validation.json` y `digits.json` al 100 %, ida y vuelta de `capture.example.json` |
| 2 | Intérprete del flujo (port de `flow-machine.js`) | `capture-flow.json` 54/54 |
| 3 | Guardado, nómina, ejemplos y cliente del servidor | Pruebas con carpeta temporal y contra el servidor local (`127.0.0.1:8740`) |
| 4 | API UniFFI + bindings Kotlin y Swift; build Android (`cargo-ndk`: arm64-v8a, x86_64) | `.so` y `cc_core.kt` generados; bindings Swift generados |
| 5 | App Android (`android/`, Compose) sobre el núcleo: lista, nueva captura, ejemplo o foto, mesa en cascada, lectura del servidor con casilleros "?", confirmación, comprobante, regla de borrado, selector F-1/F-2/F-3 | APK debug instalable; prueba manual de punta a punta contra el servidor público |
| 6 | iOS sobre el núcleo: script de xcframework y reemplazo de TelegramaCore (se compila en la Mac) | Build en la Mac; mismas funciones que hoy |
| 7 | Documentación, traducciones y PR a `main` | Revisión del autor |

## 4. Contrato de tarea

- **ID / rol / responsable:** shared-core / implementer + coordinador / sesión Claude del servidor.
- **Herramienta / modelo:** Claude Code, Opus 5.5.
- **Base:** `e320a91` (main).
- **Escritura exclusiva:** `core/`, `android/`, `sdd/specs/shared-core/`,
  `scripts/core/`. `ios/` sólo en la fase 6, coordinando con la sesión de la Mac.
- **Instalaciones autorizadas por el autor (31/10):** Android SDK y NDK en
  `~/Android/Sdk`, `cargo-ndk`, crates de Rust (uniffi, serde, sha2, ureq…) y Gradle
  wrapper. Todo en el usuario, sin `sudo`.
- **Verificación:** `cargo test` en `core/`; `./gradlew assembleDebug` en `android/`.
- **Revisión:** autocontrol. No hay revisión independiente todavía.
- **Parada:** si un vector del contrato no se puede reproducir, se consulta al autor
  antes de cambiar el contrato.
