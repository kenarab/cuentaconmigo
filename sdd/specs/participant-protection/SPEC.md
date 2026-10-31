# SPEC · Protección de participantes contra la persecución, por diseño

Estado: **propuesta; definir rol y acciones concretas queda pendiente del autor (PP-1 a PP-5).**
Fecha: 31/10/2026. Visión: [sdd/specs/vision/SPEC.md](../vision/SPEC.md).
Chequeos requeridos: electoral_counsel, data_protection_officer, security_analyst.

## Problema

Una red de personas que cuidan el proceso electoral, auditan plataformas y proponen
regulaciones puede ser blanco de persecución. Puede venir de actores estatales o
privados, de campañas de acoso, de las propias plataformas o de quien se sienta
afectado. Si el diseño concentra datos sensibles o depende de un único punto de
control, el proyecto pone en riesgo a quienes participan.

**Objetivo:** que la red sea resistente a la persecución **por su propio diseño**.
Lo que no se guarda no se puede incautar ni filtrar; lo que no depende de un único
punto no se puede apagar. Y la legitimidad pública protege. Ningún sistema es inmune;
la meta es minimizar el daño posible y volver los ataques costosos e inútiles.

## Modelo de amenazas (borrador)

| Amenaza | Ejemplo | Qué se busca |
| --- | --- | --- |
| Identificación de participantes | Pedidos de datos, filtraciones, cruce de metadatos | Saber quién participa |
| Acoso y escrache | Campañas coordinadas, doxxing | Silenciar o intimidar |
| Acoso judicial | Demandas temerarias (SLAPP) y denuncias para desgastar | Agotar recursos y generar miedo |
| Apagado | Bloqueo del sitio, de dominios o de tiendas de apps; ataques de denegación de servicio | Cortar el servicio |
| Infiltración | Cuentas que provocan, desvían consensos o fabrican "pruebas" | Deslegitimar desde adentro |
| Captura de cuentas | Robo de credenciales de moderadores o voceros | Usar la red en su contra |
| Deslegitimación | Acusar a la red de ser partidaria o ilegal | Quitarle apoyo social |

## Principios de diseño

1. **Minimización radical de datos.** No pedir nombre real, DNI, teléfono ni
   ubicación salvo que una función lo exija y lo apruebe electoral_counsel. Nunca
   registrar afinidad política (dato sensible, Ley 25.326).
2. **Seudonimato por defecto.** Se participa con seudónimo. Cada persona elige qué
   revelar; la verificación de que se trata de una persona (para respaldos y
   consensos) se separa de su identidad (PP-3).
3. **Retención mínima.** Registros técnicos (IP, dispositivo) desactivados o borrados
   en plazos cortos y publicados. Sin analítica de terceros ni rastreadores.
4. **Cifrado.** En tránsito siempre; en reposo con claves que el operador no pueda
   entregar cuando sea posible. La mensajería privada, si existe, cifrada de extremo a extremo.
5. **Evidencia sin personas.** Las capturas de evidencia (telegramas, publicaciones,
   anuncios) se publican agregadas o sin datos de quien las aportó. Se eliminan los
   metadatos de las imágenes (EXIF, ubicación) antes de compartirlas.
6. **Sin punto único de falla.** Código abierto y reproducible, réplicas y espejos
   en distintas jurisdicciones, exportación abierta de datos públicos. Analizar si
   conviene una arquitectura federada (PP-2).
7. **Legitimidad como escudo.** Neutralidad partidaria verificable, cumplimiento
   legal revisado por electoral_counsel, metodología pública y gobernanza transparente.
   Le quitan pretextos a quien quiera perseguir.
8. **Escudo institucional.** Alianzas con organizaciones de referencia que respalden
   públicamente el proyecto y acompañen a sus participantes (ver abajo).
9. **Resistencia a la infiltración.** Los consensos requieren apoyo amplio y
   transversal; los roles sensibles se rotan y tienen controles cruzados; se
   detectan comportamientos coordinados.
10. **Seguridad de cuentas.** Segundo factor obligatorio para moderación y
    vocerías, y llaves de acceso (passkeys) cuando estén disponibles.

## Escudo institucional: alianzas

**Propósito:** que organizaciones con trayectoria en derechos digitales, libertad de
expresión, derechos humanos, transparencia electoral y periodismo apoyen el proyecto.
Su respaldo hace más costosa cualquier persecución y aporta defensa legal, acompañamiento y visibilidad.

| Tipo de organización | Qué puede aportar | Candidatas a evaluar (sin contacto aún) |
| --- | --- | --- |
| Derechos digitales y privacidad | Revisión de privacidad y seguridad, respaldo público | Asociación por los Derechos Civiles (ADC), Fundación Vía Libre, Access Now, Electronic Frontier Foundation |
| Derechos humanos | Respaldo, acompañamiento ante persecución, litigio | CELS, Amnistía Internacional Argentina |
| Libertad de expresión y prensa | Respaldo a periodistas y participantes, alertas | FOPEA, Artículo 19 |
| Transparencia y elecciones | Legitimidad electoral, experiencia en observación | Poder Ciudadano |
| Verificación de información | Metodología y alianzas contra la desinformación | Chequeado |
| Universidades | Aval académico, investigación y metodología | Universidades públicas y sus observatorios |

**Reglas:**

- Ninguna organización figura como aliada sin su acuerdo explícito y por escrito.
  Nunca usar nombres ni logos sin permiso.
- Cada alianza deja registrado su alcance (respaldo público, revisión, defensa
  legal, difusión) y cómo se termina.
- La diversidad de aliados también es neutralidad: evitar depender de
  organizaciones que se identifiquen con un solo sector político.
- **Todo contacto lo decide y lo realiza el autor.**

## Protocolos (a desarrollar)

- **Respuesta a pedidos de datos:** qué se entrega ante una orden judicial válida
  (idealmente nada identificatorio, porque no existe) y cómo se informa con
  transparencia, dentro de lo que la ley permita (verificar con electoral_counsel).
- **Respuesta a acoso:** canal de ayuda, retiro rápido de datos expuestos y derivación
  a organizaciones aliadas.
- **Respuesta a acoso judicial:** red de abogados y abogadas pro bono a través de las alianzas.
- **Continuidad:** plan para sostener el servicio y los datos públicos ante bloqueos o caídas.
- **Informe de transparencia** periódico: pedidos recibidos, moderación y caídas.

## Decisiones pendientes

- PP-1. ¿Se crea un rol específico (`protection_officer`) o se reparte entre
  security_analyst, data_protection_officer y electoral_counsel?
- PP-2. Arquitectura: centralizada con minimización, federada, o híbrida. Afecta
  RC-1 (construir o reutilizar).
- PP-3. Verificación de personas sin identidad: opciones a evaluar (invitación por
  personas de confianza, verificación presencial en eventos de organizaciones
  aliadas, credenciales anónimas).
- PP-4. Jurisdicción y alojamiento de la infraestructura y de la entidad que opera la red.
- PP-5. Lista priorizada de organizaciones a contactar y en qué orden.

## Criterios de aceptación

1. Un inventario de datos documenta cada dato que se recolecta, por qué, cuánto
   tiempo se guarda y quién accede. Cada dato tiene justificación.
2. Ante una incautación total del servidor no se puede identificar a participantes
   seudónimos (prueba de diseño revisada por security_analyst).
3. Los datos públicos y el código se pueden replicar sin permiso del operador.
4. Alianzas registradas con alcance y acuerdo explícito antes de mostrarse públicamente.
5. Chequeos de electoral_counsel, data_protection_officer y security_analyst registrados.
