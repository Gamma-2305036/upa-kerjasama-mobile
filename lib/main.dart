import 'package:flutter/material.dart';
import 'login_page.dart';
import 'user/components/main_navigation.dart';
import 'mitra/pages/mitra_login_page.dart';
import 'mitra/components/main_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UPA Kerjasama Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      routes: {
        '/main': (context) => const MainNavigationWrapper(),
        '/mitra/login': (context) => const MitraLoginPage(),
        '/mitra': (context) => const MitraMainNavigation(),
      },
    );
  }
}
