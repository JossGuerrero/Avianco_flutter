import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avianco/presentation/screens/home/public_home_screen.dart';
import 'package:avianco/presentation/screens/auth/login_screen.dart';
import 'package:avianco/presentation/screens/auth/register_screen.dart';
import 'package:avianco/presentation/screens/admin/home_screen.dart';
import 'package:avianco/presentation/screens/pasajeros/profile_screen.dart';
import 'package:avianco/presentation/providers/auth_provider.dart';
import 'package:avianco/presentation/providers/vuelos_provider.dart';
import 'package:avianco/presentation/providers/aeronaves_provider.dart';
import 'package:avianco/presentation/providers/reservas_provider.dart';
import 'package:avianco/presentation/providers/pasajeros_provider.dart';
import 'package:avianco/presentation/providers/aeropuertos_provider.dart';
import 'package:avianco/presentation/providers/promociones_provider.dart';
import 'package:avianco/presentation/providers/dashboard_provider.dart';
import 'package:avianco/presentation/providers/checkins_provider.dart';
import 'package:avianco/presentation/providers/tripulacion_provider.dart';
import 'package:avianco/presentation/providers/servicios_provider.dart';
import 'package:avianco/core/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Usar valores por defecto si no hay .env
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VuelosProvider()),
        ChangeNotifierProvider(create: (_) => AeronavesProvider()),
        ChangeNotifierProvider(create: (_) => ReservasProvider()),
        ChangeNotifierProvider(create: (_) => PasajerosProvider()),
        ChangeNotifierProvider(create: (_) => AeropuertosProvider()),
        ChangeNotifierProvider(create: (_) => PromocionesProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => CheckinsProvider()),
        ChangeNotifierProvider(create: (_) => TripulacionProvider()),
        ChangeNotifierProvider(create: (_) => ServiciosProvider()),
      ],
      child: const AviancoApp(),
    ),
  );
}

class AviancoApp extends StatefulWidget {
  const AviancoApp({super.key});

  @override
  State<AviancoApp> createState() => _AviancoAppState();
}

class _AviancoAppState extends State<AviancoApp> {
  late Future<void> _loginFuture;

  @override
  void initState() {
    super.initState();
    _loginFuture = Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (ctx, auth, _) => MaterialApp(
        title: 'Avianco',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
        home: auth.isAuth
            ? const HomeScreen()
            : FutureBuilder(
                future: _loginFuture,
                builder: (ctx, authResultSnapshot) =>
                    authResultSnapshot.connectionState ==
                            ConnectionState.waiting
                        ? const Scaffold(
                            body: Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          )
                        : const PublicHomeScreen(),
              ),
        routes: {
          '/public': (ctx) => const PublicHomeScreen(),
          '/login': (ctx) => const LoginScreen(),
          '/register': (ctx) => const RegisterScreen(),
          '/home': (ctx) => const HomeScreen(),
          '/profile': (ctx) => const ProfileScreen(),
        },
      ),
    );
  }
}
