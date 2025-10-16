import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/detail_perusahaan_page.dart';
import '../../services/company_service.dart';
import '../../models/company_model.dart';

class ListPerusahaanPage extends StatefulWidget {
  const ListPerusahaanPage({super.key});

  @override
  State<ListPerusahaanPage> createState() => _ListPerusahaanPageState();
}

class _ListPerusahaanPageState extends State<ListPerusahaanPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Load companies when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CompanyService>(context, listen: false).loadCompanies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
      height: 220,
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
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Title
              Text(
                'List Perusahaan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Temukan perusahaan impianmu',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Search bar
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _query = value;
                    });
                    // Search companies with debounce
                    Future.delayed(Duration(milliseconds: 500), () {
                      if (_query == value) {
                        Provider.of<CompanyService>(context, listen: false)
                            .searchCompanies(value);
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari perusahaan...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[400],
                      size: 24,
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
      child: Consumer<CompanyService>(
        builder: (context, companyService, child) {
          if (companyService.isLoading && companyService.companies.isEmpty) {
            return _buildLoadingState();
          }

          if (companyService.error != null && companyService.companies.isEmpty) {
            return _buildErrorState(companyService.error!);
          }

          if (companyService.companies.isEmpty) {
            return _buildEmptyState();
          }

          return _buildCompaniesList(companyService.companies);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF1A365D),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat data perusahaan...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi kesalahan',
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Provider.of<CompanyService>(context, listen: false).loadCompanies();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1A365D),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada perusahaan',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data perusahaan akan muncul di sini',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompaniesList(List<Company> companies) {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<CompanyService>(context, listen: false).refreshCompanies();
      },
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        itemCount: companies.length,
        itemBuilder: (context, index) {
          final company = companies[index];
          return _buildCompanyCard(company);
        },
      ),
    );
  }

  Widget _buildCompanyCard(Company company) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPerusahaanPage(companyData: company.toJson()),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Company logo
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFF1A365D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: company.logo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            company.logo!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.business,
                                color: Color(0xFF1A365D),
                                size: 30,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.business,
                          color: Color(0xFF1A365D),
                          size: 30,
                        ),
                ),
                
                const SizedBox(width: 16),
                
                // Company info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.namaPerusahaan,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A365D),
                        ),
                      ),
                      
                      if (company.sektor != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          company.sektor!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      
                      if (company.kontak != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              company.kontak!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      const SizedBox(height: 8),
                      
                      // Job count
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF1A365D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${company.lowongan.length} lowongan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1A365D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}