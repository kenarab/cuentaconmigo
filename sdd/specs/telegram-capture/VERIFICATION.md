# VERIFICACIÓN · Captura de telegramas

## 31/10/2026 · revisión `796e5fa` · Claude Code (autocontrol, sin revisión independiente)

Comando: `ios/scripts/verify.sh` (macOS 27, Xcode 27.2 build 27B52, Swift 6.4.2).

| Criterio | Estado | Evidencia |
| --- | --- | --- |
| 1. Vectores de contrato en `swift test` | ✅ | 8 tests, 0 fallas (validación, dígitos, ida y vuelta del ejemplo, plantilla incluida idéntica al contrato, bloqueo, justificación, SHA-256) |
| 2. Ejemplo decodifica y re-codifica sin pérdida | ✅ | `testExampleCaptureRoundTrips` |
| 3. Compila para iOS 17+ sin firma | ✅ | `xcodebuild … generic/platform=iOS CODE_SIGNING_ALLOWED=NO` → BUILD SUCCEEDED, sin warnings del código de la app |
| 4. Flujo completo en iPhone real | ⏳ pendiente (autor) | No hay simulador instalado en esta Mac; el escáner VisionKit sólo funciona en un dispositivo |
| 5. Captura confirmada no editable | ✅ núcleo / ⏳ UI | `testConfirmLocksCapture`; la UI deshabilita los campos (falta verificarlo en el dispositivo) |
| 6. Sin datos reales en el repo | ✅ | Plantilla y ejemplos ficticios (`fictitious: true`) |

Limitaciones conocidas:

- La precisión del OCR sobre números manuscritos no está medida.
- Las fotos importadas se re-codifican a JPEG. El hash corresponde al archivo
  guardado, no al original de la galería.
- No hay tests de UI ni de la app (no hay runtime de simulador).

## 31/10/2026 · revisión `87927df` · compilación firmada de la primera versión (0.1.0)

- `xcodebuild … -destination generic/platform=iOS -allowProvisioningUpdates build` →
  **BUILD SUCCEEDED**. Firma: Apple Development (equipo del autor), perfil "iOS Team
  Provisioning Profile: *".
- Incluye el bloqueo completo de capturas confirmadas (`0eb1e3b`) y el aviso de Boleta Única.
- **Instalación pendiente:** el iPhone 12 Pro del autor figuraba como "unavailable" en
  `devicectl`. Instalar con `ios/scripts/install-device.sh` con el teléfono conectado y desbloqueado.

## 31/10/2026 · revisión `a7e84cb` (plantilla generales-2023) · instalación en el iPhone del autor

- Dispositivo: iPhone 12 Pro (iPhone13,3), iOS 27.0.1, emparejado por red. Antes figuraba
  "unavailable"; quedó "available (paired)" al conectar la Mac a la red del teléfono.
- `xcrun devicectl device install app` → instalada; `device process launch` → **la app abrió**.
- Script: `ios/scripts/install-device.sh` detecta ahora el UDID correctamente (`f5b7439`).
- **Pendiente (autor):** recorrer el flujo en el teléfono (escanear, cargar, confirmar,
  exportar) y anotar el resultado de los criterios 4 y 5.
