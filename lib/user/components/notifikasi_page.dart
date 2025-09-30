import 'package:flutter/material.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Notification settings
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _jobAlerts = true;
  bool _applicationUpdates = true;
  bool _companyNews = false;
  bool _weeklyDigest = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          'Notifikasi',
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
            Tab(text: 'Pengaturan'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSettingsTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Email Notifications
          _buildSettingsSection(
            title: 'Email Notifications',
            icon: Icons.email_outlined,
            children: [
              _buildSwitchTile(
                title: 'Email Notifications',
                subtitle: 'Terima notifikasi melalui email',
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                },
              ),
              _buildSwitchTile(
                title: 'Job Alerts',
                subtitle: 'Notifikasi lowongan kerja baru',
                value: _jobAlerts,
                onChanged: (value) {
                  setState(() {
                    _jobAlerts = value;
                  });
                },
              ),
              _buildSwitchTile(
                title: 'Application Updates',
                subtitle: 'Update status lamaran',
                value: _applicationUpdates,
                onChanged: (value) {
                  setState(() {
                    _applicationUpdates = value;
                  });
                },
              ),
              _buildSwitchTile(
                title: 'Company News',
                subtitle: 'Berita dan update dari perusahaan',
                value: _companyNews,
                onChanged: (value) {
                  setState(() {
                    _companyNews = value;
                  });
                },
              ),
              _buildSwitchTile(
                title: 'Weekly Digest',
                subtitle: 'Ringkasan mingguan lowongan',
                value: _weeklyDigest,
                onChanged: (value) {
                  setState(() {
                    _weeklyDigest = value;
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Push Notifications
          _buildSettingsSection(
            title: 'Push Notifications',
            icon: Icons.notifications_outlined,
            children: [
              _buildSwitchTile(
                title: 'Push Notifications',
                subtitle: 'Terima notifikasi push di aplikasi',
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Notification Frequency
          _buildSettingsSection(
            title: 'Frekuensi Notifikasi',
            icon: Icons.schedule_outlined,
            children: [
              _buildListTile(
                title: 'Waktu Notifikasi',
                subtitle: 'Setiap hari pukul 09:00',
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showTimePicker(),
              ),
              _buildListTile(
                title: 'Hari Notifikasi',
                subtitle: 'Senin - Jumat',
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showDayPicker(),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Clear Notifications
          _buildSettingsSection(
            title: 'Data Notifikasi',
            icon: Icons.storage_outlined,
            children: [
              _buildListTile(
                title: 'Hapus Semua Notifikasi',
                subtitle: 'Hapus semua notifikasi yang tersimpan',
                trailing: Icon(Icons.delete_outline, color: Colors.red),
                onTap: () => _showClearDialog(),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF1A365D).withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Color(0xFF1A365D), size: 24),
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
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const SizedBox(height: 4),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF1A365D),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A365D),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
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
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: notification['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                notification['icon'],
                color: notification['color'],
                size: 24,
              ),
            ),
            
            const SizedBox(width: 15),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notification['message'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notification['time'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            
            // Unread indicator
            if (notification['isUnread'])
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(0xFF1A365D),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Lamaran Diterima!',
      'message': 'Selamat! Lamaran Anda untuk posisi Software Developer di PT. Teknologi Indonesia telah diterima.',
      'time': '2 jam yang lalu',
      'icon': Icons.check_circle,
      'color': Colors.green,
      'isUnread': true,
    },
    {
      'title': 'Lowongan Baru',
      'message': 'Ada 5 lowongan kerja baru yang sesuai dengan profil Anda.',
      'time': '1 hari yang lalu',
      'icon': Icons.work,
      'color': Colors.blue,
      'isUnread': true,
    },
    {
      'title': 'Reminder Lamaran',
      'message': 'Jangan lupa untuk melengkapi dokumen lamaran Anda.',
      'time': '2 hari yang lalu',
      'icon': Icons.schedule,
      'color': Colors.orange,
      'isUnread': false,
    },
    {
      'title': 'Weekly Digest',
      'message': 'Ringkasan mingguan: 12 lowongan baru, 3 update lamaran.',
      'time': '3 hari yang lalu',
      'icon': Icons.summarize,
      'color': Colors.purple,
      'isUnread': false,
    },
    {
      'title': 'Interview Invitation',
      'message': 'Anda diundang untuk interview di PT. Global Finance pada 20 Desember 2024.',
      'time': '4 hari yang lalu',
      'icon': Icons.event,
      'color': Colors.indigo,
      'isUnread': false,
    },
  ];

  void _showTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
    ).then((time) {
      if (time != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Waktu notifikasi diubah ke ${time.format(context)}')),
        );
      }
    });
  }

  void _showDayPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Pilih Hari Notifikasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: Text('Senin'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: Text('Selasa'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: Text('Rabu'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: Text('Kamis'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: Text('Jumat'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: Text('Sabtu'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: Text('Minggu'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Semua Notifikasi'),
        content: Text('Apakah Anda yakin ingin menghapus semua notifikasi? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Semua notifikasi berhasil dihapus')),
              );
            },
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
