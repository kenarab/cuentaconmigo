# SPEC · Visión: una red ciudadana para cuidar el proceso democrático 2027

Estado: **visión redefinida por el autor el 31/10/2026; decisiones V-1 a V-4 pendientes.**
Esta SPEC está por encima de todas las demás: cada módulo se justifica por su aporte a esta visión.

## La idea en una frase

La acción política que millones de personas hacemos en redes de grandes empresas se
puede potenciar en una **red social ad hoc para cuidar la democracia**: un espacio
ciudadano y no partidario donde debatir, **llegar a consensos y decidir modalidades
de acción** para proteger el proceso electoral de 2027, en el que se elige presidente
y se renueva el Congreso.

**No es una herramienta de acción política partidaria, sino de cuidado del proceso
democrático.** Producto central: [civic-network](../civic-network/SPEC.md).

## Principios

1. **Cuidar el proceso, no competir en él.** No hacemos campaña ni promovemos
   candidaturas. Cuidamos las reglas de juego que comparten todas las fuerzas.
2. **Todos los partidos, en igualdad.** Interactuamos con los partidos políticos y
   admitimos a todos con las mismas herramientas, reglas y visibilidad.
3. **Consenso antes que acción.** Frente a las plataformas (o a cualquier actor) no
   actuamos directamente: toda acción es el resultado de discusiones y consensos
   registrados en la red. Las modalidades iniciales son ejemplos; pueden surgir otras.
4. **Herramientas propias, no las de las plataformas.** No dependemos de los botones
   de denuncia de las plataformas. Medimos y documentamos con herramientas propias,
   y la red decide qué hacer con esa evidencia.
5. **Evidencia verificable.** Capturas con hash y fecha, datos abiertos y metodología
   pública y reproducible.
6. **Sin amplificación paga.** En nuestra red no se compra alcance y el orden de los
   contenidos es transparente.
7. **Comunitario y abierto.** Código abierto, datos agregados abiertos y alianzas con
   la sociedad civil, el periodismo y la academia.
8. **Privacidad primero.** Mínimos datos. La afinidad política es un dato sensible
   (Ley 25.326) y no se le pide a nadie.
9. **La experiencia de usuario es fundamental.** Quien fiscaliza lo hace bajo presión
   y con poco tiempo. Se elige en lugar de tipear, se completa lo que ya se sabe y se
   minimizan pasos y errores. La UX se evalúa en cada decisión (instrucción del autor,
   31/10/2026).

## Qué se elige en 2027 (a confirmar en `docs/legal/`)

Presidente y vicepresidente (con posible segunda vuelta), renovación parcial de la
Cámara de Diputados y del Senado. Quedan **abiertas**: si habrá PASO, la elección
directa de parlamentarios del Mercosur y el calendario oficial.

## Ejes: herramientas que la red puede activar por consenso

La red (deliberación y consensos) es el centro. Los ejes son herramientas y
modalidades de acción que la comunidad decide usar:

| Eje | Qué cuida | Módulos (cada uno con su SPEC) |
| --- | --- | --- |
| **A. Plataformas** | Qué hacen las plataformas con la conversación electoral: uso indebido de publicidad electoral (desinformación viralizada con dinero de campaña), algoritmos, desinformación, cumplimiento de la veda y de sus propios compromisos | `platform-accountability` |
| **B. Desinformación** | Contenidos falsos virales sobre el proceso: detección, verificación y respuesta comunitaria; la evidencia alimenta al eje A | `misinformation-response` |
| **C. Campaña** | Gasto y publicidad declarada vs. observada, plazos legales de campaña, debates presidenciales obligatorios | `campaign-watch` |
| **D. Jornada y escrutinio** (cierre del proceso de auditoría ciudadana) | Telegramas y actas de cada mesa, cotejo con el escrutinio provisorio y el definitivo, proyección | `telegram-capture`, `amba-simulation` |
| **E. Propuestas y regulación** | La comunidad propone, discute y consolida iniciativas de regulación y de incidencia (por ejemplo, la cuenta de garantía electoral) | `civic-deliberation`, `reg-electoral-escrow` y las que surjan |

El escrutinio (D) cierra el proceso de auditoría ciudadana: es el final visible de un
trabajo que empieza meses antes, cuando la campaña ya está corriendo en las plataformas.
Las propuestas (E) atraviesan todo el ciclo y siguen después de la elección.

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

- V-1. Prioridad para la hackatón: propuesta, mostrar la **red** con una deliberación
  real en curso (por ejemplo, la cuenta de garantía electoral), una herramienta de
  evidencia del eje A y, para cerrar el proceso de auditoría ciudadana, el eje D
  (telegramas y simulación del AMBA).
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
2. Ningún módulo depende de las herramientas de denuncia de las propias plataformas,
   y ninguna acción externa ocurre sin un consenso registrado en la red.
3. Toda métrica sobre plataformas publica su metodología y sus datos agregados.
