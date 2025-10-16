import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/job_service.dart';

class MitraDashboardPage extends StatefulWidget {
  const MitraDashboardPage({super.key});

  @override
  State<MitraDashboardPage> createState() => _MitraDashboardPageState();
}

class _MitraDashboardPageState extends State<MitraDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobService>(context, listen: false).getMyJobs(refresh: true);
    });
  }

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
      child: Consumer<JobService>(
        builder: (context, jobService, child) {
          final lowonganAktif = jobService.jobs.length;
          final totalPelamar = 0; // belum ada endpoint pelamar
          final tahapInterview = 0; // belum ada endpoint status
          final diterima = 0; // belum ada endpoint status

          return Column(
            children: [
              Row(
                children: [
                  _buildStatCard(icon: Icons.work_outline, title: 'Lowongan Aktif', value: '$lowonganAktif'),
                  const SizedBox(width: 12),
                  _buildStatCard(icon: Icons.person_outline, title: 'Total Pelamar', value: '$totalPelamar', color: Colors.teal),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatCard(icon: Icons.check_circle_outline, title: 'Tahap Interview', value: '$tahapInterview', color: Colors.orange),
                  const SizedBox(width: 12),
                  _buildStatCard(icon: Icons.done_all_outlined, title: 'Diterima', value: '$diterima', color: Colors.purple),
                ],
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Aktivitas Terbaru', style: TextStyle(color: const Color(0xFF1A365D), fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: jobService.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A365D)))
                    : Center(
                        child: Text('Belum ada aktivitas', style: TextStyle(color: Colors.grey[600])),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}


