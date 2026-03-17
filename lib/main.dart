import 'package:flutter/material.dart';
import 'package:taxycity/services/storage_service.dart';
import 'package:taxycity/services/notification_service.dart';
import 'package:taxycity/services/firebase_service.dart';
import 'package:taxycity/services/theme_service.dart';
import 'package:taxycity/screens/welcome_screen.dart';
import 'package:taxycity/screens/login_screen.dart';
import 'package:taxycity/screens/driver_registration_screen.dart';
import 'package:taxycity/screens/client_registration_screen.dart';
import 'package:taxycity/screens/phone_verification_screen.dart';
import 'package:taxycity/screens/driver_home_screen.dart';
import 'package:taxycity/screens/client_home_screen.dart';
import 'package:taxycity/screens/client_order_screen.dart';
import 'package:taxycity/screens/chat_screen.dart';
import 'package:taxycity/screens/trip_history_screen.dart';
import 'package:taxycity/screens/client_settings_screen.dart';
import 'package:taxycity/screens/driver_settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация сервисов
  await StorageService.init();
  await NotificationService.init();
  await NotificationService.requestPermissions();
  
  // Инициализация Firebase (раскомментировать при настройке Firebase)
  // try {
  //   await FirebaseService.initialize();
  // } catch (e) {
  //   print('Firebase initialization failed: $e');
  // }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() {
    setState(() {
      _isDarkMode = StorageService.isDarkMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaxyCity',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(
        onThemeLoaded: _loadTheme,
      ),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/driver/register': (context) => const DriverRegistrationScreen(),
        '/client/register': (context) => const ClientRegistrationScreen(),
        '/verify': (context) => const PhoneVerificationScreen(),
        '/driver/home': (context) => const DriverHomeScreen(),
        '/client/home': (context) => const ClientHomeScreen(),
        '/client/order': (context) => const ClientOrderScreen(),
        '/chat': (context) => const ChatScreen(),
        '/client/history': (context) => const TripHistoryScreen(),
        '/client/settings': (context) => const ClientSettingsScreen(),
        '/driver/settings': (context) => const DriverSettingsScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  final VoidCallback? onThemeLoaded;

  const SplashScreen({super.key, this.onThemeLoaded});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    widget.onThemeLoaded?.call();

    final isLoggedIn = StorageService.isLoggedIn();
    final userType = StorageService.getUserType();

    if (isLoggedIn && userType != null) {
      if (userType == 'driver') {
        Navigator.pushReplacementNamed(context, '/driver/home');
      } else {
        Navigator.pushReplacementNamed(context, '/client/home');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1565C0),
              Color(0xFF1E88E5),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_taxi,
                        size: 80,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'TaxyCity',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ваш надёжный партнёр',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 48),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
