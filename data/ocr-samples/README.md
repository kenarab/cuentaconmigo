# Valores de telegramas para medir el OCR

Transcripción de 15 telegramas oficiales de escrutinio provisorio (balotaje 2015 y
PASO 2017) para comparar contra el OCR de [telegram-capture](../../sdd/specs/telegram-capture/SPEC.md).

**Los PDF no están en este repositorio** porque incluyen nombres, firmas y números de
documento (ver [AGENTS.md](../../AGENTS.md)). `manifest.json` indica de dónde obtener
cada uno y su SHA-256. Se guardan localmente en `data/private/ocr-samples/`, fuera de Git.

## Archivos

- `planilla-valores.csv`: una fila por celda (separador `;`).
- `planilla-cotejo.csv`: suma de cada columna contra los totales escritos.
- `manifest.json`: URL original, copia en Internet Archive, fecha y SHA-256 de cada PDF.

## Estado: borrador, sin confirmación humana

La transcripción la hizo Claude mirando las imágenes (`origen = borrador_ia`). Es una
lectura automática más, no una verdad de referencia, hasta que una persona la confirme
en `valor_confirmado` y `confirmado_por`. Para medir un OCR, usar solo celdas confirmadas.

## Columnas de `planilla-valores.csv`

- `como_figura`: lo escrito en el papel. `-` raya, `x` cruz, `_` vacía, `?` ilegible.
- `valor`: la interpretación numérica. Raya y cruz valen 0; vacía e ilegible quedan sin valor.
- `confianza`: autoevaluación de quien transcribió, no una medición.
- `referencia_2015`, `cruce_2015`: cotejo con la base comunitaria
  [Zequez/telegramas-balotaje-argentina-2015](https://github.com/Zequez/telegramas-balotaje-argentina-2015),
  que tampoco es una fuente oficial.

Las celdas "NO USAR" o tapadas por bloques negros no tienen fila.

## Inconsistencias de la muestra

Sirven para probar la validación. No indican una irregularidad: pueden ser errores de
carga o de lectura, y el escrutinio provisorio no es el resultado definitivo.

| Telegrama | Columna | Qué pasa |
| --- | --- | --- |
| `2015/060010004_0054.pdf` | PRES | Una agrupación vacía; total escrito 285, la suma da 69 |
| `2017/020840711D00167.pdf` | DIP | Una lista dice 8, pero el total de agrupaciones exige 81 |
| `2017/030120103_00767.pdf` | PRO | La suma da 241 y hay 236 sobres |
| `2017/040010005A00373.pdf` | DIP | Total escrito 230, pero 229 votantes y 229 sobres |
| `2017/030060051_00526.pdf`, `2017/030130124_00836.pdf` | Todas | Encabezado ilegible: sin total para cotejar |
