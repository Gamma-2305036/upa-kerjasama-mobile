import 'package:flutter/material.dart';

class DetailLowonganPage extends StatefulWidget {
  final Map<String, dynamic> jobData;
  
  const DetailLowonganPage({
    super.key,
    required this.jobData,
  });

  @override
  State<DetailLowonganPage> createState() => _DetailLowonganPageState();
}

class _DetailLowonganPageState extends State<DetailLowonganPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          onPressed: () {
            setState(() {
              _isSaved = !_isSaved;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isSaved ? 'Lowongan disimpan' : 'Lowongan dihapus dari tersimpan'),
                backgroundColor: _isSaved ? Colors.green : Colors.red,
              ),
            );
          },
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
                  widget.jobData['position'] ?? 'Software Developer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.jobData['company'] ?? 'PT. Teknologi Indonesia',
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
          _buildDetailRow(Icons.location_on, 'Lokasi', widget.jobData['location'] ?? 'Jakarta'),
          _buildDetailRow(Icons.attach_money, 'Gaji', widget.jobData['salary'] ?? 'Rp 8-12 Juta'),
          _buildDetailRow(Icons.work, 'Jenis', widget.jobData['type'] ?? 'Full Time'),
          _buildDetailRow(Icons.schedule, 'Dibuka', widget.jobData['posted'] ?? '2 hari yang lalu'),
          _buildDetailRow(Icons.people, 'Pelamar', widget.jobData['applicants'] ?? '45 pelamar'),
          
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
            'Kami mencari Software Developer yang berpengalaman untuk bergabung dengan tim pengembangan kami. Anda akan bertanggung jawab untuk mengembangkan aplikasi web dan mobile yang inovatif.',
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
            'Kualifikasi:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 10),
          _buildBulletPoint('S1 Teknik Informatika atau bidang terkait'),
          _buildBulletPoint('Minimal 2 tahun pengalaman sebagai Software Developer'),
          _buildBulletPoint('Menguasai JavaScript, React, Node.js'),
          _buildBulletPoint('Familiar dengan database MySQL/PostgreSQL'),
          _buildBulletPoint('Memahami Git dan version control'),
          
          const SizedBox(height: 20),
          Text(
            'Keahlian Tambahan:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 10),
          _buildBulletPoint('Pengalaman dengan cloud services (AWS, GCP)'),
          _buildBulletPoint('Pengetahuan tentang DevOps dan CI/CD'),
          _buildBulletPoint('Kemampuan komunikasi yang baik'),
          _buildBulletPoint('Dapat bekerja dalam tim'),
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
            'PT. Teknologi Indonesia adalah perusahaan teknologi yang fokus pada pengembangan solusi digital inovatif. Didirikan pada tahun 2015, kami telah melayani lebih dari 500 klien di berbagai industri.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildCompanyInfo('Industri', 'Teknologi Informasi'),
          _buildCompanyInfo('Ukuran Perusahaan', '500+ Karyawan'),
          _buildCompanyInfo('Lokasi', 'Jakarta, Indonesia'),
          _buildCompanyInfo('Website', 'www.teknoindonesia.com'),
          _buildCompanyInfo('Tahun Didirikan', '2015'),
          
          const SizedBox(height: 20),
          Text(
            'Keunggulan Perusahaan:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 10),
          _buildBulletPoint('Tim yang berpengalaman dan profesional'),
          _buildBulletPoint('Lingkungan kerja yang kolaboratif'),
          _buildBulletPoint('Kesempatan pengembangan karir yang luas'),
          _buildBulletPoint('Tunjangan dan benefit yang kompetitif'),
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
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
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
                  onTap: () => _saveJob(),
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
                  onTap: () => _applyJob(),
                  child: Center(
                    child: Text(
                      'Lamar Sekarang',
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
    );
  }

  void _saveJob() {
    setState(() {
      _isSaved = !_isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSaved ? 'Lowongan disimpan' : 'Lowongan dihapus dari tersimpan'),
        backgroundColor: _isSaved ? Colors.green : Colors.red,
      ),
    );
  }

  void _applyJob() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Lamar Lowongan'),
        content: Text('Apakah Anda yakin ingin melamar untuk posisi ${widget.jobData['position']} di ${widget.jobData['company']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lamaran berhasil dikirim!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Lamar', style: TextStyle(color: Color(0xFF1A365D))),
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
}
