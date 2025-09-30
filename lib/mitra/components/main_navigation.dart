import 'package:flutter/material.dart';
import 'navigation.dart';
import '../pages/mitra_dashboard_page.dart';
import '../pages/mitra_lowongan_page.dart';
import '../pages/mitra_profil_page.dart';

class MitraMainNavigation extends StatefulWidget {
  const MitraMainNavigation({super.key});

  @override
  State<MitraMainNavigation> createState() => _MitraMainNavigationState();
}

class _MitraMainNavigationState extends State<MitraMainNavigation> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    MitraDashboardPage(),
    MitraLowonganPage(),
    MitraProfilPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        pageController: _pageController,
      ),
    );
  }
}


