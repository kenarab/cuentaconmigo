# Guion de la demo · entrega 31/10/2026, 17:45

Borrador del coordinador para que el autor lo ajuste. Duración: unos 5 minutos.
Supone la decisión recomendada en #1: escrutinio + simulación AMBA, y la red como visión.

## 1. El problema (30 s)

Millones discutimos política en redes con reglas ajenas. CuentaConmigo es una red
ciudadana y no partidaria para cuidar las reglas de juego de 2027. Todos los partidos
participan en igualdad, y nada se hace sin un consenso registrado
([visión](../sdd/specs/vision/SPEC.md)).

## 2. Cierre del proceso: la app de escrutinio (2 min, iPhone en vivo)

1. "Nueva captura" → aviso de Boleta Única.
2. "Usar un telegrama de ejemplo": telegrama oficial real (muestras de Andy). La mesa
   se completa sola.
3. Mostrar las listas desplegables: distrito → sección → establecimiento con búsqueda
   → mesa. **La experiencia de usuario es fundamental:** se elige, no se tipea.
4. Cargar dos o tres valores tocando los números que detectó el OCR. Forzar un aviso
   de suma que no coincide y mostrar la validación.
5. Confirmar: la captura queda bloqueada con hash SHA-256 y fecha (cadena de custodia).
   Exportar el paquete.

## 3. Por qué cada carga suma: la simulación del AMBA (1 min, navegador)

`python3 -m http.server` en la raíz del repo y abrir `design/prototypes/simulacion-amba/`.

1. Datos reales por mesa de las generales 2023: 29.962 mesas, CABA + 24 partidos.
2. Reproducir con **sesgo de llegada alto**: la suma ingenua se desvía 3–4 puntos y la
   estratificada queda a menos de medio punto con el 5 % de las mesas.
3. Cartel permanente: simulación de una elección terminada. La veda del art. 71 inc. h
   impide publicar proyecciones durante una elección en curso.

## 4. Lo que viene: la red (1 min, diapositiva o SPECs)

- Identidad sin datos personales: alta por QR en persona y cadenas de confianza
  ([trust-chain-identity](../sdd/specs/trust-chain-identity/SPEC.md)).
- Gobernanza descentralizada sin token. La reputación da tareas, no votos. Las
  acciones frente a las plataformas pasan por una evaluación colegiada con panel
  sorteado y rúbrica pública ([network-governance](../sdd/specs/network-governance/SPEC.md)).
- Backend con OCR en servidor y conteo rápido propio, antes que el oficial y
  respetando la veda ([scrutiny-backend](../sdd/specs/scrutiny-backend/SPEC.md)).
- Modo planificación para fiscales de partidos chicos
  ([fiscal-planning](../sdd/specs/fiscal-planning/SPEC.md)).

## 5. Cierre (30 s)

Buscamos devs, datos, diseño, derecho, periodismo y comunicación. Repositorio abierto:
github.com/kenarab/cuentaconmigo.

## Checklist antes de presentar

- [ ] App reinstalada en la Mac con `git pull && ios/scripts/install-device.sh` (trae
      las listas desplegables y los ejemplos).
- [ ] Simulación abierta en el navegador con el servidor local.
- [ ] Teléfono con la pantalla duplicada en el proyector.
- [ ] No mostrar imágenes de telegramas reales con datos de personas en pantalla grande
      sin tapar (chequeo legal).
