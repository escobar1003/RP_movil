// lib/data/notificaciones_data.dart

import '../models/notificacion_model.dart';

List<NotificacionModel> notificacionesPrueba = [
  NotificacionModel(
    id: 1,
    tipo: TipoNotificacion.citaAceptada,
    titulo: '¡Cita aceptada!',
    descripcion: 'Tu cita en Éxito Panamericana para entregar Plástico (0.3 kg) fue aceptada para hoy 3:00 PM.',
    fecha: DateTime.now().subtract(const Duration(minutes: 10)),
    leida: false,
  ),
  NotificacionModel(
    id: 2,
    tipo: TipoNotificacion.citaRecordatorio,
    titulo: 'Cita en 1 hora',
    descripcion: 'Recuerda tu entrega de Vidrio en Carulla Centro hoy a las 4:00 PM.',
    fecha: DateTime.now().subtract(const Duration(minutes: 30)),
    leida: false,
  ),
  NotificacionModel(
    id: 3,
    tipo: TipoNotificacion.puntosGanados,
    titulo: '+150 puntos ganados',
    descripcion: 'Recibiste 150 puntos por tu entrega de Cartón en Jumbo Norte. Total: 1.250 pts.',
    fecha: DateTime.now().subtract(const Duration(hours: 2)),
    leida: false,
  ),
  NotificacionModel(
    id: 4,
    tipo: TipoNotificacion.citaRechazada,
    titulo: 'Cita rechazada',
    descripcion: 'El encargado rechazó tu cita en Superinter Bolívar. Puedes reagendar en otro punto.',
    fecha: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    leida: true,
  ),
  NotificacionModel(
    id: 5,
    tipo: TipoNotificacion.canjeExitoso,
    titulo: 'Recompensa canjeada',
    descripcion: 'Canjeaste 500 pts por 20% descuento en Éxito. Válido hasta 30 jun 2025.',
    fecha: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    leida: true,
  ),
  NotificacionModel(
    id: 6,
    tipo: TipoNotificacion.logroNivel,
    titulo: '¡Subiste de nivel!',
    descripcion: 'Alcanzaste el nivel "Árbol Verde". Sigue reciclando para llegar a "Bosque".',
    fecha: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
    leida: true,
  ),
];