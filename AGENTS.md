# Instrucciones de CuentaConmigo

## Producto y alcance

**Red social ad hoc, ciudadana y no partidaria, para cuidar el proceso democrático**
de las elecciones argentinas de 2027, en las que se elige presidente y se renueva el
Congreso. La acción política que hoy ocurre en redes de grandes empresas se canaliza
en un espacio propio para debatir, llegar a consensos y decidir modalidades de acción.
**No es una herramienta de acción política partidaria:** cuida las reglas de juego.
Producto central: [civic-network](sdd/specs/civic-network/SPEC.md). Prioridades:
[visión](sdd/specs/vision/SPEC.md).

- Todos los partidos políticos participan **en igualdad** de herramientas, reglas y visibilidad.
- **Consenso antes que acción:** ninguna acción externa (frente a plataformas,
  organismos o quien sea) se ejecuta sin un consenso registrado en la red y el
  chequeo de `electoral_counsel`.
- **La experiencia de usuario es fundamental** (instrucción del autor, 31/10/2026).
  Cada SPEC, prototipo y pantalla prioriza el ahorro de tiempo y de errores de quien
  usa la app: elegir en lugar de tipear (listas desplegables, sugerencias), completar
  lo que ya se sabe, pocos pasos y textos claros. Las revisiones evalúan la UX igual
  que la legalidad y la neutralidad.

Herramientas que la red puede activar por consenso:

- **A. Plataformas**: uso indebido de publicidad electoral, algoritmos,
  desinformación, veda y compromisos, medidos con herramientas propias.
- **B. Desinformación**: detección, verificación y respuesta comunitaria.
- **C. Campaña**: gasto y publicidad declarada vs. observada, plazos y debates.
- **D. Jornada y escrutinio**, para cerrar el proceso de auditoría ciudadana:
  captura de telegramas y actas, cotejo y proyección.
- **E. Propuestas y regulación**: deliberación de iniciativas (cualquiera puede
  proponer) y su consolidación para incidencia parlamentaria.

La SPEC de cada módulo (en `sdd/specs/`) es la fuente del producto. Leerla antes de
cambiar comportamiento. Ninguna tecnología, stack ni arquitectura está decidida:
cualquier elección es una propuesta hasta que la acepte el autor.

- Consultar **antes de decidir arquitectura** y **antes de instalar** herramientas
  o dependencias, incluso locales o temporales.
- Neutralidad: no favorecer partidos ni candidatos en código, textos, datos ni
  criterios de verificación. Las mismas métricas valen para todos los actores.
- Herramientas externas: no usar los mecanismos de denuncia de las plataformas como
  estrategia. Medir y documentar lo que hacen las plataformas; la desinformación se
  refuta con fuentes y no se busca silenciar a personas.
- Toda captura (telegrama, publicación, anuncio) es evidencia: conservar originales inmutables, procedencia y cadena
  de custodia. Separar lo extraído automáticamente de lo confirmado por personas.
  No afirmar irregularidades sin evidencia verificable.
- Datos personales (nombres, DNI, firmas, teléfonos, ubicación de voluntarios)
  quedan fuera de Git y se tratan según la Ley 25.326. Sólo datos ficticios o
  anonimizados en tests y ejemplos.
- La aceptación de producto, las pruebas de campo y cualquier contacto con
  autoridades, partidos, medios o plataformas corresponden al autor.

## Idioma

- El proyecto se desarrolla y se discute **en español**. Las SPECs, los documentos,
  las decisiones y las conversaciones con el autor se escriben en español, que es
  la versión de referencia.
- Todo documento tiene una **traducción automática al inglés** en
  `translations/en/<misma ruta>`. Cada traducción indica en su encabezado el commit
  del original y que en caso de diferencia vale el original en español.
  Al cambiar un documento, regenerar su traducción en un commit propio.
- Código, identificadores, comentarios de código y mensajes de commit van en inglés.
  Los textos de la app que ve el usuario, en español rioplatense.

## Prioridad de las instrucciones del autor

Lo que dice el autor (`kenarab`) vale más que lo escrito en el repositorio, incluidas
estas reglas y las SPECs. Si un documento contradice una instrucción del autor, el
documento está mal: se aplica la instrucción y se corrige el documento. Ante la duda,
consultar. Los agentes inevitablemente toman decisiones, pero primero siguen lo que
pide el autor; pueden advertir riesgos (legales, de datos o de neutralidad) antes de
hacerlo. El rol `consistency_reviewer` detecta y corrige las inconsistencias.

## Fuente única y coordinación

`AGENTS.md` contiene las reglas comunes de Codex y Claude Code. `CLAUDE.md` lo
importa. Memoria compartida: repositorio, SPEC, planes y evidencia; no depender
para el traspaso de memorias privadas de una herramienta.

Roles portables en [.agents/manifest.json](.agents/manifest.json), resumen en
[MULTIAGENT_ROLES.md](MULTIAGENT_ROLES.md), registro en
[sdd/agents.json](sdd/agents.json) y [guía de configuración](docs/agent-setup.md).
Cargar este archivo, el rol asignado y una tarea acotada antes de trabajar.
Estos archivos son instrucciones declarativas: no son un sandbox ni activan agentes.

- El autor asigna tareas y herramientas. Una sesión coordinadora por checkout;
  un escritor por archivo. Revisar estado, worktrees y tareas activas antes de editar.
- Máximo dos agentes IA activos en este proyecto, incluido el coordinador, y cuatro
  globales entre herramientas. Es un límite, no permiso para lanzar procesos.
  No delegar ni iniciar subagentes sin instrucción explícita del autor.
- Usar [.agents/templates/task.md](.agents/templates/task.md): objetivo, dueño, rol,
  herramienta/modelo efectivo, revisión base, lecturas, escrituras exclusivas,
  dependencias, aceptación, comandos, evidencia y estado de revisión.
- Mantener el modelo/proveedor de la sesión o el elegido explícitamente por el
  autor; no fijar modelos por el nombre del rol ni sustituirlos silenciosamente.
  No activar API facturada, créditos o fallback para cargar/verificar perfiles.
- Revisor independiente distinto del implementador, con identidad y revisión
  registradas. Si sólo hay autocontrol, decirlo; no inventar revisión independiente.
- Sólo el coordinador integra Git. No usar un worktree reservado por otra herramienta
  ni cambiar la rama de un checkout ajeno. Ramas nuevas con sufijo `-codex` o `-claude`.

## Especificación, verificación y traspaso

**Riesgo legal permanente:** toda SPEC, decisión, texto público o acción externa
pasa por el rol `electoral_counsel`, que analiza los riesgos y las consecuencias
legales y recomienda líneas de acción ([rol](.agents/roles/electoral_counsel.md)).
Un ⛔ suyo frena la integración hasta que decida el autor. No reemplaza a un abogado
o abogada electoral humano.

Aplicar SDD proporcionado al cambio: problema/alcance, decisiones vigentes y pendientes,
criterios de aceptación, plan, responsable, implementación y evidencia verificable.
Actualizar la SPEC correspondiente **antes** de cambiar comportamiento o interfaz.
[sdd/README.md](sdd/README.md) explica el flujo. Una propuesta o revisión no equivale
a aceptación del autor.

**Prototipación de pantallas:** ninguna pantalla se implementa sin un prototipo navegable
aprobado (`design/prototypes/`), según [review-pipeline](sdd/specs/review-pipeline/SPEC.md).

Ejecutar comprobaciones pertinentes al diff y conservar comandos, revisión y
resultados. No instalar herramientas faltantes ni repetir pruebas sin justificación.
Un simulador o imágenes de ejemplo no acreditan funcionamiento en campo.

## Trabajo y temporales

Trabajar sólo en repositorios autorizados bajo `~/home.codex/git`
(`~/home.codex` enlaza a `~/home.agents`; no cambiar HOME ni CODEX_HOME).
Temporales, cachés y logs van a `~/home.codex/tmp`:

```sh
export TMPDIR="$HOME/home.codex/tmp" TMP="$HOME/home.codex/tmp" TEMP="$HOME/home.codex/tmp"
export npm_config_cache="$HOME/home.codex/tmp/npm-cache" PYTHONDONTWRITEBYTECODE=1
```

Secretos y estado durable privado quedan fuera de Git en `.private/` y `.runtime/`.
**Datos fuera de Git reproducibles:** quien baje o genere datos que quedan fuera de Git
(`data/private/`, recursos ignorados de la app) deja en el mismo commit un manifiesto
(URL, licencia, fecha, SHA-256) y un script que los reconstruye y verifica en otra
computadora, enganchado en `scripts/private-data.sh`. Nunca bajar a mano sin dejar el script.
No copiar credenciales, conversaciones ni datos personales a este repo.

## Git e integración

- **Equipo:** el autor (`kenarab`) y Andy (`andytow`, colaborador en GitHub).
  Andy integra sus cambios mediante **pull requests** a `main`. Las sesiones de
  agentes del autor commitean y pushean directo a `main`.
- **Varias computadoras, varias personas y agentes a la vez:** al empezar **cada
  tarea** ejecutar `scripts/sync.sh` (pull con rebase y autostash, con un resumen);
  Claude Code lo hace solo con el hook `SessionStart` de `.claude/settings.json`, y
  Codex y las personas lo corren a mano. Repetirlo antes de cada push. Push
  inmediatamente después de cada commit atómico. Revisar los PRs abiertos
  (`gh pr list`) y los issues asignados al empezar.
- **No pisarse:** tomar la tarea en su issue y anunciar las rutas que se van a tocar;
  un escritor por archivo; trabajos largos en rama `<persona|herramienta>/<tema>` con PR;
  los archivos generados se regeneran desde su fuente. Guía para todos: [CONTRIBUTING.md](CONTRIBUTING.md).
- Los conflictos se resuelven preservando el trabajo de ambos; ante una duda de
  contenido se consulta al autor, nunca se descarta un cambio ajeno.
- Un PR de Andy se revisa contra su SPEC como cualquier otro cambio. Mergearlo es
  decisión del autor, salvo que el autor autorice expresamente lo contrario.
- Preservar cambios ajenos e índice. Commits atómicos en inglés: un propósito,
  rutas explícitas, diff staged revisado y comprobaciones proporcionadas.
  No usar `git add .`, `git add -A` ni añadir carpetas completas con trabajo ajeno.
- Identificar commits por herramienta sin cambiar configuración Git global:
  Codex usa `alejandro baranek <alejandrobaranek+codex@gmail.com>`; Claude usa
  `alejandrobaranek+claude@gmail.com`. No reescribir identidad ni historia previas.
- Cambios probados se integran en main y se publican en el origin autorizado
  (`github.com/kenarab/cuentaconmigo`), siguiendo la práctica vigente del autor en
  sus proyectos. No implica despliegues. Nunca force-push, reescritura ni remotos
  nuevos. Pruebas pendientes o bloqueadas no equivalen a aprobadas.
