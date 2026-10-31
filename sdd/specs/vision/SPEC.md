# SPEC · Visión: auditoría ciudadana integral del proceso electoral 2027

Estado: **visión definida por el autor el 31/10/2026; prioridades y decisiones V-1 a V-3 pendientes.**
Esta SPEC está por encima de todas las demás: cada módulo se justifica por su aporte a esta visión.

## La idea en una frase

Las elecciones en las que se elige presidente y se renueva el Congreso son la
actividad más importante de la democracia, y **no pueden ser un negocio más para
las plataformas**. CuentaConmigo construye herramientas ciudadanas **externas e
independientes de las plataformas** para auditar todo el proceso electoral y
generar presión pública que ponga a las plataformas al servicio de la democracia.

## Principios

1. **Herramientas externas, no denuncias internas.** No buscamos usar los botones de
   "denunciar" que diseñan las plataformas. Construimos medición, evidencia y
   escrutinio público propios, que las plataformas no controlan.
2. **Presión pública basada en evidencia.** Cada afirmación sobre una plataforma se
   apoya en evidencia verificable (capturas con hash y fecha, datos abiertos,
   metodología pública y reproducible).
3. **No partidario.** Auditamos el proceso y a las plataformas, no a los votantes ni a
   un partido en particular. Las mismas reglas valen para todos los actores.
4. **Integral.** Cubrimos todo el ciclo electoral, no sólo la noche del escrutinio.
5. **Comunitario y abierto.** Código abierto, datos agregados abiertos, voluntariado
   organizado y alianzas con la sociedad civil, el periodismo y la academia.
6. **Privacidad primero.** La ciudadanía que aporta datos lo hace con consentimiento
   informado, con minimización de datos y sin exponer a nadie (Ley 25.326).

## Qué se elige en 2027 (a confirmar en `docs/legal/`)

Presidente y vicepresidente (con posible segunda vuelta), renovación parcial de la
Cámara de Diputados y del Senado. Quedan **abiertas**: si habrá PASO, la elección
directa de parlamentarios del Mercosur y el calendario oficial.

## Ejes y módulos

| Eje | Qué audita | Módulos (cada uno con su SPEC) |
| --- | --- | --- |
| **A. Plataformas** (eje central) | Qué hacen las plataformas con la conversación electoral: uso indebido de publicidad electoral (desinformación viralizada con dinero de campaña), algoritmos, desinformación, cumplimiento de la veda y de sus propios compromisos | `platform-accountability` |
| **B. Desinformación** | Contenidos falsos virales sobre el proceso: detección, verificación y respuesta comunitaria; la evidencia alimenta al eje A | `misinformation-response` |
| **C. Campaña** | Gasto y publicidad declarada vs. observada, plazos legales de campaña, debates presidenciales obligatorios | `campaign-watch` |
| **D. Jornada y escrutinio** (cierre del proceso de auditoría ciudadana) | Telegramas y actas de cada mesa, cotejo con el escrutinio provisorio y el definitivo, proyección | `telegram-capture`, `amba-simulation` |

El orden refleja la prioridad conceptual: el escrutinio es el cierre visible de un
trabajo que empieza meses antes, cuando la campaña ya está corriendo en las plataformas.

## Núcleo compartido: evidencia ciudadana

Todos los ejes necesitan lo mismo: **capturar algo, fecharlo, hashearlo, preservarlo
y poder mostrarlo**, ya sea un telegrama, una publicación viral, un anuncio político
o la respuesta de una plataforma. El paquete de evidencia de `contracts/` se generaliza
para cualquier tipo de evidencia (D-EV-1, pendiente) y el telegrama pasa a ser uno de esos tipos.

## Línea de tiempo del proceso (a precisar con el calendario oficial)

```
pre-campaña ── campaña ── debates ── veda ── jornada ── escrutinio provisorio ── definitivo ── (2ª vuelta)
   A, C           A, B, C     A, C       A, B     B, D          D                     D           A, B, D
```

## Decisiones pendientes del autor

- V-1. Prioridad de construcción para la hackatón: propuesta, mostrar el **eje A**
  (observatorio de plataformas) con un caso concreto y cerrar con el **eje D**
  (prototipo de telegramas y simulación del AMBA) como cierre del proceso de auditoría ciudadana.
- V-2. ¿Nombre y marca? "CuentaConmigo" funciona para todo el proceso
  ("contá conmigo para cuidar la elección"); confirmar.
- V-3. Alianzas a buscar: organizaciones de chequeo, sociedad civil, universidades
  y observatorios de medios. La decisión y el contacto son del autor.

## Posicionamiento legal (decisión V-4, pendiente)

Según el relevamiento legal, el "acompañamiento cívico" de la justicia electoral
(CNE, Acordada 128/11, texto completo sin verificar) exige organizaciones sin fines
de lucro y sin vínculo partidario. Un proyecto que se apoya en fiscales partidarios
no encaja en ese rol tal como está planteado. Opciones:

1. Herramienta abierta que cualquier fiscal de cualquier fuerza pueda usar, sin
   ser observador acreditado (la app sólo registra documentos que el fiscal ya recibe).
2. Constituir o aliarse con una organización sin fines de lucro y sin vínculo
   partidario que se acredite como observadora.
3. Las dos: la organización audita las plataformas (ejes A–C) y la herramienta del
   eje D queda abierta a todos los fiscales.

## Criterios de aceptación de la visión

1. Cada SPEC de módulo enlaza a esta visión e indica su eje.
2. Ningún módulo depende de las herramientas de denuncia de las propias plataformas.
3. Toda métrica sobre plataformas publica su metodología y sus datos agregados.
