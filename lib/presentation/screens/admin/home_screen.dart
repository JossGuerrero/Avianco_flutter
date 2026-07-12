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
    SizedBox.shrink(), // Dashboard is built inline when _selectedIndex is 0
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
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.airplanemode_active, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'avianco',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 22),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildGreetingHeader(),
          Expanded(
            child: _selectedIndex == 0 ? _buildDashboard() : _screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildGreetingHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: const BoxDecoration(
        gradient: AppColors.bannerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              child: Text(
                _username.isNotEmpty ? _username[0].toUpperCase() : (_isStaff ? 'A' : 'P'),
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username.isNotEmpty ? 'Hola, $_username' : 'Hola',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  _isStaff ? 'Administrador · Avianco Airlines' : 'Bienvenido a Avianco Airlines',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('Viajar', [
            ModuleCard(title: 'Vuelos', icon: Icons.flight_takeoff, color: AppColors.primary, onTap: () => setState(() => _selectedIndex = 1)),
            ModuleCard(title: 'Reservas', icon: Icons.book_online, color: AppColors.dark, onTap: () => setState(() => _selectedIndex = 2)),
            ModuleCard(title: 'Aeropuertos', icon: Icons.map, color: AppColors.darkAlt, onTap: () => setState(() => _selectedIndex = 4)),
            ModuleCard(title: 'Check-ins', icon: Icons.how_to_reg, color: AppColors.greyDark, onTap: () => _push(const CheckinsScreen())),
          ]),
          const SizedBox(height: 24),
          _section('Mi cuenta', [
            ModuleCard(title: 'Pasajeros', icon: Icons.people, color: AppColors.primary, onTap: () => setState(() => _selectedIndex = 3)),
            ModuleCard(title: 'Facturas', icon: Icons.receipt, color: AppColors.dark, onTap: () => _push(const InvoicesScreen())),
            ModuleCard(title: 'Servicios', icon: Icons.room_service, color: AppColors.darkAlt, onTap: () => _push(const ServicesScreen())),
            ModuleCard(title: 'Promociones', icon: Icons.local_offer, color: AppColors.primaryLight, onTap: () => _push(const PromotionsScreen())),
          ]),
          if (_isStaff) ...[
            const SizedBox(height: 24),
            _section('Administración', [
              ModuleCard(title: 'Aeronaves', icon: Icons.airplanemode_active, color: AppColors.deepRed, onTap: () => _push(const AircraftsScreen())),
              ModuleCard(title: 'Tripulación', icon: Icons.groups, color: AppColors.dark, onTap: () => _push(const CrewScreen())),
              ModuleCard(title: 'Asientos', icon: Icons.event_seat, color: AppColors.darkAlt, onTap: () => _push(const SeatsScreen())),
              ModuleCard(title: 'Analíticas', icon: Icons.bar_chart, color: AppColors.primary, onTap: () => _push(const DashboardScreen())),
            ]),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 4),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark)),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.45,
          children: cards,
        ),
      ],
    );
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.flight_takeoff), label: 'Vuelos'),
            BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Reservas'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Pasajeros'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          ],
        ),
      ),
    );
  }
}
