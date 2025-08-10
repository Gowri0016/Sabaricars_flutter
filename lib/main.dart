import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'about_us_screen.dart';
import 'contact_us_screen.dart';
import 'request_vehicle_screen.dart';
import 'main_wrapper.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'complete_profile_screen.dart';
import 'vehicle_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sabari Cars',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const MainWrapper() : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/complete-profile': (context) => const CompleteProfileScreen(),
        '/about': (context) => AboutUsScreen(),
        '/contact': (context) => ContactUsScreen(),
        '/request': (context) => RequestVehicleScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/vehicle-details') {
          final args = settings.arguments;
          if (args is Map<String, dynamic>) {
            return MaterialPageRoute(
              builder: (context) => VehicleDetailsScreen(vehicle: args),
            );
          } else {
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text('No vehicle data provided.')),
              ),
            );
          }
        }
        return null;
      },
    );
  }
}
