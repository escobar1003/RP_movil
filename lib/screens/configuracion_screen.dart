// lib/screens/configuracion_screen.dart angie
import 'package:flutter/material.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() =>
      _ConfiguracionScreenState();
}

class _ConfiguracionScreenState
    extends State<ConfiguracionScreen> {

  bool notificaciones = true;
  bool modoOscuro = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          // PERFIL
          const Text(
            'Cuenta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          _buildTile(
            icono: Icons.person,
            titulo: 'Editar perfil',
            subtitulo: 'Cambiar información personal',
            onTap: () {},
          ),

          _buildTile(
            icono: Icons.photo_camera,
            titulo: 'Cambiar foto',
            subtitulo: 'Actualizar imagen de perfil',
            onTap: () {},
          ),

          _buildTile(
            icono: Icons.lock,
            titulo: 'Cambiar contraseña',
            subtitulo: 'Actualizar seguridad',
            onTap: () {},
          ),

          const SizedBox(height: 25),

          // PREFERENCIAS
          const Text(
            'Preferencias',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          SwitchListTile(
            value: notificaciones,

            onChanged: (value) {
              setState(() {
                notificaciones = value;
              });
            },

            title: const Text('Notificaciones'),

            subtitle: const Text(
              'Recibir alertas y recordatorios',
            ),

            secondary: const Icon(Icons.notifications),
          ),

          SwitchListTile(
            value: modoOscuro,

            onChanged: (value) {
              setState(() {
                modoOscuro = value;
              });
            },

            title: const Text('Modo oscuro'),

            subtitle: const Text(
              'Cambiar apariencia de la app',
            ),

            secondary: const Icon(Icons.dark_mode),
          ),

          const SizedBox(height: 25),

          // RECICLAJE
          const Text(
            'Reciclaje',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          _buildTile(
            icono: Icons.history,
            titulo: 'Historial de reciclaje',
            subtitulo: 'Ver entregas realizadas',
            onTap: () {},
          ),

          _buildTile(
            icono: Icons.star,
            titulo: 'Mis puntos',
            subtitulo: 'Consultar puntos acumulados',
            onTap: () {},
          ),

          _buildTile(
            icono: Icons.calendar_month,
            titulo: 'Mis reservas',
            subtitulo: 'Ver citas programadas',
            onTap: () {},
          ),

          const SizedBox(height: 25),

          // INFORMACIÓN
          const Text(
            'Información',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          _buildTile(
            icono: Icons.description,
            titulo: 'Términos y condiciones',
            subtitulo: 'Leer términos de uso',
            onTap: () {},
          ),

          _buildTile(
            icono: Icons.privacy_tip,
            titulo: 'Política de privacidad',
            subtitulo: 'Protección de datos',
            onTap: () {},
          ),

          _buildTile(
            icono: Icons.info,
            titulo: 'Acerca de',
            subtitulo: 'Versión de la aplicación',
            onTap: () {},
          ),

        ],
      ),
    );
  }

   Widget _buildTile({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: ListTile(
        leading: Icon(
          icono,
          color: Colors.green,
        ),

        title: Text(titulo),

        subtitle: Text(subtitulo),

        trailing: const Icon(Icons.arrow_forward_ios),

        onTap: onTap,
      ),
    );
  }
}