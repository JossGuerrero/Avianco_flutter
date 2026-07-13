import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../config/app_colors.dart';
import '../services/auth_service.dart';

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

  // Video de fondo: avión despegando (Pexels). Si falla, cae a la imagen.
  static const _videoUrl =
      'https://videos.pexels.com/video-files/1851190/1851190-uhd_2560_1440_25fps.mp4';
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final ctrl = VideoPlayerController.networkUrl(Uri.parse(_videoUrl));
      await ctrl.initialize();
      await ctrl.setLooping(true);
      await ctrl.setVolume(0);
      await ctrl.play();
      if (!mounted) {
        ctrl.dispose();
        return;
      }
      setState(() {
        _videoCtrl = ctrl;
        _videoReady = true;
      });
    } catch (e) {
      // Sin soporte de video (p.ej. Windows) o sin red: queda la imagen
      debugPrint('Video de fondo no disponible: $e');
    }
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    super.dispose();
  }

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
          userId: (data['user_id'] is num)
              ? (data['user_id'] as num).toInt()
              : (data['id'] is num ? (data['id'] as num).toInt() : null),
          username: _userCtrl.text.trim(),
          email: data['email']?.toString(),
        );
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _error = 'Usuario o contraseña incorrectos';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión';
      });
    }
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_videoReady && _videoCtrl != null)
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _videoCtrl!.value.size.width,
                height: _videoCtrl!.value.size.height,
                child: VideoPlayer(_videoCtrl!),
              ),
            )
          else
            Image.network(
              'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1200',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.mainGradient),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.82),
                  AppColors.dark.withValues(alpha: 0.88),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Icon(
                    Icons.airplanemode_active,
                    size: 72,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'avianco',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tu plataforma de vuelos inteligente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 38),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bienvenido de nuevo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ingresa con tu cuenta y gestiona vuelos, reservas y pasajeros con estilo.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _userCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Usuario',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: Colors.white70,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passCtrl,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.white70,
                              size: 22,
                            ),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: Color(0xFFFFCDD2),
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.dark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: _loading
                                ? const CircularProgressIndicator(
                                    color: AppColors.primary,
                                  )
                                : const Text(
                                    'Ingresar',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(
                              context,
                              '/register',
                            ),
                            child: const Text(
                              '¿No tienes cuenta? Regístrate',
                              style: TextStyle(
                                color: Colors.white70,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
