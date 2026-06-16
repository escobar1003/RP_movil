# ESPECIFICACIÓN API — MINIJUEGO 3D ECO-RECICLA

## 📋 DATOS GENERALES

- **App:** EcoRecicla (Flutter)
- **Módulo:** Minijuego educativo 3D (Babylon.js)
- **Autenticación:** JWT Bearer Token (mismo que el resto de la app)
  - Header: `Authorization: Bearer <token>`
  - Content-Type: `application/json`
- **Base URL:** `https://backend-rp-arreglado-n8p8.onrender.com/api`

---

## 📦 TABLA EN BASE DE DATOS

### `resultados_juego`

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| id | INTEGER UNSIGNED | PK, AUTO_INCREMENT | Identificador único |
| usuario_id | INTEGER UNSIGNED | FK → usuarios(id), NOT NULL | Usuario que jugó |
| puntaje | INTEGER | NOT NULL, ≥ 0 | Puntaje obtenido en la partida |
| aciertos | INTEGER | NOT NULL, ≥ 0 | Cuántos residuos clasificó correctamente |
| errores | INTEGER | NOT NULL, ≥ 0 | Cuántos residuos clasificó incorrectamente |
| plasticos | INTEGER | NOT NULL, ≥ 0 | Residuos de plástico reciclados |
| vidrios | INTEGER | NOT NULL, ≥ 0 | Residuos de vidrio reciclados |
| papeles | INTEGER | NOT NULL, ≥ 0 | Residuos de papel reciclados |
| organicos | INTEGER | NOT NULL, ≥ 0 | Residuos orgánicos reciclados |
| duracion_segundos | INTEGER | NOT NULL, ≥ 1 | Duración de la partida en segundos |
| fecha | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha y hora de la partida |
| created_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | |
| updated_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP ON UPDATE | |

**Índices:**
- PRIMARY KEY (`id`)
- INDEX `idx_usuario_id` (`usuario_id`)
- INDEX `idx_fecha` (`fecha`)

---

## 🔌 ENDPOINTS

### 1. Guardar resultado de partida

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/juego/resultados` | Guarda los datos de una partida terminada |

**Request:**
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

**Response 201:**
```json
{
  "success": true,
  "message": "Resultado guardado correctamente",
  "data": {
    "id": 42
  }
}
```

**Response 422:**
```json
{
  "success": false,
  "message": "Error de validación",
  "errors": {
    "puntaje": "El campo puntaje es requerido"
  }
}
```

---

### 2. Historial de partidas del usuario

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/juego/historial` | Lista las partidas del usuario autenticado |

**Query params:** `?page=1&limit=10`

**Response 200:**
```json
{
  "success": true,
  "data": [
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
```

---

### 3. Mejor puntuación del usuario

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/juego/mejor-puntaje` | Devuelve la puntuación más alta del usuario |

**Response 200:**
```json
{
  "success": true,
  "data": {
    "mejor_puntaje": 250,
    "total_partidas": 25,
    "promedio_puntaje": 85.5
  }
}
```

---

### 4. Ranking general de jugadores

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/juego/ranking` | Top jugadores ordenados por mejor puntaje |

**Query params:** `?limite=10`

**Response 200:**
```json
{
  "success": true,
  "data": [
    { "usuario": "Ana", "puntaje": 300, "partidas": 15 },
    { "usuario": "Juan", "puntaje": 250, "partidas": 10 },
    { "usuario": "Carlos", "puntaje": 200, "partidas": 8 }
  ]
}
```

---

## ✅ VALIDACIONES DEL BACKEND

### POST `/juego/resultados`

| Campo | Tipo | Requerido | Validación |
|-------|------|-----------|------------|
| puntaje | integer | ✅ | ≥ 0, máximo 9999 |
| aciertos | integer | ✅ | ≥ 0, máximo 999 |
| errores | integer | ✅ | ≥ 0, máximo 999 |
| plasticos | integer | ✅ | ≥ 0, máximo 999 |
| vidrios | integer | ✅ | ≥ 0, máximo 999 |
| papeles | integer | ✅ | ≥ 0, máximo 999 |
| organicos | integer | ✅ | ≥ 0, máximo 999 |
| duracion_segundos | integer | ✅ | ≥ 1, máximo 600 |

### Autenticación

Todos los endpoints requieren token JWT válido. Si el token expiró o es inválido:

```json
{
  "success": false,
  "message": "Token inválido o expirado"
}
```

---

## 🧮 REGLAS DE PUNTUACIÓN

El **frontend** calcula el puntaje. El **backend solo almacena** el valor recibido:

- Clasificación correcta: **+10 puntos**
- Clasificación incorrecta: **-5 puntos** (mínimo 0)
- El backend **no debe recalcular** el puntaje

---

## 📝 NOTAS PARA EL EQUIPO BACKEND

1. El minijuego corre en **Babylon.js 3D** dentro de un **WebView de Flutter**.
2. La comunicación juego ↔ Flutter es interna (`JavaScriptChannel`). El backend **no sirve el juego**.
3. Cuando el jugador termina la partida, Flutter envía los datos a estos endpoints.
4. Todos los endpoints deben devolver `success: true/false` para que Flutter lo maneje.
5. El endpoint de ranking debe devolver solo **top N** jugadores ordenados por `puntaje` descendente.
6. La columna `usuario_id` debe ser FK a la tabla `usuarios` existente.
7. Estos endpoints corresponden **exclusivamente al minijuego 3D**, no deben afectar otras funcionalidades.
