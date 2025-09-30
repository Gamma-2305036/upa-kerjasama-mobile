import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
                  widget.companyData['name'] ?? 'PT. Teknologi Indonesia',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  widget.companyData['industry'] ?? 'Teknologi',
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
          _buildDetailRow(Icons.location_on, 'Lokasi', widget.companyData['location'] ?? 'Jakarta'),
          _buildDetailRow(Icons.people, 'Karyawan', widget.companyData['employees'] ?? '500+ Karyawan'),
          _buildDetailRow(Icons.web, 'Website', widget.companyData['website'] ?? 'www.teknoindonesia.com'),
          _buildDetailRow(Icons.calendar_today, 'Didirikan', widget.companyData['founded'] ?? '2015'),
          _buildDetailRow(Icons.business_center, 'Industri', widget.companyData['industry'] ?? 'Teknologi'),
          
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
            'PT. Teknologi Indonesia adalah perusahaan teknologi yang fokus pada pengembangan solusi digital inovatif. Didirikan pada tahun 2015, kami telah melayani lebih dari 500 klien di berbagai industri termasuk e-commerce, fintech, dan healthcare.',
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
          Text(
            'Visi: Menjadi perusahaan teknologi terdepan di Indonesia yang memberikan solusi digital terbaik untuk kemajuan bisnis.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Misi: Mengembangkan produk dan layanan teknologi yang inovatif, memberikan pengalaman terbaik bagi klien, dan menciptakan lingkungan kerja yang inspiratif bagi karyawan.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
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
          _buildBulletPoint('Tim yang berpengalaman dan profesional'),
          _buildBulletPoint('Teknologi terdepan dan inovatif'),
          _buildBulletPoint('Layanan customer support 24/7'),
          _buildBulletPoint('Harga yang kompetitif'),
          _buildBulletPoint('Garansi dan maintenance jangka panjang'),
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
          
          _buildJobItem('Software Developer', 'Full Time', 'Jakarta', 'Rp 8-12 Juta'),
          _buildJobItem('UI/UX Designer', 'Full Time', 'Jakarta', 'Rp 6-10 Juta'),
          _buildJobItem('Data Analyst', 'Contract', 'Jakarta', 'Rp 7-11 Juta'),
          _buildJobItem('DevOps Engineer', 'Full Time', 'Jakarta', 'Rp 10-15 Juta'),
          _buildJobItem('Product Manager', 'Full Time', 'Jakarta', 'Rp 12-18 Juta'),
        ],
      ),
    );
  }

  Widget _buildJobItem(String position, String type, String location, String salary) {
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
          Text(
            position,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.work, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 5),
              Text(type, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(width: 15),
              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 5),
              Text(location, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(width: 15),
              Icon(Icons.attach_money, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 5),
              Text(salary, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
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
          
          _buildContactItem(Icons.phone, 'Telepon', '+62 21-1234-5678'),
          _buildContactItem(Icons.email, 'Email', 'hr@teknoindonesia.com'),
          _buildContactItem(Icons.web, 'Website', 'www.teknoindonesia.com'),
          _buildContactItem(Icons.location_on, 'Alamat', 'Jl. Sudirman No. 123, Jakarta Pusat'),
          _buildContactItem(Icons.schedule, 'Jam Kerja', 'Senin - Jumat, 08:00 - 17:00'),
          
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
