# SPEC · Pantallas de la app: red ciudadana y flujo de escrutinio

Estado: **propuesta de Fable (rol `ux_designer`), revisada por Astra y prototipada;
esperando la decisión del autor y de Andy en el issue #2.** Nada de lo que sigue es una
decisión: donde hay más de una alternativa, se recomienda una y se deja la elección.
Fecha: 31/10/2026 · última actualización: 31/10/2026.

## Estado y cómo revisar las pantallas

| Etapa del pipeline | Estado | Dónde |
| --- | --- | --- |
| 1. Propuesta (Fable) | ✅ | Este documento |
| 2. Validación (Astra: spec, ux, legal, neutralidad) | ✅ 6 ⛔ y 18 ⚠️ | `checks/*.astra.md` |
| 3. Consolidación | ✅ | [DECISION.md](DECISION.md) |
| 1b. Prototipo navegable (Fable) con correcciones de Astra | ✅ | `design/prototypes/escrutinio/index.html` · [vista publicada (privada)](https://claude.ai/artifact/KNrbEwf8hhBJv8bNZgY6gz) |
| 2b. Revisión de Astra sobre el prototipo | ⏳ pendiente | — |
| 4. Decisión humana (AS-1 a AS-12) | ⏳ pendiente | Issue #2 |
| 5. Implementación SwiftUI fiel al prototipo aprobado | ⏳ después de la decisión | `ios/CuentaConmigo/` |

**Para revisar:** abrí el prototipo publicado (o el HTML local en un navegador). A la
izquierda está el iPhone; a la derecha, el panel con:

- la lista de pantallas E-00 a E-13 para saltar a cualquiera;
- la nota de diseño de cada pantalla, las decisiones AS-x que la afectan y los cambios
  que pidió Astra;
- selectores para comparar alternativas: AS-2 (F-1 asistente o F-2 imagen + campos),
  AS-6 (botón "Cero" o vacío = 0), AS-3 (certificado preseleccionado) y AS-8 (origen OCR visible);
- simulaciones: sin conexión, cámara denegada, escáner no disponible y OCR apagado;
- datos de ejemplo: valores que cierran, o con un error, un aviso y un faltante.

Cada pantalla tiene un link directo (`#e-07`, por ejemplo). Todos los datos son ficticios.
La vista publicada es privada: para que Andy la vea, compartila desde el menú Share.

Relación con otras SPECs:

- Visión: [sdd/specs/vision/SPEC.md](../vision/SPEC.md) (ejes A–E; el escrutinio D cierra el proceso).
- Producto central: [civic-network](../civic-network/SPEC.md); motor de consensos: [civic-deliberation](../civic-deliberation/SPEC.md).
- Herramientas de monitoreo: [platform-accountability](../platform-accountability/SPEC.md).
- Flujo que detalla esta SPEC: [telegram-capture](../telegram-capture/SPEC.md) (alcance P0 y restricciones legales) y [amba-simulation](../amba-simulation/SPEC.md).
- Plataforma: [mobile-platform](../mobile-platform/SPEC.md) (D-001 tomada: SwiftUI primero, Android nativo equivalente; D-002 pendiente).
- Marco legal: [docs/legal/MARCO_LEGAL.md](../../../docs/legal/MARCO_LEGAL.md), secciones 3 y 6.
- Identidad visual: [design/icon/README.md](../../../design/icon/README.md) y [design/cover/cover.svg](../../../design/cover/cover.svg).

Convención de este documento: **[P0]** entra en el prototipo de escrutinio que
empieza ahora; **[después]** queda para una fase posterior; **[boceto]** es sólo
una idea de pantalla sin detalle. Todo texto de interfaz va en español rioplatense.

---

## 1. Por qué una SPEC de pantallas

La app es una sola historia: una red ciudadana que delibera durante meses y que,
el día de la elección, cierra su auditoría con fiscales y autoridades de mesa
escaneando el telegrama, el acta o el certificado de su mesa. El prototipo que
empieza ahora cubre sólo ese cierre, pero conviene diseñarlo sabiendo dónde va a
vivir después, para no tener que rehacer la navegación cuando entre la red.

Esta SPEC propone: (1) el mapa completo de navegación, (2) alternativas para la
arquitectura global, (3) alternativas para el flujo de escrutinio con wireframes,
(4) el inventario detallado de las pantallas del flujo recomendado, (5) sus
equivalencias en Android y (6) bocetos de las pantallas futuras de la red.

---

## 2. Mapa de navegación de la app completa

```
CuentaConmigo
├── Red [después]
│   ├── Espacios temáticos (Plataformas · Desinformación · Campaña · Jornada · Escrutinio · Regulación)
│   │   └── Feed del espacio (orden transparente, sin algoritmo de interacción)
│   ├── Propuestas (ideas → propuestas estructuradas)
│   │   ├── Nueva propuesta (plantilla obligatoria)
│   │   └── Detalle: deliberación a favor / en contra · enmiendas · versiones
│   ├── Consensos (estado de cada iniciativa, umbrales publicados, consenso transversal)
│   │   └── Modalidades de acción (catálogo abierto; chequeo legal visible)
│   └── Partidos (cuentas institucionales, todas con la misma tarjeta y los mismos permisos)
├── Herramientas [después]
│   ├── Archivo de evidencia viral (A1)
│   ├── Tablero público de plataformas (A4)
│   ├── Agentes de monitoreo (estado, metodología, datos agregados)
│   └── Simulación del AMBA (link a la web estática; "SIMULACIÓN" siempre visible)
├── Escrutinio [P0]  ← foco del prototipo
│   ├── Mis capturas (lista)
│   ├── Nueva captura (flujo de la sección 4)
│   │   ├── Antes de empezar: aviso de Boleta Única
│   │   ├── Tipo de documento
│   │   ├── Datos de mesa
│   │   ├── Captura de páginas (escáner / importar)
│   │   ├── Páginas capturadas (ampliar, agregar, quitar)
│   │   ├── Carga de valores (imagen + campos + OCR como ayuda)
│   │   ├── Validación
│   │   └── Confirmar y bloquear
│   ├── Captura confirmada (detalle · exportar · envío pendiente)
│   └── Cola de exportación / envíos pendientes
└── Perfil / Ajustes
    ├── [P0] Acerca de · plantilla en uso (con aviso si es ficticia) · versión · legal
    └── [después] Cuenta, verificación de persona (RC-5), moderación, notificaciones
```

Qué entra en el prototipo de escrutinio: toda la rama **Escrutinio** y un
**Acerca de** mínimo. No entran: cuentas, envío a servidor (D-003), cotejo con
resultados oficiales, red, herramientas, Android.

---

## 3. Arquitectura de navegación global: alternativas

### N-A. Una app con tab bar y la red al centro

```
┌──────────────────────────────────────┐
│  (contenido de la pestaña activa)    │
│                                      │
├──────────────────────────────────────┤
│ Espacios  Propuestas  ●Red  Herram.  Yo │
└──────────────────────────────────────┘
```

Cinco pestañas; la red (inicio: actividad de los espacios y consensos en curso)
en el centro. El escrutinio vive dentro de **Herramientas** como una herramienta
más, igual que el archivo de evidencia o los agentes.

- A favor: una sola identidad y una sola instalación; el escrutinio se presenta
  como lo que es en la visión (una modalidad de acción de la red); la pestaña
  Herramientas crece sin cambiar la estructura.
- En contra: el día de la elección, un fiscal con poca batería y poca señal tiene
  que encontrar el escrutinio dos toques adentro; el prototipo de hoy no tiene
  red, así que cuatro de las cinco pestañas estarían vacías durante meses; el
  tab bar compite con el espacio vertical en la carga de valores.

### N-B. App de escrutinio separada

Dos apps: "CuentaConmigo" (red) y "CuentaConmigo Escrutinio" (el prototipo
actual, tal como está). La app de escrutinio arranca directo en "Mis capturas".

- A favor: es lo que ya existe; cero fricción el día D; se puede distribuir a
  fiscales de cualquier fuerza sin pedirles que se sumen a la red (coherente con
  la opción 1 de V-4); menor superficie de revisión en tiendas.
- En contra: dos marcas y dos instalaciones; el escrutinio queda desconectado de
  la historia ("cierre del proceso de auditoría"); duplicación de perfil, ajustes
  y evidencia; hay que mantener dos apps en dos plataformas.

### N-C. Una app con "modo jornada electoral"

La app es la red (tab bar como N-A). El día de la elección, o cuando la persona lo
activa a mano en Ajustes, la pantalla de inicio pasa a ser **Escrutinio** a
pantalla completa, con la red accesible desde un botón "Volver a la red". Fuera
de ese modo, el escrutinio sigue disponible en Herramientas. El modo es local
(no depende de servidor) y se puede activar siempre, para practicar.

```
 modo normal                      modo jornada electoral
┌──────────────────┐              ┌──────────────────────┐
│ Red / Espacios   │   día D o    │ ▣ Escrutinio         │
│ ...              │  activación  │ Mis capturas         │
│                  │  manual  ─▶  │ [ Nueva captura ]    │
├──────────────────┤              │                      │
│ ⌂  ✎  ●  ⚒  ☺   │              │ ← Volver a la red    │
└──────────────────┘              └──────────────────────┘
```

- A favor: una sola app y una sola identidad; el día D el escrutinio es lo primero
  que se ve y sin tab bar; el prototipo actual **es** el modo jornada, así que lo
  que se construye ahora no se tira; respeta la veda (en ese modo no se muestran
  feeds ni contenidos partidarios, a definir con `electoral_counsel`).
- En contra: dos "estados" de la misma app que hay que explicar; el disparador por
  fecha depende del calendario oficial (aún abierto); hay que decidir qué pasa con
  las notificaciones de la red durante el modo.

### Recomendación (propuesta)

**N-C**, construida en dos tiempos: hoy el prototipo se implementa como la
pantalla raíz de "modo jornada electoral" (que de hecho es N-B mientras no exista
la red); cuando entre la red, esa raíz se convierte en el modo y el tab bar en el
estado normal. Condición: el flujo de escrutinio **no** debe asumir un tab bar
(pantalla completa, botón primario abajo) ni depender de una cuenta.

Riesgo a validar con `electoral_counsel`: si una misma app combina red con cuentas
partidarias y captura de documentos de mesa, hay que revisar la lectura de la
Acordada 128/11 y de la veda (sección 3 del marco legal) antes de decidir N-A/N-C.

---

## 4. Flujo de escrutinio: alternativas

Contexto de uso que condiciona todo: **de noche, con presión, poca luz, mala
conectividad, posiblemente un teléfono de gama baja, con la mano cansada después de
contar boletas**. La persona ya recibió un certificado (o va a fotografiar el
telegrama antes de entregarlo al Correo). El objetivo es una copia fiel con hash y
números verificados; nada más.

### F-1. Asistente paso a paso (wizard)

Una pregunta por pantalla, indicador "Paso n de 7", botón grande "Continuar".

```
┌────────────────────────────┐ ┌────────────────────────────┐ ┌────────────────────────────┐
│ ← Paso 1 de 7              │ │ ← Paso 2 de 7              │ │ ← Paso 3 de 7              │
│                            │ │                            │ │                            │
│   ✋ Antes de empezar       │ │  ¿Qué documento vas a      │ │  Datos de la mesa          │
│                            │ │  escanear?                 │ │                            │
│  Nunca fotografíes la      │ │                            │ │  Distrito   [________]     │
│  Boleta Única: está        │ │  ( ) Certificado de        │ │  Sección    [________]     │
│  prohibido (art. 71 g).    │ │      escrutinio            │ │  Circuito   [________]     │
│                            │ │  ( ) Telegrama             │ │  Mesa       [________]     │
│  Sí podés escanear:        │ │  ( ) Acta                  │ │                            │
│  certificado, telegrama,   │ │                            │ │                            │
│  acta.                     │ │                            │ │                            │
│                            │ │                            │ │                            │
│ [ Entendido, continuar ]   │ │ [ Continuar ]              │ │ [ Continuar ]              │
└────────────────────────────┘ └────────────────────────────┘ └────────────────────────────┘
┌────────────────────────────┐ ┌────────────────────────────┐ ┌────────────────────────────┐
│ ← Paso 4 de 7              │ │ ← Paso 5 de 7              │ │ ← Paso 6 de 7              │
│  Escaneá el documento      │ │  Presidente y Vice  (1/2)  │ │  Validación                │
│                            │ │ ┌────────────────────────┐ │ │                            │
│ ┌────────────────────────┐ │ │ │  imagen (zoom)         │ │ │  ✗ Falta el valor de       │
│ │                        │ │ │ └────────────────────────┘ │ │    Diputados: Lista C      │
│ │  (escáner nativo)      │ │ │  Lista A (ficticia) [ 123] │ │  ⚠ Presidente: la suma no  │
│ │                        │ │ │  Lista B (ficticia) [  98] │ │    coincide con votantes   │
│ └────────────────────────┘ │ │  Lista C (ficticia) [    ] │ │                            │
│  Páginas: ▢ ▢  + agregar   │ │  En blanco          [   4] │ │  [ Ir al primer error ]    │
│                            │ │  ...                       │ │                            │
│ [ Importar de Fotos ]      │ │  OCR: [123] [98] [4] [225] │ │                            │
│ [ Continuar ]              │ │ [ Siguiente categoría ]    │ │ [ Confirmar ] (deshab.)    │
└────────────────────────────┘ └────────────────────────────┘ └────────────────────────────┘
```

- A favor: imposible saltearse el aviso de Boleta Única; cada pantalla cabe con
  Dynamic Type grande; orden claro para quien usa la app una sola vez en su vida;
  VoiceOver recorre una tarea por vez.
- En contra: muchos toques bajo presión (7 pasos × categorías); volver atrás para
  corregir un dato de mesa es tedioso; la imagen queda chica o se pierde al pasar
  de categoría; en gama baja cada transición cuesta.
- Riesgos: presión (alto: demasiados pasos); poca luz (neutro, el escáner nativo
  resuelve); conectividad (neutro, todo local); gama baja (medio); VoiceOver
  (bajo); Dynamic Type (bajo).

### F-2. Vista partida: imagen arriba, campos abajo, tocar-para-copiar del OCR

Es la base del prototipo actual (`CaptureEditorView`), mejorada: la imagen queda
fija arriba (ampliable, se puede arrastrar), los campos abajo en una lista con
secciones, y los números que el OCR detectó aparecen como fichas sobre el teclado:
se toca un campo y después una ficha para copiar el número.

```
┌────────────────────────────┐ ┌────────────────────────────┐
│ ← Mesa 0421        Acta ▾  │ │ ← Mesa 0421        Acta ▾  │
│ ┌────────────────────────┐ │ │ ┌────────────────────────┐ │
│ │   [imagen · pág 1/2]   │ │ │ │ (imagen ampliada 3x,   │ │
│ │   pellizcar = zoom     │ │ │ │  arrastrada a la fila   │ │
│ │   ⤢ pantalla completa  │ │ │ │  "Lista B")             │ │
│ └────────────────────────┘ │ │ └────────────────────────┘ │
│ ─── Totales de la mesa ─── │ │ ─── Presidente y Vice ──── │
│ Electores        [   350 ] │ │ Lista A (ficticia) [ 123 ] │
│ Total votantes   [   225 ] │ │ Lista B (ficticia) [▮    ] │
│ ─── Presidente y Vice ──── │ │ Lista C (ficticia) [     ] │
│ Lista A (ficticia) [ 123 ] │ ├────────────────────────────┤
│ Lista B (ficticia) [     ] │ │ Detectados: [98] [4] [225] │
│ ...                        │ │  1    2    3    ⌫          │
│ ⚠ 1 aviso · ✗ 2 errores    │ │  4    5    6    Siguiente  │
│ [ Confirmar captura ]      │ │  7    8    9    (teclado)  │
└────────────────────────────┘ └────────────────────────────┘
```

- A favor: todo a la vista, menos toques; la persona compara número por número con
  la imagen sin cambiar de pantalla; el OCR acelera sin decidir (origen
  `ocr-accepted` trazable); ya existe en el prototipo.
- En contra: en pantallas chicas o con Dynamic Type grande la imagen y la lista
  se pelean por el espacio; es fácil olvidar el aviso de Boleta Única si queda como
  un texto más en el formulario (hoy pasa eso); mucha información para VoiceOver en
  una sola pantalla; en gama baja el zoom de una foto grande puede trabarse.
- Riesgos: presión (bajo); poca luz (neutro); conectividad (neutro); gama baja
  (medio: cuidar el tamaño de la imagen que se muestra); VoiceOver (medio: hay
  que ordenar los elementos y dar atajos "ir a los campos"/"ir a la imagen");
  Dynamic Type (medio-alto: la imagen fija se achica; prever modo "sólo campos").

### F-3. Doble carga a ciegas / verificación cruzada entre dos personas

Dos personas (por ejemplo, fiscal y autoridad de mesa, o dos fiscales de distintas
fuerzas) cargan los mismos valores sin ver la carga de la otra. La app compara y
sólo pide resolver las diferencias mirando la imagen. Variante mínima: una sola
persona vuelve a tipear sólo los totales críticos sin ver lo que cargó.

```
┌────────────────────────────┐ ┌────────────────────────────┐ ┌────────────────────────────┐
│ Carga 1 de 2               │ │ Pasale el teléfono a       │ │ Comparación                │
│ (igual a F-2)              │ │ la otra persona            │ │                            │
│                            │ │                            │ │ Coinciden 11 de 14 valores │
│ ...                        │ │ La segunda carga se hace   │ │                            │
│                            │ │ sin ver la primera.        │ │ Presidente · Lista B       │
│                            │ │ No se guardan nombres.     │ │   carga 1: 98  carga 2: 89 │
│                            │ │                            │ │   [ver imagen] ( 98 ) ( 89 )│
│                            │ │ [ Empezar carga 2 ]        │ │ Diputados · En blanco      │
│                            │ │ [ Saltear: carga simple ]  │ │   carga 1: 4   carga 2: 14 │
│ [ Listo, carga 1 ]         │ │                            │ │   [ver imagen] (  4 ) ( 14 )│
└────────────────────────────┘ └────────────────────────────┘ └────────────────────────────┘
```

- A favor: la mejor calidad de transcripción (el error humano se detecta por
  discrepancia, no por regla); el paquete de evidencia puede llevar `verification:
  double-entry`; refuerza la neutralidad si las dos personas son de fuerzas
  distintas.
- En contra: duplica el tiempo en el peor momento de la noche; exige dos personas
  disponibles (no siempre las hay); hay que diseñar "a ciegas" de verdad (la
  segunda persona no debe poder ver ni el OCR ni la carga 1); tentación de
  registrar quién fue cada persona (dato sensible: no).
- Riesgos: presión (alto); poca luz (neutro); conectividad (neutro); gama baja
  (bajo); VoiceOver (medio); Dynamic Type (bajo).

### Recomendación (propuesta)

**Híbrido: asistente corto de preparación (F-1) + editor en vista partida (F-2),
con F-3 como "segunda verificación" opcional [después].**

- Preparación en pasos (aviso de Boleta Única → tipo → mesa → escaneo → páginas):
  son decisiones que se toman una vez y que no deben poder saltearse. Cuatro
  pantallas cortas, no siete.
- Carga de valores en una sola pantalla partida (F-2), con OCR como fichas, botón
  "ampliar imagen" a pantalla completa y un modo "sólo campos" cuando Dynamic Type
  es grande o la pantalla es chica.
- Validación y confirmación como pasos finales explícitos (bloqueo con doble
  confirmación).
- F-3 se deja como variante opcional desde la pantalla de validación ("Verificar
  con otra persona"), fuera de P0, sin registrar identidades.

Razón: minimiza toques donde hay presión (la carga) y no permite saltear lo que es
legalmente sensible (el aviso) ni lo que es estructural (tipo y mesa). Coincide con
el flujo de UX de telegram-capture y reutiliza casi todo el prototipo.

---

## 5. Pantallas del flujo recomendado (inventario detallado)

Criterios comunes a todas las pantallas [P0]:

- Objetivo táctil mínimo 44×44 pt; botón primario abajo, ancho completo, 56 pt.
- Dynamic Type hasta "AX5" sin truncar ni superponer; las listas se reacomodan en
  una columna; nunca texto en imágenes.
- VoiceOver: toda imagen con etiqueta; todo campo con etiqueta y valor; los
  cambios de estado (error, confirmado) se anuncian; orden de lectura explícito.
- Contraste AA mínimo; errores no sólo por color (ícono + texto); modo oscuro
  soportado (la noche de la elección se usa a oscuras).
- Offline por defecto: nada de lo que hace la persona necesita red. Si una acción
  futura necesitara red, se encola (E-11) y se dice claramente.
- Idioma: rioplatense simple, voseo, sin jerga técnica ("hash" aparece sólo como
  "huella digital (SHA-256)" en la pantalla de detalle).
- Una captura confirmada **nunca** se edita ni se borra desde la app; corregir =
  nueva captura de la misma mesa (se ofrece como acción).
- Sin datos personales: no se pide nombre, DNI, partido ni ubicación. Las fotos
  pueden contenerlos: se guardan protegidas y no se muestran fuera de la app.

### E-00. Aviso de plantilla ficticia (componente transversal) [P0]

> Decisión del autor (31/10/2026): la app usa plantillas de elecciones reales
> (`generales-2023`), así que el aviso no se muestra. El componente queda sólo para
> plantillas con `fictitious = true`. Resuelve AS-7.

- Propósito: que nadie cargue datos reales con una plantilla que no es el
  formulario oficial. Se muestra mientras `template.fictitious == true`.
- Contenido: franja amarilla fija arriba de E-01, E-07 y E-10: "Prototipo con un
  formulario ficticio (Lista A/B/C). No cargues datos reales todavía." Las filas
  ficticias llevan "(ficticia)" en su etiqueta (ya está en `demo-2027.json`).
- Acciones: tocar lleva a E-12 (Acerca de), donde se explica qué plantilla está en
  uso y su versión.
- Estados: ninguno; no se puede descartar.
- Accesibilidad: rol "aviso", se lee primero en la pantalla.
- Aceptación: con la plantilla `demo-2027`, el aviso aparece en E-01, E-07 y E-10
  y el paquete exportado lleva `template.id = demo-2027` y `fictitious = true`;
  con una plantilla no ficticia, no aparece.

### E-01. Mis capturas [P0]

```
┌────────────────────────────┐
│ ⚠ Prototipo con formulario │
│   ficticio. Sin datos reales│
│ Escrutinio            ⓘ    │
│                            │
│ Mesa 0421 · Certificado    │
│ 🔒 Confirmada · 2 pág.     │
│ Mesa 0421 · Telegrama      │
│ ✎ Borrador · 1 pág.        │
│                            │
│ (vacío:) Todavía no hay    │
│ capturas. Tocá "Nueva      │
│ captura" al terminar el    │
│ escrutinio de tu mesa.     │
│                            │
│ [ ▣ Nueva captura ]        │
└────────────────────────────┘
```

- Propósito: punto de entrada; ver el estado de cada captura y empezar una nueva.
- Contenido: E-00 si corresponde; lista de capturas (mesa, tipo, estado
  Borrador/Confirmada/Exportada/Envío pendiente, cantidad de páginas, hora);
  botón primario fijo abajo.
- Acciones: Nueva captura → E-02; tocar un borrador → retoma en el paso donde
  quedó; tocar una confirmada → E-10; deslizar para borrar sólo borradores (con
  confirmación); ⓘ → E-12.
- Estados: vacío (texto de arriba); error de almacenamiento ("No se pudo leer el
  almacenamiento. Reiniciá la app; tus capturas no se borraron."); offline: sin
  cambios (es local).
- Accesibilidad: cada fila es un solo elemento con etiqueta compuesta ("Mesa 0421,
  certificado, confirmada, 2 páginas"); el botón primario es el último elemento.
- Aceptación: una captura confirmada no ofrece borrar; el orden es por fecha de
  creación descendente; con VoiceOver se puede crear una captura y volver a la
  lista sin tocar la pantalla.

### E-02. Antes de empezar: aviso de Boleta Única [P0]

```
┌────────────────────────────┐
│ ✕                          │
│                            │
│        ✋ (grande)          │
│  Nunca fotografíes la      │
│  Boleta Única              │
│                            │
│  Está prohibido durante    │
│  los comicios (Código      │
│  Electoral, art. 71 inc. g)│
│                            │
│  Sí podés escanear:        │
│  ✓ Certificado de          │
│    escrutinio (te lo       │
│    entrega el presidente)  │
│  ✓ Telegrama               │
│  ✓ Acta                    │
│                            │
│ [ Entendido, continuar ]   │
└────────────────────────────┘
```

- Propósito: cumplir la restricción legal antes de abrir la cámara; es la primera
  pantalla de cada captura nueva, siempre (no "no volver a mostrar").
- Contenido: texto fijo, sin opciones. Enlace "Más información" → E-12 (legal).
- Acciones: Entendido → E-03; ✕ → descarta el borrador y vuelve a E-01.
- Estados: ninguno.
- Accesibilidad: el título se anuncia al aparecer; el botón es el último elemento;
  el ícono es decorativo.
- Aceptación: no existe camino hacia la cámara que no pase por esta pantalla; el
  borrador registra `bupWarningAcknowledgedAt` (hora, sin identidad) en el
  paquete (propuesta de campo para `contract-change`, a validar).

### E-03. Tipo de documento [P0]

```
┌────────────────────────────┐
│ ← Nueva captura   Paso 1/4 │
│                            │
│ ¿Qué documento vas a       │
│ escanear?                  │
│                            │
│ ┌────────────────────────┐ │
│ │ ● Certificado de       │ │
│ │   escrutinio           │ │
│ │   El que te entregan a │ │
│ │   vos como fiscal.     │ │
│ ├────────────────────────┤ │
│ │ ○ Telegrama            │ │
│ │   Antes de entregarlo  │ │
│ │   al Correo.           │ │
│ ├────────────────────────┤ │
│ │ ○ Acta de escrutinio   │ │
│ │   Sin manipular el     │ │
│ │   original.            │ │
│ └────────────────────────┘ │
│ [ Continuar ]              │
└────────────────────────────┘
```

- Propósito: elegir uno de los tipos admitidos por la plantilla; orientar hacia
  el certificado, que es el documento propio del fiscal (marco legal 3.1).
- Contenido: opciones de `template.documentTypes` con una línea de ayuda cada una.
  Preseleccionado: certificado (propuesta; validar con `electoral_analyst`).
- Acciones: Continuar → E-04; ← vuelve a E-02.
- Estados: ninguno.
- Accesibilidad: grupo de radio con etiquetas completas, no sólo el título.
- Aceptación: el valor queda en `documentType` del paquete y se puede cambiar
  hasta confirmar.

### E-04. Datos de mesa [P0]

```
┌────────────────────────────┐
│ ← Certificado     Paso 2/4 │
│                            │
│ Datos de la mesa           │
│ Los encontrás en el        │
│ encabezado del documento.  │
│                            │
│ Distrito   [ 02         ]  │
│ Sección    [ 03         ]  │
│ Circuito   [ 0012       ]  │
│ Mesa       [ 0421       ]  │
│                            │
│ (futuro) [ ▦ Leer código   │
│   del documento ]          │
│                            │
│ [ Continuar ]              │
└────────────────────────────┘
```

- Propósito: identificar la mesa; sin esto el cotejo posterior es imposible.
- Contenido: campos de `template.mesaFields`; teclado numérico/alfanumérico según
  campo; botón futuro de lectura de código de barras/QR (Q3, [después]).
- Acciones: Continuar → E-05; se puede pasar con campos vacíos (se marcan en E-08
  como `missing_mesa`), porque a veces conviene escanear primero y completar después.
- Estados: error de formato (sólo si la plantilla define uno); nada de red.
- Accesibilidad: etiquetas visibles, no sólo placeholders; "Siguiente" en el
  teclado recorre los cuatro campos.
- Aceptación: los cuatro valores viajan en `mesa.*` del paquete; vacíos producen
  `missing_mesa` en E-08.

### E-05. Captura de páginas [P0]

```
┌────────────────────────────┐
│ ← Mesa 0421       Paso 3/4 │
│                            │
│ Escaneá todas las páginas  │
│ del certificado.           │
│                            │
│ ┌────────┐ ┌────────┐      │
│ │ pág 1  │ │   +    │      │
│ │ (mini) │ │ agregar│      │
│ └────────┘ └────────┘      │
│                            │
│ Consejos: apoyá el         │
│ documento sobre la mesa,   │
│ acercá la linterna si hay  │
│ poca luz.                  │
│                            │
│ [ 📷 Escanear ]            │
│ [ Importar de Fotos ]      │
│ [ Continuar ]  (si ≥1 pág) │
└────────────────────────────┘
```

- Propósito: obtener una o más imágenes fieles (escáner nativo con recorte y
  perspectiva) o importarlas de Fotos (prueba en simulador).
- Contenido: miniaturas de páginas ya guardadas; consejos para poca luz; botones.
  El escáner nativo ofrece linterna; si no está disponible (simulador), sólo importar.
- Acciones: Escanear → cámara nativa (varias páginas por sesión) → vuelve con las
  páginas agregadas; Importar → selector sin permiso amplio; Continuar → E-06;
  tocar miniatura → E-06.
- Estados: permiso de cámara denegado ("Sin cámara no se puede escanear. Podés
  habilitarla en Ajustes o importar de Fotos." con botón a Ajustes); error al
  guardar ("No se pudo guardar la imagen. Hay poco espacio?"); escáner no
  disponible (sólo importar).
- Accesibilidad: miniaturas con "Página 1 de 2, escaneada 20:47"; el escáner
  nativo ya es accesible; evitar depender de gestos de pellizco en esta pantalla.
- Aceptación: cada página se guarda como JPEG una sola vez con SHA-256 y hora
  UTC; se puede agregar páginas hasta confirmar; en un iPhone real la captura de
  dos páginas en una sola sesión del escáner produce dos entradas.

### E-06. Páginas capturadas [P0]

```
┌────────────────────────────┐
│ ← Páginas (2)              │
│ ┌────────────────────────┐ │
│ │                        │ │
│ │   imagen pág 1         │ │
│ │   (pellizcar = zoom)   │ │
│ │                        │ │
│ └────────────────────────┘ │
│ ◀ 1 / 2 ▶                  │
│ Escaneada 20:47 · SHA-256  │
│ 3f9a…c21e                  │
│                            │
│ [ Quitar esta página ]     │
│   (sólo en borrador)       │
│ [ Agregar otra página ]    │
│ [ Continuar a la carga ]   │
└────────────────────────────┘
```

- Propósito: comprobar que la imagen se lee (números legibles, sin dedos ni
  recortes), reordenar o quitar antes de cargar. **No se edita la imagen**
  (marco legal, sección 6: no "corregir" ni recomponer documentos).
- Contenido: visor con zoom y paginación; hora y hash abreviado; acciones.
- Acciones: Quitar (sólo borrador, confirma: "Se elimina la imagen y su hash.");
  Agregar → E-05; Continuar → E-07; se vuelve a entrar desde E-07 con "Ampliar".
- Estados: imagen ilegible (sin detección automática en P0; se confía en la persona);
  archivo faltante ("No se encontró la imagen; volvé a escanear.").
- Accesibilidad: controles de paginación como botones; zoom también con botones
  "+"/"−" y doble toque; etiqueta "Imagen del certificado, página 1 de 2".
- Aceptación: quitar una página en borrador borra su archivo y su entrada; una
  captura confirmada no muestra "Quitar" ni "Agregar".

### E-07. Carga de valores (vista partida + OCR como ayuda) [P0]

```
┌────────────────────────────┐
│ ← Mesa 0421       Paso 4/4 │
│ ┌────────────────────────┐ │
│ │ imagen pág 1 · ⤢ ampliar│ │
│ │ (fija, zoom, arrastre) │ │
│ └────────────────────────┘ │
│ ⚠ Prototipo: formulario    │
│   ficticio                 │
│ ─ Totales de la mesa ───── │
│ Electores habilit. [ 350 ] │
│ Total de votantes  [ 225 ] │
│ ─ Presidente y Vice ────── │
│ Lista A (ficticia) [ 123 ] │
│ Lista B (ficticia) [▮    ] │
│ Lista C (ficticia) [     ] │
│ Votos en blanco    [     ] │
│ ─────────────────────────  │
│ Detectados: [98] [4] [225] │
│ (teclado numérico)         │
│ ✗ 6 faltan · [ Validar ]   │
└────────────────────────────┘
```

- Propósito: transcribir cada celda de la plantilla mirando la imagen, con el OCR
  como sugerencia que nunca se aplica sola.
- Contenido: imagen fija arriba (30–40 % de alto; colapsable a una franja con
  "Mostrar imagen" cuando el teclado está abierto o con Dynamic Type grande);
  lista de campos: `headerFields` y luego una sección por categoría con todas las
  `rows`; fichas "Detectados" sobre el teclado con los números del OCR de la
  página visible (deduplicados, en orden de aparición); contador de faltantes.
- Acciones: tocar campo → teclado numérico; tocar ficha → copia el número al campo
  enfocado con origen `ocr-accepted`; tipear → origen `manual`; "Siguiente" pasa al
  próximo campo vacío; "0" explícito con un botón "Cero" al lado de las fichas
  (evita el error más frecuente: dejar vacío lo que vale cero); ⤢ → E-06;
  Validar → E-08.
- Estados: sin OCR disponible (se oculta la franja de fichas, sin error);
  procesando OCR (indicador breve "Leyendo números…" sin bloquear la carga);
  campo editado después de aceptar OCR → vuelve a `manual`; captura confirmada →
  todo deshabilitado con candado.
- Accesibilidad: acciones rápidas de VoiceOver "Ir a la imagen" / "Ir a los campos";
  cada campo anuncia "Lista A, ficticia, Presidente y Vicepresidente, vacío";
  las fichas anuncian "Copiar 98 al campo Lista B"; la imagen tiene etiqueta y no
  atrapa el foco.
- Riesgos específicos: gama baja (mostrar una versión reducida de la imagen, no el
  JPEG completo); Dynamic Type grande (modo "sólo campos"); poca luz (la imagen ya
  está capturada, el problema queda en E-05).
- Aceptación: ningún valor aparece en un campo sin un toque de la persona; cada
  valor viaja con su `origin`; con la plantilla demo hay 2 + 2×7 = 16 celdas y el
  contador refleja las vacías; se puede completar la carga sólo con VoiceOver.

### E-08. Validación [P0]

```
┌────────────────────────────┐
│ ← Validación               │
│                            │
│ ✗ Hay 2 errores            │
│   Falta Diputados: Lista C │
│     [ Ir al campo ]        │
│   Hay más votantes que     │
│   electores habilitados    │
│     [ Ir al campo ]        │
│                            │
│ ⚠ 1 aviso                  │
│   Presidente: la suma no   │
│   coincide con el total de │
│   votantes (223 ≠ 225)     │
│   Si el documento dice     │
│   eso, podés confirmar     │
│   igual con una            │
│   justificación.           │
│                            │
│ [ Confirmar captura ] (off)│
└────────────────────────────┘
```

- Propósito: mostrar el resultado de las reglas del contrato en lenguaje claro y
  llevar a la persona directo al campo a corregir. Con "Todo cierra" se pasa a E-09.
- Contenido: errores (bloquean) y avisos (permiten justificar), con las sumas que
  no coinciden explicitadas; cada ítem con "Ir al campo" → E-07 con foco en el campo.
- Acciones: Ir al campo; Confirmar (habilitado sólo sin errores y con ≥1 página)
  → E-09; [después] "Verificar con otra persona" (F-3).
- Estados: todo cierra (✓ verde + texto "Todo cierra. Revisá una vez más contra la
  imagen antes de confirmar."); sin páginas ("Agregá al menos una imagen.").
- Accesibilidad: anuncio del resumen al entrar ("2 errores, 1 aviso"); cada ítem
  es un botón con el texto completo.
- Aceptación: los textos de cada código (`missing_mesa`, `missing_value`,
  `negative_value`, `votantes_exceed_electores`, `category_total_mismatch`)
  están en un único diccionario revisable; los errores nunca se pueden justificar.

### E-09. Confirmar y bloquear [P0]

```
┌────────────────────────────┐
│ Confirmar captura          │
│                            │
│ Mesa 0421 · Certificado    │
│ 2 páginas · 16 valores     │
│ 1 aviso con justificación: │
│ "El acta dice 223."        │
│ [ ______________________ ] │
│                            │
│ Al confirmar, la captura   │
│ queda bloqueada como       │
│ evidencia: no se puede     │
│ editar ni borrar. Si hay   │
│ un error, hacé una nueva   │
│ captura de la misma mesa.  │
│                            │
│ [ 🔒 Confirmar y bloquear ]│
│ [ Volver a revisar ]       │
└────────────────────────────┘
```

- Propósito: paso explícito e irreversible; la justificación de avisos se escribe
  acá (no en un alert pequeño, como hoy).
- Contenido: resumen; campo de justificación obligatorio si hay avisos (mínimo 5
  caracteres, sin datos personales: se pide "qué dice el documento", no "quién
  sos"); texto de consecuencias.
- Acciones: Confirmar → bloquea (`lockedAt` UTC) → E-10; Volver → E-08.
- Estados: justificación faltante (botón deshabilitado + ayuda); error de
  escritura en disco ("No se pudo guardar. Intentá de nuevo; no se perdió nada.").
- Accesibilidad: anuncio "Captura confirmada y bloqueada" al éxito; el botón de
  confirmar es destructivo-irreversible: estilo prominente, no rojo (no es borrar).
- Aceptación: después de confirmar, ningún campo de E-04/E-06/E-07 es editable;
  intentar editar por código lanza error en el núcleo (ya cubierto por tests).

### E-10. Captura confirmada [P0]

```
┌────────────────────────────┐
│ ← Mesa 0421         🔒     │
│ ⚠ Formulario ficticio      │
│ Certificado · confirmada   │
│ 31/10/2026 20:52           │
│ ┌────────┐ ┌────────┐      │
│ │ pág 1  │ │ pág 2  │ ⤢    │
│ └────────┘ └────────┘      │
│ Huella digital (SHA-256)   │
│ pág 1: 3f9a…c21e           │
│ pág 2: 8b10…77d4           │
│                            │
│ Valores (sólo lectura)     │
│ Presidente · Lista A   123 │
│ ...                        │
│                            │
│ Envío: no configurado      │
│ [ Exportar evidencia ]     │
│ [ Nueva captura de la      │
│   misma mesa ]             │
└────────────────────────────┘
```

- Propósito: ver la evidencia final y sacarla del teléfono.
- Contenido: estado, hora, páginas (ampliables, E-06 en modo lectura), hashes,
  valores en sólo lectura con su origen marcado sutilmente (ícono "OCR" / "tipeado"),
  justificación si la hubo, estado de envío.
- Acciones: Exportar → menú de compartir del sistema con el JSON del contrato +
  JPEGs (y registro `exportedAt`); Nueva captura de la misma mesa → E-02 con
  mesa y tipo precargados; [después] Enviar → E-11.
- Estados: exportada (muestra "Exportada 20:55"); envío pendiente (ver E-11);
  envío no configurado (P0, texto fijo "El envío a un centro de cómputos todavía
  no está disponible. Exportá la evidencia y compartila por el canal que te indique
  tu organización.").
- Accesibilidad: hashes con etiqueta "huella digital de la página 1" y acción
  "Copiar"; lista de valores como tabla accesible.
- Aceptación: el hash mostrado coincide con `shasum -a 256` del JPEG exportado; el
  JSON exportado valida contra `contracts/schemas/capture.schema.json`.

### E-11. Cola de exportación / envíos pendientes [P0 mínimo, D-003 después]

```
┌────────────────────────────┐
│ ← Envíos                   │
│                            │
│ Sin conexión. Las capturas │
│ están guardadas en el      │
│ teléfono y se van a enviar │
│ cuando haya red.           │
│                            │
│ Mesa 0421 · Certificado    │
│   ⏳ Pendiente de envío    │
│ Mesa 0421 · Telegrama      │
│   ✓ Exportada 20:55        │
│                            │
│ [ Reintentar ahora ]       │
└────────────────────────────┘
```

- Propósito: hacer visible que nada se pierde sin red; en P0 sólo lista
  exportaciones hechas y marca "envío no disponible".
- Contenido: estado de red; lista con estado por captura.
- Acciones: Reintentar (P0: deshabilitado con explicación); tocar → E-10.
- Estados: offline (texto de arriba); sin elementos ("No hay envíos pendientes.");
  [después] error de servidor con reintento y sin perder el paquete local.
- Accesibilidad: el estado de red se anuncia al entrar.
- Aceptación: en modo avión, la app no muestra ningún error al capturar,
  validar, confirmar ni exportar por AirDrop/Archivos.

### E-12. Acerca de · plantilla · legal [P0]

- Propósito: transparencia: qué plantilla está en uso (id, versión, si es
  ficticia), versión de la app, qué datos guarda y cuáles no, enlaces al
  repositorio y al marco legal, texto "No es una herramienta de acción política
  partidaria".
- Contenido: lista estática; sin cuenta ni ajustes de red en P0.
- Acciones: [después] activar "modo jornada electoral" a mano (N-C).
- Aceptación: la plantilla mostrada es la que carga `CaptureStore`.

### E-13. Estado: permiso de cámara denegado [P0]

- Pantalla de sistema reemplazada por un estado dentro de E-05 (ver arriba). Se
  lista aparte para que Astra verifique que existe el camino alternativo
  (importar de Fotos) y el botón a Ajustes del sistema.

### Qué cambia respecto del prototipo actual

| Hoy (`HomeView` + `CaptureEditorView`) | Propuesta |
| --- | --- |
| Un solo `Form` con documento, mesa, OCR, valores, validación y acciones | Preparación en 4 pasos (E-02..E-05) + editor partido (E-07) + validación (E-08) + confirmación (E-09) |
| Aviso de Boleta Única como una fila roja del formulario | Pantalla propia obligatoria antes de la cámara (E-02) |
| Imagen como miniaturas de 120 pt | Imagen fija arriba, ampliable, colapsable (E-07) y visor con paginación (E-06) |
| Justificación en un `alert` con `TextField` | Pantalla de confirmación con campo grande y consecuencias (E-09) |
| Fichas OCR en una sección del formulario | Fichas sobre el teclado, ligadas al campo enfocado, más botón "Cero" |
| Sin estado de envío | E-10/E-11 dicen explícitamente que el envío no existe en P0 |

El núcleo (`TelegramaCore`, contratos, vectores) no cambia con esta propuesta;
sólo se propone un campo nuevo opcional (`bupWarningAcknowledgedAt`) que requiere
`contract-change` si el autor lo acepta.

---

## 6. Equivalencias Android (Jetpack Compose / Material 3)

Nivel componente, para que la implementación Android sea equivalente sin decidir
el stack compartido (D-002 sigue pendiente). Los nombres de componentes Android
son los estándar de Compose/Material 3; las dependencias de Google Play services
(escáner, ML Kit) son **propuestas** que requieren consulta antes de instalar.

| Pantalla | iOS (SwiftUI) | Android (Compose / M3) | Nota |
| --- | --- | --- | --- |
| Navegación | `NavigationStack` + `path` | `NavHost` + `rememberNavController`; back predictivo | Sin tab bar en el flujo de escrutinio en ambas |
| E-00 | `Section` con `Label` amarilla | `Card` tonal (`tertiaryContainer`) con `Icon` + `Text`; `semantics { liveRegion }` | M3 no tiene Banner oficial |
| E-01 | `List` + `safeAreaInset` botón | `Scaffold` + `LazyColumn` + `bottomBar` con `Button` ancho completo | Deslizar para borrar: `SwipeToDismissBox` sólo en borradores |
| E-02 | Vista a pantalla completa, `fullScreenCover` | Destino propio del `NavHost`; `BackHandler` descarta borrador | No usar `AlertDialog`: tiene que ser una pantalla |
| E-03 | `Picker` estilo lista / `List` con marca | `Column` de `ListItem` + `RadioButton`, `selectableGroup()` | |
| E-04 | `TextField` `.numbersAndPunctuation` | `OutlinedTextField` con `KeyboardOptions(keyboardType = Number, imeAction = Next)` | Etiquetas visibles, no sólo `placeholder` |
| E-05 escáner | `VNDocumentCameraViewController` (VisionKit) | ML Kit Document Scanner (Play services) **o** CameraX + recorte propio | Decisión pendiente: dependencia de Google vs. control propio; en AOSP sin Play no hay ML Kit |
| E-05 importar | `PhotosPicker` | `ActivityResultContracts.PickMultipleVisualMedia` (Photo Picker) | Sin permiso amplio en ambas |
| E-05 permiso | Estado en pantalla + enlace a Ajustes | `rememberLauncherForActivityResult(RequestPermission)` + estado + `Intent` a ajustes de la app | |
| E-06 visor | `ScrollView` + `MagnifyGesture` | `Image` + `Modifier.transformable` + `graphicsLayer`; `HorizontalPager` para páginas | Botones +/− para accesibilidad en ambas |
| E-07 vista partida | `VStack` (imagen fija) + `Form` | `Column` con `Image` de alto fijo + `LazyColumn`; `imePadding()` | Imagen reducida en memoria (`BitmapFactory.inSampleSize`) |
| E-07 OCR | `Vision` `VNRecognizeTextRequest` (en dispositivo) | ML Kit Text Recognition (en dispositivo) **o** Tesseract | Igual regla: nunca completa solo; `normalizeDigits` del contrato en ambos núcleos |
| E-07 fichas | `ScrollView(.horizontal)` de `Button` | `LazyRow` de `AssistChip` / `SuggestionChip` | Anclado sobre el IME |
| E-08 | `Section` con `Label` por severidad | `LazyColumn` de `ListItem` con `Icon` de severidad + `TextButton` "Ir al campo" | Color + ícono + texto |
| E-09 | Pantalla propia + `TextField` multilínea | Destino propio + `OutlinedTextField(minLines = 3)` + `Button` | Confirmación irreversible: `FilledButton`, no `error` |
| E-10 exportar | `ShareLink(items:)` | `Intent.ACTION_SEND_MULTIPLE` con `FileProvider` URIs | Mismos archivos: JSON + JPEG |
| E-11 | `List` + estado | `LazyColumn` + `ConnectivityManager` para el texto de estado | P0: sólo informativo |
| Almacenamiento protegido | `FileProtectionType.complete`, excluido de iCloud | `EncryptedFile` (Jetpack Security) o cifrado con Keystore; `android:allowBackup="false"`; `dataExtractionRules` | Validar con `security_analyst` |
| Hash | `CryptoKit SHA256` | `java.security.MessageDigest("SHA-256")` | Hex minúsculas en ambos |
| Dynamic Type | `.font(.body)` escalable | `sp` + `fontScale`; probar con 200 % | |
| VoiceOver / TalkBack | `accessibilityLabel`, `accessibilityElement(children: .combine)` | `contentDescription`, `semantics(mergeDescendants = true)`, `stateDescription` | Orden de lectura: `traversalIndex` |
| Modo oscuro | automático con colores semánticos | `dynamicColor = false` (colores propios, no Material You) + `isSystemInDarkTheme()` | Paleta del ícono como `ColorScheme` propio |

---

## 7. Pantallas futuras de la red ciudadana [boceto]

Sólo para que la navegación global y el lenguaje visual sean coherentes cuando
entre la red. Dependen de RC-1/DL-1 (construir o reutilizar Decidim/CONSUL): si se
reutiliza, estas pantallas son vistas nativas sobre esa API o una web embebida, y
el boceto describe el contenido, no la implementación.

### R-01. Espacios temáticos y feed (sin algoritmo de interacción)

```
┌────────────────────────────┐
│ Red               Orden: ▾ │
│ ▸ Plataformas (12 nuevos)  │  Orden visible y elegible:
│ ▸ Desinformación (3)       │  "Más reciente" · "Por tema" ·
│ ▸ Campaña                  │  "Por consenso alcanzado".
│ ▸ Jornada y escrutinio     │  Nunca "Para vos". Nada pago.
│ ▸ Regulación (8)           │  Cada ítem muestra su fuente.
│ ──────────────────────     │
│ 20:40 · Plataformas        │
│ Nueva evidencia A1: ...    │
│ 20:12 · Regulación         │
│ Propuesta v3 publicada ... │
└────────────────────────────┘
```

### R-02. Propuesta estructurada (plantilla obligatoria)

Campos fijos, en este orden: problema · mecanismo · evidencia (enlaces a los ejes
A–D) · base legal · riesgos · alternativas. No se publica sin completar todos. La
cuenta de garantía electoral se ve igual que cualquier otra propuesta.

### R-03. Deliberación a favor / en contra

```
┌────────────────────────────┐
│ ← Propuesta v3             │
│ [ A favor (14) ][ En contra (9) ][ Preguntas (5) ][ Enmiendas (2) ]│
│ ─ A favor ───────────────  │
│ Argumento · fuente ↗       │
│ ...                        │
│ ─ En contra ─────────────  │
│ Argumento · fuente ↗       │
│ [ Agregar argumento ]      │
│ [ Proponer enmienda ]      │
└────────────────────────────┘
```

Sin "me gusta"; los argumentos se ordenan por fecha o por respuestas, nunca por
votos. Las enmiendas son cambios concretos al texto, con diff.

### R-04. Consenso y modalidades de acción

```
┌────────────────────────────┐
│ Consenso                   │
│ Participantes verificados  │
│ 1.240 / mínimo 1.000  ✓    │
│ Acuerdo 78 % / umbral 70 % ✓│
│ Objeciones sin responder 1 ✗│
│ Consenso transversal:      │
│ fuerzas de distinto signo  │
│ 2 / mínimo 3  ✗            │
│ Chequeo legal: pendiente   │
│ ──────────────────────     │
│ Modalidad propuesta:       │
│ Carta abierta a plataformas│
│ Procedimiento · responsable│
│ [ Proponer otra modalidad ]│
└────────────────────────────┘
```

Los umbrales (RC-2) se muestran siempre con su valor publicado; ninguna acción
externa se marca como "en curso" sin el chequeo de `electoral_counsel`.

### R-05. Partidos en igualdad

Directorio con la **misma tarjeta** para cada partido reconocido (nombre,
verificación, enlace a sus argumentos), orden alfabético o aleatorio por sesión
(documentado), sin destacados, sin logos de mayor tamaño, mismos límites de
publicación visibles. Durante la veda: comportamiento a definir (RC-3).

### R-06. Herramientas y agentes de monitoreo

Tablero A4 por plataforma (métricas con definición pública y descarga de datos
agregados), archivo A1 (cargar evidencia con hash igual que un telegrama: mismo
núcleo de evidencia, D-EV-1), estado de cada agente de IA (qué mide, con qué
método, última corrida), y el link a la simulación del AMBA con "SIMULACIÓN"
siempre visible.

### R-07. Perfil

Mínimo: alias, estado de verificación de persona (RC-5), mis propuestas y
argumentos, mis capturas. Nunca se pide ni se muestra afinidad política.

---

## 8. Preguntas para el autor

1. ¿Confirmás la dirección N-C (una app, modo jornada electoral) o preferís
   mantener el escrutinio como app separada (N-B) hasta después de la hackatón?
2. ¿El certificado de escrutinio va preseleccionado en E-03, o sin preselección
   para no sugerir qué documento fotografiar?
3. ¿Aceptás agregar `bupWarningAcknowledgedAt` al contrato (requiere
   `contract-change`)? Alternativa: no registrar nada y confiar en el flujo.
4. ¿Querés F-3 (doble carga) en P0 en su variante mínima (re-tipear sólo `votantes`
   y los totales por categoría a ciegas), o queda para después?
5. ¿El botón "Cero" explícito (E-07) te parece bien o preferís que un campo vacío se
   trate como 0 con un aviso? (Hoy el contrato exige valor explícito: `missing_value`.)
6. ¿Para la demo de la hackatón, el aviso de plantilla ficticia (E-00) puede ser
   la franja amarilla permanente o preferís algo menos invasivo?
7. ¿Se muestra el origen OCR/tipeado por valor en E-10 (transparencia) o sólo en
   el JSON exportado (pantalla más simple)?
8. ¿Querés que el prototipo incluya E-12 (Acerca de) ahora o sólo E-00..E-11?

---

## 9. Puntos a validar por Astra (revisión)

Checklist concreta para quien revise esta propuesta:

1. **Legal, flujo:** que no exista ningún camino a la cámara sin pasar por E-02 y
   que E-03 sólo ofrezca telegrama/acta/certificado (telegram-capture, marco legal 3.2).
2. **Legal, textos:** que ninguna pantalla hable de "fraude", "denuncia" ni
   presente la captura como reclamo (marco legal 3.4 y 6); que E-10/E-11 no
   publiquen ni agreguen resultados (art. 71 h).
3. **Datos personales:** que ninguna pantalla pida nombre, DNI, partido, ubicación
   ni contactos; que la justificación de E-09 no induzca a identificarse; que F-3
   no registre identidades.
4. **Evidencia:** que E-06 no permita editar imágenes y que E-10 muestre el hash de
   cada página; que "Quitar página" sólo exista en borrador.
5. **Neutralidad:** que las etiquetas de filas vengan de la plantilla y que ninguna
   pantalla destaque una agrupación; que R-05 describa la misma tarjeta para todos.
6. **Consistencia con el contrato:** que cada pantalla mapee a campos existentes de
   `capture.schema.json` y que el único campo nuevo esté marcado como pendiente.
7. **Alcance P0:** que lo marcado [P0] coincida con "Alcance del prototipo" de
   telegram-capture y que no se cuele D-003 (envío) como funcionalidad.
8. **Accesibilidad:** que cada pantalla [P0] declare etiquetas, orden de lectura y
   comportamiento con Dynamic Type; que E-07 tenga el modo "sólo campos".
9. **Condiciones de campo:** que E-05 contemple poca luz (linterna, consejos) y que
   E-07 contemple gama baja (imagen reducida); que todo funcione offline.
10. **Android:** que cada pantalla tenga equivalente de componente y que las
    dependencias de Google (ML Kit) figuren como propuestas, no como decisiones.
11. **Propuesta vs. decisión:** que el documento no fije arquitectura (N-A/N-B/N-C,
    D-002) ni stack, y que cada recomendación esté etiquetada como propuesta.
12. **Coherencia visual:** que los textos de interfaz sean rioplatenses y simples,
    y que el lenguaje de "cuidar el proceso" (no "controlar", no "vigilar") se
    mantenga en todas las pantallas.

---

## 10. Criterios de aceptación de esta SPEC

1. El autor elige una arquitectura global (N-A/N-B/N-C) o pide otra alternativa.
2. El autor elige el flujo de escrutinio (F-1/F-2/F-3/híbrido) y, si corresponde,
   se actualiza la sección UX de telegram-capture.
3. Las pantallas E-00..E-13 aceptadas pasan a tareas con `.agents/templates/task.md`,
   una por pantalla o por grupo de pantallas, con el prototipo actual como base.
4. Revisión de Astra registrada con los 12 puntos de la sección 9, y chequeo de
   `electoral_counsel` sobre E-02, E-03, E-09, E-10 y la sección 3 (veda y modo jornada).
