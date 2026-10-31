---
name: sdd-change
description: Flujo SDD para cualquier cambio de comportamiento, interfaz o regla del proyecto CuentaConmigo. Usar antes de implementar una funcionalidad, corregir un comportamiento o agregar un módulo.
---

# Cambio guiado por SPEC

1. Ejecutar la skill `sync`.
2. Identificar la SPEC en `sdd/specs/<id>/`. Si no existe, crearla con `SPEC.md`
   (problema, alcance, decisiones vigentes/pendientes, criterios de aceptación,
   preguntas abiertas), `PLAN.md`, `tasks.json` y `VERIFICATION.md`.
3. Escribir o actualizar la SPEC **antes** del código. Decisiones de arquitectura e
   instalaciones: preguntar al autor; dejarlas como pendientes en la SPEC.
4. Si toca reglas compartidas entre plataformas, usar la skill `contract-change`.
5. Pedir el chequeo de `electoral_counsel` (skill `role-check`) sobre la SPEC: es
   obligatorio para todo cambio. Un ⛔ frena la integración hasta que decida el autor.
6. Indicar qué otros chequeadores requiere según la matriz de
   `sdd/specs/multiagent-system/SPEC.md` (mientras sea propuesta, mencionarlo).
7. Commit atómico de la SPEC + push. Luego implementar en commits atómicos, cada uno
   verificado y pusheado.
8. Registrar en `VERIFICATION.md`: fecha, revisión, comando, resultado y qué queda
   pendiente (p. ej. prueba en dispositivo). Autocontrol ≠ revisión independiente.
9. Regenerar traducciones con la skill `translate-docs` en un commit propio.

Español para documentos y discusión; inglés para código y mensajes de commit.
