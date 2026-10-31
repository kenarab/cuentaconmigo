# Ficha HackDash · CuentaConmigo

## Título

CuentaConmigo

## Tagline

Potenciamos tu voz en las redes y fortalecemos la democracia.

## Descripción (convocatoria) · versión final del autor, 31/10/2026

Millones de ciudadanos opinamos, discutimos y nos organizamos todos los días en las
redes sociales, pero con las reglas y algoritmos de las plataformas. CuentaConmigo es
una red social ciudadana y no partidaria para cuidar el proceso democrático de los
procesos electorales en forma íntegra. Potencia el esfuerzo individual para que nuestra
incidencia en las redes corporativas y sus algoritmos sea más efectiva y, sobre todo,
para fortalecer la capacidad de la propia democracia. Ahí debatimos, llegamos a
consensos y decidimos juntos cómo actuar: auditar campañas de desinformación pagadas
con dinero electoral, proponer regulaciones como congelar el gasto de campaña en
plataformas hasta después de la elección, usar agentes de IA que monitoreen en tiempo
real el comportamiento de las plataformas, son solo algunas opciones que se
disponibilizarán. Todos los partidos políticos participan en igualdad de condiciones,
y cualquier acción frente a las plataformas surge de consensos.

Para cerrar el proceso de auditoría ciudadana, una app permite que fiscales y
autoridades de mesa escaneen el telegrama y/o acta de su mesa, y una simulación del
AMBA muestra cómo se armaría la proyección con muy pocos datos.

Buscamos devs, gente de datos, diseño, derecho, periodismo y comunicación: contamos
con vos para cuidar la democracia entre todos.

## Estado

Prototipando

## Skills buscados

redes sociales y participación ciudadana · análisis de plataformas y publicidad · agentes de IA · datos y estadística · backend · iOS/Android ·
OCR/visión · mapas · UX · derecho electoral y datos personales · fact-checking · comunicación

## Tags

democracia, escrutinio, participación ciudadana, elecciones 2027, auditoría ciudadana,
fiscalización, transparencia, desinformación, plataformas digitales, consenso,
red social ciudadana, agentes de IA, civic tech, datos abiertos, Argentina

Versión corta (8): democracia, escrutinio, participación ciudadana, auditoría ciudadana,
desinformación, plataformas digitales, civic tech, elecciones 2027

## Imagen

`design/cover/cover.png` (1200×630).

## Qué se entrega en la hackatón (31/10/2026)

- **App iOS nativa (SwiftUI)** para fiscales y autoridades de mesa: escaneo del
  telegrama o acta, identificación de la mesa con listas en cascada, carga y validación,
  confirmación como evidencia con SHA-256, envío al servidor con comprobante encadenado
  y tres diseños de carga para comparar (F-1, F-2, F-3). Probada en un iPhone 12 Pro.
- **Servidor de escrutinio** (`server/`): ingesta de capturas con evidencia inmutable,
  OCR con Tesseract y lectura por celda alineada a la diagramación del formulario
  (`POST /v1/readings`): 18–21 anclas impresas, error de 0,3 a 2 px. La lectura de
  dígitos manuscritos está medida como línea de base (2/9) para mejorar.
- **Simulación del AMBA** (`design/prototypes/simulacion-amba/`): 29.962 mesas reales de
  las generales 2023; muestra cómo la proyección se estabiliza con pocas mesas
  (cobertura del IC 95 % medida: 92,5–96 %).
- **Prototipos navegables** de pantallas y navegación (`design/prototypes/`).
- **SPECs** de la red ciudadana, deliberación, identidad por cadenas de confianza,
  gobernanza, simulación de la red, protección de participantes, cuenta de garantía
  electoral y chequeos legales (`sdd/specs/`).

## Links

- Repositorio: https://github.com/kenarab/cuentaconmigo

El detalle técnico vive en `sdd/specs/`.
