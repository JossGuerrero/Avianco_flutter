import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/auth_service.dart';
import '../widgets/module_card.dart';
import 'airports_screen.dart';
import 'aeronaves_screen.dart';
import 'asientos_screen.dart';
import 'checkins_screen.dart';
import 'dashboard_screen.dart';
import 'flights_screen.dart';
import 'facturas_screen.dart';
import 'passengers_screen.dart';
import 'promociones_screen.dart';
import 'reservations_screen.dart';
import 'servicios_screen.dart';
import 'tripulacion_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isStaff = false;
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    FlightsScreen(),
    ReservationsScreen(),
    PassengersScreen(),
    AirportsScreen(),
  ];

  // Module list removed (cards are declared inline)

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final staff = await AuthService.isStaff();
    setState(() {
      _isStaff = staff;
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
        title: const Row(
          children: [
            Icon(Icons.airplanemode_active, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'avianco',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.darkRed, AppColors.dark],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isStaff ? 'Administrador' : 'Pasajero',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bienvenido a Avianco Airlines',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedIndex == 0
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        // Core modules (use tabs)
                        ModuleCard(
                          title: 'Vuelos',
                          icon: Icons.flight_takeoff,
                          color: AppColors.primary,
                          onTap: () => setState(() => _selectedIndex = 1),
                        ),
                        ModuleCard(
                          title: 'Reservas',
                          icon: Icons.book_online,
                          color: AppColors.greyDark,
                          onTap: () => setState(() => _selectedIndex = 2),
                        ),
                        ModuleCard(
                          title: 'Pasajeros',
                          icon: Icons.person,
                          color: AppColors.darkRed,
                          onTap: () => setState(() => _selectedIndex = 3),
                        ),
                        ModuleCard(
                          title: 'Aeropuertos',
                          icon: Icons.location_on,
                          color: AppColors.darkAlt,
                          onTap: () => setState(() => _selectedIndex = 4),
                        ),

                        // Additional modules (open as pages)
                        ModuleCard(
                          title: 'Servicios',
                          icon: Icons.room_service,
                          color: AppColors.deepRed,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ServicesScreen(),
                            ),
                          ),
                        ),
                        ModuleCard(
                          title: 'Promociones',
                          icon: Icons.local_offer,
                          color: AppColors.primaryLight,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PromotionsScreen(),
                            ),
                          ),
                        ),
                        ModuleCard(
                          title: 'Facturas',
                          icon: Icons.receipt_long,
                          color: AppColors.greyAccent,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InvoicesScreen(),
                            ),
                          ),
                        ),
                        ModuleCard(
                          title: 'Check-ins',
                          icon: Icons.how_to_reg,
                          color: AppColors.darkRed,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckinsScreen(),
                            ),
                          ),
                        ),

                        // Staff-only modules
                        if (_isStaff) ...[
                          ModuleCard(
                            title: 'Dashboard',
                            icon: Icons.dashboard,
                            color: AppColors.dark,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DashboardScreen(),
                              ),
                            ),
                          ),
                          ModuleCard(
                            title: 'Aeronaves',
                            icon: Icons.airplanemode_active,
                            color: AppColors.darkAlt,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AircraftsScreen(),
                              ),
                            ),
                          ),
                          ModuleCard(
                            title: 'Tripulación',
                            icon: Icons.people,
                            color: AppColors.deepRed,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CrewScreen(),
                              ),
                            ),
                          ),
                          ModuleCard(
                            title: 'Asientos',
                            icon: Icons.event_seat,
                            color: AppColors.greyDark,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SeatsScreen(),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : _screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex == 0 ? 0 : _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight_takeoff),
            label: 'Vuelos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Pasajeros'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_airport),
            label: 'Aeropuertos',
          ),
        ],
      ),
    );
  }
}

// _ModuleItem removed (cards declared inline)
