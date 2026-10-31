# Funcionalidades candidatas

Fecha: 31/10/2026. Backlog inicial que surge de las SPECs. La **prioridad propuesta** es
una recomendación del coordinador de diseño, **no una decisión**. La deciden el autor y
Andy en el issue de priorización (`decision-humana`). Después, la red ciudadana
podrá proponer funcionalidades nuevas por consenso ([civic-network](../civic-network/SPEC.md)).

Prioridad propuesta: **P0** hackatón · **P1** siguiente versión · **P2** más adelante.
Estado: ✅ implementado (prototipo) · 🟡 parcial · 🎨 en prototipo de pantallas · 📝 sólo SPEC · ❓ sin SPEC.

## D · Jornada y escrutinio (cierre del proceso de auditoría ciudadana)

| ID | Funcionalidad | SPEC | Depende de | Prioridad propuesta | Estado |
| --- | --- | --- | --- | --- | --- |
| F-01 | Escanear telegrama, acta o certificado (escáner nativo) e importar desde Fotos | telegram-capture | — | P0 | ✅ |
| F-02 | Cargar valores según la plantilla y validar (errores y avisos) | telegram-capture | — | P0 | ✅ |
| F-03 | Confirmar y bloquear la captura como evidencia (hash SHA-256 y fecha) | telegram-capture | — | P0 | ✅ |
| F-04 | Exportar el paquete de evidencia con aviso de datos personales y veda de proyecciones | telegram-capture, app-screens | AS-11 | P0 | 🟡 |
| F-05 | Flujo guiado: aviso de Boleta Única → tipo → mesa → escaneo → carga | app-screens | AS-1, AS-2 | P0 | 🎨 |
| F-06 | Sugerencias de OCR en el contexto de cada fila | app-screens | AS-2 | P1 | 📝 |
| F-07 | Doble carga a ciegas (verificación cruzada) | app-screens | AS-5 | P1 | 📝 |
| F-08 | Envío a recepción central | mobile-platform, scrutiny-backend | D-003, SB-1 | P1 | 📝 |
| F-09 | Cotejo con el escrutinio provisorio y el definitivo | telegram-capture | F-08, datos oficiales | P2 | 📝 |
| F-10 | Simulación geolocalizada del AMBA con proyección | amba-simulation | S-1, S-2, S-3 | P0 | 🟡 |
| F-11 | App Android nativa equivalente | mobile-platform | D-002 | P1 | 📝 |
| F-12 | Backend local: ingesta de capturas, OCR en servidor, revisión humana y espejo oficial | scrutiny-backend | SB-1…SB-4 | P0 | 📝 |
| F-13 | Conteo rápido propio sobre una muestra de mesas, antes que el oficial | scrutiny-backend, amba-simulation | SB-5, SB-6, S-3 | P1 | 📝 |
| F-14 | Modo planificación para fiscales que cubren varias mesas, con avisos de capturas de terceros | fiscal-planning | FP-1…FP-6 | P1 | 📝 |
| F-15 | Sugerir el establecimiento con la ubicación pedida a demanda (nunca en segundo plano, sin guardarla) | telegram-capture, app-screens | dataset de establecimientos (Q1) | P1 | 📝 |
| F-16 | Identificar la mesa con listas desplegables en cascada y autocompletado (UX fundamental) | telegram-capture, app-screens | nómina de establecimientos (Q1) | P0 | 📝 |
| F-17 | Modo demostración: elegir un telegrama oficial de ejemplo (muestras de Andy, fuera de Git) que completa la mesa | telegram-capture | contrato `sample` | P0 | 🟡 |

## Red ciudadana (producto central)

| ID | Funcionalidad | SPEC | Depende de | Prioridad propuesta | Estado |
| --- | --- | --- | --- | --- | --- |
| F-20 | Espacios temáticos con orden transparente (sin algoritmo de interacción) | civic-network | RC-1 | P1 | 📝 |
| F-21 | Propuestas estructuradas y deliberación a favor y en contra | civic-deliberation | RC-1, DL-1 | P0 (demo) | 📝 |
| F-22 | Medición de consenso y activación de modalidades de acción | civic-network | RC-2 | P1 | 📝 |
| F-23 | Proponer funcionalidades de la app y decidirlas por consenso | civic-network | F-21, F-22 | P1 | 📝 |
| F-24 | Cuentas institucionales de partidos en igualdad | civic-network | RC-3 | P2 | 📝 |
| F-25 | Identidad seudónima y verificación de que se trata de una persona | civic-network, participant-protection, trust-chain-identity | RC-5, PP-3, TC-1 | P1 | 📝 |
| F-26 | Alta por QR en cadenas de confianza, niveles y cupos de invitación, contención de subredes maliciosas | trust-chain-identity | TC-1…TC-5 | P1 | 📝 |
| F-27 | Registro de partidos con responsables identificados y alta de sus fiscales | trust-chain-identity, civic-network | RC-3, TC-6, TC-7 | P1 | 📝 |

## A · Plataformas

| ID | Funcionalidad | SPEC | Depende de | Prioridad propuesta | Estado |
| --- | --- | --- | --- | --- | --- |
| F-30 | Archivo de evidencia viral (A1) | platform-accountability | P-3 | P0 | 📝 |
| F-31 | Re-chequeo automático del estado público de cada URL | platform-accountability | F-30 | P0 | 📝 |
| F-32 | Tablero público de plataformas (A4) | platform-accountability | F-30 | P0 (mínimo) | 📝 |
| F-33 | Agentes de IA que monitorean en tiempo real el comportamiento de las plataformas | — | P-1 | P1 | ❓ |
| F-34 | Auditoría colectiva de publicidad electoral indebida (A2) | platform-accountability | P-1 | P1 | 📝 |
| F-35 | Panel ciudadano de exposición, con donación de datos (A3) | platform-accountability | P-4, PP-* | P2 | 📝 |

## E · Propuestas y regulación

| ID | Funcionalidad | SPEC | Depende de | Prioridad propuesta | Estado |
| --- | --- | --- | --- | --- | --- |
| F-40 | Cuenta de garantía electoral publicada como primera propuesta a deliberar | reg-electoral-escrow | F-21 | P0 (demo) | 📝 |
| F-41 | Documento de incidencia exportable desde una propuesta con consenso | civic-deliberation | F-22 | P2 | 📝 |

## Transversal · Protección de participantes

| ID | Funcionalidad | SPEC | Depende de | Prioridad propuesta | Estado |
| --- | --- | --- | --- | --- | --- |
| F-50 | Evidencia preservada vs. copia publicable (datos tapados, sin EXIF) | participant-protection | PP-6 | P1 | 📝 |
| F-51 | Inventario de datos y retención mínima | participant-protection | PP-7 | P1 | 📝 |

## Propuesta de alcance para la hackatón (P0)

App de escrutinio con flujo guiado (F-01 a F-05), simulación del AMBA (F-10), una
deliberación de muestra con la cuenta de garantía electoral (F-21, F-40) y un archivo de
evidencia viral con un tablero mínimo (F-30 a F-32).
