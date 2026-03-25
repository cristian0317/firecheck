import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBwjwYP8mSXIZb-SU5Il4nA2G2rQ1WuFBM',
        appId: '1:575046042727:web:d7732b64a35b6dc37bc0c2',
        messagingSenderId: '575046042727',
        projectId: 'firecheck-1ec4c',
        authDomain: 'firecheck-1ec4c.firebaseapp.com',
        storageBucket: 'firecheck-1ec4c.firebasestorage.app',
        measurementId: 'G-DRC35F0ZF8',
      ),
    );
  } catch (e) {
    debugPrint('Error inicializando Firebase: $e');
  }

  runApp(const FirecheckApp());
}

class FirecheckApp extends StatelessWidget {
  const FirecheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firecheck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          }

          // Si no hay sesión iniciada, mostrar LoginScreen
          return const LoginScreen();
        },
      ),
    );
  }
}
