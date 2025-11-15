import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/page_transitions.dart';
import '../../login_page.dart';
import '../../services/auth_service.dart';
import '../components/edit_profil_page.dart';
import '../components/lamaran_saya_page.dart';
import '../components/lowongan_tersimpan_page.dart';
import '../components/notifikasi_page.dart';
import '../components/bantuan_page.dart';
import '../components/tentang_aplikasi_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header dengan gradient
          _buildHeader(),
          
          // Main content area
          Expanded(
            child: _buildMainContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.user;
        
        return Container(
          height: 250,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A365D),
                Color(0xFF4E4376),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Profile info
                  Row(
                    children: [
                      // Profile picture
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF1A365D),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 20),
                      
                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'User',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              user?.email ?? 'email@example.com',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                authService.userRole ?? 'User',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Edit button
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Menu items
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Edit Profil',
              subtitle: 'Ubah informasi pribadi',
              onTap: () {
                PageTransitions.slideTo(
                  context,
                  const EditProfilPage(),
                );
              },
            ),
            
            _buildMenuItem(
              icon: Icons.work_outline,
              title: 'Lamaran Saya',
              subtitle: 'Lihat status lamaran',
              onTap: () {
                PageTransitions.slideTo(
                  context,
                  const LamaranSayaPage(),
                );
              },
            ),
            
            _buildMenuItem(
              icon: Icons.favorite_outline,
              title: 'Lowongan Tersimpan',
              subtitle: 'Lowongan yang disimpan',
              onTap: () {
                PageTransitions.slideTo(
                  context,
                  const LowonganTersimpanPage(),
                );
              },
            ),
            
            _buildMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifikasi',
              subtitle: 'Pengaturan notifikasi',
              onTap: () {
                PageTransitions.slideTo(
                  context,
                  const NotifikasiPage(),
                );
              },
            ),
            
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Bantuan',
              subtitle: 'FAQ dan dukungan',
              onTap: () {
                PageTransitions.slideTo(
                  context,
                  const BantuanPage(),
                );
              },
            ),
            
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              subtitle: 'Versi 1.0.0',
              onTap: () {
                PageTransitions.slideTo(
                  context,
                  const TentangAplikasiPage(),
                );
              },
            ),
            
            const SizedBox(height: 30),
            
            // Logout button
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.red[200]!,
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.red[600],
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Keluar',
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Add bottom padding to ensure content doesn't get cut off by navigation bar
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFF1A365D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: Color(0xFF1A365D),
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 15),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A365D),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final outerContext = context; // preserve page context
    showDialog(
      context: outerContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Konfirmasi Keluar',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A365D),
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                
                // Show loading dialog
                showDialog(
                  context: outerContext,
                  barrierDismissible: false,
                  builder: (loadingDialogContext) => AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Logging out...'),
                      ],
                    ),
                  ),
                );
                
                try {
                  // Logout using AuthService
                  final authService = Provider.of<AuthService>(outerContext, listen: false);
                  await authService.logout();
                  
                  // Close loading dialog
                  if (outerContext.mounted) {
                    Navigator.of(outerContext).pop();
                  }
                  
                  // Force navigation to login page
                  if (outerContext.mounted) {
                    PageTransitions.fadeAndRemoveUntil(
                      outerContext,
                      const LoginPage(),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  // Close loading dialog
                  if (outerContext.mounted) {
                    Navigator.of(outerContext).pop();
                  }
                  
                  // Show error and still navigate to login
                  if (outerContext.mounted) {
                    ScaffoldMessenger.of(outerContext).showSnackBar(
                      SnackBar(
                        content: Text('Logout berhasil'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    PageTransitions.fadeAndRemoveUntil(
                      outerContext,
                      const LoginPage(),
                      (route) => false,
                    );
                  }
                }
              },
              child: Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.red[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
