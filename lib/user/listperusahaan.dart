import 'package:flutter/material.dart';

class ListPerusahaanPage extends StatelessWidget {
  const ListPerusahaanPage({super.key});

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
              
              // "Cari Perusahaan" text
              Text(
                'Cari Perusahaan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Search bar dengan filter
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Color(0xFF1A365D).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Icon(
                        Icons.search,
                        color: Colors.grey[600],
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari nama perusahaan...',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF1A365D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.tune,
                        color: Color(0xFF1A365D),
                        size: 20,
                      ),
                    ),
                  ],
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
              'Daftar Perusahaan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A365D),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Company cards list
            Expanded(
              child: ListView.builder(
                itemCount: 8,
                itemBuilder: (context, index) {
                  return _buildCompanyCard(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyCard(int index) {
    final companies = [
      {
        'name': 'PT. Teknologi Indonesia',
        'industry': 'Teknologi',
        'location': 'Jakarta',
        'employees': '500+ Karyawan',
        'rating': '4.8',
      },
      {
        'name': 'CV. Digital Solutions',
        'industry': 'IT Services',
        'location': 'Bandung',
        'employees': '100+ Karyawan',
        'rating': '4.6',
      },
      {
        'name': 'PT. Inovasi Kreatif',
        'industry': 'Marketing',
        'location': 'Surabaya',
        'employees': '200+ Karyawan',
        'rating': '4.7',
      },
      {
        'name': 'PT. Global Finance',
        'industry': 'Keuangan',
        'location': 'Jakarta',
        'employees': '1000+ Karyawan',
        'rating': '4.9',
      },
      {
        'name': 'PT. Media Digital',
        'industry': 'Media',
        'location': 'Yogyakarta',
        'employees': '150+ Karyawan',
        'rating': '4.5',
      },
      {
        'name': 'CV. Startup Hub',
        'industry': 'Startup',
        'location': 'Bali',
        'employees': '50+ Karyawan',
        'rating': '4.4',
      },
      {
        'name': 'PT. E-commerce Plus',
        'industry': 'E-commerce',
        'location': 'Jakarta',
        'employees': '300+ Karyawan',
        'rating': '4.8',
      },
      {
        'name': 'PT. Konsultan Pro',
        'industry': 'Konsultan',
        'location': 'Medan',
        'employees': '80+ Karyawan',
        'rating': '4.6',
      },
    ];

    final company = companies[index % companies.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company info
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF1A365D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.business,
                  color: Color(0xFF1A365D),
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company['name']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A365D),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      company['industry']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.orange[600],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      company['rating']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 15),
          
          // Company details
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 5),
              Text(
                company['location']!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 20),
              Icon(
                Icons.people,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 5),
              Text(
                company['employees']!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 15),
          
          // View button
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
    );
  }
}
