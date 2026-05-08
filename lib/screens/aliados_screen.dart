import 'package:flutter/material.dart';

class AliadosScreen extends StatelessWidget {
  const AliadosScreen({super.key});

  final List<Map<String, dynamic>> aliados = const [
    {
      "name": "Éxito",
      "address": "Centro Comercial Campanario",
      "materials": ["Plástico", "Cartón", "Vidrio"]
    },
    {
      "name": "D1",
      "address": "Popayán Centro",
      "materials": ["Papel", "Vidrio"]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aliados'),
      ),
      body: ListView.builder(
        itemCount: aliados.length,
        itemBuilder: (context, index) {

          final aliado = aliados[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(Icons.store),
              title: Text(aliado["name"]),
              subtitle: Text(aliado["address"]),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          );
        },
      ),
    );
  }
}