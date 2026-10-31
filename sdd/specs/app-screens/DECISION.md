# DECISIÓN · Pantallas de la app (consolidación del pipeline)

Fecha: 31/10/2026. Propuesta: Fable (`SPEC.md`). Revisión: Astra (`checks/*.astra.md`,
revisión `c8b3d20`). Consolida: planner (Claude). **Decide: el autor junto con Andy**
(`decisions/PREGUNTAS.md`, AS-1 a AS-12).

## Bloqueos (⛔) y cómo se tratan

| # | Lente | Hallazgo | Tratamiento | Estado |
| --- | --- | --- | --- | --- |
| 1 | legal | Se presentaba como resuelta la autorización para fotografiar certificado, telegrama y acta | Textos neutrales en el prototipo; la pregunta va a un abogado o abogada electoral humano (D-MA-3) | En prototipo / pendiente legal |
| 2 | legal | Protección de datos incompleta al exportar (firmas, nombres; responsable, conservación, derechos) | Aviso antes de exportar en el prototipo; definir responsable, base jurídica y conservación (AS-11) | Pendiente de decisión |
| 3 | spec | La pantalla E-00 exige exportar campos que el contrato no admite (`fictitious`, `lockedAt`, `exportedAt`) | No exportar campos fuera del contrato; si hacen falta, cambio de contrato (AS-4, AS-12) | Pendiente de decisión |
| 4 | spec | El bloqueo del núcleo no cubría todas las propiedades | **Corregido** en `0eb1e3b`: campos `private(set)` y test de todas las mutaciones | ✅ |
| 5 | ux | Los errores de mesa llevaban a la pantalla equivocada | En el prototipo, tocar un error lleva al campo exacto | En prototipo |
| 6 | ux | Promesa de envío automático que P0 no cumple | Estado "No enviada · exportá manualmente" | En prototipo |

## Riesgos (⚠️) principales

- **OCR (ux 3):** intercambiar votos entre filas no lo detectan las sumas. Mitigaciones
  posibles: mostrar el número en el contexto de su fila, o una doble carga completa en vez de sólo totales (AS-5).
- **Modo jornada y veda (legal 4):** el modo jornada no prueba que se cumpla la veda.
  Definir reglas operativas con electoral_counsel antes de activarlo.
- **Orden por interacción (neutrality 1, spec 6):** ordenar argumentos por cantidad de
  respuestas contradice el principio de no amplificar por interacción. Usar un orden
  cronológico o elegido por quien lee.
- **"Fuerzas de distinto signo" (neutrality 2):** falta un criterio verificable. Va a RC-2.
- **Accesibilidad y texto grande (ux 4 y 5):** transcribir sin ver exige un flujo
  verificable con VoiceOver; hay que probarlo con personas usuarias.
- **Android (spec 5):** la equivalencia debe cubrir datos válidos y recuperación del
  flujo, no sólo componentes visuales.

## Recomendación del planner

1. Seguir con el **prototipo navegable** (Fable, en curso) que ya incorpora los ⛔ 1, 5 y 6.
2. Revisar el prototipo con Astra (lentes `ux`, `legal` y `neutrality`).
3. Decidir AS-1 a AS-12 por consenso y recién entonces implementar en SwiftUI.
4. Mientras tanto, el prototipo SwiftUI actual queda como base técnica (escaneo,
   OCR, validación, bloqueo y exportación) sin cambios de flujo.
