# Traspaso · 31/10/2026 · sesión Claude (checkout principal, Mac del autor)

Objetivo que deja abierto: **terminar los milestones M1 y M2 de la hackatón**
(<https://github.com/kenarab/cuentaconmigo/milestone/1>, `/milestone/2`), avanzando
todo lo posible sin consultar al autor. Quien continúe: correr `scripts/sync.sh`,
leer `AGENTS.md`, `CONTRIBUTING.md` y este archivo, y tomar la tarea en su issue.

## Hecho en esta sesión

| Qué | Dónde | Estado |
| --- | --- | --- |
| Prototipo navegable de escrutinio E-00..E-13 | `design/prototypes/escrutinio/index.html`, publicado (privado) en <https://claude.ai/artifact/KNrbEwf8hhBJv8bNZgY6gz> | Hecho; link en issue #2 |
| SPEC de pantallas con estado del pipeline y cómo revisar | `sdd/specs/app-screens/SPEC.md` | Hecho |
| Sincronización entre computadoras | `scripts/sync.sh`, hook `SessionStart` en `.claude/settings.json`, `CONTRIBUTING.md`, regla en `AGENTS.md` | Hecho |
| Tags y portada de HackDash | `docs/hackdash.md` | Hecho |
| App instalada y abierta en el iPhone 12 Pro del autor (por red) | `sdd/specs/telegram-capture/VERIFICATION.md`, issue #11 | Hecho; falta la prueba del flujo por el autor |
| Detección del UDID en el script de instalación | `ios/scripts/install-device.sh` (`f5b7439`) | Hecho |
| **Borrador** del flujo de captura como statechart JSON | `contracts/flows/capture.flow.json` | Borrador sin vectores ni intérprete (issue #14) |
| Issues #13, #14, #15 reservados por esta sesión | comentarios en cada issue | Liberarlos o retomarlos (ver abajo) |

## Pendiente por issue

### M1 (15:00)

- **#1 Decidir funcionalidades y alcance** (autor + Andy): sin respuestas todavía.
  `sdd/specs/roadmap/FEATURES.md` tiene la propuesta P0.
- **#11 Probar la app en el iPhone** (autor): instalada; recorrer escanear → cargar →
  confirmar → exportar y anotar criterios 4 y 5 en VERIFICATION.md. Reinstalar con
  `ios/scripts/install-device.sh 00008101-001A344034D0001E` (la Mac tiene que estar en
  la misma red que el teléfono; en la red de la casa no lo veía, sí en la del teléfono).
- **#12 Cerrar sesiones extra** (autor).
- **#13 Traducciones al inglés** (Claude): nada hecho. `translations/en/` sólo tiene
  `data/` (de Andy). Documentos listados en el issue: amba-simulation, scrutiny-backend,
  fiscal-planning, app-architecture, trust-chain-identity, telegram-capture, app-screens,
  FEATURES, contracts/README. Skill `translate-docs`; un commit por documento con el
  encabezado (commit del original, vale el español).

### M2 (16:00)

- **#2 Decidir pantallas** (autor + Andy): Andy ya respondió (N-C, F-1, certificado
  preseleccionado, doble carga mínima ya, vacío = 0 con aviso, aviso ficticio sólo en
  "Acerca de", mostrar origen OCR). Falta la respuesta del autor y aplicar el consenso
  (skill `hitl-decisions`).
- **#3 Decidir simulación del AMBA** (autor + Andy): sin respuestas.
- **#14 Prototipo con F-1/F-2/F-3 sobre el flujo en JSON** (Claude/Fable). Diseño ya
  definido en `contracts/flows/capture.flow.json` (estados E-02..E-10, región `editing`
  con datos manejados en el padre para que F-2 tenga orden libre, rama F-3
  `handoff → values2 → compare`, guardas y acciones con nombre). Falta:
  1. `contracts/flows/README.md` con la semántica: estado hoja con ruta `a.b`; el evento
     se busca de la hoja a la raíz; candidatos en orden, gana el primero cuyas guardas
     pasan (`!` niega); sin manejador o guardas fallidas = evento ignorado sin cambios;
     acciones puras antes de efectos; destino compuesto entra por `initial`.
  2. Intérprete JS de referencia (`contracts/flows/flow-machine.js`, UMD, sin
     dependencias) con las guardas/acciones nombradas y el validador portado de
     `ios/TelegramaCore/.../Validation.swift`, y un runner en Node que corra
     `contracts/vectors/validation.json` y los nuevos `contracts/vectors/capture-flow.json`
     (`{name, events, expectState, expectEffects (del último evento), expectContext?,
     expectIgnored?}`), con negativos: no saltear `bupWarning`, nada editable tras
     `confirmed`, `confirm` con errores ignorado.
  3. Doble carga mínima (AS-5 a, respuesta de Andy): la segunda persona tipea
     `header.votantes` y el total de cada categoría; se compara con la suma de la primera.
  4. Prototipo `design/prototypes/flujo/index.html` que cargue el mismo JSON (generar
     `capture.flow.js` para que funcione con `file://`), con selector F-1/F-2/F-3 dentro
     de la pantalla E-12 del teléfono simulado, panel con estado, contexto y efectos, y
     tokens de color de `design/prototypes/escrutinio/index.html`. Publicarlo como
     Artifact y dejar el link en #14.
  5. Revisión Astra (`ux`, `legal`, `neutrality`) sólo si el autor la autoriza.
  Decisiones AA-2, AA-3 y AA-5 siguen abiertas: se trabaja con la opción ★ como propuesta.
- **#15 Simulación AMBA** (Claude): la cobertura del IC ya está medida (05dc1e1). Falta
  el cotejo de totales contra lo publicado (criterio 4 de
  `sdd/specs/amba-simulation/SPEC.md`) y verla en un navegador
  (`design/prototypes/simulacion-amba/index.html`).
- **#16 Chequeo legal y de ciberseguridad** (otra sesión, "en curso"): no tocar sin
  coordinar en el issue.

## Otros pendientes fuera de los milestones

- Traducciones al inglés de todos los documentos (regla de `AGENTS.md`).
- Chequeos de electoral_counsel sobre civic-network, civic-deliberation y reg-electoral-escrow.
- HL-1 (revisión diaria programada): decisión en el issue #9.

## Cuidado

- Hay otra sesión de Claude pusheando desde otra computadora: sincronizar antes de cada
  commit y anunciar rutas en el issue.
- Máximo dos agentes IA activos en el proyecto.
