import 'package:flutter/material.dart';
import 'package:avianco/services/auth_service.dart';
import 'package:avianco/core/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (_userCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Por favor completa todos los campos');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await AuthService.register(_userCtrl.text, _emailCtrl.text, _passCtrl.text);

      if (res.containsKey('access')) {
        await AuthService.saveToken(
          res['access'],
          res['refresh'],
          res['is_staff'] ?? false,
          userId: res['user_id'],
          username: res['username'],
          email: res['email'],
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Cuenta creada exitosamente!')));
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        String errorMsg = 'Error en el registro';
        final firstKey = res.keys.firstWhere((k) => k != 'error', orElse: () => '');
        if (firstKey.isNotEmpty) {
          final val = res[firstKey];
          errorMsg = (val is List) ? val.first.toString() : val.toString();
        }
        setState(() => _error = errorMsg);
      }
    } catch (e) {
      setState(() => _error = 'Error de conexión');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.dark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add_outlined, size: 70, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Crear cuenta',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Text(
                    'Únete a Avianco Airlines',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  _buildField(_userCtrl, 'Usuario', Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildField(_emailCtrl, 'Email', Icons.email_outlined),
                  const SizedBox(height: 16),
                  _buildField(_passCtrl, 'Contraseña', Icons.lock_outline, obscure: true),
                  if (_error != null) _buildError(),
                  const SizedBox(height: 32),
                  _buildSubmit(),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: RichText(
                      text: const TextSpan(
                        text: '¿Ya tienes cuenta? ',
                        style: TextStyle(color: Colors.white70),
                        children: [
                          TextSpan(
                            text: 'Inicia sesión',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white38),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(_error!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
    );
  }

  Widget _buildSubmit() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _loading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _loading
            ? const CircularProgressIndicator(color: AppColors.primary)
            : const Text(
                'Registrarme',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark),
              ),
      ),
    );
  }
}
