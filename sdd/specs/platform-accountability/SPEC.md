# SPEC · Eje A: plataformas al servicio de la democracia

Estado: **propuesta; decisiones P-1 a P-4 pendientes del autor.** Fecha: 31/10/2026.
Visión: [sdd/specs/vision/SPEC.md](../vision/SPEC.md).

## Problema

Durante la campaña, la conversación electoral ocurre dentro de plataformas privadas
que deciden qué se ve, qué publicidad se vende y a quién, y qué hacen (o no) con la
desinformación. Hoy la única vía que ofrecen a la ciudadanía es denunciar contenidos
con sus propias herramientas, sin saber qué pasa después. **Queremos medir desde
afuera lo que hacen y convertir esa medición en presión pública.**

## Lo que no hacemos

- No usamos los botones de denuncia de las plataformas como estrategia.
- No pedimos que se borren publicaciones de personas. Exigimos transparencia y que
  las plataformas cumplan la ley y sus propios compromisos.
- No exponemos a usuarios particulares. El foco está en el comportamiento de las
  plataformas y en datos agregados.

## Herramientas externas propuestas

| # | Herramienta | Qué mide | Cómo obtiene los datos (sin depender de la buena voluntad de la plataforma) |
| --- | --- | --- | --- |
| A1 | **Archivo de evidencia viral** | Contenidos electorales virales: cómo crecen y qué hace la plataforma (nada, etiqueta, reduce alcance, elimina) y en cuánto tiempo | Voluntarios capturan URL, imagen, fecha y métricas visibles, con hash. Re-chequeo periódico automático del estado público de la URL |
| A2 | **Monitor de publicidad política** | Anuncios electorales, gasto, segmentación y anuncios durante la veda | Bibliotecas de anuncios públicas de cada plataforma, contrastadas con anuncios observados por voluntarios (A3) y con las rendiciones de gastos de campaña |
| A3 | **Panel ciudadano de exposición** (donación de datos) | Qué le muestran los algoritmos a distintas personas: recomendaciones, anuncios y contenido electoral | Personas voluntarias donan, con consentimiento informado, capturas o sus propios datos. Explorar el **derecho de acceso** de la Ley 25.326 para pedirle a cada plataforma los datos que tiene de uno |
| A4 | **Tablero público de plataformas** | Cumplimiento comparado: transparencia publicitaria, veda, tiempos de respuesta, compromisos asumidos ante la justicia electoral, acceso a datos para investigación | Resultados de A1–A3 con metodología pública y reproducible |
| A5 | **Caja de herramientas de presión** | — | Informes con evidencia, cartas abiertas, pedidos de acceso a la información pública (Ley 27.275) sobre acuerdos del Estado con plataformas, presentaciones ante organismos, kit de prensa. **Todo contacto externo lo decide el autor** |

A1 reutiliza el núcleo de evidencia de la app (hash, fecha, cadena de custodia);
ver D-EV-1 en la visión.

## Métricas (borrador, cada una con definición pública)

- Tiempo hasta la primera acción visible de la plataforma sobre contenido falso
  verificado por fuentes independientes.
- Porcentaje de contenido falso verificado que sigue disponible sin etiqueta a las 24, 48 y 72 h.
- Anuncios electorales observados por el panel que **no** aparecen en la biblioteca
  de anuncios de la plataforma.
- Anuncios electorales activos durante la veda.
- Diferencia entre lo que la plataforma dice que hace (políticas y compromisos) y lo
  que se observa.

Todas se miden por igual para contenido de cualquier fuerza política (neutralidad auditable).

## MVP para la hackatón (propuesta)

**A1 + A4 mínimo:** cargar evidencia de contenidos virales (web y app), re-chequear
su estado automáticamente y mostrar un tablero por plataforma con el tiempo de
respuesta. Es demostrable en vivo, no depende de APIs privadas y comparte el núcleo
de evidencia con la app de telegramas.

## Riesgos y chequeos requeridos

| Riesgo | Rol que chequea |
| --- | --- |
| Términos de servicio, scraping y bloqueos | legal_analyst, security_analyst |
| Afirmaciones sobre una plataforma sin evidencia suficiente (difamación) | legal_analyst, reviewer |
| Datos de quienes donan sus datos y de terceros que aparecen en capturas | data_protection_officer |
| Sesgo en qué contenido se carga (todo de un solo sector) | neutrality_auditor |
| Brigadas que inunden el archivo con falsos positivos | trust_safety_analyst, red_team |

## Decisiones pendientes

- P-1. Plataformas a cubrir primero. Propuesta: las de mayor uso en Argentina para
  política (familia Meta, X, TikTok, YouTube); WhatsApp y Telegram con un método
  especial, porque su contenido no es público.
- P-2. ¿Qué herramientas entran a la hackatón? Propuesta: A1 + A4 mínimo.
- P-3. Plataforma técnica de A1/A4: web y backend sin decidir (ver mobile-platform D-003).
- P-4. Explorar el pedido de datos personales a plataformas (derecho de acceso)
  como acción colectiva: requiere una opinión legal.

## Criterios de aceptación

1. Ninguna herramienta usa los mecanismos de denuncia de las plataformas como insumo principal.
2. Cada métrica tiene una definición, una fuente y datos agregados descargables.
3. Chequeos legal, de datos personales y de neutralidad registrados antes de publicar resultados.
