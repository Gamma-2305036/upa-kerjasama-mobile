import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'user/components/main_navigation.dart';
import 'mitra/pages/mitra_login_page.dart';
import 'mitra/components/main_navigation.dart';
import 'services/auth_service.dart';
import 'services/job_service.dart';
import 'services/company_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final authService = AuthService();
            authService.initialize();
            return authService;
          },
        ),
        ChangeNotifierProvider(create: (context) => JobService()),
        ChangeNotifierProvider(create: (context) => CompanyService()),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, child) {
          return MaterialApp(
            title: 'UPA Kerjasama Mobile',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: authService.isLoggedIn
                ? (authService.hasRole('mitra')
                    ? const MitraMainNavigation()
                    : const MainNavigationWrapper())
                : const LoginPage(),
            routes: {
              '/main': (context) => const MainNavigationWrapper(),
              '/mitra/login': (context) => const MitraLoginPage(),
              '/mitra': (context) => const MitraMainNavigation(),
            },
          );
        },
      ),
    );
  }
}
