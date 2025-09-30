import 'package:flutter/material.dart';

class LowonganTersimpanPage extends StatefulWidget {
  const LowonganTersimpanPage({super.key});

  @override
  State<LowonganTersimpanPage> createState() => _LowonganTersimpanPageState();
}

class _LowonganTersimpanPageState extends State<LowonganTersimpanPage> {
  List<Map<String, dynamic>> _savedJobs = [
    {
      'id': 1,
      'position': 'Software Developer',
      'company': 'PT. Teknologi Indonesia',
      'location': 'Jakarta',
      'salary': 'Rp 8-12 Juta',
      'type': 'Full Time',
      'savedDate': '2024-12-15',
      'isActive': true,
    },
    {
      'id': 2,
      'position': 'UI/UX Designer',
      'company': 'CV. Digital Solutions',
      'location': 'Bandung',
      'salary': 'Rp 6-10 Juta',
      'type': 'Full Time',
      'savedDate': '2024-12-14',
      'isActive': true,
    },
    {
      'id': 3,
      'position': 'Data Analyst',
      'company': 'PT. Inovasi Kreatif',
      'location': 'Surabaya',
      'salary': 'Rp 7-11 Juta',
      'type': 'Contract',
      'savedDate': '2024-12-13',
      'isActive': false,
    },
    {
      'id': 4,
      'position': 'Marketing Specialist',
      'company': 'PT. Global Finance',
      'location': 'Jakarta',
      'salary': 'Rp 5-9 Juta',
      'type': 'Full Time',
      'savedDate': '2024-12-12',
      'isActive': true,
    },
    {
      'id': 5,
      'position': 'Frontend Developer',
      'company': 'PT. Media Digital',
      'location': 'Yogyakarta',
      'salary': 'Rp 6-10 Juta',
      'type': 'Remote',
      'savedDate': '2024-12-11',
      'isActive': true,
    },
  ];

  String _selectedFilter = 'Semua';

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
                      color: Color(0xFF1A365D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _applyJob(job),
                        child: Center(
                          child: Text(
                            'Lamar Sekarang',
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

  void _removeJob(int jobId) {
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
              setState(() {
                _savedJobs.removeWhere((job) => job['id'] == jobId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lowongan berhasil dihapus')),
              );
            },
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _shareJob(Map<String, dynamic> job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Membagikan lowongan ${job['position']}...')),
    );
  }

  void _applyJob(Map<String, dynamic> job) {
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lamaran berhasil dikirim!')),
              );
            },
            child: Text('Lamar', style: TextStyle(color: Color(0xFF1A365D))),
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
