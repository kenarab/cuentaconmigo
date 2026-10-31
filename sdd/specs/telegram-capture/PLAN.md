# PLAN · Captura de telegramas (prototipo iOS)

1. Contratos: schema, plantilla demo, ejemplo y vectores (`contracts/`).
2. Núcleo `ios/TelegramaCore` (Swift Package, sin UI): modelos, plantilla,
   validación, normalización de dígitos, hashing; tests contra vectores.
3. App `ios/CuentaConmigo` (SwiftUI): almacenamiento, escáner VisionKit/PhotosPicker,
   OCR Vision, flujo de carga, validación, confirmación y exportación.
4. Script `ios/scripts/verify.sh`: `swift test` + compilación iOS sin firma.
5. Prueba en iPhone real por el autor (criterio 4). Android: después de D-002.

Rutas exclusivas por tarea en `tasks.json`. Integración Git: planner.
