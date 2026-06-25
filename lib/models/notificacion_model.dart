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
    final id = json['id_notificacion'] ?? json['id'] ?? 0;
    final tipo = _tipoFromString(json['tipo'] ?? '');
    final titulo = json['titulo'] ?? '';
    final descripcion = json['descripcion'] ?? json['mensaje'] ?? '';
    final fechaStr = json['fecha'] ?? json['created_at'] ?? '';
    final fecha = DateTime.tryParse(fechaStr) ?? DateTime.now();
    final leida = json['leida'] == true || json['leida'] == 1;
    final camposConocidos = {
      'id_notificacion', 'id', 'tipo', 'titulo', 'descripcion',
      'mensaje', 'fecha', 'created_at', 'leida', 'extra',
    };
    final extras = <String, dynamic>{};
    for (final entry in json.entries) {
      if (!camposConocidos.contains(entry.key)) {
        extras[entry.key] = entry.value;
      }
    }
    if (json['extra'] != null) {
      final e = json['extra'];
      extras.addAll(e is Map ? Map<String, dynamic>.from(e) : {});
    }

    return NotificacionModel(
      id: id is int ? id : int.tryParse(id.toString()) ?? 0,
      tipo: tipo,
      titulo: titulo,
      descripcion: descripcion,
      fecha: fecha,
      leida: leida,
      extra: extras.isNotEmpty ? extras : null,
    );
  }

  static TipoNotificacion _tipoFromString(String tipo) {
    switch (tipo) {
      case 'cita_aceptada':
      case 'reserva':
      case 'reserva_aceptada':  return TipoNotificacion.citaAceptada;
      case 'cita_rechazada':
      case 'reserva_cancelada':
      case 'reserva_rechazada': return TipoNotificacion.citaRechazada;
      case 'cita_recordatorio': return TipoNotificacion.citaRecordatorio;
      case 'cita_completada':
      case 'entrega':
      case 'nueva_entrega':     return TipoNotificacion.citaCompletada;
      case 'puntos_ganados':
      case 'puntos':
      case 'puntos_actualizados': return TipoNotificacion.puntosGanados;
      case 'canje_exitoso':
      case 'canje':             return TipoNotificacion.canjeExitoso;
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