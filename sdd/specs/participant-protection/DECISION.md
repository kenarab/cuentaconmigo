# DECISIÓN · Protección de participantes (consolidación del pipeline)

Fecha: 31/10/2026. Revisión: Astra (`checks/legal.astra.md`, `checks/spec.astra.md`).
**Decide: el autor junto con Andy** (PP-1 a PP-7 en `decisions/PREGUNTAS.md`).

| # | Lente | Bloqueo (⛔) | Propuesta de tratamiento |
| --- | --- | --- | --- |
| 1 | legal | Ocultar al aportante no protege a terceros visibles (nombres y firmas en las imágenes) ni evita que respaldos y patrones revelen opiniones políticas | Separar **evidencia preservada** (original con hash, acceso restringido) de **copia publicable** (derivada, con datos de terceros tapados y vínculo al hash del original); tratar los respaldos como datos sensibles |
| 2 | legal | Réplicas abiertas sin condiciones: propagan datos y frustran el retiro rápido | Replicar sólo datos agregados o disociados, con licencia y obligación de seguir las correcciones; definir responsable y canal de derechos |
| 3 | spec | No se distingue original de copia: quitar EXIF del original rompe el hash | Igual que 1: derivados con su propio hash y referencia al original (requiere cambio de contrato, PP-6) |
| 4 | spec | "No se puede identificar a nadie" es una garantía absoluta que no se puede verificar | Reemplazarla por criterios verificables: inventario de datos, prueba de incautación simulada con un modelo de atacante definido, y lista de lo que la persona revela por su cuenta (PP-7) |

⚠️ Además: veda y continuidad del servicio sin reglas operativas; "consenso transversal" depende de RC-2.

Recomendación: aplicar 1 a 4 en la SPEC después de que respondan PP-6 y PP-7.
