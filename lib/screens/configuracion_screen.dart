import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../services/usuario_service.dart';
import 'info_screen.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() =>
      _ConfiguracionScreenState();
}

class _ConfiguracionScreenState
    extends State<ConfiguracionScreen> {

  bool notificaciones = true;

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
            icono: Icons.lock,
            titulo: 'Cambiar contraseña',
            subtitulo: 'Actualizar seguridad',
            onTap: _mostrarDialogoCambiarPassword,
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
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InfoScreen(
              titulo: 'Términos y condiciones',
              mostrarBoton: true,
              secciones: [
                {
                  'titulo': '1. Aceptación de los términos',
                  'contenido': 'Al usar esta aplicación aceptas los presentes términos. Si no estás de acuerdo, no uses la aplicación.',
                },
                {
                  'titulo': '2. Uso del servicio',
                  'contenido': 'La app permite registrar entregas de materiales reciclables, acumular puntos y canjear recompensas. Debes usar la app solo para fines legales y autorizados.',
                },
                {
                  'titulo': '3. Cuenta de usuario',
                  'contenido': 'Eres responsable de mantener la confidencialidad de tu cuenta y contraseña. Debes proporcionar información veraz al registrarte.',
                },
                {
                  'titulo': '4. Puntos y recompensas',
                  'contenido': 'Los puntos se asignan según el material y cantidad reciclada. No tienen valor monetario y pueden estar sujetos a cambios. La empresa puede modificar el sistema de puntos en cualquier momento.',
                },
                {
                  'titulo': '5. Privacidad',
                  'contenido': 'Tus datos personales se manejan según nuestra Política de Privacidad. No compartimos tu información sin tu consentimiento.',
                },
                {
                  'titulo': '6. Modificaciones',
                  'contenido': 'Nos reservamos el derecho de modificar estos términos. Los cambios serán notificados a través de la aplicación.',
                },
              ],
            ))),
          ),

          _buildTile(
            icono: Icons.privacy_tip,
            titulo: 'Política de privacidad',
            subtitulo: 'Protección de datos',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InfoScreen(
              titulo: 'Política de privacidad',
              secciones: [
                {
                  'titulo': '1. Información que recopilamos',
                  'contenido': 'Recopilamos tu nombre, correo electrónico, teléfono y foto de perfil cuando te registras. También almacenamos el historial de entregas, puntos acumulados y canjes realizados.',
                },
                {
                  'titulo': '2. Uso de la información',
                  'contenido': 'Usamos tus datos para gestionar tu cuenta, registrar tus reciclajes, asignar puntos, procesar canjes y mejorar nuestros servicios. No vendemos tu información personal.',
                },
                {
                  'titulo': '3. Almacenamiento de datos',
                  'contenido': 'Tus datos se almacenan de forma segura en servidores protegidos. Conservamos tu información mientras tengas una cuenta activa.',
                },
                {
                  'titulo': '4. Tus derechos',
                  'contenido': 'Puedes solicitar la corrección o eliminación de tus datos personales en cualquier momento contactándonos a través de la aplicación.',
                },
                {
                  'titulo': '5. Cambios en la política',
                  'contenido': 'Esta política puede actualizarse periódicamente. Te notificaremos cualquier cambio importante a través de la app.',
                },
              ],
            ))),
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

  Future<void> _mostrarDialogoCambiarPassword() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    String getStrength(String pwd) {
      if (pwd.isEmpty) return '';
      if (pwd.length < 6) return 'Débil';
      if (pwd.length < 10) return 'Media';
      return 'Fuerte';
    }

    Color strengthColor(String s) {
      if (s == 'Débil') return Colors.red;
      if (s == 'Media') return Colors.amber;
      if (s == 'Fuerte') return const Color(0xFF2E7D32);
      return Colors.transparent;
    }

    double strengthValue(String s) {
      if (s == 'Débil') return 0.33;
      if (s == 'Media') return 0.66;
      if (s == 'Fuerte') return 1.0;
      return 0;
    }

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final strength = getStrength(newCtrl.text);
          return Stack(
            children: [
              // Blur fondo
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(color: Colors.black.withValues(alpha: 0.3)),
                ),
              ),
              Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 360,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          // ── Botón cerrar X ──
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(ctx),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(BootstrapIcons.x, size: 18, color: Colors.grey.shade600),
                              ),
                            ),
                          ),

                          // ── Icono candado + hojas ──
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(BootstrapIcons.tree, size: 22, color: const Color(0xFF4CAF50).withValues(alpha: 0.5)),
                              const SizedBox(width: 12),
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Icon(BootstrapIcons.shield_lock, color: Color(0xFF2E7D32), size: 30),
                              ),
                              const SizedBox(width: 12),
                              Icon(BootstrapIcons.tree, size: 22, color: const Color(0xFF4CAF50).withValues(alpha: 0.5)),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ── Título ──
                          const Text('Cambiar contraseña',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF263238)),
                          ),
                          const SizedBox(height: 6),
                          Text('Mantén tu cuenta segura actualizando tu contraseña',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),

                          const SizedBox(height: 24),

                          // ── Campo: Contraseña actual ──
                          _passwordField(
                            controller: currentCtrl,
                            label: 'Contraseña actual',
                            hint: 'Ingresa tu contraseña actual',
                          ),

                          const SizedBox(height: 14),

                          // ── Campo: Nueva contraseña ──
                          _passwordField(
                            controller: newCtrl,
                            label: 'Nueva contraseña',
                            hint: 'Mínimo 6 caracteres',
                            onChanged: (_) => setDialogState(() {}),
                          ),

                          const SizedBox(height: 14),

                          // ── Campo: Confirmar ──
                          _passwordField(
                            controller: confirmCtrl,
                            label: 'Confirmar nueva contraseña',
                            hint: 'Repite la nueva contraseña',
                            confirmCtrl: newCtrl,
                          ),

                          // ── Indicador de seguridad ──
                          if (newCtrl.text.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32).withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(BootstrapIcons.shield_check, color: strengthColor(strength), size: 18),
                                      const SizedBox(width: 8),
                                      Text('Seguridad de la contraseña',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                                      ),
                                      const Spacer(),
                                      Text(strength,
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: strengthColor(strength)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: strengthValue(strength),
                                      minHeight: 6,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(strengthColor(strength)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // ── Botones ──
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF2E7D32),
                                    side: const BorderSide(color: Color(0xFF2E7D32)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (!formKey.currentState!.validate()) return;
                                      try {
                                        await UsuarioService.cambiarPassword(
                                          passwordActual: currentCtrl.text,
                                          passwordNuevo: newCtrl.text,
                                        );
                                        if (ctx.mounted) Navigator.pop(ctx);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Contraseña actualizada')),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(BootstrapIcons.check2, color: Colors.white, size: 18),
                                        SizedBox(width: 6),
                                        Text('Guardar', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Widget campo de contraseña ──
  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextEditingController? confirmCtrl,
    ValueChanged<String>? onChanged,
  }) {
    return StatefulBuilder(
      builder: (context, setLocalState) {
        bool obscure = true;
        return TextFormField(
          controller: controller,
          obscureText: obscure,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: const Icon(BootstrapIcons.lock, size: 18, color: Color(0xFF2E7D32)),
            suffixIcon: GestureDetector(
              onTap: () => setLocalState(() => obscure = !obscure),
              child: Icon(
                obscure ? BootstrapIcons.eye : BootstrapIcons.eye_slash,
                size: 18,
                color: Colors.grey.shade500,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Campo obligatorio';
            if (label == 'Confirmar nueva contraseña' && v != confirmCtrl?.text) return 'No coincide con la nueva contraseña';
            return null;
          },
        );
      },
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
