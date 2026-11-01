# App Android (prototipo)

Pantallas en Jetpack Compose sobre el núcleo compartido en Rust (`core/`,
[shared-core](../sdd/specs/shared-core/SPEC.md)). Toda la lógica vive en el núcleo: la app
sólo dibuja las pantallas y usa la cámara, la galería y las preferencias privadas.

```sh
scripts/core/build-android.sh                      # núcleo (.so) + bindings Kotlin + ejemplos
cd android && ./gradlew assembleDebug              # APK en app/build/outputs/apk/debug/
CC_TEST_SERVER=https://newbery.duckdns.org/cuentaconmigo CC_TEST_JPEG=… ./gradlew testDebugUnitTest
```

Requiere el Android SDK y el NDK en `~/Android/Sdk`, JDK 17, los targets de Rust
`aarch64-linux-android` y `x86_64-linux-android`, y `cargo-ndk`. La URL del servidor y el
código de alta de la app salen de `.private/server.json` (fuera de Git); sin ese archivo,
la app usa la URL pública y pide el código en Ajustes.
