import 'package:flutter/material.dart';

class MaterialData {
  final String nombre;
  final String tipo;
  final String caneco;
  final String deposito;
  final String descripcion;
  final Color colorCaneca;
  final String cantidadEstimada;
  final String pesoAproximado;
  final String nivelReciclabilidad;
  final String recomendacionIA;

  const MaterialData({
    required this.nombre,
    required this.tipo,
    this.caneco = 'Caneco Blanco',
    this.deposito = 'Aprovechable',
    required this.descripcion,
    required this.colorCaneca,
    this.cantidadEstimada = '1 unidad',
    this.pesoAproximado = '0.3 kg',
    this.nivelReciclabilidad = 'Alto',
    this.recomendacionIA = '',
  });

  static const plastico = MaterialData(
    nombre: 'Plástico',
    tipo: 'Residuo Aprovechable',
    caneco: 'Caneco Blanco',
    deposito: 'Aprovechable',
    descripcion: 'Botellas, envases, bolsas, empaques.',
    colorCaneca: Color(0xFFF5F5F5),
    cantidadEstimada: '1 unidad',
    pesoAproximado: '0.3 kg',
    nivelReciclabilidad: 'Alto',
    recomendacionIA: 'Enjuaga y aplasta antes de depositar.',
  );

  static const metal = MaterialData(
    nombre: 'Metal',
    tipo: 'Residuo Aprovechable',
    caneco: 'Caneco Blanco',
    deposito: 'Aprovechable',
    descripcion: 'Latas, tapas, envases metálicos.',
    colorCaneca: Color(0xFFF5F5F5),
    cantidadEstimada: '1 unidad',
    pesoAproximado: '0.3 kg',
    nivelReciclabilidad: 'Alto',
    recomendacionIA: 'Aplasta la lata para ahorrar espacio.',
  );

  static const vidrio = MaterialData(
    nombre: 'Vidrio',
    tipo: 'Residuo Aprovechable',
    caneco: 'Caneco Blanco',
    deposito: 'Aprovechable',
    descripcion: 'Botellas, frascos, envases de vidrio.',
    colorCaneca: Color(0xFFF5F5F5),
    cantidadEstimada: '1 unidad',
    pesoAproximado: '0.8 kg',
    nivelReciclabilidad: 'Alto',
    recomendacionIA: 'Envuelve en papel antes de depositar.',
  );

  static const carton = MaterialData(
    nombre: 'Cartón',
    tipo: 'Residuo Aprovechable',
    caneco: 'Caneco Blanco',
    deposito: 'Aprovechable',
    descripcion: 'Cajas, empaques de cartón, papel.',
    colorCaneca: Color(0xFFF5F5F5),
    cantidadEstimada: '1 unidad',
    pesoAproximado: '0.4 kg',
    nivelReciclabilidad: 'Alto',
    recomendacionIA: 'Dóblalo para que ocupe menos espacio.',
  );

  static const desconocido = MaterialData(
    nombre: 'Desconocido',
    tipo: 'Residuo No Aprovechable',
    caneco: 'Caneco Negro',
    deposito: 'No aprovechable',
    descripcion:
        'Papel higiénico, servilletas, cartones contaminados, papeles metalizados.',
    colorCaneca: Color(0xFF2E2E2E),
    cantidadEstimada: '1 unidad',
    pesoAproximado: '0.2 kg',
    nivelReciclabilidad: 'Bajo',
    recomendacionIA: 'Depositar en Caneco Negro. No apto para reciclaje.',
  );

  static final Map<String, MaterialData> _mapa = {
    'plastico': plastico,
    'metal': metal,
    'vidrio': vidrio,
    'carton': carton,
    'papel': carton,
  };

  static MaterialData fromClase(String clase) {
    final data = _mapa[clase.toLowerCase()];
    if (data != null) return data;
    return desconocido.copyWith(
      nombre: clase.isNotEmpty ? clase : 'Desconocido',
    );
  }

  MaterialData copyWith({String? nombre}) => MaterialData(
        nombre: nombre ?? this.nombre,
        tipo: tipo,
        caneco: caneco,
        deposito: deposito,
        descripcion: descripcion,
        colorCaneca: colorCaneca,
        cantidadEstimada: cantidadEstimada,
        pesoAproximado: pesoAproximado,
        nivelReciclabilidad: nivelReciclabilidad,
        recomendacionIA: recomendacionIA,
      );

  String get estado => deposito == 'Aprovechable' ? 'Aprovechable' : 'No clasificado';

  static Color nivelColor(String nivel) {
    switch (nivel) {
      case 'Alto':
        return const Color(0xFF3B6D11);
      case 'Medio':
        return Colors.orange;
      case 'Bajo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static Color nivelBg(String nivel) {
    switch (nivel) {
      case 'Alto':
        return const Color(0xFFEAF3DE);
      case 'Medio':
        return const Color(0xFFFAEEDA);
      case 'Bajo':
        return const Color(0xFFFCEBEB);
      default:
        return Colors.grey[100]!;
    }
  }
}
