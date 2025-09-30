import 'package:flutter/material.dart';
import '../components/detail_lowongan_page.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header dengan gradient
          _buildHeader(),
          
          // Main content area
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // "Untuk Kamu" text
              Text(
                'Untuk Kamu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Search bar
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari lowongan kerja...',
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Lowongan Terbaru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A365D),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Cards list
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return _buildJobCard(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, int index) {
    final jobs = [
      {
        'position': 'Software Developer',
        'company': 'PT. Teknologi Indonesia',
        'location': 'Jakarta',
        'salary': 'Rp 8-12 Juta',
        'type': 'Full Time',
        'posted': '2 hari yang lalu',
        'applicants': '45 pelamar',
      },
      {
        'position': 'UI/UX Designer',
        'company': 'CV. Digital Solutions',
        'location': 'Bandung',
        'salary': 'Rp 6-10 Juta',
        'type': 'Full Time',
        'posted': '1 hari yang lalu',
        'applicants': '23 pelamar',
      },
      {
        'position': 'Data Analyst',
        'company': 'PT. Inovasi Kreatif',
        'location': 'Surabaya',
        'salary': 'Rp 7-11 Juta',
        'type': 'Contract',
        'posted': '3 hari yang lalu',
        'applicants': '18 pelamar',
      },
      {
        'position': 'Marketing Specialist',
        'company': 'PT. Global Finance',
        'location': 'Jakarta',
        'salary': 'Rp 5-9 Juta',
        'type': 'Full Time',
        'posted': '4 hari yang lalu',
        'applicants': '32 pelamar',
      },
      {
        'position': 'Frontend Developer',
        'company': 'PT. Media Digital',
        'location': 'Yogyakarta',
        'salary': 'Rp 6-10 Juta',
        'type': 'Remote',
        'posted': '5 hari yang lalu',
        'applicants': '28 pelamar',
      },
    ];

    final job = jobs[index % jobs.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailLowonganPage(jobData: job),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company info
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.business,
                        color: Colors.grey[600],
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['position']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A365D),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            job['company']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 15),
                
                // Job details
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      job['location']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      job['salary']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 15),
                
                // Apply button
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF1A365D),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Lihat Detail',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
