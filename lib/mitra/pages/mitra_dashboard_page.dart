import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/job_service.dart';
import '../../services/api_service.dart';

class MitraDashboardPage extends StatefulWidget {
  const MitraDashboardPage({super.key});

  @override
  State<MitraDashboardPage> createState() => _MitraDashboardPageState();
}

class _MitraDashboardPageState extends State<MitraDashboardPage> {
  List<Map<String, dynamic>> _allApplicants = [];
  bool _loadingApplicants = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final jobService = Provider.of<JobService>(context, listen: false);
    await jobService.getMyJobs(refresh: true, archived: false);
    await _loadAllApplicants();
  }

  Future<void> _loadAllApplicants() async {
    setState(() => _loadingApplicants = true);
    try {
      final jobService = Provider.of<JobService>(context, listen: false);
      final jobs = jobService.jobs;
      
      List<Map<String, dynamic>> allApps = [];
      
      for (var job in jobs) {
        try {
          final res = await ApiService.getApplicantsForJob(
            job.id,
            archived: false,
          );
          if (res['success'] == true) {
            final List<dynamic> apps = res['data'] as List<dynamic>;
            for (var app in apps) {
              if (app is Map<String, dynamic>) {
                allApps.add(app);
              }
            }
          }
        } catch (e) {
          // Skip jika error, lanjut ke lowongan berikutnya
          continue;
        }
      }
      
      if (mounted) {
        setState(() {
          _allApplicants = allApps;
          _loadingApplicants = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingApplicants = false);
      }
    }
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Dashboard Mitra', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('Ringkasan pelamar dan lowongan aktif', 
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, 
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(value, 
                    style: const TextStyle(color: Color(0xFF1A365D), fontSize: 16, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
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
          // Filter lowongan aktif (tidak diarsipkan dan status aktif)
          final lowonganAktif = jobService.jobs.where((job) {
            final isArchived = job.archivedAt != null && job.archivedAt!.isNotEmpty;
            return !isArchived && (job.statusAktif == true);
          }).length;

          // Hitung statistik pelamar
          final totalPelamar = _allApplicants.length;
          final tahapInterview = _allApplicants.where((app) {
            final status = (app['status'] ?? '').toString().toLowerCase();
            return status == 'interview';
          }).length;
          final diterima = _allApplicants.where((app) {
            final status = (app['status'] ?? '').toString().toLowerCase();
            return status == 'diterima';
          }).length;

          // Aktivitas terbaru (pelamar terbaru, maksimal 5)
          final aktivitasTerbaru = _allApplicants
              .where((app) => app['created_at'] != null)
              .toList()
            ..sort((a, b) {
              try {
                final dateA = DateTime.parse(a['created_at'] ?? '');
                final dateB = DateTime.parse(b['created_at'] ?? '');
                return dateB.compareTo(dateA);
              } catch (e) {
                return 0;
              }
            });
          final aktivitasList = aktivitasTerbaru.take(5).toList();

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
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
                  (jobService.isLoading || _loadingApplicants)
                      ? const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: CircularProgressIndicator(color: Color(0xFF1A365D))),
                        )
                      : aktivitasList.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Center(
                                child: Text('Belum ada aktivitas', style: TextStyle(color: Colors.grey[600])),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: aktivitasList.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final app = aktivitasList[index];
                                final pelamar = app['pelamar'] as Map<String, dynamic>?;
                                final name = pelamar?['name'] ?? 'Pelamar';
                                final status = (app['status'] ?? '').toString();
                                final createdAt = app['created_at'] ?? '';
                                
                                Color statusColor;
                                String statusText;
                                switch (status.toLowerCase()) {
                                  case 'lolos':
                                  case 'interview':
                                    statusColor = Colors.orange;
                                    statusText = status.isEmpty ? 'Melamar' : status;
                                    break;
                                  case 'diterima':
                                    statusColor = Colors.green;
                                    statusText = status;
                                    break;
                                  case 'ditolak':
                                    statusColor = Colors.red;
                                    statusText = status;
                                    break;
                                  default:
                                    statusColor = const Color(0xFF1A365D);
                                    statusText = status.isEmpty ? 'Melamar' : status;
                                }

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(Icons.person, color: statusColor, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A365D)),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatDate(createdAt),
                                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: statusColor),
                                        ),
                                        child: Text(
                                          statusText,
                                          style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return 'Hari ini';
      } else if (difference.inDays == 1) {
        return 'Kemarin';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari lalu';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks minggu lalu';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months bulan lalu';
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years tahun lalu';
      }
    } catch (e) {
      return dateString;
    }
  }
}


