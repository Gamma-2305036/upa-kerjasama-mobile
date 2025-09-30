import 'package:flutter/material.dart';

class LamaranSayaPage extends StatefulWidget {
  const LamaranSayaPage({super.key});

  @override
  State<LamaranSayaPage> createState() => _LamaranSayaPageState();
}

class _LamaranSayaPageState extends State<LamaranSayaPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  Widget _buildAllApplications() {
    return _buildApplicationsList([
      _createApplication('Software Developer', 'PT. Teknologi Indonesia', 'Diterima', Colors.green),
      _createApplication('UI/UX Designer', 'CV. Digital Solutions', 'Pending', Colors.orange),
      _createApplication('Data Analyst', 'PT. Inovasi Kreatif', 'Ditolak', Colors.red),
      _createApplication('Marketing Specialist', 'PT. Global Finance', 'Pending', Colors.orange),
      _createApplication('Frontend Developer', 'PT. Media Digital', 'Diterima', Colors.green),
    ]);
  }

  Widget _buildPendingApplications() {
    return _buildApplicationsList([
      _createApplication('UI/UX Designer', 'CV. Digital Solutions', 'Pending', Colors.orange),
      _createApplication('Marketing Specialist', 'PT. Global Finance', 'Pending', Colors.orange),
    ]);
  }

  Widget _buildAcceptedApplications() {
    return _buildApplicationsList([
      _createApplication('Software Developer', 'PT. Teknologi Indonesia', 'Diterima', Colors.green),
      _createApplication('Frontend Developer', 'PT. Media Digital', 'Diterima', Colors.green),
    ]);
  }

  Widget _buildRejectedApplications() {
    return _buildApplicationsList([
      _createApplication('Data Analyst', 'PT. Inovasi Kreatif', 'Ditolak', Colors.red),
    ]);
  }

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

  Widget _buildApplicationCard(Map<String, dynamic> application) {
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
                        application['position'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A365D),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        application['company'],
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
                    color: application['statusColor'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: application['statusColor'],
                      width: 1,
                    ),
                  ),
                  child: Text(
                    application['status'],
                    style: TextStyle(
                      color: application['statusColor'],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 15),
            
            // Detail lamaran
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 5),
                Text(
                  'Dikirim: 15 Des 2024',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 20),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 5),
                Text(
                  '2 hari yang lalu',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 15),
            
            // Aksi berdasarkan status
            if (application['status'] == 'Pending')
              _buildPendingActions()
            else if (application['status'] == 'Diterima')
              _buildAcceptedActions()
            else if (application['status'] == 'Ditolak')
              _buildRejectedActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingActions() {
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
                  _viewApplicationDetails();
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

  Widget _buildAcceptedActions() {
    return Row(
      children: [
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
                  _showCongratulationsDialog();
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.celebration, color: Colors.green[600], size: 16),
                      const SizedBox(width: 5),
                      Text(
                        'Selamat!',
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
                  _viewApplicationDetails();
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

  Widget _buildRejectedActions() {
    return Row(
      children: [
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
                  _showFeedbackDialog();
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
                  _viewApplicationDetails();
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

  void _showCongratulationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.green),
            const SizedBox(width: 10),
            Text('Selamat!'),
          ],
        ),
        content: Text('Lamaran Anda diterima! Silakan hubungi perusahaan untuk langkah selanjutnya.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Feedback'),
        content: Text('Terima kasih atas lamaran Anda. Sayangnya, untuk saat ini posisi ini sudah terisi. Silakan coba lowongan lain yang sesuai dengan kualifikasi Anda.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _viewApplicationDetails() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Membuka detail lamaran...')),
    );
  }
}
