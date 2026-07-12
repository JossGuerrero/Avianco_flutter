import 'package:flutter/material.dart';
import 'package:avianco/services/auth_service.dart';
import 'package:avianco/core/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = '';
  String _email = '';
  bool _isStaff = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Usuario';
      _email = prefs.getString('email') ?? 'sin email';
      _isStaff = prefs.getBool('is_staff') ?? false;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildProfileCard(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Preferencias de Cuenta'),
                        _buildInfoList(),
                        const SizedBox(height: 32),
                        _buildActionButtons(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        background: Container(decoration: const BoxDecoration(gradient: AppColors.bannerGradient)),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(_username[0].toUpperCase(), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(height: 20),
          Text(_username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.dark)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Text(
              _isStaff ? 'ADMINISTRADOR' : 'CLIENTE FRECUENTE',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String t) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 4),
        child: Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark)),
      ),
    );
  }

  Widget _buildInfoList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _infoTile(Icons.email_outlined, 'Correo Electrónico', _email),
          const Divider(height: 1, indent: 60),
          _infoTile(Icons.language, 'Idioma Preferido', 'Español (América Latina)'),
          const Divider(height: 1, indent: 60),
          _infoTile(Icons.notifications_none, 'Notificaciones', 'Activadas'),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String val) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.dark.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.dark, size: 20),
      ),
      title: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
      subtitle: Text(val, style: const TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_isStaff) ...[
          _actionBtn(Icons.visibility_outlined, 'Ver Vista Pública (Cliente)', () => Navigator.pushNamed(context, '/public')),
          const SizedBox(height: 12),
        ],
        _actionBtn(Icons.edit_outlined, 'Editar Información', () {}),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () async {
              await AuthService.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('CERRAR SESIÓN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.dark, size: 20),
        label: Text(label, style: const TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.dark.withValues(alpha: 0.15)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}
