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
      setState(() => _error = 'Completa todos los campos'); return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await AuthService.register(_userCtrl.text, _emailCtrl.text, _passCtrl.text);
      if (res.containsKey('access')) {
        await AuthService.saveToken(res['access'], res['refresh'], res['is_staff'] ?? false);
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() => _error = 'Error en el registro');
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1517935706615-2717063c2225?w=1000&q=80'),
                fit: BoxFit.cover,
              ),
            ),
          ),
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
                  const SizedBox(height: 20),
                  const BackButton(color: Colors.white),
                  const SizedBox(height: 30),
                  const Text('Crea tu\ncuenta', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
                  const SizedBox(height: 40),
                  _buildInput(_userCtrl, 'Usuario', Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildInput(_emailCtrl, 'Email', Icons.email_outlined),
                  const SizedBox(height: 16),
                  _buildInput(_passCtrl, 'Contraseña', Icons.lock_outline, isPass: true),
                  if (_error != null) _buildError(),
                  const SizedBox(height: 40),
                  _buildSubmit(),
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
      onPressed: _loading ? null : _register,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: _loading
        ? const CircularProgressIndicator(color: AppColors.primary)
        : const Text('REGISTRARME', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.dark)),
    ),
  );
}
