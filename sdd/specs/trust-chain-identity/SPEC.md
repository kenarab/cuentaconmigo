# SPEC · Identidad sin datos personales: cadenas de confianza por QR

Estado: **propuesta del autor (31/10/2026) redactada para su revisión; decisiones TC-n
pendientes; chequeo de `electoral_counsel` (legal y ciberseguridad) pendiente.**
Responde a RC-5 de [civic-network](../civic-network/SPEC.md) y PP-3 de
[participant-protection](../participant-protection/SPEC.md), y precisa RC-3 (partidos).
Afecta la autenticación de [scrutiny-backend](../scrutiny-backend/SPEC.md) y
[fiscal-planning](../fiscal-planning/SPEC.md).

## Idea del autor

- La gente entra **sin dar información personal**: alguien que ya está adentro la
  invita en persona con un **QR**. No conocemos identidades, pero sí quién invitó a quién.
- Si aparece un agente malicioso, se investiga **la subred que lo invitó**.
- Hay una **jerarquía**: las personas más comprometidas y activas pueden invitar a más
  gente que otras.
- Los **partidos políticos** sí se registran con **responsables identificados** y
  tienen características especiales.

## Cuentas de personas

1. **Alta por QR, en persona.** La app de quien invita genera un QR de un solo uso,
   firmado con la clave de su dispositivo y de vida corta (por ejemplo, 2 minutos).
   La persona invitada lo escanea, su teléfono genera su propio par de claves y elige
   un seudónimo. El servidor guarda la clave pública, el seudónimo y la arista
   `invitó → invitada` con la fecha. **No guarda** nombre, DNI, teléfono, mail ni ubicación.
2. **Sesión:** el dispositivo firma cada pedido con su clave (guardada en el Secure
   Enclave o Keystore). Es la misma base que el `deviceToken` de scrutiny-backend.
3. **Recuperación** (pérdida del teléfono): recuperación social. Quien la invitó y
   otra persona de nivel suficiente confirman en persona una clave nueva. La cuenta
   vieja queda revocada.

## Niveles y cupos de invitación

Los niveles dependen de la **conducta en la red**, nunca del partido, la ideología o el
contenido de las opiniones. Los valores son propuestas para calibrar (TC-2).

| Nivel | Cómo se llega | Puede | Cupo de invitaciones |
| --- | --- | --- | --- |
| 0 · Nueva | Por invitación | Leer, deliberar, cargar capturas (requieren segunda verificación) | 0 |
| 1 · Activa | 14 días y aportes confirmados por otras personas (por ejemplo, 3 capturas coincidentes o 5 aportes valorados) | Lo anterior y respaldar propuestas | 2 por mes |
| 2 · Comprometida | 60 días en nivel 1, aportes sostenidos y ninguna sanción | Lo anterior, verificar capturas de otros y recuperar cuentas | 5 por mes |
| 3 · Referente | Elegida por pares de nivel 2 o más, con mandato renovable | Lo anterior, organizar eventos de alta masiva con cupo especial, moderar | 20 por mes o por evento |

- El cupo se **renueva** con el tiempo. Lo no usado no se acumula sin límite.
- **Responsabilidad hacia arriba:** si alguien invitado resulta malicioso, quien
  invitó pierde cupo temporalmente y su nivel queda en revisión. Así se cuida a
  quién se invita, sin castigar por adelantado.

## Detección e investigación de agentes maliciosos

- **Señales:** capturas que divergen de forma sistemática de las de otras personas en
  la misma mesa; volumen anómalo; muchas cuentas nuevas de una misma rama que actúan
  coordinadas; reportes de pares.
- **Análisis del grafo:** los atacantes suelen crear muchas cuentas falsas que se
  conectan poco con la red honesta (ataque Sybil). Los métodos de ranking por grafo
  de confianza aprovechan ese patrón. Se aplican a la estructura de invitaciones, no
  al contenido.
- **Contención proporcional, no expulsión masiva:**
  1. Cuarentena de la cuenta señalada: sus aportes dejan de contar para consensos y
     agregados.
  2. Se congelan los cupos de su rama (quien la invitó y quienes invitó).
  3. Se investiga la subred con registro de auditoría. Las personas afectadas pueden
     apelar.
  4. Sólo con evidencia: revocación de las cuentas involucradas y recálculo de lo
     que hayan aportado. Lo extraído y lo confirmado se recalculan por separado.
- Ninguna medida se basa en opiniones políticas expresadas.

## Partidos políticos

- **Registro institucional** con responsables identificados (por ejemplo, apoderados),
  verificado contra el registro de la justicia electoral (a verificar con
  `electoral_counsel`). Los datos personales de los responsables se tratan con su
  consentimiento, fuera de Git y con acceso restringido.
- **Mismas características para todos los partidos** (neutralidad):
  - cuenta institucional rotulada como tal, separada de las cuentas de personas;
  - publicación de posiciones oficiales en los espacios de deliberación, con las
    mismas reglas y límites;
  - **alta de sus fiscales** con un QR institucional: las cuentas quedan rotuladas
    "fiscal de [partido]", fuera de la jerarquía ciudadana. No suman cupos ni niveles
    ciudadanos, para que un partido no pueda capturar la red;
  - asignación de mesas a sus fiscales (se integra con
    [fiscal-planning](../fiscal-planning/SPEC.md));
  - la misma vista de capturas y cotejos que cualquier persona. Sin acceso a la
    identidad ni al grafo de las personas.
- Las acciones de la red siguen requiriendo consenso. Un partido no tiene más votos
  por ser partido.

## Datos personales y riesgos

- **El grafo de invitaciones es sensible.** En un contexto político puede revelar redes
  de afinidad. Las opiniones políticas son datos sensibles (Ley 25.326, art. 2 y 7, a
  verificar). Propuesta: guardar las aristas cifradas, con acceso sólo para
  investigaciones registradas y con retención limitada (TC-5).
- Nada del grafo se publica. Las estadísticas públicas son agregadas.
- Riesgo de **coerción** (alguien obligado a invitar o a entregar su teléfono): cupos
  bajos, revocación rápida y recuperación social.
- Riesgo de **exclusión**: quien no conoce a nadie adentro no puede entrar. Se mitiga
  con eventos de alta masiva de referentes y de organizaciones aliadas (PP-3).

## Decisiones pendientes

| ID | Decisión | Opciones |
| --- | --- | --- |
| TC-1 | Método de alta | QR en persona ★ · QR también a distancia (link) con cupo menor · ambos con rótulo distinto |
| TC-2 | Niveles y cupos | Tabla de arriba como punto de partida ★ · menos niveles (0/1/2) · cupos fijos sin niveles |
| TC-3 | Responsabilidad hacia arriba | Pérdida temporal de cupo ★ · sin consecuencias · degradación de nivel |
| TC-4 | Quién investiga una subred | Equipo de moderación elegido (RC-4) ★ · operador de la red · comité mixto con partidos |
| TC-5 | Almacenamiento del grafo | Cifrado con acceso registrado y retención limitada ★ · en claro con control de acceso · sólo en los dispositivos (dificulta investigar) |
| TC-6 | Partidos: verificación de responsables | Contra el registro de la justicia electoral ★ · declaración jurada · ambos |
| TC-7 | Fiscales de partido en la jerarquía | Fuera de la jerarquía ciudadana ★ · dentro, con nivel 0 · elección del fiscal |
| TC-8 | Credenciales anónimas (prueba de que alguien es una persona sin vincularla a su cuenta) | Después de la hackatón ★ · ahora |

## Criterios de aceptación

1. Un alta por QR completa en menos de 1 minuto entre dos teléfonos, sin pedir ningún
   dato personal.
2. Un QR usado, vencido o con la firma alterada se rechaza (vectores de contrato).
3. Con una rama simulada de 50 cuentas falsas invitadas desde una sola cuenta, el
   análisis del grafo las marca y la contención las deja fuera de los agregados sin
   afectar a más del 1 % de las cuentas honestas (a medir en simulación).
4. Los cupos y niveles se calculan sólo con señales de conducta: lo verifica una
   revisión de neutralidad.
5. Los partidos tienen exactamente las mismas funciones entre sí.

## Chequeo de electoral_counsel (legal y ciberseguridad): pendiente

A evaluar: datos sensibles y grafo social (Ley 25.326); verificación y datos de los
responsables de partidos; rótulo de fiscales de partido; modelo de amenazas (Sybil,
robo de dispositivo, coerción, abuso de cupos, compromiso de una cuenta de nivel 3,
ataque al servidor el día de la elección); controles de NIST SP 800-63 y OWASP MASVS
que apliquen.
