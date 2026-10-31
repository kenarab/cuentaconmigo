# SPEC · Diagramación de formularios y alineación previa para la lectura en el servidor

Estado: **pedido del autor del 31/10/2026 ("si hay que hacer una configuración para saber
de dónde sacar los datos y una alineación previa, configuralo como SPEC; lo implementa el
server"); implementación inicial en `server/` con Tesseract.** Decisiones FL-1 a FL-5
pendientes. Fecha: 31/10/2026.
Depende de [assisted-review](../assisted-review/SPEC.md) (lecturas por celda con confianza
y ubicación) y de [scrutiny-backend](../scrutiny-backend/SPEC.md) (OCR en servidor).

## 1. Problema

La plantilla del formulario (`contracts/templates/*.json`) dice **qué** datos tiene un
telegrama (filas, encabezados), pero no **dónde** están en la hoja. Buscar cada número
"por cercanía" a su etiqueta falla con letra manuscrita, filas de distinta altura y fotos
torcidas: en las muestras de 2015 la primera prueba acertó 0 de 9 valores. Hace falta:

1. Una **diagramación** por modelo de formulario: dónde está cada celda en una imagen de
   referencia.
2. Una **alineación previa** de cada foto contra esa referencia, para llevar las celdas a
   la foto aunque esté movida, escalada o un poco rotada.

## 2. Contrato: `contracts/layouts/<formulario>.json`

Un archivo por modelo impreso (por elección y tipo de documento: el telegrama de 2015 no es
igual al de 2023). Coordenadas en píxeles de la **imagen de referencia** declarada.

```json
{
  "id": "balotaje-2015.telegrama",
  "templateId": "balotaje-2015",
  "documentType": "telegrama",
  "reference": { "width": 1275, "height": 2100, "source": "muestra oficial pública, sin datos personales en el archivo" },
  "anchors": [ { "text": "TELEGRAMA", "center": [319, 252] }, … ],
  "cells": [ { "ref": "cells.presidente.agrupacion-131", "box": [630, 865, 565, 118],
               "label": { "text": "131 ALIANZA FRENTE PARA LA VICTORIA", "box": [76, 860, 520, 40] } }, … ],
  "masks": [ { "kind": "firma", "box": [70, 1365, 1072, 300] }, … ]
}
```

- **anchors:** textos impresos que están en todos los ejemplares (títulos, encabezados de
  columna, nombres de filas especiales). Cuantos más y más repartidos por la hoja, mejor
  alineación. Nunca datos manuscritos.
- **cells:** caja de cada dato (`ref` igual que en assisted-review y en el paquete de
  captura) y caja de su identificador impreso (número y nombre de la agrupación), que la
  app dibuja al lado.
- **masks:** zonas con firmas, nombres y documentos de personas: se tapan en la vista de
  revisión y nunca se leen (assisted-review §2, participant-protection).
- La referencia es una **imagen pública** del formulario; el repositorio guarda sólo las
  coordenadas, no la imagen si tiene datos personales.

## 3. Alineación previa (servidor)

1. OCR de la página completa (texto impreso) con posiciones.
2. Para cada ancla, buscar la palabra que coincide (comparación aproximada: los impresos
   salen rotos, p. ej. "IMPUGNAD").
3. Con 3 o más anclas encontradas, estimar una **transformación afín** referencia → foto
   por mínimos cuadrados, descartar anclas con error alto (más de 2 % del ancho) y volver a
   estimar.
4. Calidad de alineación = error medio de las anclas en píxeles y cantidad de anclas usadas.
   Con menos de 3 anclas o error alto, la lectura se devuelve **sin valores** y con
   `alignment.ok = false` (la persona carga a mano); nunca se inventa una posición.
5. Llevar cada `cell.box` y `label.box` a la foto con la transformación y recortar.

Fotos muy en perspectiva (no planas) necesitarían una homografía (FL-2); el escáner nativo
del teléfono ya entrega la hoja recortada y plana, así que la afín alcanza para empezar.

## 4. Lectura de cada celda

- Recorte con un margen interior para no leer las líneas de la tabla; escala de grises,
  contraste y binarización.
- Motor de dígitos: Tesseract con lista blanca de dígitos (base actual, SB-2). La salida
  por celda es `{value, confidence, valueBox, cellBox, label}` (assisted-review §5).
- Raya, guion o celda vacía → `value: null` con `empty: true`: la persona decide si es 0.
- **Convención de "no leído":** el servidor devuelve **una entrada por cada celda de la
  diagramación**, se haya leído o no, con su `cellBox`. `value: null` y `empty: false` =
  no se pudo leer: la app dibuja un casillero vacío para completar a mano. `value: null`
  y `empty: true` = raya o celda en blanco: casillero con "—" que propone 0. Nunca se
  inventa un número para llenar el hueco.
- El motor es intercambiable: la diagramación y la alineación no dependen de Tesseract.
  Si la exactitud sobre manuscritos no alcanza, el reemplazo es un clasificador de dígitos
  sobre los mismos recortes (scrutiny-backend §5.3).

## 5. API

`POST /v1/readings?templateId=balotaje-2015` con la imagen (`image/jpeg`) →
`200 {origin: "ocr-server", layoutId, alignment: {ok, anchorsUsed, meanErrorPx},
image: {width, height}, fields: [...], notFound: [...]}`. No guarda la imagen (RV-2 ★):
sólo lee y responde. Requiere token de dispositivo.

### Celdas sin lectura: marca "?" (pedido del autor, 31/10/2026)

Cada celda de `POST /v1/readings` lleva `status` y `text`:

| `status` | Cuándo | `text` | La app muestra |
| --- | --- | --- | --- |
| `read` | se leyó con confianza ≥ 0,3 | el número | el valor sugerido |
| `empty` | no hay tinta | `""` | celda vacía (o cero, según AS-6) |
| `unreadable` | hay escritura, pero no se reconoció o la confianza es < 0,3 | `"?"` | **el cuadro vacío para completar** |

En las ilegibles, `value` y `confidence` quedan sólo como pista. `pending` lista las celdas
que la persona tiene que completar: las ilegibles más las esperadas que no se pudieron
ubicar (`notFound`). `"?"` es la misma marca de ilegible que usa la planilla de
`data/ocr-samples`. El contrato está en `contracts/api/scrutiny-v1.openapi.json`.

## 6. Medición

`server/eval_readings.py` compara las lecturas con los valores transcriptos de
`data/ocr-samples/planilla-valores.csv` (muestras de Andy, fuera de Git) y publica:
anclas encontradas por imagen, error de alineación, exactitud por celda y calibración de la
confianza (de las lecturas con confianza ≥ 0,8, qué porcentaje es correcto).

## 7. Decisiones pendientes

| ID | Decisión | Opciones (★ = recomendada) |
| --- | --- | --- |
| FL-1 | Cómo se crean las diagramaciones | ★ A mano sobre una imagen de referencia, con una herramienta HTML que dibuja cajas y exporta el JSON · detección automática de la grilla de la tabla |
| FL-2 | Transformación | ★ Afín (escáner plano) · homografía (fotos en perspectiva) |
| FL-3 | Formularios en la hackatón | ★ Telegrama del balotaje 2015 (hay muestras) y generales 2023 cuando haya una imagen pública de referencia · todos los modelos 2015–2023 |
| FL-4 | Motor de dígitos | ★ Tesseract como base medida, clasificador propio si no alcanza · motor externo en la nube (descartado por datos personales) |
| FL-5 | Lectura con mala alineación | ★ Sin valores y aviso "cargá a mano" · leer igual con confianza mínima |

## 8. Criterios de aceptación

1. Las diagramaciones validan contra su esquema y cada `ref` existe en la plantilla.
2. En las muestras del balotaje 2015, la alineación encuentra al menos 3 anclas y el error
   medio es menor a 1 % del ancho en todas las imágenes.
3. Una foto rotada 3° o escalada 80 % se alinea con el mismo criterio (prueba sintética).
4. Ninguna zona de `masks` se lee ni se devuelve.
5. La exactitud por celda y la calibración quedan registradas en
   `sdd/specs/form-layouts/VERIFICATION.md` antes de optimizar el motor.
