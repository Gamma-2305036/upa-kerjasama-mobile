import 'package:flutter/material.dart';

class BantuanPage extends StatefulWidget {
  const BantuanPage({super.key});

  @override
  State<BantuanPage> createState() => _BantuanPageState();
}

class _BantuanPageState extends State<BantuanPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
          'Bantuan & Dukungan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'FAQ'),
            Tab(text: 'Kontak'),
            Tab(text: 'Feedback'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFAQTab(),
          _buildContactTab(),
          _buildFeedbackTab(),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari pertanyaan...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Color(0xFF1A365D), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          
          // FAQ List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: _getFilteredFAQs().map((faq) => _buildFAQItem(faq)).toList(),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Contact Info
          _buildContactCard(
            title: 'Hubungi Kami',
            icon: Icons.phone,
            color: Colors.blue,
            children: [
              _buildContactItem('Telepon', '+62 21-1234-5678', Icons.phone),
              _buildContactItem('WhatsApp', '+62 812-3456-7890', Icons.chat),
              _buildContactItem('Email', 'support@upakerjasama.com', Icons.email),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Office Hours
          _buildContactCard(
            title: 'Jam Operasional',
            icon: Icons.schedule,
            color: Colors.green,
            children: [
              _buildContactItem('Senin - Jumat', '08:00 - 17:00 WIB', Icons.access_time),
              _buildContactItem('Sabtu', '08:00 - 12:00 WIB', Icons.access_time),
              _buildContactItem('Minggu', 'Tutup', Icons.close),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Social Media
          _buildContactCard(
            title: 'Media Sosial',
            icon: Icons.share,
            color: Colors.purple,
            children: [
              _buildContactItem('Instagram', '@upakerjasama', Icons.camera_alt),
              _buildContactItem('Facebook', 'UPA Kerjasama POLINDRA', Icons.facebook),
              _buildContactItem('LinkedIn', 'UPA Kerjasama POLINDRA', Icons.business),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Quick Actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildFeedbackTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Feedback Form
          Container(
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
                  Text(
                    'Kirim Feedback',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Subject
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Subjek',
                      prefixIcon: Icon(Icons.subject, color: Color(0xFF1A365D)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(0xFF1A365D)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Message
                  TextField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Pesan',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(0xFF1A365D)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Rating
                  Text(
                    'Rating Aplikasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        color: index < 4 ? Colors.orange : Colors.grey[300],
                        size: 30,
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Submit Button
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF1A365D),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () => _submitFeedback(),
                        child: Center(
                          child: Text(
                            'Kirim Feedback',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq) {
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
      child: ExpansionTile(
        title: Text(
          faq['question'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A365D),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(
              faq['answer'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
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
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A365D),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String label, String value, IconData icon) {
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
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A365D),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.copy, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
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
            Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A365D),
              ),
            ),
            const SizedBox(height: 20),
            
            _buildQuickActionItem(
              title: 'Laporkan Bug',
              subtitle: 'Laporkan masalah teknis',
              icon: Icons.bug_report,
              color: Colors.red,
              onTap: () => _reportBug(),
            ),
            
            _buildQuickActionItem(
              title: 'Minta Fitur Baru',
              subtitle: 'Saran untuk pengembangan',
              icon: Icons.lightbulb,
              color: Colors.orange,
              onTap: () => _requestFeature(),
            ),
            
            _buildQuickActionItem(
              title: 'Tutorial Aplikasi',
              subtitle: 'Panduan penggunaan',
              icon: Icons.play_circle,
              color: Colors.blue,
              onTap: () => _showTutorial(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A365D),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _faqs = [
    {
      'question': 'Bagaimana cara melamar pekerjaan?',
      'answer': 'Untuk melamar pekerjaan, ikuti langkah berikut:\n1. Buka halaman beranda\n2. Pilih lowongan yang sesuai\n3. Klik "Lihat Detail"\n4. Baca deskripsi pekerjaan dengan teliti\n5. Klik "Lamar Sekarang"\n6. Lengkapi formulir lamaran\n7. Upload dokumen yang diperlukan\n8. Submit lamaran Anda',
    },
    {
      'question': 'Bagaimana cara menyimpan lowongan?',
      'answer': 'Untuk menyimpan lowongan:\n1. Buka detail lowongan yang ingin disimpan\n2. Klik ikon hati (❤️) di pojok kanan atas\n3. Lowongan akan tersimpan di halaman "Lowongan Tersimpan"\n4. Anda dapat mengaksesnya kapan saja dari menu profil',
    },
    {
      'question': 'Bagaimana cara melacak status lamaran?',
      'answer': 'Untuk melacak status lamaran:\n1. Buka menu profil\n2. Pilih "Lamaran Saya"\n3. Lihat daftar semua lamaran yang telah dikirim\n4. Status akan diperbarui secara otomatis\n5. Anda akan mendapat notifikasi jika ada perubahan status',
    },
    {
      'question': 'Bagaimana cara mengubah profil?',
      'answer': 'Untuk mengubah profil:\n1. Buka menu profil\n2. Pilih "Edit Profil"\n3. Ubah informasi yang diperlukan\n4. Klik "Simpan Perubahan"\n5. Profil akan diperbarui secara otomatis',
    },
    {
      'question': 'Bagaimana cara mengatur notifikasi?',
      'answer': 'Untuk mengatur notifikasi:\n1. Buka menu profil\n2. Pilih "Notifikasi"\n3. Atur preferensi notifikasi sesuai kebutuhan\n4. Pilih jenis notifikasi yang ingin diterima\n5. Setel waktu dan frekuensi notifikasi',
    },
    {
      'question': 'Apa yang harus dilakukan jika lupa password?',
      'answer': 'Jika lupa password:\n1. Di halaman login, klik "Lupa Password?"\n2. Masukkan email yang terdaftar\n3. Periksa email Anda untuk link reset password\n4. Klik link yang dikirim\n5. Buat password baru\n6. Login dengan password baru',
    },
  ];

  List<Map<String, dynamic>> _getFilteredFAQs() {
    if (_searchQuery.isEmpty) {
      return _faqs;
    }
    return _faqs.where((faq) {
      return faq['question'].toLowerCase().contains(_searchQuery) ||
             faq['answer'].toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _submitFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Feedback berhasil dikirim! Terima kasih atas masukan Anda.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _reportBug() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Membuka form laporan bug...')),
    );
  }

  void _requestFeature() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Membuka form permintaan fitur...')),
    );
  }

  void _showTutorial() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Memulai tutorial aplikasi...')),
    );
  }
}
