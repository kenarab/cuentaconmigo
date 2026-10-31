# Ficha HackDash · CuentaConmigo

Borrador para cargar el proyecto en HackDash. Cada sección corresponde a un campo
del formulario. Estado: propuesta pendiente de aprobación del autor.

## Título

CuentaConmigo

## Bajada / tagline

Auditoría ciudadana de las elecciones 2027: cada mesa cuenta, cada voto cuenta.

## Estado

Brainstorming / investigación

## Descripción

**CuentaConmigo** es una plataforma comunitaria y **no partidaria** para que la
ciudadanía pueda auditar las elecciones generales de Argentina de 2027 y defender
el debate público de la desinformación. Tiene dos módulos.

### 1. Telegramas: cada mesa, una foto

Fiscales y autoridades de mesa fotografían el telegrama de escrutinio de su mesa
apenas termina el conteo. La app:

- Guía la toma de la foto (encuadre, nitidez, que sea legible) y funciona con
  mala conectividad: guarda la foto y la sube cuando vuelve la señal.
- Registra mesa, circuito y sección, hora y huella digital (hash) de la imagen
  original para preservar la cadena de custodia.
- Procesa las imágenes de forma centralizada: extracción automática de los números
  y validación humana por voluntarios (doble carga a ciegas).
- Coteja cada mesa con el telegrama y el resultado provisorio que publica el
  organismo oficial, y marca las diferencias para que se revisen.
- Publica datos abiertos agregados y un tablero de avance y discrepancias.

### 2. Desinformación: respuesta comunitaria en tiempo real

Durante la campaña y la jornada electoral circulan noticias falsas sobre el
proceso (fraude inventado, cambios de lugar de votación, fotos sacadas de
contexto). CuentaConmigo propone:

- **Canal de alerta**: cualquier persona reporta un contenido sospechoso
  (link, captura, audio) desde la web o reenviándolo a un bot de mensajería.
- **Cola de verificación**: voluntarios agrupan reportes del mismo contenido,
  priorizan según cuánto se está difundiendo y verifican con fuentes.
- **Respuesta lista para compartir**: placas y textos breves con la evidencia,
  pensados para circular por los mismos canales que la desinformación.
- **Alianzas**: trabajo con organizaciones de chequeo y de la sociedad civil
  para no duplicar esfuerzos.

Respondemos con información y fuentes; no buscamos silenciar a nadie.

## Principios

- No partidario: no favorecemos a ningún partido ni candidato.
- Evidencia antes que opinión: las fotos originales nunca se modifican y toda
  discrepancia muestra su fuente.
- Privacidad: los datos personales de voluntarios y fiscales se protegen según la
  Ley 25.326 de Protección de Datos Personales y no se publican.
- Abierto: código abierto y datos agregados abiertos.

## Qué necesitamos (skills buscados)

- Desarrollo mobile (captura offline, cámara, subida resiliente)
- Backend y datos (colas, almacenamiento de evidencia, APIs)
- Visión por computadora / OCR de formularios
- UX/UI para uso bajo presión y en dispositivos de gama baja
- Derecho electoral y protección de datos
- Periodismo de datos y verificación (fact-checking)
- Seguridad, moderación y prevención de abuso
- Coordinación de voluntarios y comunicación

## Tags

elecciones, argentina, 2027, auditoría-ciudadana, telegramas, fiscalización,
desinformación, fact-checking, datos-abiertos, civic-tech, transparencia

## Links

- Repositorio: https://github.com/kenarab/cuentaconmigo

## Preguntas abiertas

- Formato de los telegramas en 2027: la Boleta Única de Papel ya cambió el
  escrutinio en 2025, así que hay que relevar el formato vigente antes de diseñar
  la extracción.
- Disponibilidad y formato de los telegramas y resultados que publique el
  organismo oficial.
- Stack técnico y arquitectura: todavía no hay nada decidido.
