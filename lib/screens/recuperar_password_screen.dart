import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class RecuperarPasswordScreen extends StatefulWidget {
  const RecuperarPasswordScreen({super.key});

  @override
  State<RecuperarPasswordScreen> createState() => _RecuperarPasswordScreenState();
}

class _RecuperarPasswordScreenState extends State<RecuperarPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();

  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _cargando = false;
  String _correo = '';
  int _step = 1;

  Future<void> _solicitarCodigo() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _snack('Ingresa tu correo electrónico');
      return;
    }

    setState(() => _cargando = true);
    try {
      final res = await AuthService.recuperarPasswordSolicitar(email);
      if (!mounted) return;
      _snack(res['mensaje'] ?? 'Revisa tu correo electrónico');
      _correo = email;
      setState(() => _step = 2);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      _snack('Error: $msg');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _restablecer() async {
    final codigo = _codigoCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirmar = _confirmarCtrl.text;

    if (codigo.length != 6) {
      _snack('El código debe ser de 6 dígitos');
      return;
    }
    if (password.length < 6) {
      _snack('La contraseña debe tener mínimo 6 caracteres');
      return;
    }
    if (password != confirmar) {
      _snack('Las contraseñas no coinciden');
      return;
    }

    setState(() => _cargando = true);
    try {
      final res = await AuthService.recuperarPasswordRestablecer(
        correo: _correo,
        codigo: codigo,
        password: password,
      );
      if (!mounted) return;
      if (res['mensaje'] != null) {
        _snack('Contraseña restablecida correctamente');
        Navigator.pop(context);
      } else {
        _snack(res['mensaje'] ?? 'Error al restablecer');
      }
    } catch (e) {
      if (!mounted) return;
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codigoCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              _step == 1 ? '¿Olvidaste tu contraseña?' : 'Restablecer contraseña',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _step == 1
                  ? 'Te enviaremos un código a tu correo'
                  : 'Ingresa el código y tu nueva contraseña',
              style: const TextStyle(color: AppColors.textMid, fontSize: 14),
            ),
            const SizedBox(height: 36),

            if (_step == 1) ...[
              _label('Correo electrónico'),
              const SizedBox(height: 6),
              _field(controller: _emailCtrl, hint: 'tu@correo.com', icon: Icons.email_outlined),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _solicitarCodigo,
                  child: _cargando
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Enviar código'),
                ),
              ),
            ],

            if (_step == 2) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.mark_email_read, color: AppColors.primary, size: 36),
                    const SizedBox(height: 8),
                    const Text(
                      'Revisa tu correo',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enviamos un código de verificación a $_correo',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: AppColors.textMid),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _label('Código de verificación'),
              const SizedBox(height: 6),
              _field(controller: _codigoCtrl, hint: '123456', icon: Icons.pin_outlined),
              const SizedBox(height: 18),
              _label('Nueva contraseña'),
              const SizedBox(height: 6),
              _field(
                controller: _passwordCtrl,
                hint: '••••••••',
                icon: Icons.lock_outline,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.textLight, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 18),
              _label('Confirmar contraseña'),
              const SizedBox(height: 6),
              _field(
                controller: _confirmarCtrl,
                hint: '••••••••',
                icon: Icons.lock_outline,
                obscure: _obscureConfirm,
                suffix: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: AppColors.textLight, size: 20),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _restablecer,
                  child: _cargando
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Restablecer contraseña'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: AppColors.textMid,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textLight),
        prefixIcon: Icon(icon, color: AppColors.textLight, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
