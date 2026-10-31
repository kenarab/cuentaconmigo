# SPEC · Sistema multiagente de chequeo y alternativas

Estado: **propuesta para el autor.** Fecha: 31/10/2026.
Reemplazaría al catálogo actual de ocho roles (`.agents/manifest.json`) sólo
después de que el autor la acepte. Hasta entonces sigue vigente el catálogo actual.

## Objetivo

Que cada decisión del proyecto (SPEC, contrato, código, texto público) pase por
roles especializados que **chequean** lo que les toca y **proponen alternativas**,
y que el autor decida con toda esa información consolidada. Ningún rol decide solo
sobre arquitectura, instalaciones, publicación o contacto externo.

## Estructura de roles

### 1. Gobierno

| Rol | Qué hace | Acceso |
| --- | --- | --- |
| **owner** (humano) | Decide, acepta, prueba en campo y es el único contacto externo | — |
| **planner** | Divide el pedido en tareas, convoca a los chequeadores, consolida alternativas y es el único que integra Git | coordinate |

### 1 bis. Asesoría permanente

| Rol | Qué hace | Acceso |
| --- | --- | --- |
| **electoral_counsel** (experto en derecho electoral) | Analiza **todo el tiempo** los riesgos y las consecuencias legales de cada decisión, SPEC, texto público y acción externa. Cuando hay que evitar una situación, recomienda una línea de acción concreta. Puede marcar ⛔ y frenar una integración hasta que el owner decida | read-only; escribe sólo en `docs/legal/` y en `checks/` |

A diferencia de legal_analyst, que investiga y documenta normas, electoral_counsel
opina sobre decisiones concretas: qué puede pasar, quién podría reclamar, qué
sanción hay y qué hacer en su lugar. Interviene en **todas** las filas de la matriz.
Su informe no es asesoramiento legal profesional; los ⛔ y las preguntas de fondo se
derivan a un abogado o abogada electoral humano (D-MA-3).

### 2. Chequeo de dominio (sólo lectura: chequean y proponen, no implementan)

| Rol | Chequea | Propone |
| --- | --- | --- |
| **legal_analyst** | Respaldo y límites legales: Código Electoral, BUP, acceso a la información, libertad de expresión, delitos electorales. Mantiene `docs/legal/` | Encuadres legales alternativos y preguntas para un abogado electoral |
| **electoral_analyst** | Proceso real del escrutinio, formatos de telegrama, acta y certificado, roles de mesa y publicación oficial de resultados | Plantillas de formulario y reglas de validación |
| **data_protection_officer** | Datos personales (Ley 25.326), minimización, retención, consentimiento y derechos ARCO | Esquemas de anonimización y retención |
| **platform_accountability_analyst** | Qué hacen las plataformas: políticas, bibliotecas de anuncios, compromisos, términos de servicio, métodos externos de medición (eje A de la visión) | Métricas, metodologías reproducibles y acciones de presión pública basadas en evidencia |
| **trust_safety_analyst** | Desinformación, abuso, brigadas, reportes falsos y riesgo de doxxing | Criterios de verificación, reputación de voluntarios y moderación |
| **security_analyst** | Modelo de amenazas: capturas falsas, manipulación de evidencia, cuentas comprometidas, infraestructura | Controles y su costo |
| **neutrality_auditor** | Sesgo partidario en textos, datos, criterios, alianzas y en el orden de las listas | Redacciones y criterios neutrales |
| **accessibility_ux_analyst** | Uso bajo presión, gama baja, conectividad, lectores de pantalla, lenguaje simple | Flujos alternativos |
| **civic_ops_analyst** | Operación en campo: reclutamiento y capacitación de voluntarios, el día de la elección, soporte | Protocolos y materiales |

### 3. Ingeniería (escritura acotada a sus rutas)

| Rol | Rutas | Entrega |
| --- | --- | --- |
| **contracts_steward** | `contracts/` | Schemas, plantillas y vectores. Única fuente compartida entre plataformas |
| **ios_engineer** | `ios/` | App SwiftUI y núcleo `TelegramaCore` |
| **android_engineer** | `android/` | App Kotlin/Compose (después de D-002) |
| **backend_engineer** | `backend/` | Recepción central y cotejo (después de D-003) |
| **vision_engineer** | `vision/` | OCR y extracción por regiones; mide la precisión con datos ficticios o anonimizados |
| **ux_designer** | `design/` | Prototipos y criterios de diseño |

### 4. Calidad

| Rol | Hace | Acceso |
| --- | --- | --- |
| **reviewer** | Revisión independiente del diff contra la SPEC y la evidencia | read-only |
| **red_team** | Intenta romper el sistema: fraude de capturas, desinformación adversaria, abuso | read-only, sólo sobre entornos de prueba |
| **executor** | Ejecuta los comandos acordados, sin modelo | script-only |

## Flujo de una decisión

```
pedido del owner
   └─ planner: SPEC borrador + lista de chequeadores requeridos
        └─ electoral_counsel: riesgos legales y líneas de acción (siempre)
        └─ chequeadores (en paralelo, sólo lectura)
             → informe: ✅ ok / ⚠️ riesgo / ⛔ bloqueo + alternativas
        └─ planner: consolida en DECISION.md (opciones, pros/contras, recomendación)
             └─ owner decide → SPEC aceptada
                  └─ ingeniería implementa (rutas exclusivas)
                       └─ executor verifica → reviewer (+ red_team si aplica)
                            └─ planner integra: commit atómico + push
```

### Matriz de chequeos obligatorios

| Cambio | Chequeadores mínimos (además de electoral_counsel, siempre) |
| --- | --- |
| Captura y manejo de evidencia | electoral, legal, data_protection, security |
| Plataformas: métricas, tablero y presión pública | platform_accountability, legal, neutrality, data_protection |
| Desinformación y respuesta | trust_safety, legal, neutrality |
| Textos públicos (app, HackDash, prensa) | neutrality, legal, accessibility_ux |
| Datos de personas | data_protection, legal, security |
| Infraestructura y backend | security, data_protection |
| UI | accessibility_ux (+ civic_ops si se usa el día de la elección) |

### Formato del informe de cada chequeador

`sdd/specs/<id>/checks/<rol>.md`:

1. Alcance revisado (revisión y archivos).
2. Hallazgos con severidad (⛔/⚠️/✅) y fuente.
3. **Al menos dos alternativas** cuando hay ⚠️ o ⛔, con su costo y riesgo.
4. Qué no pudo verificar.

## Límites operativos

- Vigente: dos agentes IA activos en este proyecto y cuatro globales. Con esta
  estructura, los chequeos corren en tandas de a uno junto al planner.
  **Decisión del owner (D-MA-1):** mantener el límite o subirlo, por ejemplo a
  cuatro, para chequeos de sólo lectura en paralelo.
- Los chequeadores no editan código ni contactan a nadie fuera del proyecto.
- Un rol configurado no es una revisión hecha: queda registrado quién revisó qué
  y en qué revisión del repositorio.
- Modelo: hereda el de la sesión. No se fija un modelo por rol ni se cambia sin aviso.

## Migración propuesta (si el owner acepta)

1. Agregar los nuevos roles a `.agents/roles/` y regenerar el manifiesto y el
   registro (`sdd/agents.json`) con su hash.
2. `capture_engineer` pasa a llamarse `ios_engineer` (más adelante, `android_engineer`).
3. Crear la plantilla `.agents/templates/check.md` con el formato del informe.
4. Aplicar la matriz de chequeos a las SPECs abiertas: `telegram-capture`
   (legal, electoral, data_protection, security) y `mobile-platform`.

## Decisiones pendientes del owner

- D-MA-1: límite de agentes en paralelo.
- D-MA-2: ¿qué roles se activan ya? electoral_counsel ya está activo (pedido del
  owner, 31/10/2026). Propuesta para el resto: platform_accountability, legal,
  data_protection y neutrality (el eje A es el central).
- D-MA-3: ¿se busca un abogado electoral humano que valide `docs/legal/`?
