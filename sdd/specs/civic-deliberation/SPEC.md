# SPEC · Deliberación ciudadana de propuestas de regulación

Estado: **propuesta; decisiones DL-1 a DL-4 pendientes del autor.** Fecha: 31/10/2026.
Eje: **E. Propuestas y regulación** de la [visión](../vision/SPEC.md).
Chequeo de `electoral_counsel`: **pendiente**.

## Problema

Auditar sin proponer deja la presión pública a mitad de camino. Las ideas de
regulación (por ejemplo, la [cuenta de garantía electoral](../reg-electoral-escrow/SPEC.md))
necesitan discutirse, mejorarse y sumar apoyos antes de llegar al Congreso. A
cualquier persona usuaria se le puede ocurrir una idea mejor, así que la plataforma
tiene que **permitir proponer y discutir iniciativas**, no sólo difundir las nuestras.

## Objetivo

Un espacio donde la comunidad pueda **proponer, deliberar, mejorar y respaldar**
iniciativas de regulación y de acción pública sobre plataformas y elecciones, y
consolidarlas en documentos listos para una estrategia parlamentaria o de incidencia.

## Ciclo de vida de una iniciativa

```
idea → propuesta estructurada → deliberación → versión consolidada → chequeo legal → documento de incidencia
```

1. **Idea:** texto breve, cualquiera puede publicarla.
2. **Propuesta estructurada:** plantilla obligatoria con problema, mecanismo,
   evidencia (enlaces a los ejes A–D), base legal, riesgos y alternativas. Así se evita
   discutir eslóganes.
3. **Deliberación:** argumentos **a favor y en contra** y preguntas, en lugar de un
   hilo plano de comentarios. Las enmiendas se proponen como cambios concretos al texto.
4. **Versión consolidada:** cada versión queda registrada con sus autorías y
   con las enmiendas aceptadas o rechazadas, y por qué.
5. **Chequeo legal:** `electoral_counsel` analiza riesgos y recomienda ajustes.
   Lo que requiera opinión profesional se deriva a un abogado o abogada humano.
6. **Documento de incidencia:** resumen, texto articulado si corresponde, evidencia,
   apoyos y estrategia. Llevarlo a legisladores u organismos lo decide el autor.

## Reglas de deliberación

- **No partidaria:** se discuten mecanismos, no candidaturas. No se aceptan propuestas
  dirigidas a perjudicar o favorecer a una fuerza en particular.
- **Respeto y evidencia:** se moderan los ataques personales y los datos personales
  de terceros. Las afirmaciones de hecho llevan fuente.
- **Moderación transparente:** reglas públicas, registro de decisiones de moderación
  y posibilidad de apelar. Moderamos para que la conversación funcione, no para
  imponer una opinión.
- **Resistencia a brigadas:** limitar la frecuencia de publicación, priorizar
  argumentos sobre votos y detectar apoyos coordinados (trust_safety_analyst).
- **Identidad graduada:** se puede leer sin cuenta; para proponer y argumentar hace
  falta una cuenta; para que un respaldo cuente en un documento de incidencia hay que
  verificar que se trata de una persona (método a definir, DL-3).

## Construir o reutilizar (DL-1)

Ya existen plataformas abiertas de participación ciudadana, muy probadas:

| Opción | A favor | En contra |
| --- | --- | --- |
| **Reutilizar Decidim** (código abierto) | Procesos participativos, propuestas, enmiendas, debates y apoyos ya resueltos; comunidad activa | Hay que hostearlo y operarlo; integrarlo con la evidencia de los ejes A–D |
| **Reutilizar CONSUL Democracy** (código abierto) | Propuestas ciudadanas con umbral de apoyos y legislación colaborativa | Lo mismo |
| **Recuperar la experiencia de DemocracyOS** (origen argentino) | Pensado para debatir proyectos de ley | Verificar el estado de mantenimiento |
| **Construir un módulo propio** | Integración total con la evidencia y la identidad del proyecto | Mucho trabajo; reinventar problemas resueltos (moderación, enmiendas, versiones) |

Recomendación: **reutilizar una plataforma existente** (Decidim o CONSUL, según la
evaluación técnica) y construir sólo el puente con la evidencia de CuentaConmigo.
Arquitectura e instalaciones: decide el autor.

## Decisiones pendientes

- DL-1. Construir o reutilizar (ver tabla).
- DL-2. ¿Quién modera? Voluntarios capacitados con reglas públicas, más un comité
  diverso para las apelaciones.
- DL-3. Verificación de personas para los respaldos: la dificultad de crear cuentas
  falsas contra la privacidad (no pedir DNI salvo una decisión legal).
- DL-4. ¿Las iniciativas se pueden firmar como petición formal? Revisar con
  electoral_counsel las vías existentes, por ejemplo la iniciativa popular del
  art. 39 de la Constitución, con sus requisitos (verificar).

## Criterios de aceptación

1. Cualquier persona registrada puede publicar una propuesta con la plantilla
   estructurada, y otras pueden argumentar a favor o en contra y proponer enmiendas.
2. Cada versión de una propuesta es trazable: quién, qué cambió y por qué.
3. Las reglas y las decisiones de moderación son públicas y se pueden apelar.
4. La cuenta de garantía electoral se publica como una propuesta más, sin destacarla por sobre las demás.
5. Chequeos de electoral_counsel, data_protection, neutrality y trust_safety registrados.
