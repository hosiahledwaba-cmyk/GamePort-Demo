import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'logic/game_controller.dart';
import 'theme/app_theme.dart'; // Define your light/dark data here if needed

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => GameController())],
      child: const LudoApp(),
    ),
  );
}

class LudoApp extends StatelessWidget {
  const LudoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ludo Glass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark, // Better for glass effects
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
