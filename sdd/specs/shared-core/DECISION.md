# Decisión · Duplicación pendiente en el núcleo compartido

Revisión `0156dc8` (1/11/2026). Pedido del autor: que Fable y Astra analicen el núcleo
Rust para reducir toda la duplicación posible. Informes:
[duplication.astra.md](checks/duplication.astra.md) (Astra, gpt-6-astra vía Codex) y
[duplication.fable.md](checks/duplication.fable.md) (Fable, claude-fable-5-1).
Consolidó la sesión Claude coordinadora. Es una propuesta: no se implementa nada hasta que
decida el autor.

## Coincidencias de los dos revisores

| # | Duplicación | Consecuencia observada | Propuesta | Esfuerzo |
| --- | --- | --- | --- | --- |
| 1 | `FlowSession` no lo usa ninguna app: pasos de F-1, habilitar Confirmar, avisos → justificación y "doble carga sólo en F-3" se reescriben en Kotlin y Swift | Las guardas del flujo no rigen en las apps; `Capture::confirm` acepta justificación de 1 carácter (el flujo pide 5) y no exige imagen | Corto plazo: `can_confirm`, `needs_justification`, `supports_double_entry`, `steps` en `CaptureDetail`. Después: sesión de captura única (flujo + captura + guardado) | S / L |
| 2 | Doble carga F-3 escrita 4 veces (Rust, JS, Swift, Kotlin) | Swift y Kotlin cuentan una categoría vacía como 0; Rust y JS, como incompleta | `compare_second_entry(id, SecondEntry) -> Comparison` en el núcleo | S |
| 3 | Validación, mensajes y rótulos de tipo de documento | Redacciones distintas; Android fija los 3 tipos en vez de leer la plantilla | Mensajes desde el núcleo (o catálogo en `contracts/`); usar `TemplateRecord.document_types` | S |
| 4 | Presentaciones F-1/F-2/F-3 en 3 enums | iOS guarda `"F-2"` y el flujo espera `"f2"` | `presentations()` desde `capture.flow.json` | S |
| 5 | Formato de mesa `%05d` y "Mesa N" en cada pantalla | El prototipo no rellena con ceros | `TableRecord.code/label` y `mesa_for_table` | S |
| 6 | Telegramas de ejemplo y elección de plantilla | iOS cambia la plantilla al ejemplo y Android no | `load_samples` + `use_sample` | M |
| 7 | Cliente del servidor duplicado (Swift) y lecturas incompletas en Rust | El núcleo descarta cajas y máscaras que usa el cotejo de iOS; `ocr_numbers` no distingue "pendiente" de "sin números" | Lecturas completas, `ocr_status`, `ReceiptRecord`, correcciones del cotejo en el núcleo | M |
| 8 | Repeticiones dentro de `core/` | Rutas `header.x`/`cells.c.r` parseadas a mano en 4 lugares, plantilla por defecto 3 veces, conexión repetida | `ValuePath`, `FormTemplate::{contains,label}`, `connected_client()` | S |

Sólo Astra: el intérprete Rust duplica el JS del prototipo (propone WASM, decisión de
arquitectura) y hay copias menores en `server/` (inferencia de dígitos) y prototipos.
Fable no marca ⛔; Astra marca ⛔ los puntos 1 y 2 respecto del objetivo de "lógica
compartida". Ninguna propuesta cambia el significado de los contratos.

## Recomendación

1. **Etapa A (S, sólo núcleo + Android):** puntos 1 corto plazo, 2, 3, 4, 5 y 8, con
   pruebas en Rust y JVM. Corrige además las dos reglas divergentes (justificación de 5
   caracteres e imagen obligatoria dentro de `Capture::confirm`), que ya están en el
   contrato del flujo.
2. **Etapa B (M):** puntos 6 y 7, para que iOS migre una sola vez.
3. **Etapa C (Mac):** fase 6, iOS sobre el núcleo.
4. Postergar la sesión de captura única y el WASM para los prototipos.

## Preguntas para el autor

1. ¿Se hace la etapa A ahora y la B antes de la fase 6?
2. Doble carga con una categoría vacía: ¿"incompleta" (como el contrato y Rust) o 0 (como
   las apps hoy)? Recomendación: incompleta.
3. Textos de la app: ¿catálogo en `contracts/` (sirve también a la web) o dentro del núcleo?
   Recomendación: `contracts/`.
4. ¿WASM para que los prototipos web usen el mismo núcleo? Recomendación: más adelante.
