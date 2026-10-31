# Chequeo electoral_counsel (legal, datos personales y ciberseguridad) · amba-simulation

## 31/10/2026

> No es asesoramiento legal ni de seguridad profesional.

### 1. Alcance

- Revisión `1dd5c8f`. `sdd/specs/amba-simulation/SPEC.md`,
  `design/prototypes/simulacion-amba/index.html` (leído completo), `.gitignore`
  (`data/private/` excluido; `git ls-files data/private` vacío: verificado hoy).
- Norma verificada hoy: Código Electoral art. 71 inc. h (Infoleg texto actualizado).

### 2. Modelo de amenazas (resumen)

- **Activos:** resultados oficiales por mesa 2023 (públicos, sin datos personales);
  muestra de imágenes oficiales de telegramas/actas 2023 (con nombres, firmas y fiscales
  por partido) en `data/private/`; credibilidad del proyecto.
- **Actores:** quien recorta una captura de la demo y la presenta como "proyección" de
  una elección en curso o como prueba de fraude; quien obtiene la carpeta privada.
- **Superficie:** la página estática (carga de JSON local), capturas de pantalla, la
  carpeta `data/private/` en la máquina del autor.

### 3. Hallazgos

| # | Sev. | Hallazgo | Base / control |
| --- | --- | --- | --- |
| L1 | ✅ | Reproducir una elección terminada no está alcanzado por el art. 71 inc. h, que rige "durante la realización del comicio y hasta tres horas después de su cierre". Banner permanente "SIMULACIÓN · reproducción de las generales 2023 · no es una proyección de una elección en curso" presente en el prototipo. | Art. 71 inc. h verificado; aplicación a 2023: interpretación razonable. |
| L2 | ✅ | Resultados por mesa: dato público sin datos personales; reutilización respaldada por Ley 27.275 arts. 1, 2 y 32 (verificado en MARCO_LEGAL). Procedencia con URL, fecha y SHA-256 documentada. | — |
| L3 | ✅ | Neutralidad: listas A–E por `agrupacion_id` ascendente, mismo método para todas; los nombres reales quedan en datos. Los colores de la paleta no remiten a partidos (verificado en el CSS). | AGENTS.md. |
| L4 | ⚠️ | **Imágenes oficiales 2023 en `data/private/`:** contienen nombres, firmas y fiscales asociados a partidos (dato sensible indirecto, Ley 25.326 arts. 2 y 7 inc. 3, verificados). Fuera de Git es correcto, pero falta: finalidad documentada, plazo de borrado y no proyectarlas sin tapar. | Control: muestra mínima; borrar o tapar tras la hackatón; disco cifrado; nunca en capturas de la demo. |
| L5 | ⚠️ | **Atribución de licencias:** los polígonos de PBA son CC BY 4.0 (según la SPEC); el prototipo no muestra atribución. Licencia de `comunas.geojson` de CABA y términos de los datos de DINE: **a verificar**. | Agregar pie "Fuentes: DINE (resultados provisorios 2023), PBA datos abiertos (CC BY 4.0), GCBA datos abiertos". |
| L6 | ⚠️ | **Riesgo de uso fuera de contexto:** el panel muestra "Oficial 2023" que en realidad es el **provisorio** (la nota lo aclara, la cabecera de la tabla no). Diferencias entre provisorio y definitivo pueden alimentar narrativas de fraude. | Rotular la columna "Provisorio 2023" y evitar la palabra "error" sin contexto ("diferencia con el provisorio"). |
| S1 | ⚠️ bajo | `innerHTML` con valores del JSON (`l.letter`, números) en `render()`: XSS si alguien carga un archivo manipulado. Riesgo bajo (archivo local). | Usar `textContent`/creación de nodos (ASVS V5 codificación de salida). |
| S2 | ✅ | Sin dependencias externas ni teselas; corre offline; datos sólo locales. | — |

### 4. Alternativas (L4)

1. Muestra mínima de imágenes, tapadas en el momento de incorporarlas; originales
   borrados tras la hackatón. Menor riesgo.
2. Sólo imágenes tapadas para la demo; originales cifrados con plazo de borrado.
3. Imágenes completas en `data/private/` sin plazo (actual): mayor riesgo.

### 5. Recomendaciones

1. Pie de atribución de fuentes y licencias (L5).
2. Rotular "Provisorio 2023" (L6).
3. Documentar finalidad y fecha de borrado de las imágenes 2023 (L4).
4. Reemplazar `innerHTML` por nodos (S1).

### 6. No verificado

- Licencias de comunas CABA y términos de uso de la descarga DINE.
- Que las imágenes de 2023 se hayan obtenido de una publicación oficial vigente.

### Veredicto

**⚠️ leve** (cercano a ✅): sin ⛔. Riesgo principal: imágenes 2023 con datos de
fiscales y autoridades, y uso de la demo fuera de contexto.
