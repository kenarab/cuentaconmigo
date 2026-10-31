# SPEC · Ubicación del servidor de escrutinio en la app

Origen: entrega de Nexo (metodologia-ia), integrada por la sesión de `cuentaconmigo`.
Estado: **vigente por pedido del autor** ("la app carga la dirección del servidor por
default, nada configurado a mano"). Fecha: 31/10/2026.
**Verificado** el 31/10/2026 desde este equipo por HTTPS, con estos resultados:
- `health` responde 200 y el alta con código de un solo uso funciona.
- La captura y la imagen se envían y vuelve el comprobante encadenado.
- El OCR termina y sin token se responde 401.
- `/v1/readings` alinea con 18–20 anclas y error de 0,3–0,4 px.
Relacionada con [scrutiny-backend](../scrutiny-backend/SPEC.md) (decisión D-003 de
mobile-platform) y con la pantalla de servidor de [app-screens](../app-screens/SPEC.md).

## 1. Problema

`ServerSettingsView` arranca con `http://` y el ejemplo `http://192.168.1.99:8740`, así que
cada fiscal tiene que escribir la dirección a mano. Eso genera errores de tipeo, lleva a
direcciones de LAN que no andan con datos móviles y hace probar HTTP sin cifrar. El autor
pidió que la app venga configurada con el servidor público.

## 2. Ubicación vigente

| Campo | Valor |
| --- | --- |
| URL base | `https://newbery.duckdns.org/cuentaconmigo` |
| Salud | `GET https://newbery.duckdns.org/cuentaconmigo/v1/health` → `{"status":"ok",...}` |
| API | `/v1/...` según `contracts/api/scrutiny-v1.openapi.json`, bajo la URL base |
| Transporte | HTTPS (TLS 1.2+), certificado Let's Encrypt; no requiere excepción ATS |
| Operación | Proxy Apache de Nexo a `127.0.0.1:8740`; backend operado por esta sesión |

La URL base incluye el prefijo `/cuentaconmigo`. El cliente arma las rutas con
`appendingPathComponent`, que conserva ese prefijo. **No** usar `URL(string:relativeTo:)`
con rutas absolutas como `/v1/...`, porque descartaría el prefijo.

## 3. Comportamiento requerido

1. **Valor por defecto configurable por build.** La URL vive en `Info.plist`, clave
   `CCDefaultServerURL`, alimentada por un build setting (`CC_DEFAULT_SERVER_URL`). En Release
   y TestFlight vale la URL del punto 2; en Debug puede quedar igual o apuntar a la LAN.
   Nunca codificarla dentro de las vistas.
2. **Precarga.** `ServerSettingsView` muestra `ServerSettings.url` si existe; si no, el valor
   por defecto. El campo sigue editable, para usar servidores alternativos o de prueba.
3. **Restablecer.** Agregar la acción «Usar servidor predeterminado». No borra el token:
   cambiar de servidor exige un nuevo alta.
4. **HTTPS obligatorio fuera de Debug.** En Release, rechazar `http://` con el mensaje
   «La dirección tiene que empezar con https://».
5. **Alta sin configuración (decisión del autor, reemplaza la propuesta original).** Los
   builds del equipo traen un **código de alta de la app** (24+ caracteres) en
   `Resources/server.json`, fuera de Git y copiado por `ios/scripts/install-device.sh` desde
   `.private/server.json`. Al abrirse, la app se da de alta sola. Los códigos de un solo
   uso siguen valiendo para quien instale otro build.
   - **Riesgo:** el código se puede extraer del binario. Mitigaciones:
     - límite de altas por IP;
     - el código no da más permisos que un alta común (subir capturas propias);
     - se rota cambiando `CC_APP_ENROLL_CODE` y `.private/server.json`;
     - nunca va en Git, en `Info.plist` ni en enlaces públicos.
   - Pendiente: chequeo de `electoral_counsel`.
   - **Modo de prueba vigente (decisión del autor, 31/10/2026):** el código de la app es
     `0000` (`CC_OPEN_TEST=1`). Cualquiera que conozca la URL puede darse de alta. Lo
     frenan los límites (5 altas cada 10 minutos por IP y 120 capturas por hora por
     dispositivo). **Cerrarlo antes de cualquier uso con datos reales.**
6. **Placeholder y texto de ayuda** sin direcciones de LAN; ejemplo
   `https://newbery.duckdns.org/cuentaconmigo`.
7. **Prueba de conexión** antes del alta: `GET /v1/health`. Si falla, mostrar «No se pudo
   contactar al servidor» sin exponer detalles internos.

## 4. Fuera de alcance

- Descubrimiento automático o configuración remota de la URL.
- Cambiar el dominio, el certificado o el proxy: los opera Nexo
  (`metodologia-ia/docs/cuentaconmigo-publicacion.md`). Para mudar el servidor, Nexo avisa
  y se actualiza el build setting.
- Persistencia del backend, cuotas y revisión de seguridad: pendientes de cada responsable.

## 5. Verificación

- Prueba unitaria: con base `https://host/cuentaconmigo`, `ScrutinyClient` pide
  `https://host/cuentaconmigo/v1/health`.
- Prueba unitaria: en Release se rechaza una URL `http://`.
- Manual en TestFlight: instalación limpia → Servidor muestra la URL pública → código de alta
  → envío de una captura de prueba. Hacerlo con WiFi y con datos móviles.
- `GET /v1/health` desde fuera de la red local responde 200 (`sh ops/activate-cuentaconmigo-publico.sh check`
  en metodologia-ia).

## 6. Riesgo legal

Sin datos personales nuevos: la URL es pública y el alta usa un código anónimo de un
solo uso. El chequeo de `electoral_counsel` sigue pendiente, como en scrutiny-backend.
