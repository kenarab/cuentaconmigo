# Contratos compartidos

Fuente independiente de plataforma para iOS, Android y el futuro backend
(ver `sdd/specs/mobile-platform/SPEC.md`). Cambiar una regla: primero el contrato
y sus vectores, después cada implementación.

- `schemas/capture.schema.json`: paquete de captura exportado (JSON Schema 2020-12).
- `templates/`: formularios declarativos. `demo-2027` es **ficticio**.
- `vectors/validation.json`: reglas de validación; resultados comparados como conjunto.
- `vectors/digits.json`: normalización de texto OCR a enteros.
- `examples/`: ejemplos ficticios válidos.

Todos los datos de este directorio son ficticios. Nunca agregar datos reales.
