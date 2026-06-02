// lib/models/notificacion_model.dart

enum TipoNotificacion {
  citaAceptada,
  citaRechazada,
  citaRecordatorio,
  citaCompletada,
  puntosGanados,
  canjeExitoso,
  logroNivel,
  logroEntrega,
  sistemaInfo,
}

class NotificacionModel {
  final int id;
  final TipoNotificacion tipo;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final bool leida;
  final Map<String, dynamic>? extra; // datos adicionales opcionales

  const NotificacionModel({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    this.leida = false,
    this.extra,
  });

  // Convierte JSON del backend a modelo
  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      id:          json['id'] ?? 0,
      tipo:        _tipoFromString(json['tipo'] ?? ''),
      titulo:      json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fecha:       DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
      leida:       json['leida'] == true || json['leida'] == 1,
      extra:       json['extra'] != null
                     ? Map<String, dynamic>.from(json['extra'])
                     : null,
    );
  }

  static TipoNotificacion _tipoFromString(String tipo) {
    switch (tipo) {
      case 'cita_aceptada':     return TipoNotificacion.citaAceptada;
      case 'cita_rechazada':    return TipoNotificacion.citaRechazada;
      case 'cita_recordatorio': return TipoNotificacion.citaRecordatorio;
      case 'cita_completada':   return TipoNotificacion.citaCompletada;
      case 'puntos_ganados':    return TipoNotificacion.puntosGanados;
      case 'canje_exitoso':     return TipoNotificacion.canjeExitoso;
      case 'logro_nivel':       return TipoNotificacion.logroNivel;
      case 'logro_entrega':     return TipoNotificacion.logroEntrega;
      default:                  return TipoNotificacion.sistemaInfo;
    }
  }

  // Copia con leida = true
  NotificacionModel marcarLeida() {
    return NotificacionModel(
      id: id, tipo: tipo, titulo: titulo,
      descripcion: descripcion, fecha: fecha,
      leida: true, extra: extra,
    );
  }
}