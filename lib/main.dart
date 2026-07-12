import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/app_colors.dart';
import 'screens/public_home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

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
    return MaterialApp(
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
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const PublicHomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
