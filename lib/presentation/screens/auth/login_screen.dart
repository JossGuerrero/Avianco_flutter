import 'package:flutter/material.dart';
import 'package:avianco/services/auth_service.dart';
import 'package:avianco/core/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await AuthService.login(_userCtrl.text, _passCtrl.text);
      if (data['access'] != null) {
        await AuthService.saveToken(
          data['access'],
          data['refresh'],
          data['is_staff'] ?? false,
          userId: data['user_id'],
          username: data['username'],
          email: data['email'],
        );
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() => _error = 'Usuario o contraseña incorrectos');
      }
    } catch (e) {
      setState(() => _error = 'Error de conexión');
    }
    setState(() => _loading = false);
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
                  const Icon(Icons.airplanemode_active, size: 80, color: Colors.white),
                  const SizedBox(height: 8),
                  const Text(
                    'avianco',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                  const Text(
                    'Sistema de Vuelos',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 48),
                  _buildField(_userCtrl, 'Usuario', Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildField(_passCtrl, 'Contraseña', Icons.lock_outline, obscure: true),
                  if (_error != null) _buildError(),
                  const SizedBox(height: 24),
                  _buildSubmit(),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: RichText(
                      text: const TextSpan(
                        text: '¿No tienes cuenta? ',
                        style: TextStyle(color: Colors.white70),
                        children: [
                          TextSpan(
                            text: 'Regístrate',
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
      child: Text(_error!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSubmit() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _loading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _loading
            ? const CircularProgressIndicator(color: AppColors.primary)
            : const Text(
                'Ingresar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark),
              ),
      ),
    );
  }
}
