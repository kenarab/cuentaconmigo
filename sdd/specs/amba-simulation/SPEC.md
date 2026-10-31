# SPEC · Simulación geolocalizada del AMBA: proyección con pocos datos

Estado: **propuesta; decisiones S-1 a S-3 pendientes del autor.** Fecha: 31/10/2026.
Eje: **D. Jornada y escrutinio** de la [visión](../vision/SPEC.md), el cierre visible del proceso.

## Objetivo

Mostrar, en un mapa del Área Metropolitana de Buenos Aires, cómo los fiscales van
cargando telegramas y cómo una proyección del resultado se estabiliza con muy pocos
datos. Sirve para la demo de la hackatón y para explicar por qué cada carga suma.

## Alcance

1. Mapa del AMBA (CABA y partidos del conurbano) con los locales de votación como puntos.
2. Generador de **datos sintéticos**: electores por mesa y resultados de listas
   ficticias (Lista A/B/C, blanco, nulos) con variación geográfica plausible.
   Ningún dato electoral real. La pantalla muestra "SIMULACIÓN" en todo momento.
3. Llegada de cargas en el tiempo, con velocidad y **sesgo de llegada** configurables
   (por ejemplo, CABA reporta antes que el tercer cordón).
4. Proyección en vivo:
   - ingenua: suma simple de las mesas cargadas;
   - estratificada: por municipio o sección, ponderada por electores;
   - con intervalo de confianza que se achica a medida que llegan datos.
5. Panel: % de mesas cargadas, proyección vs. "verdad" sintética, error y amplitud
   del intervalo. Controles de reproducir, pausar, velocidad y semilla.
6. Reproducible: la misma semilla produce la misma simulación.

Fuera de alcance: datos reales, predicción de elecciones reales, integración con la app.

## Decisiones pendientes

| ID | Decisión | Opciones |
| --- | --- | --- |
| S-1 | Plataforma | Web estática (MapLibre GL + JS, sin backend) · notebook Python · SwiftUI MapKit |
| S-2 | Geografía | Polígonos oficiales de partidos y comunas (IGN, datos abiertos de CABA/PBA) · puntos sintéticos dentro de cada polígono · locales de votación reales si hay un dataset público (ver Q1) |
| S-3 | Modelo estadístico | Estratificado por municipio con intervalos (propuesta) · postestratificado con regresión · bayesiano jerárquico |

Recomendación: S-1 web estática (se puede mostrar en un proyector, cualquiera la
abre con un link y no requiere instalar nada en el teléfono); S-2 polígonos oficiales
con puntos sintéticos; S-3 estratificado, que es explicable en un minuto.

## Criterios de aceptación

1. Con 5 % de las mesas cargadas sin sesgo, la proyección estratificada queda a
   menos de 2 puntos de la verdad sintética en la mayoría de las semillas (a medir).
2. Con sesgo de llegada, la demo muestra que la suma ingenua se desvía y la
   estratificada no.
3. Corre offline desde un archivo o un link, con datos ficticios marcados como tales.
4. Revisión de neutralidad: las listas ficticias no remiten a partidos reales.

## Preguntas abiertas

- Q1. ¿Hay un dataset público y reciente de locales de votación con coordenadas y
  cantidad de mesas? Asignar a electoral_analyst.
- Q2. ¿Qué definición de AMBA usamos: CABA + 24 partidos o la región ampliada?
