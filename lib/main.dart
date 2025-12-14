import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'chat_screen.dart';
// import 'firebase_options.dart'; // Uncomment once user generates this via flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // For now, valid firebase setup is assumed or mocked until user configures it.
  // We will proceed for UI Preview.
  
  runApp(const ProviderScope(child: GhostUserApp()));
}

class GhostUserApp extends StatelessWidget {
  const GhostUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // WhatsApp Color Palette
        primaryColor: const Color(0xFF075E54),
        scaffoldBackgroundColor: const Color(0xFFECE5DD), // Chat background
        appBarTheme: const AppBarTheme(
          color: Color(0xFF075E54),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF128C7E),
        ),
        useMaterial3: true, 
      ),
      home: const ChatScreen(),
    );
  }
}
