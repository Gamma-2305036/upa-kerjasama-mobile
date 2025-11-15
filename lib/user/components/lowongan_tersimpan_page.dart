import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/job_model.dart';
import 'edit_profil_page.dart';

class LowonganTersimpanPage extends StatefulWidget {
  const LowonganTersimpanPage({super.key});

  @override
  State<LowonganTersimpanPage> createState() => _LowonganTersimpanPageState();
}

class _LowonganTersimpanPageState extends State<LowonganTersimpanPage> {
  List<Map<String, dynamic>> _savedJobs = [];
  bool _loading = false;
  String? _error;
  Set<String> _appliedJobIds = {};

  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchSavedJobs());
  }

  Future<void> _fetchSavedJobs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await ApiService.getSavedJobs();
      final apps = await ApiService.getMyApplications();
      if (resp['success'] == true) {
        final List<dynamic> list = resp['data'] as List<dynamic>;
        if (apps['success'] == true) {
          final List<dynamic> myApps = apps['data'] as List<dynamic>;
          _appliedJobIds = myApps
              .whereType<Map<String, dynamic>>()
              .where((e) => (e['status'] ?? '') != 'tersimpan')
              .map((e) => ((e['lowongan'] as Map<String, dynamic>?)?['id']).toString())
              .toSet();
        } else {
          _appliedJobIds = {};
        }
        final mapped = list
            .whereType<Map<String, dynamic>>()
            .map((e) {
              final job = e['lowongan'] as Map<String, dynamic>?;
              if (job == null) return null;
              final mitra = job['mitra'] as Map<String, dynamic>?;
              return {
                'id': job['id'],
                'position': job['judul'] ?? job['posisi'] ?? '-',
                'company': mitra != null ? (mitra['nama_perusahaan'] ?? '-') : '-',
                'location': job['lokasi'] ?? '-',
                'salary': _formatGaji(job['gaji_min'], job['gaji_max']),
                'type': job['jenis_pekerjaan'] ?? '-',
                'savedDate': (e['saved_at'] ?? job['created_at'] ?? DateTime.now().toString()).toString(),
                'isActive': job['status_aktif'] == true,
                'isApplied': _appliedJobIds.contains(job['id']?.toString()),
              };
            })
            .whereType<Map<String, dynamic>>()
            .toList();
        setState(() => _savedJobs = mapped);
      } else {
        setState(() => _error = resp['message']?.toString());
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatGaji(dynamic min, dynamic max) {
    if (min == null && max == null) return '-';
    String fmt(dynamic v) => v == null ? '' : 'Rp ${v.toString()}';
    if (min != null && max != null) return '${fmt(min)} - ${fmt(max)}';
    return fmt(min ?? max);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF1A365D),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lowongan Tersimpan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),
          
          // Job list
          Expanded(
            child: _buildJobList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Semua', _selectedFilter == 'Semua'),
          _buildFilterChip('Aktif', _selectedFilter == 'Aktif'),
          _buildFilterChip('Tidak Aktif', _selectedFilter == 'Tidak Aktif'),
          _buildFilterChip('Full Time', _selectedFilter == 'Full Time'),
          _buildFilterChip('Contract', _selectedFilter == 'Contract'),
          _buildFilterChip('Remote', _selectedFilter == 'Remote'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        selectedColor: Color(0xFF1A365D).withOpacity(0.2),
        checkmarkColor: Color(0xFF1A365D),
        labelStyle: TextStyle(
          color: isSelected ? Color(0xFF1A365D) : Colors.grey[600],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildJobList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red[400], size: 48),
              const SizedBox(height: 10),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchSavedJobs,
                child: const Text('Coba lagi'),
              )
            ],
          ),
        ),
      );
    }
    final filteredJobs = _getFilteredJobs();
    
    if (filteredJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              _selectedFilter == 'Semua' ? 'Belum ada lowongan tersimpan' : 'Tidak ada lowongan dengan filter ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Mulai simpan lowongan yang menarik',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredJobs.length,
      itemBuilder: (context, index) {
        final job = filteredJobs[index];
        return _buildJobCard(job);
      },
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['position'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A365D),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        job['company'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: job['isActive'] ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: job['isActive'] ? Colors.green[200]! : Colors.red[200]!,
                        ),
                      ),
                      child: Text(
                        job['isActive'] ? 'Aktif' : 'Tidak Aktif',
                        style: TextStyle(
                          color: job['isActive'] ? Colors.green[600] : Colors.red[600],
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Remove button
                    GestureDetector(
                      onTap: () => _removeJob(job['id']),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.red[600],
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 15),
            
            // Job details
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 5),
                Text(
                  job['location'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 20),
                Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 5),
                Text(
                  job['salary'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            Row(
              children: [
                Icon(Icons.work, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 5),
                Text(
                  job['type'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 20),
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 5),
                Text(
                  'Disimpan ${_getTimeAgo(job['savedDate'])}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _shareJob(job),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.share, color: Colors.grey[600], size: 16),
                              const SizedBox(width: 5),
                              Text(
                                'Bagikan',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: (job['isApplied'] == true) ? Colors.grey : Color(0xFF1A365D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: (job['isApplied'] == true) ? null : () => _applyJob(job),
                        child: Center(
                          child: Text(
                            (job['isApplied'] == true) ? 'Sudah Melamar' : 'Lamar Sekarang',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredJobs() {
    if (_selectedFilter == 'Semua') {
      return _savedJobs;
    } else if (_selectedFilter == 'Aktif') {
      return _savedJobs.where((job) => job['isActive'] == true).toList();
    } else if (_selectedFilter == 'Tidak Aktif') {
      return _savedJobs.where((job) => job['isActive'] == false).toList();
    } else {
      return _savedJobs.where((job) => job['type'] == _selectedFilter).toList();
    }
  }

  String _getTimeAgo(String date) {
    // Simple time ago calculation
    final now = DateTime.now();
    final jobDate = DateTime.parse(date);
    final difference = now.difference(jobDate).inDays;
    
    if (difference == 0) {
      return 'hari ini';
    } else if (difference == 1) {
      return 'kemarin';
    } else {
      return '$difference hari yang lalu';
    }
  }

  void _removeJob(dynamic jobId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Lowongan'),
        content: Text('Apakah Anda yakin ingin menghapus lowongan ini dari daftar tersimpan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmRemove(jobId);
            },
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(dynamic jobId) async {
    try {
      final resp = await ApiService.removeSavedJob(jobId.toString());
      if (resp['success'] == true) {
        setState(() {
          _savedJobs.removeWhere((job) => job['id'].toString() == jobId.toString());
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lowongan berhasil dihapus')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp['message']?.toString() ?? 'Gagal menghapus')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
      );
    }
  }

  void _shareJob(Map<String, dynamic> job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Membagikan lowongan ${job['position']}...')),
    );
  }

  void _applyJob(Map<String, dynamic> job) async {
    // Check profile completion first - must be 100%
    final completionCheck = await ApiService.checkProfileCompletion();
    
    final percentage = completionCheck['percentage'] ?? 0;
    if (completionCheck['success'] != true || percentage < 100) {
      // Show alert to complete profile - must be 100%
      _showProfileIncompleteDialog(completionCheck);
      return;
    }

    // Profile is complete, proceed with application
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Lamar Lowongan'),
        content: Text('Apakah Anda yakin ingin melamar untuk posisi ${job['position']} di ${job['company']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final res = await ApiService.applyJob(job['id'].toString());
                if (res['success'] == true) {
                  setState(() {
                    _appliedJobIds.add(job['id'].toString());
                    final idx = _savedJobs.indexWhere((e) => e['id'] == job['id']);
                    if (idx >= 0) _savedJobs[idx]['isApplied'] = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lamaran berhasil dikirim!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res['message']?.toString() ?? 'Gagal melamar')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
                );
              }
            },
            child: Text('Lamar', style: TextStyle(color: Color(0xFF1A365D))),
          ),
        ],
      ),
    );
  }

  void _showProfileIncompleteDialog(Map<String, dynamic> completionCheck) {
    final percentage = completionCheck['percentage'] ?? 0;
    final missingFields = completionCheck['missingFields'] as List<dynamic>? ?? [];
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Profil Belum Lengkap',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A365D),
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profil Anda baru terisi $percentage%. Untuk dapat melamar lowongan, profil harus 100% lengkap terlebih dahulu.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              if (missingFields.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Data yang masih perlu dilengkapi:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const SizedBox(height: 8),
                ...missingFields.take(5).map((field) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 6, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          field.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                if (missingFields.length > 5)
                  Text(
                    'dan ${missingFields.length - 5} data lainnya...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Nanti',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to edit profile page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1A365D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, size: 18),
                const SizedBox(width: 8),
                Text('Lengkapi Profil'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Filter Lowongan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Semua'),
              leading: Radio<String>(
                value: 'Semua',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: Text('Aktif'),
              leading: Radio<String>(
                value: 'Aktif',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: Text('Tidak Aktif'),
              leading: Radio<String>(
                value: 'Tidak Aktif',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
