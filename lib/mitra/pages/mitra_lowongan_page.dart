import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../user/components/pdf_viewer_page.dart';
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
    return _ApplicantsScreen(jobId: jobId);
  }
}

class _ApplicantsScreen extends StatefulWidget {
  final String jobId;
  const _ApplicantsScreen({required this.jobId});

  @override
  State<_ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<_ApplicantsScreen> {
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _apps = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.getApplicantsForJob(widget.jobId);
      if (res['success'] == true) {
        final List<dynamic> list = res['data'] as List<dynamic>;
        _apps = list.whereType<Map<String, dynamic>>().toList();
      } else {
        _error = res['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A365D),
        elevation: 0.5,
        title: const Text('Detail Lowongan', style: TextStyle(color: Color(0xFF1A365D))),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A365D)))
            : _error != null
                ? ListView(children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(_error!, style: TextStyle(color: Colors.grey[600])),
                    )
                  ])
                : _apps.isEmpty
                    ? ListView(children: const [
                        SizedBox(height: 80),
                        Center(child: Text('Belum ada pelamar')),
                      ])
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _apps.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _applicantCard(_apps[i]),
                      ),
      ),
    );
  }

  Widget _applicantCard(Map<String, dynamic> app) {
    final pelamar = app['pelamar'] as Map<String, dynamic>?;
    final name = pelamar?['name'] ?? 'Pelamar';
    final email = pelamar?['email'] ?? '-';
    final cvUrl = pelamar?['cv_url'] as String?;
    final status = (app['status'] ?? '').toString();
    Color color;
    switch (status) {
      case 'lolos':
      case 'interview':
        color = Colors.orange;
        break;
      case 'diterima':
        color = Colors.green;
        break;
      case 'ditolak':
        color = Colors.red;
        break;
      default:
        color = const Color(0xFF1A365D);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: const Color(0xFF1A365D).withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.person, color: Color(0xFF1A365D)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A365D))),
                    Text(email, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color)),
                child: Text(status.isEmpty ? 'melamar' : status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _ApplicantDetailPage(
                        application: app,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.person_search),
                label: const Text('Lihat Pelamar'),
              ),
              if (cvUrl != null)
                TextButton.icon(onPressed: () => _openPdf(cvUrl), icon: const Icon(Icons.picture_as_pdf), label: const Text('Lihat CV')),
              _statusMenu(app['id'].toString(), status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusMenu(String applicationId, String current) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        final res = await ApiService.updateApplicantStatus(applicationId, value);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Diperbarui')));
        if (res['success'] == true) _load();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'melamar', child: Text('Melamar')),
        PopupMenuItem(value: 'lolos', child: Text('Lolos Screening')),
        PopupMenuItem(value: 'interview', child: Text('Tahap Interview')),
        PopupMenuItem(value: 'diterima', child: Text('Diterima')),
        PopupMenuItem(value: 'ditolak', child: Text('Ditolak')),
      ],
      child: OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.sync_alt, size: 18),
        label: const Text('Ubah Status'),
      ),
    );
  }

  void _openUrl(String url) {
    // Can be wired with url_launcher if available; for now show snackbar
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Buka: $url')));
  }

  void _openPdf(String url) {
    // Fix: Add base URL if the URL is relative
    var fullUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      // It's a relative path, add base URL
      fullUrl = '${ApiService.baseUrl.replaceFirst('/api', '')}$url';
      print('🔧 Fixed relative URL to: $fullUrl');
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfViewerPage(url: fullUrl, title: 'CV Pelamar'),
      ),
    );
  }
}

class _ApplicantDetailPage extends StatefulWidget {
  final Map<String, dynamic> application;
  const _ApplicantDetailPage({required this.application});

  @override
  State<_ApplicantDetailPage> createState() => _ApplicantDetailPageState();
}

class _ApplicantDetailPageState extends State<_ApplicantDetailPage> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _dataAkademik;
  Map<String, dynamic>? _dataKeluarga;
  List<Map<String, dynamic>>? _dokumenPendukung;
  String? _cvUrl;
  bool _loading = false;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final userId = widget.application['user_id']?.toString();
      if (userId == null) {
        _error = 'User tidak valid';
      } else {
        final res = await ApiService.getAlumniProfileByUserId(userId);
        if (res['success'] == true) {
          setState(() {
            _profile = res['data']?['profile'];
            _dataAkademik = res['data']?['data_akademik'];
            _dataKeluarga = res['data']?['data_keluarga'];
            
            // Get dokumen pendukung
            final dk = res['data']?['dokumen_pendukung'];
            if (dk != null && dk is List) {
              _dokumenPendukung = dk.map((e) => e as Map<String, dynamic>).toList();
            }
            
            // Get CV URL from profile
            _cvUrl = res['data']?['cv_url'] as String? ?? 
                     _profile?['cv_url'] as String?;
          });
        } else {
          _error = res['message'];
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pelamar = widget.application['pelamar'] as Map<String, dynamic>?;
    final name = pelamar?['name'] ?? 'Pelamar';
    final email = pelamar?['email'] ?? '-';
    final cvUrl = _cvUrl ?? pelamar?['cv_url'] as String?;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A365D),
        elevation: 0.5,
        title: const Text('Data Pelamar', style: TextStyle(color: Color(0xFF1A365D))),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1A365D),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1A365D),
          tabs: const [
            Tab(text: 'Data Pribadi', icon: Icon(Icons.person)),
            Tab(text: 'Akademik', icon: Icon(Icons.school)),
            Tab(text: 'Keluarga', icon: Icon(Icons.family_restroom)),
            Tab(text: 'File', icon: Icon(Icons.folder)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A365D)))
            : _error != null
                ? Center(child: Text(_error!, style: TextStyle(color: Colors.grey[600])))
                : Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(color: const Color(0xFF1A365D).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.person, color: Color(0xFF1A365D)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A365D))),
                                  Text(email, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildDataPribadiTab(),
                            _buildDataAkademikTab(),
                            _buildDataKeluargaTab(),
                            _buildFileTab(cvUrl),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildDataPribadiTab() {
    final profile = _profile;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _infoTile('NIM', profile?['nim']),
        _infoTile('NIK', profile?['nik']),
        _infoTile('No. HP', profile?['no_hp']),
        _infoTile('Tempat Lahir', profile?['tempat_lahir']),
        _infoTile('Tanggal Lahir', profile?['tanggal_lahir']),
        _infoTile('Jenis Kelamin', profile?['jenis_kelamin']),
        _infoTile('Alamat', profile?['alamat']),
        _infoTile('Kota', profile?['kota']),
        _infoTile('Provinsi', profile?['provinsi']),
        _infoTile('Kode Pos', profile?['kode_pos']),
        _infoTile('Nama Bank', profile?['nama_bank']),
        _infoTile('No. Rekening', profile?['no_rekening']),
        if (profile?['tentang_saya'] != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tentang Saya', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(profile?['tentang_saya'] ?? '-', style: const TextStyle(color: Color(0xFF1A365D))),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDataAkademikTab() {
    final akademik = _dataAkademik;
    if (akademik == null) {
      return const Center(child: Text('Data akademik belum diisi'));
    }
    
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _infoTile('NIM', akademik['nim']),
        _infoTile('Program Studi', akademik['program_studi']),
        _infoTile('Universitas', akademik['universitas']),
        _infoTile('Tahun Masuk', akademik['tahun_masuk']?.toString()),
        _infoTile('Tahun Lulus', akademik['tahun_lulus']?.toString()),
        _infoTile('IPK', akademik['ipk']?.toString()),
        if (akademik['hard_skill'] != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hard Skill', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(akademik['hard_skill'] ?? '-', style: const TextStyle(color: Color(0xFF1A365D))),
              ],
            ),
          ),
        ],
        if (akademik['soft_skill'] != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Soft Skill', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(akademik['soft_skill'] ?? '-', style: const TextStyle(color: Color(0xFF1A365D))),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDataKeluargaTab() {
    final keluarga = _dataKeluarga;
    if (keluarga == null) {
      return const Center(child: Text('Data keluarga belum diisi'));
    }
    
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _sectionHeader('Data Ayah'),
        _infoTile('Nama Ayah', keluarga['nama_ayah']),
        _infoTile('Pekerjaan Ayah', keluarga['pekerjaan_ayah']),
        const SizedBox(height: 10),
        _sectionHeader('Data Ibu'),
        _infoTile('Nama Ibu', keluarga['nama_ibu']),
        _infoTile('Pekerjaan Ibu', keluarga['pekerjaan_ibu']),
        const SizedBox(height: 10),
        _sectionHeader('Data Wali'),
        _infoTile('Nama Wali', keluarga['nama_wali']),
        _infoTile('Pekerjaan Wali', keluarga['pekerjaan_wali']),
        const SizedBox(height: 10),
        _sectionHeader('Data Keluarga'),
        _infoTile('Jumlah Saudara', keluarga['jumlah_saudara']?.toString()),
        _infoTile('Alamat Keluarga', keluarga['alamat_keluarga']),
      ],
    );
  }

  Widget _buildFileTab(String? cvUrl) {
    final docs = _dokumenPendukung ?? [];
    final hasDocuments = (cvUrl != null && cvUrl.isNotEmpty) || docs.isNotEmpty;
    
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // CV Section
        if (cvUrl != null && cvUrl.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                const Icon(Icons.picture_as_pdf, size: 48, color: Color(0xFF1A365D)),
                const SizedBox(height: 12),
                const Text('CV Pelamar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A365D))),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openPdf(cvUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A365D),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.visibility, size: 20),
                    label: const Text('Lihat CV'),
                  ),
                ),
              ],
            ),
          ),
        
        if (cvUrl != null && cvUrl.isNotEmpty && docs.isNotEmpty)
          const SizedBox(height: 16),
        
        // Supporting Documents Section
        if (docs.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Dokumen Pendukung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A365D))),
          const SizedBox(height: 12),
          ...docs.map((doc) => _documentCard(doc)).toList(),
        ],
        
        // Empty state
        if (!hasDocuments)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada dokumen',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pelamar belum mengunggah CV atau dokumen',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _documentCard(Map<String, dynamic> doc) {
    final fileName = doc['file_name'] ?? doc['nama_dokumen'] ?? 'Dokumen';
    final fileUrl = doc['file_url'] ?? doc['path_file'] ?? '';
    final fileSize = doc['file_size'] ?? doc['ukuran_file'];
    final jenisDokumen = doc['jenis_dokumen'] ?? doc['tipe_dokumen'] ?? 'Dokumen';
    
    String formatFileSize(int? bytes) {
      if (bytes == null) return '';
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1A365D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.insert_drive_file, color: Color(0xFF1A365D)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A365D)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  jenisDokumen,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (fileSize != null)
                  Text(
                    formatFileSize(fileSize),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: fileUrl.isNotEmpty ? () => _openPdf(fileUrl) : null,
            icon: const Icon(Icons.visibility, color: Color(0xFF1A365D)),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(color: Color(0xFF1A365D), fontWeight: FontWeight.w700, fontSize: 16)),
    );
  }

  Widget _infoTile(String label, dynamic value) {
    final displayValue = value == null || (value is String && value.isEmpty) ? '-' : value.toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(displayValue, style: const TextStyle(color: Color(0xFF1A365D), fontWeight: FontWeight.w600), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  void _openPdf(String url) {
    // Fix: Add base URL if the URL is relative
    var fullUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      // It's a relative path, add base URL
      fullUrl = '${ApiService.baseUrl.replaceFirst('/api', '')}$url';
      print('🔧 Fixed relative URL to: $fullUrl');
    }
    
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PdfViewerPage(url: fullUrl, title: 'CV Pelamar')));
  }
}


// imports needed at top of file
// in-app pdf viewer is factored out to PdfViewerPage


