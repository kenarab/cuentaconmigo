# VERIFICACIÓN · Diagramaciones y alineación previa

## 31/10/2026 · Claude Code (autocontrol, sin revisión independiente) · línea de base

Comando: `python3 server/eval_readings.py` (Tesseract 5.5.4, spa; Pillow 12.1).
Muestras: los 3 telegramas del balotaje 2015 de `data/ocr-samples` (Andy), 9 valores
transcriptos. Valores todavía sin confirmar por personas (`borrador_ia`).

| Criterio | Resultado |
| --- | --- |
| 2. Alineación (≥ 3 anclas, error < 1 % del ancho) | ✅ 21, 20 y 18 anclas; error medio 0,5 / 2,0 / 0,3 px (ancho 1275) |
| Elige la diagramación correcta entre los dos modelos de 2015 | ✅ modelo A para distrito 01, modelo B para distrito 06 |
| Exactitud por celda (manuscrito, Tesseract) | ⚠️ 2 de 9 |
| Calibración (confianza ≥ 0,8) | ⚠️ 2 lecturas, 1 correcta: la confianza de Tesseract no sirve todavía como "más negro = más seguro" |
| 3. Foto rotada o escalada | ⏳ falta la prueba sintética |
| 4. Zonas `masks` sin leer | ✅ no se leen (sólo se devuelven sus cajas) |

Conclusión: la diagramación y la alineación funcionan; Tesseract lee mal los dígitos
manuscritos (p. ej. "1" escrito como un trazo curvo). Siguiente paso (FL-4): clasificador
de dígitos sobre los mismos recortes, o calibrar la confianza por motor antes de usarla
para el tono de los números en la app.
