// lib/editar_perfil/editar_perfil_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/usuario_service.dart';
import '../styles/colors.dart';
import 'editar_perfil_style.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final perfil = await UsuarioService.getPerfil();
      if (perfil['usuario'] != null) {
        _nombreController.text = perfil['usuario']['nombre'] ?? '';
        _telefonoController.text = perfil['usuario']['telefono'] ?? '';
        return;
      }
    } catch (_) {}
    _nombreController.text = await AuthService.getNombre();
    _telefonoController.text = await AuthService.getTelefono();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await UsuarioService.updatePerfil(
        nombre: _nombreController.text,
        telefono: _telefonoController.text,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nombre_usuario', _nombreController.text);
      await prefs.setString('usuario_telefono', _telefonoController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado'), backgroundColor: GreenColors.dark),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar perfil'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _guardando = false);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EditarPerfilStyles.bg,
      appBar: AppBar(
        title: const Text('Editar perfil'),
        backgroundColor: GreenColors.dark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EditarPerfilStyles.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: EditarPerfilStyles.cardPadding,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(EditarPerfilStyles.cardRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nombre',
                        style: EditarPerfilStyles.label),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nombreController,
                      decoration: _inputDec('Tu nombre'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: EditarPerfilStyles.formGap),
                    const Text('Teléfono',
                        style: EditarPerfilStyles.label),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _telefonoController,
                      decoration: _inputDec('Tu teléfono'),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: EditarPerfilStyles.buttonGap),
              SizedBox(
                width: double.infinity,
                height: EditarPerfilStyles.buttonHeight,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  child: _guardando
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Guardar cambios', style: EditarPerfilStyles.buttonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GreenColors.dark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(EditarPerfilStyles.buttonRadius),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: EditarPerfilStyles.bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(EditarPerfilStyles.fieldRadius),
        borderSide: BorderSide.none,
      ),
      contentPadding: EditarPerfilStyles.fieldPadding,
    );
  }
}
