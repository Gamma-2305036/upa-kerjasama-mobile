import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math';
import 'user/components/main_navigation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    // Dummy login - langsung redirect ke main navigation
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationWrapper()),
    );
  }

  void _handleGoogleLogin() {
    // Dummy Google login - langsung redirect ke main navigation
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 390,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Logo and Header
                  _buildHeader(),
                  
                  const SizedBox(height: 36),
                  
                  // Main content
                  _buildMainContent(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo POLINDRA dari assets
        Container(
          width: 140,
          height: 140,
          child: Image.asset(
            'assets/images/logo_polindra.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback jika logo tidak ditemukan
              return Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1A365D),
                ),
                child: Icon(
                  Icons.school,
                  size: 80,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 25),
        
        // Portal Karir POLINDRA text
        Text(
          'Portal Karir POLINDRA',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A365D), // Dark blue
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Main headline
          Text(
            'Langsung Kerja Gak Pake Ribet.',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A365D),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Sub headline
          Text(
            'Banyak lowongan menanti kamu!',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF4A5568),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 50),
          
          // Email input field
          Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFE2E8F0), width: 1.5),
              color: Colors.white,
            ),
            child: TextField(
              controller: _emailController,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(
                  color: Color(0xFFA0AEC0),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Password input field
          Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFE2E8F0), width: 1.5),
              color: Colors.white,
            ),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(
                  color: Color(0xFFA0AEC0),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Login button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Color(0xFF1A365D),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _handleLogin,
                child: Center(
                  child: Text(
                    'Masuk',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // ATAU separator
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: Color(0xFFE2E8F0),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'ATAU',
                  style: TextStyle(
                    color: Color(0xFFA0AEC0),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: Color(0xFFE2E8F0),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Google login button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFE2E8F0), width: 1.5),
              color: Colors.white,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _handleGoogleLogin,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google logo
                    Container(
                      width: 24,
                      height: 24,
                      child: CustomPaint(
                        painter: GoogleLogoPainter(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Masuk menggunakan Google',
                      style: TextStyle(
                        color: Color(0xFF4A5568),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Mitra link (single centered line)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Color(0xFF4A5568)),
                  children: [
                    const TextSpan(text: 'Ingin merekrut kandidat? '),
                    TextSpan(
                      text: 'Masuk sebagai Perusahaan',
                      style: const TextStyle(
                        color: Color(0xFF0EA5E9),
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: (TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, '/mitra/login');
                        }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}


class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Google G logo colors
    final blue = Color(0xFF4285F4);
    final red = Color(0xFFEA4335);
    final yellow = Color(0xFFFBBC05);
    final green = Color(0xFF34A853);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    // Blue section (top-left)
    paint.color = blue;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi, pi/2,
      true,
      paint,
    );

    // Red section (top-right)
    paint.color = red;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi/2, pi/2,
      true,
      paint,
    );

    // Yellow section (bottom-right)
    paint.color = yellow;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0, pi/2,
      true,
      paint,
    );

    // Green section (bottom-left)
    paint.color = green;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi/2, pi/2,
      true,
      paint,
    );

    // Draw the white horizontal bar for "G"
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    
    // White horizontal bar extending from blue section
    final barRect = Rect.fromCenter(
      center: Offset(center.dx - radius * 0.2, center.dy),
      width: radius * 0.6,
      height: radius * 0.15,
    );
    canvas.drawRect(barRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

