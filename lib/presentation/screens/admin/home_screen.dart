import 'package:flutter/material.dart';
import 'package:avianco/services/auth_service.dart';
import 'package:avianco/core/app_colors.dart';
import 'package:avianco/presentation/widgets/module_card.dart';
import 'package:avianco/presentation/screens/infraestructura/airports_screen.dart';
import 'package:avianco/presentation/screens/aeronaves/aeronaves_screen.dart';
import 'package:avianco/presentation/screens/infraestructura/asientos_screen.dart';
import 'package:avianco/presentation/screens/checkins/checkins_screen.dart';
import 'package:avianco/presentation/screens/admin/dashboard_screen.dart';
import 'package:avianco/presentation/screens/vuelos/flights_screen.dart';
import 'package:avianco/presentation/screens/financiero/facturas_screen.dart';
import 'package:avianco/presentation/screens/pasajeros/passengers_screen.dart';
import 'package:avianco/presentation/screens/financiero/promociones_screen.dart';
import 'package:avianco/presentation/screens/reservas/reservations_screen.dart';
import 'package:avianco/presentation/screens/infraestructura/servicios_screen.dart';
import 'package:avianco/presentation/screens/infraestructura/tripulacion_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isStaff = false;
  String _username = '';
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    SizedBox.shrink(),
    FlightsScreen(),
    ReservationsScreen(),
    PassengersScreen(),
    AirportsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isStaff = prefs.getBool('is_staff') ?? false;
      _username = prefs.getString('username') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _selectedIndex == 0 ? _buildDashboard() : _screens[_selectedIndex],
              ),
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: _buildFloatingBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        gradient: AppColors.bannerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                child: Text(
                  _username.isNotEmpty ? _username[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${_username.isNotEmpty ? _username : 'Viajero'}',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                Text(
                  _isStaff ? 'Administrador del Sistema' : 'Bienvenido de nuevo',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await AuthService.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Viajar'),
          _buildGrid([
            ModuleCard(title: 'Vuelos', icon: Icons.flight_takeoff, color: const Color(0xFFD32F2F), onTap: () => setState(() => _selectedIndex = 1)),
            ModuleCard(title: 'Reservas', icon: Icons.book_online, color: const Color(0xFF1A1A1A), onTap: () => setState(() => _selectedIndex = 2)),
            ModuleCard(title: 'Aeropuertos', icon: Icons.map, color: const Color(0xFF424242), onTap: () => setState(() => _selectedIndex = 4)),
            ModuleCard(title: 'Check-ins', icon: Icons.how_to_reg, color: const Color(0xFF616161), onTap: () => _push(const CheckinsScreen())),
          ]),
          const SizedBox(height: 32),
          _sectionTitle('Mi cuenta'),
          _buildGrid([
            ModuleCard(title: 'Pasajeros', icon: Icons.people, color: const Color(0xFFD32F2F), onTap: () => setState(() => _selectedIndex = 3)),
            ModuleCard(title: 'Facturas', icon: Icons.receipt, color: const Color(0xFF1A1A1A), onTap: () => _push(const InvoicesScreen())),
            ModuleCard(title: 'Servicios', icon: Icons.room_service, color: const Color(0xFF424242), onTap: () => _push(const ServicesScreen())),
            ModuleCard(title: 'Promociones', icon: Icons.local_offer, color: const Color(0xFFE53935), onTap: () => _push(const PromotionsScreen())),
          ]),
          if (_isStaff) ...[
            const SizedBox(height: 32),
            _sectionTitle('Administración'),
            _buildGrid([
              ModuleCard(title: 'Aeronaves', icon: Icons.airplanemode_active, color: const Color(0xFF8E0000), onTap: () => _push(const AircraftsScreen())),
              ModuleCard(title: 'Tripulación', icon: Icons.groups, color: const Color(0xFF1A1A1A), onTap: () => _push(const CrewScreen())),
              ModuleCard(title: 'Asientos', icon: Icons.event_seat, color: const Color(0xFF212121), onTap: () => _push(const SeatsScreen())),
              ModuleCard(title: 'Analíticas', icon: Icons.bar_chart, color: const Color(0xFFD32F2F), onTap: () => _push(const DashboardScreen())),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark)),
    );
  }

  Widget _buildGrid(List<Widget> cards) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.25,
      children: cards,
    );
  }

  Widget _buildFloatingBottomNav() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 25, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.grid_view_rounded, 0, 'Panel'),
          _navItem(Icons.flight_takeoff, 1, 'Vuelos'),
          _navItem(Icons.book_online, 2, 'Viajes'),
          _navItem(Icons.people_outline, 3, 'Gente'),
          _navItem(Icons.map_outlined, 4, 'Mapa'),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index, String label) {
    bool isSel = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSel ? AppColors.primary : Colors.white54, size: 22),
            if (isSel) ...[
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
