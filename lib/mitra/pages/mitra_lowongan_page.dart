import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/job_service.dart';
import '../../services/api_service.dart';

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
                        MaterialPageRoute(builder: (_) => _DetailLowonganPage(jobId: job.id)),
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
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Hapus Lowongan'),
                                  content: const Text('Yakin ingin menghapus lowongan ini?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final res = await Provider.of<JobService>(context, listen: false).deleteJob(job.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Dihapus')));
                                }
                              }
                            } else if (value == 'expire') {
                              final today = DateTime.now();
                              final dateStr = today.toIso8601String().split('T').first;
                              final res = await Provider.of<JobService>(context, listen: false).updateJobStatus(job.id, statusAktif: false, tanggalSelesai: dateStr);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Diperbarui')));
                              }
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'expire', child: Text('Tandai Kadaluarsa')),
                            const PopupMenuItem(value: 'delete', child: Text('Hapus Lowongan')),
                          ],
                          icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                        ),
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

class _BuatLowonganPage extends StatefulWidget {
  const _BuatLowonganPage({super.key});

  @override
  State<_BuatLowonganPage> createState() => _BuatLowonganPageState();
}

class _BuatLowonganPageState extends State<_BuatLowonganPage> {
  final _formKey = GlobalKey<FormState>();
  final _judul = TextEditingController();
  final _posisi = TextEditingController();
  final _lokasi = TextEditingController();
  final _gajiMin = TextEditingController();
  final _gajiMax = TextEditingController();
  final _deskripsi = TextEditingController();
  final _jenis = TextEditingController();
  final _pendidikan = TextEditingController();
  final _persyaratan = TextEditingController();
  DateTime? _tanggalSelesai;

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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _input(controller: _judul, label: 'Judul Lowongan', validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 12),
                _input(controller: _posisi, label: 'Posisi'),
                const SizedBox(height: 12),
                _input(controller: _lokasi, label: 'Lokasi'),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _input(controller: _gajiMin, label: 'Gaji Min', keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _input(controller: _gajiMax, label: 'Gaji Max', keyboardType: TextInputType.number)),
                ]),
                const SizedBox(height: 12),
                _input(controller: _deskripsi, label: 'Deskripsi', maxLines: 5, validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 12),
                _input(controller: _jenis, label: 'Jenis Pekerjaan (Full Time/Part Time/Kontrak)')
                ,
                const SizedBox(height: 12),
                _input(controller: _pendidikan, label: 'Jenjang Pendidikan (SMA/D3/S1)')
                ,
                const SizedBox(height: 12),
                _input(controller: _persyaratan, label: 'Persyaratan (pisahkan dengan ";")', maxLines: 3),
                const SizedBox(height: 12),
                _datePicker(context),
                const SizedBox(height: 20),
              ],
            ),
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
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final payload = {
                      'judul': _judul.text.trim(),
                      'posisi': _posisi.text.trim(),
                      'lokasi': _lokasi.text.trim(),
                      'gaji_min': int.tryParse(_gajiMin.text.trim()),
                      'gaji_max': int.tryParse(_gajiMax.text.trim()),
                      'deskripsi': _deskripsi.text.trim(),
                      'jenis_pekerjaan': _jenis.text.trim().isEmpty ? null : _jenis.text.trim(),
                      'jenjang_pendidikan': _pendidikan.text.trim().isEmpty ? null : _pendidikan.text.trim(),
                      'rincian_lowongan': _persyaratan.text.trim().isEmpty ? null : _persyaratan.text.trim(),
                      'tanggal_selesai': _tanggalSelesai != null ? _tanggalSelesai!.toIso8601String().split('T').first : null,
                    };
                    final res = await Provider.of<JobService>(context, listen: false).createJob(payload);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Tersimpan')));
                    if (res['success'] == true) Navigator.pop(context);
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

  Widget _input({required TextEditingController controller, required String label, int maxLines = 1, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _datePicker(BuildContext context) {
    final label = _tanggalSelesai == null ? 'Tanggal Selesai (kadaluarsa)' : _tanggalSelesai!.toIso8601String().split('T').first;
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(context: context, initialDate: now, firstDate: now, lastDate: DateTime(now.year + 3));
        if (picked != null) setState(() => _tanggalSelesai = picked);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(
          children: [
            const Icon(Icons.event, color: Color(0xFF1A365D)),
            const SizedBox(width: 10),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _DetailLowonganPage extends StatelessWidget {
  final String jobId;
  const _DetailLowonganPage({super.key, required this.jobId});

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


