import 'package:flutter/material.dart';
import 'package:taxycity/screens/welcome_screen.dart';
import 'package:taxycity/screens/login_screen.dart';
import 'package:taxycity/screens/driver_registration_screen.dart';
import 'package:taxycity/screens/client_registration_screen.dart';
import 'package:taxycity/screens/driver_home_screen.dart';
import 'package:taxycity/screens/client_home_screen.dart';
import 'package:taxycity/screens/client_order_screen.dart';
import 'package:taxycity/screens/chat_screen.dart';
import 'package:taxycity/screens/phone_verification_screen.dart';
import 'package:taxycity/screens/trip_history_screen.dart';

void main() {
  runApp(const TaxyCityApp());
}

class TaxyCityApp extends StatelessWidget {
  const TaxyCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaxyCity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register/driver': (context) => const DriverRegistrationScreen(),
        '/register/client': (context) => const ClientRegistrationScreen(),
        '/verify': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return PhoneVerificationScreen(
            userType: args['userType'],
            phoneNumber: args['phoneNumber'],
            userData: args['userData'],
          );
        },
        '/driver/home': (context) => const DriverHomeScreen(),
        '/driver/chat': (context) => const ChatScreen(userType: 'driver'),
        '/client/home': (context) => const ClientHomeScreen(),
        '/client/order': (context) => const ClientOrderScreen(),
        '/client/chat': (context) => const ChatScreen(userType: 'client'),
        '/client/history': (context) => const TripHistoryScreen(),
      },
    );
  }
}
