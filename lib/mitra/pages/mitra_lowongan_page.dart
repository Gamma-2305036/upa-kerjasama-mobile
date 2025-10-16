import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/job_service.dart';

class MitraLowonganPage extends StatefulWidget {
  const MitraLowonganPage({super.key});

  @override
  State<MitraLowonganPage> createState() => _MitraLowonganPageState();
}

class _MitraLowonganPageState extends State<MitraLowonganPage> {
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
          _buildHeader(),
          Expanded(child: _buildContent(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A365D),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const _BuatLowonganPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
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
                child: const Icon(Icons.work_outline, color: Color(0xFF1A365D), size: 36),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Lowongan', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('Kelola dan pantau lowongan Anda', style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Consumer<JobService>(
        builder: (context, jobService, child) {
          if (jobService.isLoading && jobService.jobs.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1A365D)));
          }

          if (jobService.error != null && jobService.jobs.isEmpty) {
            return Center(
              child: Text(jobService.error!, style: TextStyle(color: Colors.grey[600])),
            );
          }

          if (jobService.jobs.isEmpty) {
            return Center(
              child: Text('Belum ada lowongan', style: TextStyle(color: Colors.grey[600])),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Provider.of<JobService>(context, listen: false).getMyJobs(refresh: true);
            },
            child: ListView.separated(
              itemCount: jobService.jobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final job = jobService.jobs[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const _DetailLowonganPage()),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A365D).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.work_outline, color: Color(0xFF1A365D)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.judul,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A365D)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                job.lokasi ?? '-',
                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _BuatLowonganPage extends StatelessWidget {
  const _BuatLowonganPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A365D),
        elevation: 0.5,
        title: const Text('Buat Lowongan', style: TextStyle(color: Color(0xFF1A365D))),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              _input('Posisi'),
              const SizedBox(height: 12),
              _input('Lokasi'),
              const SizedBox(height: 12),
              _input('Gaji (opsional)'),
              const SizedBox(height: 12),
              _input('Deskripsi', maxLines: 5),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Builder(
          builder: (ctx) {
            final double kb = MediaQuery.of(ctx).viewInsets.bottom;
            return AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + kb),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A365D), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan Lowongan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _input(String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _DetailLowonganPage extends StatelessWidget {
  const _DetailLowonganPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A365D),
        elevation: 0.5,
        title: const Text('Detail Lowongan', style: TextStyle(color: Color(0xFF1A365D))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Frontend Developer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A365D))),
            const SizedBox(height: 8),
            Text('12 pelamar • 3 hari lagi', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            const Text('Pelamar', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: 8,
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
                          decoration: BoxDecoration(color: const Color(0xFF1A365D).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.person, color: Color(0xFF1A365D)),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('Nama Pelamar', style: TextStyle(fontWeight: FontWeight.w600))),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


