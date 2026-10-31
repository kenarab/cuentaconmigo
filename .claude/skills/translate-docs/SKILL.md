---
name: translate-docs
description: Genera o actualiza las traducciones automáticas al inglés de los documentos del proyecto en translations/en/. Usar después de cambiar cualquier documento .md en español.
---

# Traducciones al inglés

Regla (AGENTS.md › Idioma): el español es la versión de referencia; cada documento
tiene una traducción automática en `translations/en/<misma ruta>`.

1. Listar los documentos modificados: `git diff --name-only <base>..HEAD -- '*.md'`
   (excluir `translations/`, `.claude/skills/` y archivos ya en inglés).
2. Para cada uno, traducir al inglés preservando estructura, tablas, enlaces y código.
   Ajustar los enlaces relativos para que apunten a las traducciones cuando existan.
3. Encabezado de cada traducción:
   ```
   > Automatic English translation of [`<ruta>`](<ruta relativa al original>)
   > at commit `<sha corto>`. The Spanish original prevails.
   ```
4. Borrar las traducciones de documentos eliminados.
5. Un commit propio: `Update English translations` + push (skill `sync`).
