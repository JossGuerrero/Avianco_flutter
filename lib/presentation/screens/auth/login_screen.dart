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
    setState(() { _loading = true; _error = null; });
    try {
      final data = await AuthService.login(_userCtrl.text, _passCtrl.text);
      if (data['access'] != null) {
        await AuthService.saveToken(
          data['access'], data['refresh'], data['is_staff'] ?? false,
          userId: data['user_id'], username: data['username'], email: data['email'],
        );
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() => _error = 'Credenciales incorrectas');
      }
    } catch (e) {
      setState(() => _error = 'Error de conexión');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo profesional
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1544016768-982d1554f0b9?w=1000&q=80'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay de color degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.dark.withValues(alpha: 0.8), AppColors.primary.withValues(alpha: 0.6)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  const Icon(Icons.airplanemode_active, size: 60, color: Colors.white),
                  const SizedBox(height: 24),
                  const Text('Bienvenido\na bordo', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
                  const SizedBox(height: 8),
                  const Text('Inicia sesión para continuar tu viaje', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 60),
                  _buildInput(_userCtrl, 'Usuario', Icons.person_outline),
                  const SizedBox(height: 20),
                  _buildInput(_passCtrl, 'Contraseña', Icons.lock_outline, isPass: true),
                  if (_error != null) _buildError(),
                  const SizedBox(height: 40),
                  _buildSubmit(),
                  const SizedBox(height: 32),
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool isPass = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: isPass,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildError() => Padding(
    padding: const EdgeInsets.only(top: 15),
    child: Text(_error!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  );

  Widget _buildSubmit() => SizedBox(
    width: double.infinity,
    height: 60,
    child: ElevatedButton(
      onPressed: _loading ? null : _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: _loading
        ? const CircularProgressIndicator(color: AppColors.primary)
        : const Text('INGRESAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.dark)),
    ),
  );

  Widget _buildRegisterLink() => Center(
    child: TextButton(
      onPressed: () => Navigator.pushNamed(context, '/register'),
      child: RichText(
        text: const TextSpan(
          text: '¿No tienes cuenta? ',
          style: TextStyle(color: Colors.white70),
          children: [
            TextSpan(text: 'Regístrate aquí', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
          ],
        ),
      ),
    ),
  );
}
