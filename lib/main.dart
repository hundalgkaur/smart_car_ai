import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:smart_car_ai_alert/bloc/media_bloc/alert_bloc.dart';
import 'package:smart_car_ai_alert/view/screens/home_screen.dart';
import 'package:smart_car_ai_alert/view/screens/splash_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //  Sign in anonymously before app starts
  await signInAnonymously();

  runApp(const SmartCarAIApp());
}

Future<void> signInAnonymously() async {
  try {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    print(" Signed in anonymously. UID: ${userCredential.user?.uid}");
  } catch (e) {
    print(" Anonymous sign-in failed: $e");
  }
}

class SmartCarAIApp extends StatelessWidget {
  const SmartCarAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AlertBloc()),
      ],
      child: MaterialApp(
        title: 'Smart Car AI Alert',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
