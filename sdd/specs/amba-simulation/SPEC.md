# SPEC · Simulación geolocalizada del AMBA: proyección con pocos datos

Estado: **datos reales de 2023 decididos por el autor el 31/10/2026; S-1 y S-3
pendientes.** Eje: **D. Jornada y escrutinio** de la [visión](../vision/SPEC.md),
el cierre visible del proceso.

## Objetivo

Mostrar, en un mapa del Área Metropolitana de Buenos Aires, cómo los fiscales van
cargando telegramas y cómo una proyección del resultado se estabiliza con muy pocos
datos. Se **reproduce una elección real ya terminada** (generales 2023) para la demo de
la hackatón y para explicar por qué cada carga suma.

## Decisión del autor · 31/10/2026

La versión anterior exigía sólo datos sintéticos. El autor aclaró que era un error
y que nunca lo autorizó. Desde ahora:

- **Datos:** resultados oficiales **por mesa** de las elecciones generales del
  **22/10/2023**, categoría **Presidente y Vicepresidente**.
- **Región:** **CABA + 24 partidos** del conurbano (responde Q2).
- **Telegramas y actas de ejemplo:** además de los resultados, una muestra de imágenes
  oficiales de 2023 del AMBA para mostrar qué se captura y para probar la carga.
  Contienen nombres y firmas de autoridades de mesa y fiscales: se guardan en
  `data/private/`, nunca en Git, y no se muestran en público sin tapar esos datos
  (Ley 25.326). Los resultados por mesa no contienen datos personales.
- **Presentación:** en la demo las fuerzas se muestran como **Lista A/B/C…** (opción
  elegida por el autor). El mapeo a las fuerzas reales queda en los datos, fuera de
  la pantalla.

## Alcance

1. Mapa del AMBA (CABA y los 24 partidos) con los locales de votación o las secciones
   y circuitos como puntos.
2. **Datos reales de 2023:** electores, votantes y votos por agrupación, blanco y
   nulos de cada mesa, con su procedencia (URL oficial, fecha de descarga y SHA-256
   del archivo). Lo descargado no se modifica; la normalización produce un archivo
   derivado y reproducible. La muestra de telegramas y actas guarda lo mismo
   (URL, mesa, fecha y SHA-256) por imagen.
3. Llegada de cargas en el tiempo, con velocidad y **sesgo de llegada** configurables
   (por ejemplo, CABA reporta antes que el tercer cordón).
4. Proyección en vivo:
   - ingenua: suma simple de las mesas cargadas;
   - estratificada: por municipio o sección, ponderada por electores;
   - con intervalo de confianza que se achica a medida que llegan datos.
5. Panel: % de mesas cargadas, proyección vs. **resultado oficial 2023 de las mismas
   mesas**, error y amplitud del intervalo. Controles de reproducir, pausar,
   velocidad y semilla.
6. Reproducible: la misma semilla produce el mismo orden de llegada.
7. La pantalla indica en todo momento "SIMULACIÓN · reproducción de las generales 2023".

Fuera de alcance: descarga masiva de imágenes, predicción de elecciones futuras,
integración con la app.

## Decisiones pendientes

| ID | Decisión | Opciones |
| --- | --- | --- |
| S-1 | Plataforma | Web estática (MapLibre GL + JS, sin backend) · notebook Python · SwiftUI MapKit |
| S-2 | Geografía | Polígonos oficiales de partidos y comunas (IGN, datos abiertos de CABA/PBA) · puntos dentro de cada polígono · locales de votación reales si hay un dataset público (ver Q1) |
| S-3 | Modelo estadístico | Estratificado por municipio con intervalos (propuesta) · postestratificado con regresión · bayesiano jerárquico |

Recomendación: S-1 web estática (se puede mostrar en un proyector, cualquiera la
abre con un link y no requiere instalar nada en el teléfono); S-2 polígonos oficiales;
S-3 estratificado, que es explicable en un minuto.

Propuesta de almacenamiento (a confirmar por el autor): los archivos oficiales
descargados quedan en `data/private/` (fuera de Git, por tamaño), y en Git sólo un
manifiesto con URL, fecha y SHA-256 y el script que los normaliza.

## Restricción legal

El Código Electoral (art. 71 inc. h) prohíbe publicar proyecciones durante los
comicios y hasta tres horas después del cierre. La reproducción de 2023 no está
alcanzada porque esa elección terminó, pero no debe presentarse como proyección de
una elección en curso. Cualquier uso con datos reales el día de la elección debe
respetar esa ventana. Pendiente: chequeo de `electoral_counsel` de este cambio.

## Criterios de aceptación

1. Con 5 % de las mesas cargadas sin sesgo, la proyección estratificada queda a
   menos de 2 puntos del resultado oficial 2023 en la mayoría de las semillas (a medir).
2. Con sesgo de llegada, la demo muestra que la suma ingenua se desvía y la
   estratificada no.
3. Corre offline desde un archivo o un link.
4. Las sumas por partido y totales del archivo normalizado coinciden con los totales
   oficiales publicados para el AMBA.
5. Neutralidad: el mismo método y las mismas métricas se aplican a todas las fuerzas.

## Preguntas abiertas

- Q1. ¿Hay un dataset público de locales de votación de 2023 con coordenadas y
  cantidad de mesas? Asignar a electoral_analyst.
- Q2. Respondida por el autor: CABA + 24 partidos.
