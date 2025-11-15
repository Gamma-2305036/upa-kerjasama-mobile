import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/job_model.dart';
import '../../utils/page_transitions.dart';
import 'detail_lamaran_page.dart';

class LamaranSayaPage extends StatefulWidget {
  const LamaranSayaPage({super.key});

  @override
  State<LamaranSayaPage> createState() => _LamaranSayaPageState();
}

class _LamaranSayaPageState extends State<LamaranSayaPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = false;
  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _pending = [];
  List<Map<String, dynamic>> _accepted = [];
  List<Map<String, dynamic>> _rejected = [];

  Future<void> _loadApplications() async {
    setState(() => _loading = true);
    try {
      final resp = await ApiService.getMyApplications();
      if (resp['success'] == true) {
        final List<dynamic> list = resp['data'] as List<dynamic>;
        final mapped = list.whereType<Map<String, dynamic>>().map((e) => e).toList();
        _all = mapped;
        _pending = mapped.where((e) => e['status'] == 'melamar' || e['status'] == 'pending').toList();
        _accepted = mapped.where((e) => e['status'] == 'diterima').toList();
        _rejected = mapped.where((e) => e['status'] == 'ditolak').toList();
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadApplications());
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
      appBar: AppBar(
        backgroundColor: Color(0xFF1A365D),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lamaran Saya',
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
            Tab(text: 'Semua'),
            Tab(text: 'Pending'),
            Tab(text: 'Diterima'),
            Tab(text: 'Ditolak'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllApplications(),
          _buildPendingApplications(),
          _buildAcceptedApplications(),
          _buildRejectedApplications(),
        ],
      ),
    );
  }

  Widget _buildAllApplications() => _loading ? _buildLoading() : _buildApplicationsList(_all);

  Widget _buildPendingApplications() => _loading ? _buildLoading() : _buildApplicationsList(_pending);

  Widget _buildAcceptedApplications() => _loading ? _buildLoading() : _buildApplicationsList(_accepted);

  Widget _buildRejectedApplications() => _loading ? _buildLoading() : _buildApplicationsList(_rejected);

  Widget _buildApplicationsList(List<Map<String, dynamic>> applications) {
    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'Belum ada lamaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Mulai cari lowongan kerja yang sesuai',
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final application = applications[index];
        return _buildApplicationCard(application);
      },
    );
  }

  Widget _buildLoading() => Center(child: CircularProgressIndicator());

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final lowongan = application['lowongan'] as Map<String, dynamic>?;
    final perusahaan = (lowongan?['mitra'] as Map<String, dynamic>?)?['nama_perusahaan'] ?? 'Perusahaan';
    final posisi = lowongan?['judul'] ?? 'Posisi';
    final status = (application['status'] ?? '').toString();
    final statusColor = status == 'diterima'
        ? Colors.green
        : status == 'ditolak'
            ? Colors.red
            : Colors.orange;
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
                        posisi,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A365D),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        perusahaan,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            // Tampilkan subject dan message jika ada
            if (application['subject'] != null && application['subject'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF1A365D).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Color(0xFF1A365D).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.email_outlined, size: 16, color: Color(0xFF1A365D)),
                        const SizedBox(width: 6),
                        Text(
                          'Pesan dari Perusahaan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A365D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (application['subject'] != null && application['subject'].toString().isNotEmpty)
                      Text(
                        application['subject'].toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    if (application['message'] != null && application['message'].toString().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        application['message'].toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 15),
            
            // Detail lamaran
            _buildApplicationTimeline(application),
            
            const SizedBox(height: 15),
            
            // Aksi berdasarkan status
            if (status == 'melamar' || status == 'pending')
              _buildPendingActions(application)
            else if (status == 'diterima')
              _buildAcceptedActions(application)
            else if (status == 'ditolak')
              _buildRejectedActions(application),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingActions(Map<String, dynamic> application) {
    return Row(
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
                onTap: () {
                  _showCancelDialog();
                },
                child: Center(
                  child: Text(
                    'Batalkan',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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
              color: Color(0xFF1A365D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  _viewApplicationDetails(application);
                },
                child: Center(
                  child: Text(
                    'Lihat Detail',
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
    );
  }

  Widget _buildAcceptedActions(Map<String, dynamic> application) {
    final hasMessage = (application['subject'] != null && application['subject'].toString().isNotEmpty) ||
                       (application['message'] != null && application['message'].toString().isNotEmpty);
    
    return Row(
      children: [
        if (hasMessage) ...[
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    _showCongratulationsDialog(application);
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.celebration, color: Colors.green[600], size: 16),
                        const SizedBox(width: 5),
                        Text(
                          'Lihat Pesan',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
        ],
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF1A365D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  _viewApplicationDetails(application);
                },
                child: Center(
                  child: Text(
                    'Lihat Detail',
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
    );
  }

  Widget _buildRejectedActions(Map<String, dynamic> application) {
    final hasFeedback = (application['subject'] != null && application['subject'].toString().isNotEmpty) ||
                       (application['message'] != null && application['message'].toString().isNotEmpty);
    
    return Row(
      children: [
        if (hasFeedback) ...[
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    _showFeedbackDialog(application);
                  },
                  child: Center(
                    child: Text(
                      'Lihat Feedback',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF1A365D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  _viewApplicationDetails(application);
                },
                child: Center(
                  child: Text(
                    'Lihat Detail',
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
    );
  }

  Map<String, dynamic> _createApplication(String position, String company, String status, Color statusColor) {
    return {
      'position': position,
      'company': company,
      'status': status,
      'statusColor': statusColor,
    };
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Batalkan Lamaran'),
        content: Text('Apakah Anda yakin ingin membatalkan lamaran ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lamaran berhasil dibatalkan')),
              );
            },
            child: Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCongratulationsDialog(Map<String, dynamic> application) {
    final subject = application['subject'] as String?;
    final message = application['message'] as String?;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.green),
            const SizedBox(width: 10),
            Expanded(
              child: Text(subject ?? 'Selamat!'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(message ?? 'Lamaran Anda diterima! Silakan hubungi perusahaan untuk langkah selanjutnya.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(Map<String, dynamic> application) {
    final subject = application['subject'] as String?;
    final message = application['message'] as String?;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(subject ?? 'Feedback'),
        content: SingleChildScrollView(
          child: Text(message ?? 'Terima kasih atas lamaran Anda. Sayangnya, untuk saat ini posisi ini sudah terisi. Silakan coba lowongan lain yang sesuai dengan kualifikasi Anda.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _viewApplicationDetails(Map<String, dynamic> application) {
    PageTransitions.slideTo(
      context,
      DetailLamaranPage(application: application),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatRelativeTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Baru saja';
          }
          return '${difference.inMinutes} menit yang lalu';
        }
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inDays == 1) {
        return 'Kemarin';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari yang lalu';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks minggu yang lalu';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months bulan yang lalu';
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years tahun yang lalu';
      }
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildApplicationTimeline(Map<String, dynamic> application) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 5),
        Text(
          'Dikirim: ${_formatDate(application['created_at']?.toString())}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 20),
        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 5),
        Text(
          _formatRelativeTime(application['created_at']?.toString()),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
