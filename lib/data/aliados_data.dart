// lib/data/aliados_data.dart

import '../models/aliado_model.dart';

final List<AliadoModel> aliadosEjemplo = [
  AliadoModel(
    id: '1',
    nombre: 'Éxito',
    direccion: 'Centro Comercial Campanario, Popayán',
    horario: 'Lun - Sáb: 8:00am - 8:00pm',
    materiales: ['Plástico', 'Cartón', 'Vidrio', 'Papel'],
    telefono: '(2) 123-4567',
    descripcion:
        'Punto de reciclaje ubicado en la entrada principal del supermercado. Acepta materiales limpios y secos.',
  ),
  AliadoModel(
    id: '2',
    nombre: 'D1',
    direccion: 'Calle 5 # 8-23, Popayán Centro',
    horario: 'Lun - Dom: 7:00am - 9:00pm',
    materiales: ['Papel', 'Vidrio'],
    telefono: '(2) 234-5678',
    descripcion:
        'Contenedor de reciclaje disponible en el exterior de la tienda. Solo materiales secos.',
  ),
  AliadoModel(
    id: '3',
    nombre: 'Jumbo',
    direccion: 'Av. Panamericana, Popayán',
    horario: 'Lun - Dom: 9:00am - 9:00pm',
    materiales: ['Plástico', 'Cartón', 'Vidrio', 'Metal', 'Papel'],
    telefono: '(2) 345-6789',
    descripcion:
        'Estación de reciclaje completa con clasificación por tipo de material. Personal disponible para orientarte.',
  ),
  AliadoModel(
    id: '4',
    nombre: 'Carulla',
    direccion: 'Calle 15 # 12-40, Popayán',
    horario: 'Lun - Sáb: 8:00am - 7:00pm',
    materiales: ['Plástico', 'Cartón'],
    telefono: '(2) 456-7890',
    descripcion:
        'Punto de reciclaje en la zona de parqueadero. Horario especial los fines de semana.',
  ),
];