import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../services/auth_service.dart';

class ReservasScreen extends StatefulWidget {
  final Map<String, dynamic> aliado;

  const ReservasScreen({
    super.key,
    required this.aliado,
  });

  @override
  State<ReservasScreen> createState() =>
      _ReservasScreenState();
}

class _ReservasScreenState
    extends State<ReservasScreen> {
  final TextEditingController
      observacionesController =
      TextEditingController();

  bool loading = false;

  List<MaterialSeleccionado> materiales = [];

  @override
  void initState() {
    super.initState();

    materiales = [
      MaterialSeleccionado(
        id: 1,
        nombre: 'Plástico',
      ),
      MaterialSeleccionado(
        id: 2,
        nombre: 'Cartón',
      ),
      MaterialSeleccionado(
        id: 3,
        nombre: 'Vidrio',
      ),
      MaterialSeleccionado(
        id: 4,
        nombre: 'Metal',
      ),
    ];
  }

  Future<void> registrarEntrega() async {
    try {
      setState(() {
        loading = true;
      });

      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró token de autenticación'),
          ),
        );
        return;
      }

      final detalles = materiales
          .where((m) =>
              m.seleccionado &&
              m.pesoController.text.isNotEmpty)
          .map((m) => {
                "idMaterial": m.id,
                "peso": double.parse(
                  m.pesoController.text,
                )
              })
          .toList();

      if (detalles.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Selecciona materiales',
            ),
          ),
        );

        return;
      }

      final body = {
        "idPunto": widget.aliado['id'],
        "observacion": observacionesController.text,
        "detalles": detalles
      };

      final response = await http.post(
        Uri.parse(
          'http://10.0.2.2:3333/api/usuario/entregas',
        ),
        headers: {
          'Content-Type':
              'application/json',
          'Authorization':
              'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text(
              'Entrega registrada',
            ),
            content: Text(
              'Puntos ganados: ${data['entrega']['puntosTotales']}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child:
                    const Text('Aceptar'),
              )
            ],
          ),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              data['message']
                      ?.toString() ??
                  'Error del servidor',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Widget materialCard(
      MaterialSeleccionado material) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value:
                    material.seleccionado,
                onChanged: (value) {
                  setState(() {
                    material.seleccionado =
                        value!;
                  });
                },
              ),
              Expanded(
                child: Text(
                  material.nombre,
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          if (material.seleccionado)
            TextField(
              controller:
                  material.pesoController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  InputDecoration(
                hintText:
                    'Peso en KG',
                prefixIcon: const Icon(
                  BootstrapIcons.box,
                ),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    15,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF4F7F5),

      appBar: AppBar(
        title:
            const Text('Reservar entrega'),
        backgroundColor:
            Colors.green,
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius
                        .circular(20),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    widget.aliado['nombre'],
                    style:
                        const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Row(
                    children: [
                      const Icon(
                        BootstrapIcons
                            .geo_alt_fill,
                        color:
                            Colors.green,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Expanded(
                        child: Text(
                          widget.aliado['direccion'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Materiales',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            ...materiales.map(materialCard),

            const SizedBox(height: 25),

            const Text(
              'Observaciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller:
                  observacionesController,
              maxLines: 4,
              decoration:
                  InputDecoration(
                hintText:
                    'Escribe detalles...',
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(15),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loading
                    ? null
                    : registrarEntrega,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      15,
                    ),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(
                        color:
                            Colors.white,
                      )
                    : const Text(
                        'Registrar entrega',
                        style:
                            TextStyle(
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MaterialSeleccionado {
  final int id;
  final String nombre;

  bool seleccionado;

  TextEditingController
      pesoController =
      TextEditingController();

  MaterialSeleccionado({
    required this.id,
    required this.nombre,
    this.seleccionado = false,
  });
}