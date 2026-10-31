# Contratos compartidos

Fuente independiente de plataforma para iOS, Android y el futuro backend
(ver `sdd/specs/mobile-platform/SPEC.md`). Cambiar una regla: primero el contrato
y sus vectores, después cada implementación.

- `schemas/capture.schema.json`: paquete de captura exportado (JSON Schema 2020-12).
- `templates/`: formularios declarativos. `generales-2023` (Presidente, generales
  del 22/10/2023) es la que usa la app; `balotaje-2015` coincide con las muestras de
  `data/ocr-samples/`; `demo-2027` es **ficticia** y sólo se usa en los vectores.
- `vectors/validation.json`: reglas de validación; resultados comparados como conjunto.
- `vectors/digits.json`: normalización de texto OCR a enteros.
- `flows/capture.flow.json`: flujo de captura como statechart declarativo, compartido por
  las presentaciones F-1/F-2/F-3 ([app-architecture](../sdd/specs/app-architecture/SPEC.md)).
  Semántica en `flows/README.md`, intérprete de referencia `flows/flow-machine.js`.
- `vectors/capture-flow.json`: transiciones esperadas del flujo. Para correr todos los
  vectores en JS: `node contracts/flows/run-vectors.js`.
- `examples/`: ejemplos ficticios válidos.

Vectores y ejemplos son ficticios. Las plantillas de 2015 y 2023 reproducen formularios
oficiales públicos (agrupaciones y filas, sin datos de mesas ni de personas), por
decisión del autor del 31/10/2026. Nunca agregar datos personales.
