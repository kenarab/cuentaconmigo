---
name: ios-verify
description: Verifica la app iOS de CuentaConmigo (tests del núcleo contra contratos + compilación iOS sin firma). Usar después de cualquier cambio en ios/ o contracts/ y antes de commitear código iOS.
---

# Verificación iOS

```sh
ios/scripts/verify.sh
```

- Corre `swift test` de `ios/TelegramaCore` (vectores de `contracts/`) y compila la app
  para `generic/platform=iOS` con `CODE_SIGNING_ALLOWED=NO`.
- Temporales en `~/home.codex/tmp`. No instala nada: si falta una herramienta,
  informar al autor.
- Si falla `testBundledTemplateMatchesContract`, ejecutar `ios/scripts/sync-contracts.sh`.
- Reportar cantidad de tests, fallas y resultado del build en `VERIFICATION.md` de la SPEC.
- Compilar no acredita el funcionamiento en el dispositivo: el escáner VisionKit, la cámara
  y la exportación se prueban en un iPhone real (lo hace el autor o Andy).

Para correr en un iPhone: abrir `ios/CuentaConmigo.xcodeproj` en Xcode, elegir el
equipo de firma y el dispositivo, y ejecutar ▶︎.
