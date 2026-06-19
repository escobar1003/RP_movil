# Requerimientos para el equipo Backend

## Minijuego 3D EcoRecicla — Integración con backend

---

## 1. Resumen

El minijuego 3D de clasificación de residuos está desarrollado en **Babylon.js** dentro de un **WebView de Flutter**. Cuando el jugador termina una partida, Flutter debe enviar los resultados al backend para persistir la puntuación y estadísticas.

---

## 2. Endpoints necesarios

### 2.1. Guardar resultado de partida

**Endpoint:** `POST /api/juego/resultado`

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Body (request):**
```json
{
  "puntaje": 120,
  "aciertos": 8,
  "errores": 4,
  "plasticos": 3,
  "vidrios": 2,
  "papeles": 2,
  "organicos": 1,
  "duracion_segundos": 87
}
```

**Respuesta exitosa (201):**
```json
{
  "success": true,
  "mensaje": "Resultado guardado",
  "data": {
    "id": 42,
    "puntos_ganados": 10
  }
}
```

**Respuesta error (400/401):**
```json
{
  "success": false,
  "mensaje": "Token inválido o datos incorrectos"
}
```

### 2.2. Obtener historial de partidas

**Endpoint:** `GET /api/juego/historial?page=1&limit=10`

**Headers:**
```
Authorization: Bearer <token>
```

**Respuesta exitosa (200):**
```json
{
  "success": true,
  "data": {
    "partidas": [
      {
        "id": 42,
        "puntaje": 120,
        "aciertos": 8,
        "errores": 4,
        "plasticos": 3,
        "vidrios": 2,
        "papeles": 2,
        "organicos": 1,
        "duracion_segundos": 87,
        "fecha": "2026-06-16T14:30:00.000Z"
      }
    ],
    "total": 25,
    "pagina": 1,
    "total_paginas": 3
  }
}
```

### 2.3. Obtener mejor puntuación del usuario

**Endpoint:** `GET /api/juego/mejor-puntaje`

**Headers:**
```
Authorization: Bearer <token>
```

**Respuesta exitosa (200):**
```json
{
  "success": true,
  "data": {
    "mejor_puntaje": 150,
    "total_partidas": 25,
    "promedio_puntaje": 85.5,
    "total_aciertos": 180,
    "total_errores": 45
  }
}
```

### 2.4. Asignar puntos por jugar (cuando corresponda)

Si ya existe el endpoint `POST /api/puntos/asignar`, puede ser reutilizado. El juego enviará desde Flutter:

```json
{
  "usuario_id": 1,
  "puntos": 10,
  "motivo": "juego_3d",
  "descripcion": "Partida completada - 120 pts",
  "fuente": "minijuego"
}
```

---

## 3. Tabla en base de datos

### `resultados_juego`

| Campo             | Tipo         | Descripción                              |
|-------------------|-------------|------------------------------------------|
| `id`              | INTEGER PK  | Auto-incrementable                       |
| `usuario_id`      | INTEGER FK  | Relación con tabla `usuarios`            |
| `puntaje`         | INTEGER     | Puntaje final de la partida              |
| `aciertos`        | INTEGER     | Número de clasificaciones correctas      |
| `errores`         | INTEGER     | Número de clasificaciones incorrectas    |
| `plasticos`       | INTEGER     | Residuos de plástico reciclados          |
| `vidrios`         | INTEGER     | Residuos de vidrio reciclados            |
| `papeles`         | INTEGER     | Residuos de papel reciclados             |
| `organicos`       | INTEGER     | Residuos orgánicos reciclados            |
| `duracion_segundos` | INTEGER   | Duración de la partida en segundos       |
| `fecha`           | DATETIME    | Fecha y hora de la partida               |
| `created_at`      | DATETIME    | Timestamp de creación                    |
| `updated_at`      | DATETIME    | Timestamp de actualización               |

**Índices sugeridos:**
- `usuario_id` (para búsquedas por usuario)
- `fecha` (para ordenamiento cronológico)

---

## 4. Validaciones del backend

| Campo             | Validación                              |
|-------------------|----------------------------------------|
| `puntaje`         | Entero ≥ 0, requerido                  |
| `aciertos`        | Entero ≥ 0, requerido                  |
| `errores`         | Entero ≥ 0, requerido                  |
| `plasticos`       | Entero ≥ 0, requerido                  |
| `vidrios`         | Entero ≥ 0, requerido                  |
| `papeles`         | Entero ≥ 0, requerido                  |
| `organicos`       | Entero ≥ 0, requerido                  |
| `duracion_segundos` | Entero ≥ 1, requerido                |
| `token`           | JWT válido, no expirado                |

---

## 5. Reglas de asignación de puntos

| Concepto               | Puntos |
|------------------------|--------|
| Clasificación correcta | +10    |
| Clasificación incorrecta | -5   |
| Bonificación por partida completada | +10 |

El backend **no debe calcular** el puntaje — el juego ya lo calcula en el frontend. El backend solo persiste el valor recibido.

---

## 6. Diagrama de flujo

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│  Flutter      │         │  Backend      │         │  Base de     │
│  (WebView)    │         │  (AdonisJS)   │         │  Datos       │
└──────┬───────┘         └──────┬───────┘         └──────┬───────┘
       │                        │                        │
       │  POST /api/juego/      │                        │
       │  resultado             │                        │
       │  (Bearer token)        │                        │
       │───────────────────────>│                        │
       │                        │  Validar token JWT      │
       │                        │  Validar datos          │
       │                        │  INSERT en              │
       │                        │  resultados_juego       │
       │                        │───────────────────────>│
       │                        │                        │
       │  { success, data }     │                        │
       │<───────────────────────│                        │
       │                        │                        │
       │  POST /api/puntos/     │                        │
       │  asignar (si aplica)   │                        │
       │───────────────────────>│                        │
       │                        │  UPDATE saldo usuario   │
       │                        │───────────────────────>│
       │  { success }           │                        │
       │<───────────────────────│                        │
```

---

## 7. Notas para el equipo backend

- El minijuego está en **Babylon.js** corriendo dentro de un **WebView de Flutter**.
- La comunicación entre el juego y Flutter usa un `JavaScriptChannel` interno — el backend no necesita servir el juego.
- Este documento cubre **solo la persistencia de resultados**. El juego funciona completamente offline.
- La autenticación usa el mismo sistema JWT existente en la app.
