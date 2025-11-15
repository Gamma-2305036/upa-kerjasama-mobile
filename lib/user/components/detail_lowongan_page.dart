import 'package:flutter/material.dart';
import '../../models/job_model.dart';
import '../../services/api_service.dart';
import 'edit_profil_page.dart';

class DetailLowonganPage extends StatefulWidget {
  final Job job;
  
  const DetailLowonganPage({
    super.key,
    required this.job,
  });

  @override
  State<DetailLowonganPage> createState() => _DetailLowonganPageState();
}

class _DetailLowonganPageState extends State<DetailLowonganPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSaved = false;
  bool _hasApplied = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedState();
      _loadAppliedState();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // App Bar dengan gambar
          _buildSliverAppBar(),
          
          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Job Header Info
                _buildJobHeader(),
                
                // Tab Bar
                _buildTabBar(),
                
                // Tab Content
                _buildTabContent(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Color(0xFF1A365D),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isSaved ? Icons.favorite : Icons.favorite_border,
            color: _isSaved ? Colors.red : Colors.white,
          ),
          onPressed: _toggleSave,
        ),
        IconButton(
          icon: Icon(Icons.share, color: Colors.white),
          onPressed: () => _shareJob(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.work,
                    size: 40,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.job.judul,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.job.mitraPerusahaan?.namaPerusahaan ?? 'Perusahaan',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          // Job Details
          _buildDetailRow(Icons.location_on, 'Lokasi', widget.job.lokasi),
          _buildDetailRow(Icons.attach_money, 'Gaji', _formatSalary(widget.job.gajiMin, widget.job.gajiMax)),
          _buildDetailRow(Icons.work, 'Jenis', widget.job.jenisPekerjaan ?? 'Tidak disebutkan'),
          _buildDetailRow(Icons.schedule, 'Berakhir', widget.job.tanggalPenerimaanLamaran ?? 'Tidak disebutkan'),
          _buildDetailRow(Icons.school, 'Pendidikan', widget.job.jenjangPendidikan ?? 'Tidak disebutkan'),
          
          const SizedBox(height: 20),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                const SizedBox(width: 5),
                Text(
                  'Lowongan Aktif',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 15),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A365D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: TabBar(
        controller: _tabController,
        indicatorColor: Color(0xFF1A365D),
        labelColor: Color(0xFF1A365D),
        unselectedLabelColor: Colors.grey[600],
        tabs: [
          Tab(text: 'Deskripsi'),
          Tab(text: 'Persyaratan'),
          Tab(text: 'Perusahaan'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return Container(
      margin: const EdgeInsets.all(20),
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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 400,
          maxHeight: 500,
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDescriptionTab(),
            _buildRequirementsTab(),
            _buildCompanyTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deskripsi Pekerjaan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            widget.job.deskripsi,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tanggung Jawab:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 10),
          _buildBulletPoint('Mengembangkan aplikasi web dan mobile menggunakan teknologi terbaru'),
          _buildBulletPoint('Berkolaborasi dengan tim desain untuk membuat UI/UX yang menarik'),
          _buildBulletPoint('Melakukan testing dan debugging aplikasi'),
          _buildBulletPoint('Mengoptimalkan performa aplikasi'),
          _buildBulletPoint('Dokumentasi kode dan proses pengembangan'),
        ],
      ),
    );
  }

  Widget _buildRequirementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Persyaratan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 15),
          
          Text(
            widget.job.rincianLowongan ?? 'Persyaratan tidak disebutkan',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tentang Perusahaan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 15),
          
          Text(
            widget.job.mitraPerusahaan?.namaPerusahaan ?? 'Perusahaan',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildCompanyInfo('Industri', widget.job.mitraPerusahaan?.sektor ?? 'Tidak disebutkan'),
          _buildCompanyInfo('Lokasi', widget.job.lokasi),
          _buildCompanyInfo('Website', widget.job.mitraPerusahaan?.tautan ?? 'Tidak disebutkan'),
          _buildCompanyInfo('Kontak', widget.job.mitraPerusahaan?.kontak ?? 'Tidak disebutkan'),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 10),
            decoration: BoxDecoration(
              color: Color(0xFF1A365D),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A365D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: _toggleSave,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isSaved ? Icons.favorite : Icons.favorite_border,
                          color: _isSaved ? Colors.red : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isSaved ? 'Tersimpan' : 'Simpan',
                          style: TextStyle(
                            color: _isSaved ? Colors.red : Colors.grey[600],
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
          const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFF1A365D),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: _hasApplied ? null : () => _applyJob(),
                  child: Center(
                    child: Text(
                      _hasApplied ? 'Sudah Melamar' : 'Lamar Sekarang',
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
          ),
        ],
      ),
    ),
    );
  }

  Future<void> _loadSavedState() async {
    try {
      final resp = await ApiService.getSavedJobs();
      if (resp['success'] == true) {
        final List<dynamic> list = resp['data'] as List<dynamic>;
        final found = list.whereType<Map<String, dynamic>>().any((e) {
          final job = e['lowongan'] as Map<String, dynamic>?;
          return job != null && job['id']?.toString() == widget.job.id.toString();
        });
        if (mounted) setState(() => _isSaved = found);
      }
    } catch (_) {
      // ignore load error; UI defaults to not saved
    }
  }

  Future<void> _toggleSave() async {
    final wasSaved = _isSaved;
    setState(() => _isSaved = !wasSaved);

    try {
      if (!wasSaved) {
        final resp = await ApiService.saveJob(widget.job.id.toString());
        if (resp['success'] != true) throw resp['message'] ?? 'Gagal menyimpan';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lowongan disimpan')),
        );
      } else {
        final resp = await ApiService.removeSavedJob(widget.job.id.toString());
        if (resp['success'] != true) throw resp['message'] ?? 'Gagal menghapus';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lowongan dihapus dari tersimpan')),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isSaved = wasSaved); // revert on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadAppliedState() async {
    try {
      final resp = await ApiService.getMyApplications();
      if (resp['success'] == true) {
        final List<dynamic> list = resp['data'] as List<dynamic>;
        final applied = list.whereType<Map<String, dynamic>>().any((e) {
          final job = e['lowongan'] as Map<String, dynamic>?;
          final status = (e['status'] ?? '').toString();
          if (job == null) return false;
          final isThisJob = job['id']?.toString() == widget.job.id.toString();
          return isThisJob && status != 'tersimpan';
        });
        if (mounted) setState(() => _hasApplied = applied);
      }
    } catch (_) {}
  }

  void _applyJob() async {
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
        content: Text('Apakah Anda yakin ingin melamar untuk posisi ${widget.job.judul} di ${widget.job.mitraPerusahaan?.namaPerusahaan ?? 'Perusahaan'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final res = await ApiService.applyJob(widget.job.id.toString());
                if (res['success'] == true) {
                  if (mounted) setState(() => _hasApplied = true);
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

  void _shareJob() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Membagikan lowongan...')),
    );
  }

  String _formatSalary(String? min, String? max) {
    if (min != null && max != null) {
      return 'Rp $min - $max';
    } else if (min != null) {
      return 'Rp $min+';
    } else if (max != null) {
      return 'Rp $max';
    }
    return 'Gaji tidak disebutkan';
  }
}
