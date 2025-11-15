import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailLamaranPage extends StatelessWidget {
  final Map<String, dynamic> application;

  const DetailLamaranPage({super.key, required this.application});

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
                      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
                      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute';
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

  String _formatGaji(dynamic min, dynamic max) {
    if (min == null && max == null) return 'Gaji tidak disebutkan';
    if (min == null) return 'Hingga ${_formatCurrency(max)}';
    if (max == null) return 'Mulai dari ${_formatCurrency(min)}';
    return '${_formatCurrency(min)} - ${_formatCurrency(max)}';
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '';
    final num = amount is int ? amount : (int.tryParse(amount.toString()) ?? 0);
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(num);
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'melamar':
      case 'pending':
        return 'Menunggu Review';
      case 'lolos':
        return 'Lolos Screening';
      case 'interview':
        return 'Tahap Interview';
      case 'diterima':
        return 'Diterima';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diterima':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      case 'lolos':
      case 'interview':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lowongan = application['lowongan'] as Map<String, dynamic>? ?? {};
    final mitra = (lowongan['mitra'] as Map<String, dynamic>?) ?? {};
    final status = (application['status'] ?? '').toString();
    final statusColor = _getStatusColor(status);
    final statusLabel = _getStatusLabel(status);

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
          'Detail Lamaran',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan status
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1A365D),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 2),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    lowongan['judul'] ?? 'Posisi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    mitra['nama_perusahaan'] ?? 'Perusahaan',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informasi Lamaran
                  _buildSection(
                    title: 'Informasi Lamaran',
                    icon: Icons.info_outline,
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.calendar_today,
                          label: 'Tanggal Melamar',
                          value: _formatDate(application['created_at']?.toString()),
                        ),
                        SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.access_time,
                          label: 'Waktu Melamar',
                          value: _formatRelativeTime(application['created_at']?.toString()),
                        ),
                        if (application['updated_at'] != null) ...[
                          SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.update,
                            label: 'Terakhir Diupdate',
                            value: _formatDateTime(application['updated_at']?.toString()),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Detail Lowongan
                  _buildSection(
                    title: 'Detail Lowongan',
                    icon: Icons.work_outline,
                    child: Column(
                      children: [
                        if (lowongan['deskripsi'] != null && lowongan['deskripsi'].toString().isNotEmpty) ...[
                          _buildInfoRow(
                            icon: Icons.description,
                            label: 'Deskripsi Pekerjaan',
                            value: null,
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Text(
                              lowongan['deskripsi'].toString(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                                height: 1.5,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                        if (lowongan['lokasi'] != null) ...[
                          _buildInfoRow(
                            icon: Icons.location_on,
                            label: 'Lokasi',
                            value: lowongan['lokasi'].toString(),
                          ),
                          SizedBox(height: 12),
                        ],
                        if (lowongan['gaji_min'] != null || lowongan['gaji_max'] != null) ...[
                          _buildInfoRow(
                            icon: Icons.attach_money,
                            label: 'Gaji',
                            value: _formatGaji(lowongan['gaji_min'], lowongan['gaji_max']),
                          ),
                          SizedBox(height: 12),
                        ],
                        if (lowongan['jenis_pekerjaan'] != null) ...[
                          _buildInfoRow(
                            icon: Icons.schedule,
                            label: 'Jenis Pekerjaan',
                            value: lowongan['jenis_pekerjaan'].toString(),
                          ),
                          SizedBox(height: 12),
                        ],
                        if (lowongan['jenjang_pendidikan'] != null) ...[
                          _buildInfoRow(
                            icon: Icons.school,
                            label: 'Jenjang Pendidikan',
                            value: lowongan['jenjang_pendidikan'].toString(),
                          ),
                          SizedBox(height: 12),
                        ],
                        if (lowongan['rincian_lowongan'] != null && lowongan['rincian_lowongan'].toString().isNotEmpty) ...[
                          _buildInfoRow(
                            icon: Icons.list_alt,
                            label: 'Rincian Lowongan',
                            value: null,
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Text(
                              lowongan['rincian_lowongan'].toString(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Informasi Perusahaan
                  _buildSection(
                    title: 'Informasi Perusahaan',
                    icon: Icons.business,
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.business_center,
                          label: 'Nama Perusahaan',
                          value: mitra['nama_perusahaan']?.toString() ?? '-',
                        ),
                        if (mitra['sektor'] != null) ...[
                          SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.category,
                            label: 'Sektor',
                            value: mitra['sektor'].toString(),
                          ),
                        ],
                        if (mitra['kontak'] != null) ...[
                          SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.phone,
                            label: 'Kontak',
                            value: mitra['kontak'].toString(),
                            onTap: () {
                              final phone = mitra['kontak'].toString().replaceAll(RegExp(r'[^\d+]'), '');
                              if (phone.isNotEmpty) {
                                launchUrl(Uri.parse('tel:$phone'));
                              }
                            },
                          ),
                        ],
                        if (mitra['tautan'] != null) ...[
                          SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.link,
                            label: 'Website',
                            value: mitra['tautan'].toString(),
                            onTap: () {
                              var url = mitra['tautan'].toString();
                              if (!url.startsWith('http://') && !url.startsWith('https://')) {
                                url = 'https://$url';
                              }
                              launchUrl(Uri.parse(url));
                            },
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Pesan dari Perusahaan
                  if (application['subject'] != null || application['message'] != null) ...[
                    SizedBox(height: 20),
                    _buildSection(
                      title: 'Pesan dari Perusahaan',
                      icon: Icons.email_outlined,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (application['subject'] != null && application['subject'].toString().isNotEmpty) ...[
                              Text(
                                application['subject'].toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                              SizedBox(height: 12),
                            ],
                            if (application['message'] != null && application['message'].toString().isNotEmpty) ...[
                              Text(
                                application['message'].toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 20),

                  // Action Buttons
                  if (status == 'diterima') ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.celebration, color: Colors.green[700], size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selamat!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Lamaran Anda diterima. Silakan hubungi perusahaan untuk langkah selanjutnya.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (status == 'ditolak') ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.red[700], size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lamaran Ditolak',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[700],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Terima kasih atas minat Anda. Silakan coba lowongan lain yang sesuai dengan kualifikasi Anda.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF1A365D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Color(0xFF1A365D), size: 20),
              ),
              SizedBox(width: 12),
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
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String? value,
    VoidCallback? onTap,
  }) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Color(0xFF1A365D)),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (value != null) ...[
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onTap != null)
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: row,
        ),
      );
    }

    return row;
  }
}

