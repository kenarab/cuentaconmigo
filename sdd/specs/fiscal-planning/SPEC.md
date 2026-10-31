# SPEC · Modo planificación para fiscales que cubren varias mesas

Estado: **propuesta para el diseño de la app; pendiente de prototipo y aceptación del autor.**
Eje: **D. Jornada y escrutinio** de la [visión](../vision/SPEC.md).
Fecha: 31/10/2026. Pedido del autor. Depende de [telegram-capture](../telegram-capture/SPEC.md),
[scrutiny-backend](../scrutiny-backend/SPEC.md) y [app-screens](../app-screens/SPEC.md).

## Problema

Las fuerzas con pocos fiscales no llegan a cubrir todas las mesas. La misma persona
recorre varios establecimientos (fiscal general o fiscal que cubre más de una mesa;
figura y facultades a verificar con `electoral_counsel`). Hoy anota a mano qué mesas
vio, qué le falta y qué cargaron otras personas. Pierde tiempo y mesas.

La app tiene que ayudarla a planificar el día, registrar lo que controló y enterarse
a tiempo de lo que suben otras personas sobre sus mesas.

**Neutralidad:** el modo está disponible igual para cualquier fuerza, fiscal
independiente o voluntario. Ninguna función depende del partido. Es más útil para
quien cubre muchas mesas, pero las reglas son las mismas para todos.

## Usuarios

- **Fiscal que cubre varias mesas** (caso principal): de 2 a decenas de mesas, en uno
  o varios establecimientos.
- **Coordinación de su equipo** (opcional): asigna mesas y ve la cobertura. Sólo ve a
  las personas de su propio equipo.

## Alcance

1. **Plan del día:** elegir o recibir las mesas a cubrir (establecimiento, mesas,
   circuito). Ordenarlas por establecimiento y recorrido. Mostrar los horarios clave:
   apertura, cierre y escrutinio (a verificar con el cronograma vigente).
2. **Estado por mesa**, con una sola acción en cada cambio:
   `pendiente → visitada → escrutinio presenciado → telegrama/acta capturado → cotejado`,
   más `incidencia` (con nota) y `no cubierta`.
3. **Registro de chequeo:** cada cambio de estado guarda la hora y, si la persona
   quiere, una nota. No guarda la ubicación por defecto (ver Datos personales).
4. **Notificaciones de mesas seguidas:** cuando otra persona (fiscal de otra fuerza,
   autoridad de mesa o voluntario) sube una captura de una mesa de su plan:
   - aviso con mesa, tipo de documento y hora;
   - si ya hay una carga propia, el cotejo automático celda a celda: **coincide** o
     **hay diferencias** (con las celdas). Usar el vocabulario "diferencia", nunca
     "irregularidad";
   - si la mesa no está cubierta, ofrecer usar esa captura como referencia sin
     confirmarla como propia.
5. **Vista de cobertura:** mesas del plan con captura propia, con captura de terceros
   o sin ninguna. Prioriza las que no tienen captura de nadie.
6. **Modo sin conexión:** el plan, los estados y las capturas funcionan offline. Se
   sincronizan al recuperar señal, con la cola de [scrutiny-backend](../scrutiny-backend/SPEC.md).
7. **Resumen al cierre:** mesas cubiertas, capturas, diferencias e incidencias.
   Exportable con el mismo aviso de datos personales y de veda que el paquete de
   evidencia.
8. **Recordatorios** locales: cierre de mesas y "te faltan N mesas sin captura".

Fuera de alcance de la primera versión: navegación paso a paso (se abre el mapa del
sistema), chat entre fiscales, asignación automática óptima.

## Notificaciones y backend

- Suscripción por mesa: el dispositivo registra las mesas de su plan. Propuesta de
  API para sumar a [scrutiny-backend](../scrutiny-backend/SPEC.md):
  `PUT /v1/devices/{id}/watchlist` `{mesas:[…]}` y un canal de eventos
  `GET /v1/devices/{id}/events?since=…` (sondeo; push del sistema como mejora).
- Evento `capture.received` de una mesa seguida: `{mesa, documentType, receivedAt,
  comparison?:{status: match|differences, cells:[…]}}`. **No incluye la imagen ni
  la identidad de quien subió**, salvo que el autor decida otra cosa (FP-3).
- Escala: las suscripciones se indexan por mesa. Un evento de captura se reparte a
  N suscriptores por cola, sin consultar a todos los dispositivos.
- Veda (Código Electoral art. 71 inc. h, a verificar): las notificaciones son de mesas
  individuales a quien las sigue y no contienen proyecciones ni agregados. Debe
  confirmarlo `electoral_counsel`.

## Datos personales (Ley 25.326)

- El plan y la ubicación quedan **en el teléfono**. Al servidor sólo llegan la lista
  de mesas seguidas y el token del dispositivo, sin nombre, DNI ni teléfono.
- El equipo ve estados de mesa, no ubicaciones. Compartir la ubicación sería opcional,
  explícito y apagable (FP-4).
- Las capturas de terceros conservan el tratamiento de evidencia: original inmutable,
  separación entre lo extraído y lo confirmado.

## Decisiones pendientes

| ID | Decisión | Opciones |
| --- | --- | --- |
| FP-1 | Origen del plan | Lo arma la persona ★ · lo asigna su coordinación · ambos |
| FP-2 | Notificaciones | Sondeo al abrir y cada N minutos ★ (prototipo) · push del sistema (APNs/FCM) |
| FP-3 | Identidad de quien subió una captura de terceros | Anónima ★ · fuerza declarada · seudónimo |
| FP-4 | Ubicación | Nunca sale del teléfono ★ · se comparte con la coordinación por elección |
| FP-5 | Equipos | Sin equipos en v1 ★ · equipos con código de invitación |
| FP-6 | Uso de capturas de terceros en mesas no cubiertas | Sólo referencia ★ · se puede confirmar como propia tras revisión |

## Pantallas

Ninguna se implementa sin un prototipo navegable aprobado en `design/prototypes/`
([review-pipeline](../review-pipeline/SPEC.md)). Pantallas candidatas: plan del día,
detalle de establecimiento, detalle de mesa con estados, bandeja de avisos, cobertura
y resumen. Se integran a la navegación que elija el autor en AS-1.

## Criterios de aceptación

1. Una persona con 12 mesas en 3 establecimientos arma su plan en menos de 3 minutos.
2. Cambiar el estado de una mesa toma una acción y funciona sin conexión.
3. Una captura de terceros de una mesa seguida genera aviso dentro de 1 minuto con
   conexión. Cuando hay carga propia, el aviso trae el cotejo celda a celda.
4. Ningún dato personal ni ubicación sale del teléfono sin elección explícita.
5. Mismas funciones y textos para cualquier fuerza (revisión de neutralidad).

## Chequeo de electoral_counsel: pendiente

Riesgos a evaluar: facultades del fiscal general y de quien cubre varias mesas;
uso de capturas de otras fuerzas; avisos durante la jornada y veda; tratamiento de
imágenes con datos de autoridades de mesa.
