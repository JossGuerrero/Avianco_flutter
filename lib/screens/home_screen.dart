import 'package:flutter/material.dart';
import '../config/api.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/module_card.dart';
import 'profile_screen.dart';
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
  String _username = '';
  String? _fotoUrl;
  int _selectedIndex = 0;
  List<dynamic> _notifs = [];

  int get _noLeidas => _notifs.where((n) => n['leida'] != true).length;

  final List<Widget> _screens = const [
    DashboardScreen(),
    FlightsScreen(),
    ReservationsScreen(),
    PassengersScreen(),
    AirportsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final staff = await AuthService.isStaff();
    final username = await AuthService.getUsername();
    final userId = await AuthService.getUserId();
    final notifs = await ApiService.getNotificaciones();
    // Foto de perfil del pasajero propio (si existe)
    String? fotoUrl;
    if (userId != null) {
      final pasajeros = await ApiService.getPasajeros();
      final propios = pasajeros.where((p) => p['usuario'] == userId);
      if (propios.isNotEmpty) {
        fotoUrl = Api.mediaUrl(propios.first['foto_perfil']);
      }
    }
    if (!mounted) return;
    setState(() {
      _isStaff = staff;
      _username = username ?? '';
      _fotoUrl = fotoUrl;
      // Solo las notificaciones del usuario actual (si el campo existe)
      _notifs = notifs
          .where((n) => n['usuario'] == null || n['usuario'] == userId)
          .toList();
    });
  }

  void _showNotificaciones() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.7,
        ),
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Notificaciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),
            ),
            Flexible(
              child: _notifs.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 56,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No tienes notificaciones',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _notifs.length,
                      itemBuilder: (ctx, i) {
                        final n = _notifs[i];
                        final leida = n['leida'] == true;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: leida
                                ? Colors.grey[300]
                                : AppColors.primary,
                            child: Icon(
                              Icons.notifications,
                              color: leida ? Colors.grey : Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            (n['titulo'] ?? 'Notificación').toString(),
                            style: TextStyle(
                              fontWeight: leida
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            (n['mensaje'] ?? '').toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: leida
                              ? null
                              : () async {
                                  await ApiService.marcarNotificacionLeida(
                                    n['id'],
                                  );
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  _loadRole();
                                },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
          ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _section(String title, List<Widget> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
              letterSpacing: 0.3,
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: _showNotificaciones,
              ),
              if (_noLeidas > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_noLeidas',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // ---- Header con saludo ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.darkRed, AppColors.dark],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                  child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    backgroundImage:
                        _fotoUrl != null ? NetworkImage(_fotoUrl!) : null,
                    child: _fotoUrl != null
                        ? null
                        : Text(
                            _username.isNotEmpty
                                ? _username[0].toUpperCase()
                                : (_isStaff ? 'A' : 'P'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _username.isNotEmpty ? 'Hola, $_username' : 'Hola',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isStaff
                            ? 'Administrador · Avianco Airlines'
                            : 'Bienvenido a Avianco Airlines',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedIndex == 0
                ? SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _section('Viajar', [
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
                            title: 'Aeropuertos',
                            icon: Icons.location_on,
                            color: AppColors.darkAlt,
                            onTap: () => setState(() => _selectedIndex = 4),
                          ),
                          ModuleCard(
                            title: 'Check-ins',
                            icon: Icons.how_to_reg,
                            color: AppColors.darkRed,
                            onTap: () => _push(const CheckinsScreen()),
                          ),
                        ]),
                        _section('Mi cuenta', [
                          ModuleCard(
                            title: 'Pasajeros',
                            icon: Icons.person,
                            color: AppColors.darkRed,
                            onTap: () => setState(() => _selectedIndex = 3),
                          ),
                          ModuleCard(
                            title: 'Facturas',
                            icon: Icons.receipt_long,
                            color: AppColors.greyAccent,
                            onTap: () => _push(const InvoicesScreen()),
                          ),
                          ModuleCard(
                            title: 'Servicios',
                            icon: Icons.room_service,
                            color: AppColors.deepRed,
                            onTap: () => _push(const ServicesScreen()),
                          ),
                          ModuleCard(
                            title: 'Promociones',
                            icon: Icons.local_offer,
                            color: AppColors.primaryLight,
                            onTap: () => _push(const PromotionsScreen()),
                          ),
                        ]),
                        if (_isStaff)
                          _section('Administración', [
                            ModuleCard(
                              title: 'Dashboard',
                              icon: Icons.dashboard,
                              color: AppColors.dark,
                              onTap: () => _push(const DashboardScreen()),
                            ),
                            ModuleCard(
                              title: 'Aeronaves',
                              icon: Icons.airplanemode_active,
                              color: AppColors.darkAlt,
                              onTap: () => _push(const AircraftsScreen()),
                            ),
                            ModuleCard(
                              title: 'Tripulación',
                              icon: Icons.people,
                              color: AppColors.deepRed,
                              onTap: () => _push(const CrewScreen()),
                            ),
                            ModuleCard(
                              title: 'Asientos',
                              icon: Icons.event_seat,
                              color: AppColors.greyDark,
                              onTap: () => _push(const SeatsScreen()),
                            ),
                          ]),
                      ],
                    ),
                  )
                : _screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex == 0 ? 0 : _selectedIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.flight_takeoff),
                label: 'Vuelos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book_online),
                label: 'Reservas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Pasajeros',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_airport),
                label: 'Aeropuertos',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
