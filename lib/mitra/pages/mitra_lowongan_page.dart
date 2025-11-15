import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_file/open_file.dart';
import '../../user/components/pdf_viewer_page.dart';
import 'package:provider/provider.dart';
import '../../utils/page_transitions.dart';
import '../../services/job_service.dart';
import '../../services/api_service.dart';
import '../../models/job_model.dart';

class MitraLowonganPage extends StatefulWidget {
  const MitraLowonganPage({super.key});

  @override
  State<MitraLowonganPage> createState() => _MitraLowonganPageState();
}

class _MitraLowonganPageState extends State<MitraLowonganPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isArchivedTab = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final newIsArchived = _tabController.index == 1;
        if (newIsArchived != _isArchivedTab) {
          setState(() {
            _isArchivedTab = newIsArchived;
            // Keep search query when switching tabs
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<JobService>(context, listen: false).getMyJobs(refresh: true, archived: _isArchivedTab, search: _searchQuery.isNotEmpty ? _searchQuery : null);
          });
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobService>(context, listen: false).getMyJobs(refresh: true, archived: false, search: null);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchQuery == value && mounted) {
        Provider.of<JobService>(context, listen: false).getMyJobs(refresh: true, archived: _isArchivedTab, search: value.isNotEmpty ? value : null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          _buildSearchBar(),
          Expanded(child: _buildContent(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A365D),
        onPressed: () async {
          final result = await PageTransitions.slideTo(
            context,
            const _BuatLowonganPage(),
          );
          // Refresh data setelah kembali dari halaman buat lowongan
          if (result == true && mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<JobService>(context, listen: false).getMyJobs(
                refresh: true,
                archived: _isArchivedTab,
                search: _searchQuery.isNotEmpty ? _searchQuery : null,
              );
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF1A365D),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF1A365D),
        tabs: const [
          Tab(text: 'Aktif', icon: Icon(Icons.work_outline)),
          Tab(text: 'Arsip', icon: Icon(Icons.archive_outlined)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Cari lowongan...',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[500], size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                      Provider.of<JobService>(context, listen: false).getMyJobs(refresh: true, archived: _isArchivedTab, search: null);
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      jobService.error!,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Provider.of<JobService>(context, listen: false).getMyJobs(refresh: true, archived: _isArchivedTab);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A365D),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Filter jobs based on archived status and search query (client-side fallback)
          final filteredJobs = jobService.jobs.where((job) {
            final isArchived = job.archivedAt != null && job.archivedAt!.isNotEmpty;
            final matchesArchived = _isArchivedTab ? isArchived : !isArchived;
            
            // If search query exists, filter by search
            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              final matchesSearch = 
                  (job.judul.toLowerCase().contains(query)) ||
                  (job.lokasi?.toLowerCase().contains(query) ?? false) ||
                  (job.posisi?.toLowerCase().contains(query) ?? false) ||
                  (job.deskripsi.toLowerCase().contains(query));
              return matchesArchived && matchesSearch;
            }
            
            return matchesArchived;
          }).toList();

          if (filteredJobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchQuery.isNotEmpty 
                        ? Icons.search_off 
                        : (_isArchivedTab ? Icons.archive_outlined : Icons.work_outline),
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Tidak ada lowongan ditemukan untuk "${_searchQuery}"'
                        : (_isArchivedTab ? 'Belum ada lowongan diarsipkan' : 'Belum ada lowongan'),
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        Provider.of<JobService>(context, listen: false).getMyJobs(refresh: true, archived: _isArchivedTab, search: null);
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Hapus Pencarian'),
                    ),
                  ],
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Provider.of<JobService>(context, listen: false).getMyJobs(refresh: true, archived: _isArchivedTab, search: _searchQuery.isNotEmpty ? _searchQuery : null);
            },
            child: ListView.separated(
              itemCount: filteredJobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final job = filteredJobs[index];
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
                      PageTransitions.slideTo(
                        context,
                        _DetailLowonganPage(jobId: job.id),
                      );
                    },
                    child: Column(
                      children: [
                        Row(
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          job.judul,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A365D)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Status indicator
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: (job.statusAktif == true) ? Colors.green : Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    job.lokasi ?? '-',
                                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                  ),
                                  if (job.createdAt != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Dibuat: ${_formatDate(job.createdAt!)}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                    ),
                                  ],
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
                                } else if (value == 'archive') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Arsipkan Lowongan'),
                                      content: const Text('Yakin ingin mengarsipkan lowongan ini? Lowongan yang diarsipkan tidak akan muncul di list aktif.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Arsipkan')),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    final jobService = Provider.of<JobService>(context, listen: false);
                                    final res = await jobService.archiveJob(job.id);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Diarsipkan')));
                                      // Reload current tab after archive
                                      await jobService.getMyJobs(refresh: true, archived: _isArchivedTab);
                                    }
                                  }
                                } else if (value == 'unarchive') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Kembalikan dari Arsip'),
                                      content: const Text('Yakin ingin mengembalikan lowongan ini dari arsip?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Kembalikan')),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    final jobService = Provider.of<JobService>(context, listen: false);
                                    final res = await jobService.unarchiveJob(job.id);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Dikembalikan dari arsip')));
                                      // Reload current tab after unarchive
                                      await jobService.getMyJobs(refresh: true, archived: _isArchivedTab);
                                    }
                                  }
                                }
                              },
                              itemBuilder: (_) {
                                final isArchived = job.archivedAt != null && job.archivedAt!.isNotEmpty;
                                if (isArchived) {
                                  return [
                                    const PopupMenuItem(value: 'unarchive', child: Text('Kembalikan dari Arsip')),
                                    const PopupMenuItem(value: 'delete', child: Text('Hapus Lowongan')),
                                  ];
                                } else {
                                  return [
                                    const PopupMenuItem(value: 'archive', child: Text('Arsipkan Lowongan')),
                                    const PopupMenuItem(value: 'delete', child: Text('Hapus Lowongan')),
                                  ];
                                }
                              },
                              icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final result = await PageTransitions.slideTo(
                                    context,
                                    _EditLowonganPage(job: job),
                                  );
                                  // Refresh data setelah kembali dari halaman edit lowongan
                                  if (result == true && mounted) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      Provider.of<JobService>(context, listen: false).getMyJobs(
                                        refresh: true,
                                        archived: _isArchivedTab,
                                        search: _searchQuery.isNotEmpty ? _searchQuery : null,
                                      );
                                    });
                                  }
                                },
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1A365D),
                                  side: const BorderSide(color: Color(0xFF1A365D)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: job.statusAktif == true
                                  ? ElevatedButton.icon(
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Nonaktifkan Lowongan'),
                                            content: const Text('Yakin ingin menonaktifkan lowongan ini?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Nonaktifkan')),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          final today = DateTime.now();
                                          final dateStr = today.toIso8601String().split('T').first;
                                          final jobService = Provider.of<JobService>(context, listen: false);
                                          final res = await jobService.updateJobStatus(job.id, statusAktif: false, tanggalSelesai: dateStr);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Dinonaktifkan')));
                                            // Refresh current tab after update
                                            await jobService.getMyJobs(refresh: true, archived: _isArchivedTab);
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.cancel, size: 18),
                                      label: const Text('Nonaktifkan'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                      ),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: () async {
                                        final jobService = Provider.of<JobService>(context, listen: false);
                                        final res = await jobService.activateJob(job.id);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Diaktifkan')));
                                          // Refresh current tab after update
                                          await jobService.getMyJobs(refresh: true, archived: _isArchivedTab);
                                        }
                                      },
                                      icon: const Icon(Icons.check_circle, size: 18),
                                      label: const Text('Aktifkan'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                            ),
                          ],
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
                    if (res['success'] == true) Navigator.pop(context, true);
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

class _EditLowonganPage extends StatefulWidget {
  final Job job;
  const _EditLowonganPage({super.key, required this.job});

  @override
  State<_EditLowonganPage> createState() => _EditLowonganPageState();
}

class _EditLowonganPageState extends State<_EditLowonganPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judul;
  late final TextEditingController _posisi;
  late final TextEditingController _lokasi;
  late final TextEditingController _gajiMin;
  late final TextEditingController _gajiMax;
  late final TextEditingController _deskripsi;
  late final TextEditingController _jenis;
  late final TextEditingController _pendidikan;
  late final TextEditingController _persyaratan;
  DateTime? _tanggalSelesai;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _judul = TextEditingController(text: widget.job.judul);
    _posisi = TextEditingController(text: widget.job.posisi ?? '');
    _lokasi = TextEditingController(text: widget.job.lokasi ?? '');
    _gajiMin = TextEditingController(text: widget.job.gajiMin ?? '');
    _gajiMax = TextEditingController(text: widget.job.gajiMax ?? '');
    _deskripsi = TextEditingController(text: widget.job.deskripsi);
    _jenis = TextEditingController(text: widget.job.jenisPekerjaan ?? '');
    _pendidikan = TextEditingController(text: widget.job.jenjangPendidikan ?? '');
    _persyaratan = TextEditingController(text: widget.job.rincianLowongan ?? '');
    if (widget.job.tanggalSelesai != null) {
      try {
        _tanggalSelesai = DateTime.parse(widget.job.tanggalSelesai!);
      } catch (e) {
        // ignore
      }
    }
  }

  @override
  void dispose() {
    _judul.dispose();
    _posisi.dispose();
    _lokasi.dispose();
    _gajiMin.dispose();
    _gajiMax.dispose();
    _deskripsi.dispose();
    _jenis.dispose();
    _pendidikan.dispose();
    _persyaratan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A365D),
        elevation: 0.5,
        title: const Text('Edit Lowongan', style: TextStyle(color: Color(0xFF1A365D))),
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
                _input(controller: _jenis, label: 'Jenis Pekerjaan (Full Time/Part Time/Kontrak)'),
                const SizedBox(height: 12),
                _input(controller: _pendidikan, label: 'Jenjang Pendidikan (SMA/D3/S1)'),
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
                  onPressed: _loading ? null : () async {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => _loading = true);
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
                    final res = await Provider.of<JobService>(context, listen: false).updateJob(widget.job.id, payload);
                    setState(() => _loading = false);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Diperbarui')));
                    if (res['success'] == true) Navigator.pop(context, true);
                  },
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
        final picked = await showDatePicker(context: context, initialDate: _tanggalSelesai ?? now, firstDate: now, lastDate: DateTime(now.year + 3));
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

class _ApplicantsScreenState extends State<_ApplicantsScreen> with SingleTickerProviderStateMixin {
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _allApps = [];
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isAcceptedTab = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final newIsAccepted = _tabController.index == 1;
        if (newIsAccepted != _isAcceptedTab) {
          setState(() {
            _isAcceptedTab = newIsAccepted;
            // Keep search query when switching tabs
          });
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final searchQuery = _searchQuery.isNotEmpty ? _searchQuery : null;
      final res = await ApiService.getApplicantsForJob(
        widget.jobId,
        archived: false, // Always get non-archived applicants
        search: searchQuery,
      );
      if (res['success'] == true) {
        final List<dynamic> list = res['data'] as List<dynamic>;
        final apps = list.whereType<Map<String, dynamic>>().toList();
        setState(() {
          _allApps = apps;
        });
      } else {
        _error = res['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }
  
  List<Map<String, dynamic>> get _filteredApps {
    if (_isAcceptedTab) {
      // Filter untuk tab "Diterima" - hanya pelamar dengan status "diterima"
      return _allApps.where((app) {
        final status = (app['status'] ?? '').toString().toLowerCase();
        return status == 'diterima';
      }).toList();
    } else {
      // Tab "Lamaran" - semua pelamar kecuali yang diterima
      return _allApps.where((app) {
        final status = (app['status'] ?? '').toString().toLowerCase();
        return status != 'diterima';
      }).toList();
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchQuery == value) {
        _load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentApps = _filteredApps;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A365D),
        elevation: 0.5,
        title: const Text('Detail Lowongan', style: TextStyle(color: Color(0xFF1A365D))),
        actions: [
          if (currentApps.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download, color: Color(0xFF1A365D)),
              tooltip: 'Download Data Pelamar',
              onPressed: () => _downloadAllApplicantsData(),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1A365D),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1A365D),
          tabs: const [
            Tab(
              text: 'Lamaran',
              icon: Icon(Icons.inbox_outlined),
            ),
            Tab(
              text: 'Diterima',
              icon: Icon(Icons.check_circle_outline),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cari pelamar...',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[500], size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            _load();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: RefreshIndicator(
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
                      : currentApps.isEmpty
                          ? ListView(children: [
                              const SizedBox(height: 80),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      _isAcceptedTab ? Icons.check_circle_outline : Icons.inbox_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _isAcceptedTab ? 'Belum ada pelamar yang diterima' : 'Belum ada pelamar',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ])
                          : ListView.separated(
                              padding: const EdgeInsets.all(20),
                              itemCount: currentApps.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, i) => _applicantCard(currentApps[i]),
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _applicantCard(Map<String, dynamic> app) {
    final pelamar = app['pelamar'] as Map<String, dynamic>?;
    final name = pelamar?['name'] ?? 'Pelamar';
    final email = pelamar?['email'] ?? '-';
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
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF1A365D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A365D))),
                        ),
                      ],
                    ),
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
          // Action button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                PageTransitions.slideTo(
                  context,
                  _ApplicantDetailPage(
                    application: app,
                  ),
                );
              },
              icon: const Icon(Icons.person_search, size: 18),
              label: const Text('Lihat Pelamar', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A365D),
                side: const BorderSide(color: Color(0xFF1A365D)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Status button row
          Row(
            children: [
              Expanded(
                child: _statusMenu(app['id'].toString(), status),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusMenu(String applicationId, String current) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => _ConfirmStatusDialog(status: value),
        );
        if (confirmed != true) return;

        final res = await showDialog<Map<String, String>?>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => _EmailFormDialog(status: value),
        );

        if (res == null) return; // cancelled

        final apiRes = await ApiService.updateApplicantStatus(
          applicationId,
          value,
          subject: res['subject'],
          message: res['message'],
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiRes['message'] ?? 'Diperbarui')));
        if (apiRes['success'] == true) {
          _load();
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'melamar', child: Text('Melamar')),
        PopupMenuItem(value: 'lolos', child: Text('Lolos Screening')),
        PopupMenuItem(value: 'interview', child: Text('Tahap Interview')),
        PopupMenuItem(value: 'diterima', child: Text('Diterima')),
        PopupMenuItem(value: 'ditolak', child: Text('Ditolak')),
      ],
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.sync_alt, size: 18),
          label: const Text('Ubah Status', style: TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1A365D),
            side: const BorderSide(color: Color(0xFF1A365D)),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
    );
  }

  // Dialog konfirmasi singkat
  Widget _ConfirmStatusDialog({required String status}) {
    String label;
    switch (status) {
      case 'lolos':
        label = 'Lolos Screening';
        break;
      case 'interview':
        label = 'Tahap Interview';
        break;
      case 'diterima':
        label = 'Diterima';
        break;
      case 'ditolak':
        label = 'Ditolak';
        break;
      default:
        label = 'Melamar';
    }
    return AlertDialog(
      title: const Text('Konfirmasi Perubahan'),
      content: Text('Yakin ubah status pelamar menjadi "$label"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Lanjut')),
      ],
    );
  }

  // Dialog form email: subject dan message
  Widget _EmailFormDialog({required String status}) {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Subjek default sesuai status
    String defaultSubject;
    switch (status) {
      case 'lolos':
        defaultSubject = 'Informasi: Anda Lolos Screening';
        break;
      case 'interview':
        defaultSubject = 'Undangan Interview';
        break;
      case 'diterima':
        defaultSubject = 'Selamat! Anda Diterima';
        break;
      case 'ditolak':
        defaultSubject = 'Informasi Hasil Lamaran';
        break;
      default:
        defaultSubject = 'Update Status Lamaran';
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      subjectController.text = defaultSubject;
    });

    return AlertDialog(
      title: const Text('Kirim Email ke Pelamar'),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Subjek'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Subjek wajib diisi' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: messageController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Pesan',
                  alignLabelWithHint: true,
                  hintText: 'Tulis pesan untuk pelamar...'
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Pesan wajib diisi' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            Navigator.pop<Map<String, String>>(context, {
              'subject': subjectController.text.trim(),
              'message': messageController.text.trim(),
            });
          },
          child: const Text('Kirim'),
        ),
      ],
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
    
    PageTransitions.slideTo(context, PdfViewerPage(url: fullUrl, title: 'CV Pelamar'));
  }

  Future<void> _downloadAllApplicantsData() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Download Data Pelamar'),
        content: Text(
          'Download semua data pelamar (${_allApps.length} pelamar) dalam format ZIP? '
          'File akan berisi profil, data akademik, data keluarga, dan dokumen pendukung.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A365D),
              foregroundColor: Colors.white,
            ),
            child: const Text('Download'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF1A365D)),
                SizedBox(height: 16),
                Text('Mengunduh data pelamar...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final result = await ApiService.downloadApplicantsZip(widget.jobId);
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (result['success'] == true) {
        final filePath = result['filePath'] as String?;
        if (filePath != null && filePath.isNotEmpty) {
          // Try to open file
          try {
            await OpenFile.open(filePath);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data pelamar berhasil diunduh dan dibuka!'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File berhasil diunduh di: $filePath'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File berhasil diunduh'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal mengunduh data pelamar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    
    // Map untuk jenis dokumen
    final Map<String, String> dokumenTypes = {
      'cv': 'CV',
      'ktp': 'KTP',
      'ijazah': 'Ijazah/SKL',
      'transkrip': 'Transkrip Nilai',
      'sertifikat': 'Sertifikat',
      'portofolio': 'Portofolio',
      'lainnya': 'Dokumen Lainnya',
    };
    
    final title = dokumenTypes[jenisDokumen] ?? jenisDokumen;
    
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
            onPressed: fileUrl.isNotEmpty ? () => _openPdf(fileUrl, title: title) : null,
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

  void _openPdf(String url, {String title = 'Dokumen PDF'}) {
    // Fix: Add base URL if the URL is relative
    var fullUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      // It's a relative path, add base URL
      fullUrl = '${ApiService.baseUrl.replaceFirst('/api', '')}$url';
      print('🔧 Fixed relative URL to: $fullUrl');
    }
    
    PageTransitions.slideTo(context, PdfViewerPage(url: fullUrl, title: title));
  }
}


// imports needed at top of file
// in-app pdf viewer is factored out to PdfViewerPage


