---
name: role-check
description: Ejecuta el chequeo de un rol (legal, electoral, datos personales, seguridad, neutralidad, UX, trust & safety) sobre una SPEC o un cambio y produce un informe con alternativas. Usar cuando se pida chequear, auditar o revisar una propuesta desde un rol.
---

# Chequeo por rol

Estructura de roles: `sdd/specs/multiagent-system/SPEC.md` (propuesta) y
`.agents/roles/` (vigente).

1. Leer AGENTS.md, el archivo del rol y la SPEC/diff a revisar. Anotar la revisión (`git rev-parse --short HEAD`).
2. Trabajar en **sólo lectura** sobre el código. No contactar a nadie externo.
3. Escribir `sdd/specs/<id>/checks/<rol>.md`:
   1. Alcance revisado (revisión y archivos).
   2. Hallazgos con severidad ⛔ bloqueo / ⚠️ riesgo / ✅ ok, cada uno con fuente
      (artículo, archivo:línea, URL con fecha de acceso).
   3. **Al menos dos alternativas** por cada ⚠️ o ⛔, con costo y riesgo.
   4. Qué no se pudo verificar.
4. Mantener neutralidad partidaria. Para lo legal, partir de `docs/legal/MARCO_LEGAL.md`
   y aclarar que no es asesoramiento legal.
5. Commit atómico del informe + push. Lanzar subagentes sólo si el autor lo pidió y
   dentro del límite de agentes activos.
