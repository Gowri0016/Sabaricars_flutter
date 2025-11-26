import 'package:firebase_auth/firebase_auth.dart';
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
import 'theme.dart';
import 'sell_vehicle_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sabari Cars',
      theme: AppTheme.light(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          print(
            'Auth state changed: user = [32m[1m[4m[7m${snapshot.data}[0m',
          );
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const MainWrapper();
          } else {
            return const LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/complete-profile': (context) => const CompleteProfileScreen(),
        '/about': (context) => AboutUsScreen(),
        '/contact': (context) => ContactUsScreen(),
        '/request': (context) => RequestVehicleScreen(),
        '/sell': (context) => const SellVehicleScreen(),
        '/privacy-policy': (context) => const PrivacyPolicyScreen(),
        '/terms-conditions': (context) => const TermsConditionsScreen(),
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
