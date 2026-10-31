# SPEC · Plataforma móvil y desacople iOS/Android

Estado: **decisión D-001 tomada por el autor; D-002 y D-003 pendientes.**
Fecha: 31/10/2026. Responsable: planner. Aceptación: autor.

## Problema

La captura de telegramas debe existir en iOS y Android con apariencia y
comportamiento **nativos** (cámara, escáner de documentos, accesibilidad,
rendimiento en gama baja). El autor descartó Expo Go por la experiencia obtenida.
Hay que evitar que la lógica del dominio (formato del telegrama, validaciones,
paquete de evidencia) quede atada a una plataforma.

## Decisiones

| ID | Decisión | Estado |
| --- | --- | --- |
| D-001 | Prototipo y diseño en **Swift/SwiftUI**; Android como implementación nativa equivalente (Kotlin/Jetpack Compose) | Tomada por el autor, 31/10/2026 |
| D-002 | Mecanismo para compartir lógica entre plataformas (ver alternativas) | **Pendiente del autor** |
| D-003 | Backend/recepción central de capturas | **Pendiente**: fuera del prototipo |

## Requisito de desacople (vigente con cualquier alternativa)

**Contratos primero.** Todo lo que deban compartir ambas apps vive en
`contracts/`, independiente del lenguaje:

- `contracts/schemas/`: JSON Schema del paquete de captura (lo que una app entrega).
- `contracts/templates/`: definición declarativa de cada formulario
  (telegrama/acta/certificado): categorías, filas, campos y reglas.
- `contracts/vectors/`: vectores de conformidad (entrada → resultado esperado)
  para validaciones y normalización de dígitos. Ambas apps los ejecutan en sus tests.
- `contracts/examples/`: ejemplos **ficticios** válidos.

Cada app implementa en su lenguaje un núcleo puro (`ios/TelegramaCore`, futuro
`android/telegrama-core`) sin dependencias de UI ni de I/O de cámara. La UI y los
servicios de plataforma quedan en la capa nativa. Una app es conforme cuando pasa
todos los vectores. Cambiar una regla = cambiar contrato + vectores primero.

## Alternativas evaluadas para D-002

| Opción | UI | Lógica compartida | A favor | En contra |
| --- | --- | --- | --- | --- |
| **A. Dos apps nativas + contratos** | SwiftUI / Compose | Duplicada, verificada por vectores | UI 100 % nativa; cero dependencia extra; cada equipo usa su stack estándar; contratos sirven también al backend | La lógica se escribe dos veces; riesgo de divergencia mitigado por vectores |
| **B. Kotlin Multiplatform (KMP) para el núcleo** | SwiftUI / Compose nativas | Núcleo Kotlin compilado a framework iOS | UI nativa en ambas; una sola implementación de reglas; respaldo de JetBrains/Google | Swift consume API vía puente (Swift export aún madurando); toolchain Gradle en el build iOS; prototipo Swift actual habría que portar el núcleo |
| **C. Skip (SwiftUI → Kotlin/Compose)** | SwiftUI transpilada a Compose | Swift compartido | Se escribe una vez en Swift y Android resulta nativo Compose | Herramienta joven y de nicho; dependencia fuerte de un proveedor; verificar licencia y soporte vigentes; cobertura parcial de APIs (VisionKit no se transpila) |
| **D. Compose Multiplatform** | Compose dibujada en iOS | Todo en Kotlin | Un solo código | En iOS no usa controles nativos: no cumple la apariencia nativa pedida |
| **E. Flutter** | Motor propio | Todo en Dart | Un solo código, maduro | Imita controles nativos; mismo problema que D |
| **F. React Native sin Expo Go** | Componentes nativos reales vía JS | Todo en JS/TS | Vistas nativas, gran ecosistema | Capa JS y puente; cámara/escáner vía módulos de terceros; experiencia cercana a la que el autor descartó |

### Recomendación (propuesta, no decisión)

**A ahora, con B como evolución.** El prototipo Swift sigue D-001 y no fija nada
irreversible: el núcleo `TelegramaCore` es chico y está definido por contratos.
Cuando empiece Android, si la lógica compartida creció (plantillas de formulario,
reglas, extracción por regiones), evaluar migrar el núcleo a KMP manteniendo
SwiftUI y Compose. Los vectores de `contracts/vectors` siguen siendo la prueba de
conformidad en cualquiera de los dos caminos.

## Equivalencias de plataforma (para la implementación Android)

| Función | iOS | Android |
| --- | --- | --- |
| Escaneo con corrección de perspectiva | VisionKit `VNDocumentCameraViewController` | ML Kit Document Scanner |
| OCR en el dispositivo | Vision `VNRecognizeTextRequest` | ML Kit Text Recognition v2 |
| Importar desde galería | PhotosUI `PhotosPicker` | Photo Picker (`PickVisualMedia`) |
| SHA-256 | CryptoKit | `java.security.MessageDigest` |
| Almacenamiento cifrado local | Data Protection `.complete` | Almacenamiento interno de la app (cifrado por archivo del sistema) |
| Compartir/exportar | `ShareLink` | `Intent.ACTION_SEND_MULTIPLE` |

## Criterios de aceptación de esta SPEC

1. El autor elige D-002 (o confirma A como vigente para el prototipo).
2. Toda regla compartida está en `contracts/` con vectores antes de implementarse.
3. El núcleo Swift no importa UIKit/SwiftUI/VisionKit y pasa los vectores en `swift test`.
