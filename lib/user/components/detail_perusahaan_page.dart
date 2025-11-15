import 'package:flutter/material.dart';
import '../../utils/page_transitions.dart';
import '../../models/job_model.dart';
import '../../services/api_service.dart';
import 'detail_lowongan_page.dart';

class DetailPerusahaanPage extends StatefulWidget {
  final Map<String, dynamic> companyData;
  
  const DetailPerusahaanPage({
    super.key,
    required this.companyData,
  });

  @override
  State<DetailPerusahaanPage> createState() => _DetailPerusahaanPageState();
}

class _DetailPerusahaanPageState extends State<DetailPerusahaanPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;
  List<Job> _jobs = [];
  bool _jobsLoading = false;

  Future<void> _loadCompanyJobs() async {
    setState(() => _jobsLoading = true);
    try {
      // Fetch public jobs list then filter by this company id
      final resp = await ApiService.getJobs();
      if (resp['success'] == true) {
        final List<dynamic> list = resp['data'] as List<dynamic>;
        final companyId = widget.companyData['id']?.toString();
        final jobs = list
            .whereType<Map<String, dynamic>>()
            .map((e) => Job.fromJson(e))
            .where((j) => j.mitraId == companyId)
            .toList();
        setState(() => _jobs = jobs);
      }
    } catch (_) {
      // ignore errors; UI will show empty state
    } finally {
      if (mounted) setState(() => _jobsLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCompanyJobs());
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
                // Company Header Info
                _buildCompanyHeader(),
                
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
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Color(0xFF1A365D),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFollowing ? Icons.favorite : Icons.favorite_border,
            color: _isFollowing ? Colors.red : Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isFollowing = !_isFollowing;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isFollowing ? 'Mengikuti perusahaan' : 'Berhenti mengikuti'),
                backgroundColor: _isFollowing ? Colors.green : Colors.red,
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.share, color: Colors.white),
          onPressed: () => _shareCompany(),
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
                  width: 100,
                  height: 100,
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
                    Icons.business,
                    size: 50,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  // Prefer backend `nama_perusahaan`, fallback to generic keys or placeholder
                  widget.companyData['nama_perusahaan'] ??
                      widget.companyData['name'] ??
                      'Perusahaan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  // Prefer backend `sektor`
                  widget.companyData['sektor'] ??
                      widget.companyData['industry'] ??
                      'Industri tidak ditentukan',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                // Rating
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        widget.companyData['rating'] ?? '4.8',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyHeader() {
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
          // Company Details
          if ((widget.companyData['lokasi'] ?? widget.companyData['location']) != null)
            _buildDetailRow(
              Icons.location_on,
              'Lokasi',
              (widget.companyData['lokasi'] ?? widget.companyData['location']).toString(),
            ),
          if (widget.companyData['employees'] != null)
            _buildDetailRow(Icons.people, 'Karyawan', widget.companyData['employees'].toString()),
          if ((widget.companyData['tautan'] ?? widget.companyData['website']) != null)
            _buildDetailRow(
              Icons.web,
              'Website',
              (widget.companyData['tautan'] ?? widget.companyData['website']).toString(),
            ),
          if (widget.companyData['founded'] != null)
            _buildDetailRow(Icons.calendar_today, 'Didirikan', widget.companyData['founded'].toString()),
          if ((widget.companyData['sektor'] ?? widget.companyData['industry']) != null)
            _buildDetailRow(
              Icons.business_center,
              'Industri',
              (widget.companyData['sektor'] ?? widget.companyData['industry']).toString(),
            ),
          
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
                  'Perusahaan Terverifikasi',
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
        isScrollable: true,
        tabs: [
          Tab(text: 'Tentang'),
          Tab(text: 'Lowongan'),
          Tab(text: 'Review'),
          Tab(text: 'Kontak'),
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
            _buildAboutTab(),
            _buildJobsTab(),
            _buildReviewsTab(),
            _buildContactTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTab() {
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
            // Use provided description if exists, otherwise show a concise fallback
            (widget.companyData['tentang'] ?? widget.companyData['deskripsi'] ?? 'Belum ada deskripsi perusahaan.').toString(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Visi & Misi:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 10),
          Builder(builder: (context) {
            final String visi = (widget.companyData['visi'] ?? '').toString().trim();
            final String misi = (widget.companyData['misi'] ?? '').toString().trim();
            final bool hasVisi = visi.isNotEmpty && visi != '-';
            final bool hasMisi = misi.isNotEmpty && misi != '-';

            if (!hasVisi && !hasMisi) {
              return Text(
                'Belum ada visi & misi.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasVisi) ...[
                  Text(
                    visi,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                if (hasMisi)
                  Text(
                    misi,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 20),
          Text(
            'Keunggulan:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 10),
          Builder(builder: (context) {
            List<String> items = [];
            final raw = widget.companyData['keunggulan'];
            if (raw is List) {
              items = raw.map((e) => e.toString().trim()).toList();
            } else if (raw is String) {
              final s = raw.trim();
              if (s.isNotEmpty && s != '-') {
                items = (s.contains('\n') ? s.split('\n') : s.split(','))
                    .map((e) => e.trim())
                    .toList();
              }
            }
            items = items.where((e) => e.isNotEmpty && e != '-').toList();

            if (items.isEmpty) {
              return Text(
                'Belum ada keunggulan.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((e) => _buildBulletPoint(e)).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildJobsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lowongan Tersedia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 15),
          if (_jobsLoading)
            Center(child: CircularProgressIndicator())
          else if (_jobs.isEmpty)
            Text('Belum ada lowongan aktif dari perusahaan ini.', style: TextStyle(color: Colors.grey[600]))
          else
            ..._jobs.map((job) => _buildJobCard(job)).toList(),
        ],
      ),
    );
  }

  Widget _buildJobCard(Job job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            PageTransitions.slideTo(
              context,
              DetailLowonganPage(job: job),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.judul, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A365D))),
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(Icons.work, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 5),
                    Flexible(
                      fit: FlexFit.tight,
                      child: Text(
                        job.jenisPekerjaan ?? 'Tidak disebutkan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 5),
                    Flexible(
                      fit: FlexFit.tight,
                      child: Text(
                        job.lokasi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.attach_money, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 5),
                    Flexible(
                      fit: FlexFit.tight,
                      child: Text(
                        _formatSalary(job.gajiMin, job.gajiMax),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatSalary(String? min, String? max) {
    if (min != null && max != null) return 'Rp $min - $max';
    if (min != null) return 'Rp $min+';
    if (max != null) return 'Rp $max';
    return 'Gaji tidak disebutkan';
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Karyawan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 15),
          
          _buildReviewItem('Ahmad Rizki', 'Software Developer', 5, 'Perusahaan yang sangat baik untuk mengembangkan karir. Tim yang solid dan lingkungan kerja yang nyaman.'),
          _buildReviewItem('Sarah Putri', 'UI/UX Designer', 4, 'Kesempatan belajar yang banyak dan proyek yang menarik. Manajemen yang responsif terhadap feedback.'),
          _buildReviewItem('Budi Santoso', 'Data Analyst', 5, 'Work-life balance yang baik dan benefit yang kompetitif. Sangat direkomendasikan untuk fresh graduate.'),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, String position, int rating, String review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF1A365D),
                child: Text(
                  name[0],
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A365D),
                      ),
                    ),
                    Text(
                      position,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    size: 16,
                    color: index < rating ? Colors.orange : Colors.grey[300],
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Kontak',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 15),
          if (widget.companyData['kontak'] != null)
            _buildContactItem(Icons.phone, 'Telepon', widget.companyData['kontak'].toString()),
          if (widget.companyData['email'] != null)
            _buildContactItem(Icons.email, 'Email', widget.companyData['email'].toString()),
          if ((widget.companyData['tautan'] ?? widget.companyData['website']) != null)
            _buildContactItem(Icons.web, 'Website', (widget.companyData['tautan'] ?? widget.companyData['website']).toString()),
          if (widget.companyData['alamat'] != null)
            _buildContactItem(Icons.location_on, 'Alamat', widget.companyData['alamat'].toString()),
          if (widget.companyData['jam_kerja'] != null)
            _buildContactItem(Icons.schedule, 'Jam Kerja', widget.companyData['jam_kerja'].toString()),
          
          const SizedBox(height: 20),
          Text(
            'Media Sosial',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 10),
          
          // Wrap social buttons in a flexible row
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildSocialButton(Icons.facebook, 'Facebook'),
              _buildSocialButton(Icons.camera_alt, 'Instagram'),
              _buildSocialButton(Icons.business, 'LinkedIn'),
            ],
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A365D),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.copy, color: Colors.grey[400], size: 16),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF1A365D).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF1A365D).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Color(0xFF1A365D), size: 16),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF1A365D),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
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
                  onTap: () => _followCompany(),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isFollowing ? Icons.favorite : Icons.favorite_border,
                          color: _isFollowing ? Colors.red : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isFollowing ? 'Mengikuti' : 'Ikuti',
                          style: TextStyle(
                            color: _isFollowing ? Colors.red : Colors.grey[600],
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
                  onTap: () => _viewJobs(),
                  child: Center(
                    child: Text(
                      'Lihat Lowongan',
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

  void _followCompany() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFollowing ? 'Mengikuti perusahaan' : 'Berhenti mengikuti'),
        backgroundColor: _isFollowing ? Colors.green : Colors.red,
      ),
    );
  }

  void _viewJobs() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Membuka daftar lowongan perusahaan...')),
    );
  }

  void _shareCompany() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Membagikan informasi perusahaan...')),
    );
  }
}
