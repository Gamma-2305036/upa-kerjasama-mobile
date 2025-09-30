import 'package:flutter/material.dart';

class MitraDashboardPage extends StatelessWidget {
  const MitraDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A365D), Color(0xFF4E4376)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.dashboard_outlined, color: Color(0xFF1A365D), size: 36),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Dashboard Mitra', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('Ringkasan pelamar dan lowongan aktif', style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String title, required String value, Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (color ?? const Color(0xFF1A365D)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color ?? const Color(0xFF1A365D)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Color(0xFF1A365D), fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard(icon: Icons.work_outline, title: 'Lowongan Aktif', value: '4'),
              const SizedBox(width: 12),
              _buildStatCard(icon: Icons.person_outline, title: 'Total Pelamar', value: '127', color: Colors.teal),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(icon: Icons.check_circle_outline, title: 'Tahap Interview', value: '9', color: Colors.orange),
              const SizedBox(width: 12),
              _buildStatCard(icon: Icons.done_all_outlined, title: 'Diterima', value: '3', color: Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Aktivitas Terbaru', style: TextStyle(color: const Color(0xFF1A365D), fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A365D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person, color: Color(0xFF1A365D)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Pelamar baru untuk Frontend Developer', style: TextStyle(fontSize: 14)),
                      ),
                      Text('2m', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


