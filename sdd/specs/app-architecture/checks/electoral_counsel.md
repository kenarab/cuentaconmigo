# Chequeo electoral_counsel (legal, datos personales y ciberseguridad) · app-architecture

## 31/10/2026 · revisión breve

> No es asesoramiento legal ni de seguridad profesional. La SPEC apareció en el commit
> `1dd5c8f` durante este chequeo; se revisó de forma acotada (no es el foco del encargo).

### Alcance

`sdd/specs/app-architecture/SPEC.md` (secciones 1, 5-9). Es una SPEC de arquitectura de
presentación; casi no cambia el tratamiento de datos.

### Hallazgos

| # | Sev. | Hallazgo | Control |
| --- | --- | --- | --- |
| A1 | ✅ | Ningún campo de identidad en la máquina de flujo ni en el contrato; F-3 sin identidades; fotos en el `EvidenceStore` protegido. | — |
| A2 | ⚠️ | **Guardas legales como datos** (`bupWarning` no salteable, `confirmed` sin ediciones): si `capture.flow.json` alguna vez se descarga del servidor (server-driven UI), una versión alterada podría saltear la advertencia de la Boleta Única (Código Electoral art. 71 inc. g). | Flujo embebido en el binario o firmado; vectores negativos ya previstos (criterio 1). |
| A3 | ⚠️ | **Canales de workflows/asistentes (chat, voz, bot):** si usan mensajería de terceros, las fotos con nombres y firmas (Ley 25.326 arts. 2, 7) salen a proveedores externos y posiblemente al exterior (art. 12). | Requerir chequeo propio antes de cualquier adaptador de canal; no enviar imágenes por canales de terceros. |
| A4 | ⚠️ bajo | F-3 "traspaso" del teléfono a otra persona: la segunda persona accede a la captura y a la galería de la app. | Modo traspaso que sólo muestra la captura en curso. |

### Veredicto

**✅ con observaciones** (A2, A3). Sin ⛔.
