// lib/data/recompensas_data.dart

import '../models/recompensa_model.dart';

final List<RecompensaModel> recompensasEjemplo = [
  RecompensaModel(
    id: '1',
    tienda: 'SuperNorte',
    descripcion: '10% de descuento en toda la tienda',
    descuentoPorcentaje: 10,
    puntosRequeridos: 100,
    disponibles: 270,
    validoHasta: '31 de diciembre 2024',
    categoria: 'descuento',
    condiciones: [
      'Válido hasta el 31 de diciembre de 2024',
      'No acumulable con otras promociones',
      'Aplica en compras mayores a \$50,000',
      'Un canje por usuario',
    ],
  ),
  RecompensaModel(
    id: '2',
    tienda: 'Éxito',
    descripcion: '5% de descuento en frutas y verduras',
    descuentoPorcentaje: 5,
    puntosRequeridos: 50,
    disponibles: 500,
    validoHasta: '28 de febrero 2025',
    categoria: 'descuento',
    condiciones: [
      'Válido hasta el 28 de febrero de 2025',
      'Solo aplica en sección de frutas y verduras',
      'No tiene mínimo de compra',
    ],
  ),
  RecompensaModel(
    id: '3',
    tienda: 'Jumbo',
    descripcion: '15% de descuento en productos de aseo',
    descuentoPorcentaje: 15,
    puntosRequeridos: 200,
    disponibles: 120,
    validoHasta: '15 de enero 2025',
    categoria: 'descuento',
    condiciones: [
      'Válido hasta el 15 de enero de 2025',
      'Solo en sección de aseo del hogar',
      'Aplica en compras mayores a \$80,000',
    ],
  ),
  RecompensaModel(
    id: '4',
    tienda: 'Carulla',
    descripcion: 'Bolsa reutilizable gratis',
    descuentoPorcentaje: 0,
    puntosRequeridos: 75,
    disponibles: 80,
    validoHasta: '30 de marzo 2025',
    categoria: 'producto',
    condiciones: [
      'Válido hasta el 30 de marzo de 2025',
      'Un producto por usuario',
      'Reclamar en caja con el código QR',
    ],
  ),
];