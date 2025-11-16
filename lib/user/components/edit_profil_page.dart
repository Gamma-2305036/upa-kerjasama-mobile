import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/page_transitions.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import 'edit_profil_detail_page.dart';
import 'edit_academic_info_page.dart';
import 'edit_keluarga_page.dart';
import 'edit_dokumen_page.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _academicData;
  Map<String, dynamic>? _familyData;
  List<dynamic>? _documents;
  String? _cvUrl; // Store CV URL separately
  bool _loading = true;
  int _completionPercentage = 0;
  bool _isProfileComplete = false;
  bool _showEditButtons = false;
  final GlobalKey _completionCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getProfile();
      if (res['success'] == true && mounted) {
        final data = res['data'];
        final profile = data['profile'] ?? data['alumni'] ?? {};
        
        // CV URL might be at data level, not profile level
        final cvUrl = data['cv_url'] ?? profile['cv_url'] ?? profile['file_cv'];
        
        // Add CV URL to profile if exists
        if (cvUrl != null && profile['cv_url'] == null) {
          profile['cv_url'] = cvUrl;
        }
        
        // Debug: print all data received
        print('📦 Raw API Response:');
        print('  - Profile keys: ${profile.keys.toList()}');
        print('  - Academic data: ${data['data_akademik']}');
        print('  - Family data: ${data['data_keluarga']}');
        print('  - Documents: ${data['dokumen_pendukung']}');
        print('  - CV URL: $cvUrl');
        
        setState(() {
          _profileData = profile;
          _academicData = data['data_akademik'];
          _familyData = data['data_keluarga'];
          _documents = data['dokumen_pendukung'] ?? [];
          _cvUrl = cvUrl?.toString();
          _calculateCompletion();
        });
      } else {
        print('❌ API Response failed: ${res['message']}');
      }
    } catch (e) {
      print('❌ Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _calculateCompletion() {
    print('\n🔍 ========== CALCULATING PROFILE COMPLETION ==========');
    
    // Hitung berdasarkan field individual dengan bobot per section
    double totalWeight = 0.0;
    double completedWeight = 0.0;
    
    // 1. Check Detail Profile (25% total, 7 field profile saja - CV tidak termasuk di sini)
    final profile = _profileData ?? {};
    const double profileSectionWeight = 25.0; // 25% dari total
    const int totalProfileFields = 7; // 7 field profile (CV tidak termasuk)
    
    final profileRequiredFields = [
      'nim', 'nik', 'no_hp', 'tempat_lahir', 
      'tanggal_lahir', 'jenis_kelamin', 'alamat'
    ];
    
    int profileCompleted = 0;
    print('\n📋 Section 1: Detail Profile');
    for (var field in profileRequiredFields) {
      final value = profile[field];
      final isValid = value != null && value.toString().trim().isNotEmpty && value.toString().trim() != 'null';
      if (isValid) {
        profileCompleted++;
        print('  ✅ $field: ${value.toString().substring(0, value.toString().length > 20 ? 20 : value.toString().length)}...');
      } else {
        print('  ❌ $field: EMPTY or NULL');
      }
    }
    
    // CV tidak dihitung di Section 1, karena CV masuk ke dokumen pendukung
    double profileSectionPercentage = (profileCompleted / totalProfileFields) * profileSectionWeight;
    totalWeight += profileSectionWeight;
    completedWeight += profileSectionPercentage;
    
    print('  Section 1 Progress: $profileCompleted/$totalProfileFields fields (${((profileCompleted / totalProfileFields) * 100).toStringAsFixed(1)}%)');
    print('  Section 1 Weight: ${profileSectionPercentage.toStringAsFixed(2)}% / $profileSectionWeight%');
    print('  Note: CV dihitung sebagai bagian dari dokumen pendukung, bukan di sini');

    // 2. Check Informasi Akademik (25% total, 5 fields)
    final academic = _academicData ?? {};
    const double academicSectionWeight = 25.0; // 25% dari total
    
    print('\n📚 Section 2: Informasi Akademik');
    print('  Academic data: $academic');
    
    final academicRequiredFields = ['program_studi', 'universitas', 'tahun_masuk', 'tahun_lulus', 'ipk'];
    
    int academicCompleted = 0;
    for (var field in academicRequiredFields) {
      final value = academic[field];
      final isValid = value != null && 
          value.toString().trim().isNotEmpty && 
          value.toString().trim() != 'null' &&
          (field != 'ipk' || (value is num && value > 0));
      if (isValid) {
        academicCompleted++;
        print('  ✅ $field: $value');
      } else {
        print('  ❌ $field: EMPTY or NULL or 0');
      }
    }
    
    double academicSectionPercentage = (academicCompleted / academicRequiredFields.length) * academicSectionWeight;
    totalWeight += academicSectionWeight;
    completedWeight += academicSectionPercentage;
    
    print('  Section 2 Progress: $academicCompleted/${academicRequiredFields.length} fields (${((academicCompleted / academicRequiredFields.length) * 100).toStringAsFixed(1)}%)');
    print('  Section 2 Weight: ${academicSectionPercentage.toStringAsFixed(2)}% / $academicSectionWeight%');

    // 3. Check Data Keluarga (25% total, 4 fields)
    final family = _familyData ?? {};
    const double familySectionWeight = 25.0; // 25% dari total
    
    print('\n👨‍👩‍👧 Section 3: Data Keluarga');
    print('  Family data: $family');
    
    final familyRequiredFields = ['nama_ayah', 'pekerjaan_ayah', 'nama_ibu', 'pekerjaan_ibu'];
    
    int familyCompleted = 0;
    for (var field in familyRequiredFields) {
      final value = family[field];
      final isValid = value != null && value.toString().trim().isNotEmpty && value.toString().trim() != 'null';
      if (isValid) {
        familyCompleted++;
        print('  ✅ $field: ${value.toString().substring(0, value.toString().length > 20 ? 20 : value.toString().length)}...');
      } else {
        print('  ❌ $field: EMPTY or NULL');
      }
    }
    
    double familySectionPercentage = (familyCompleted / familyRequiredFields.length) * familySectionWeight;
    totalWeight += familySectionWeight;
    completedWeight += familySectionPercentage;
    
    print('  Section 3 Progress: $familyCompleted/${familyRequiredFields.length} fields (${((familyCompleted / familyRequiredFields.length) * 100).toStringAsFixed(1)}%)');
    print('  Section 3 Weight: ${familySectionPercentage.toStringAsFixed(2)}% / $familySectionWeight%');

    // 4. Check Dokumen Pendukung (25% total)
    // CV termasuk di sini sebagai dokumen pendukung dengan jenis_dokumen = 'cv'
    const double documentsSectionWeight = 25.0; // 25% dari total
    
    print('\n📄 Section 4: Dokumen Pendukung');
    print('  Documents: $_documents');
    print('  Documents count: ${_documents?.length ?? 0}');
    
    // Cek apakah ada CV di dokumen pendukung
    bool hasCvInDocuments = false;
    if (_documents != null && _documents!.isNotEmpty) {
      for (var doc in _documents!) {
        final jenisDokumen = doc['jenis_dokumen']?.toString().toLowerCase() ?? 
                            doc['tipe_dokumen']?.toString().toLowerCase() ?? '';
        if (jenisDokumen == 'cv') {
          hasCvInDocuments = true;
          print('  ✅ CV ditemukan di dokumen pendukung');
          break;
        }
      }
    }
    
    // Cek juga CV dari profile/file_cv (untuk backward compatibility)
    final hasCvFromProfile = (_cvUrl != null && _cvUrl!.trim().isNotEmpty && _cvUrl!.trim() != 'null') ||
                            (profile['cv_url'] != null && profile['cv_url'].toString().trim().isNotEmpty && profile['cv_url'].toString().trim() != 'null') ||
                            (profile['file_cv'] != null && profile['file_cv'].toString().trim().isNotEmpty && profile['file_cv'].toString().trim() != 'null');
    
    // Dokumen lengkap jika ada minimal 1 dokumen (termasuk CV)
    bool isDocumentsComplete = _documents != null && _documents!.isNotEmpty;
    
    // Jika ada CV dari profile tapi belum ada di dokumen pendukung, tetap dianggap ada dokumen
    if (hasCvFromProfile && !hasCvInDocuments) {
      print('  ℹ️ CV ditemukan di profile/file_cv (backward compatibility)');
      isDocumentsComplete = true; // Tetap dianggap lengkap jika ada CV di profile
    }
    
    double documentsSectionPercentage = isDocumentsComplete ? documentsSectionWeight : 0.0;
    totalWeight += documentsSectionWeight;
    completedWeight += documentsSectionPercentage;
    
    print('  Section 4 Progress: ${isDocumentsComplete ? 1 : 0}/1 (minimal 1 dokumen, termasuk CV)');
    print('  Section 4 Weight: ${documentsSectionPercentage.toStringAsFixed(2)}% / $documentsSectionWeight%');

    // Calculate final percentage
    final percentage = totalWeight > 0 ? ((completedWeight / totalWeight) * 100).round() : 0;
    
    print('\n📊 ========== RESULT ==========');
    print('  Total Weight: ${totalWeight.toStringAsFixed(2)}%');
    print('  Completed Weight: ${completedWeight.toStringAsFixed(2)}%');
    print('  Completion Percentage: $percentage%');
    print('  Profile Complete (>=80%): ${percentage >= 80}');
    print('================================\n');
    
    setState(() {
      _completionPercentage = percentage;
      _isProfileComplete = percentage >= 80; // Profile dianggap lengkap jika >= 80%
    });
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
          'Edit Profil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF1A365D)))
          : RefreshIndicator(
              onRefresh: _loadProfileData,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header dengan foto profil
                    _buildHeader(),
                    
                    // Profile completion indicator
                    _buildCompletionCard(),
                    
                    // Form edit profil
                    _buildForm(),
                  ],
                ),
              ),
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
      child: Center(
        child: Consumer<AuthService>(
          builder: (context, authService, child) {
            // Get foto profil from profile data
            final profile = _profileData;
            String? fotoProfilUrl;
            
            if (profile != null) {
              String? fotoProfil;
              
              // Access as Map
              if (profile is Map) {
                fotoProfil = (profile['foto_profil_url'] ?? profile['foto_profil'])?.toString();
              } else {
                // Try to access as AlumniProfile model
                try {
                  fotoProfil = (profile as dynamic)?.fotoProfil?.toString();
                } catch (e) {
                  // Ignore if not available
                }
              }
              
              if (fotoProfil != null && fotoProfil.isNotEmpty) {
                if (fotoProfil.startsWith('http')) {
                  fotoProfilUrl = fotoProfil;
                } else {
                  fotoProfilUrl = '${ApiService.baseUrl.replaceFirst('/api', '')}/storage/$fotoProfil';
                }
              }
            }
            
            // Get user name
            final userName = authService.user?.name ?? 'Alumni';
            
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: ClipOval(
                    child: fotoProfilUrl != null && fotoProfilUrl.isNotEmpty
                        ? Image.network(
                            fotoProfilUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 60,
                                color: Color(0xFF1A365D),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A365D)),
                                ),
                              );
                            },
                          )
                        : Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF1A365D),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      key: _completionCardKey,
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          // Stars indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              // Bintang 1: >= 0%, Bintang 2: >= 50%, Bintang 3: >= 80%
              final thresholds = [0, 50, 80];
              final filled = _completionPercentage >= thresholds[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  filled ? Icons.star : Icons.star_border,
                  color: filled ? Colors.amber : Colors.grey[300],
                  size: 32,
                ),
              );
            }),
          ),
          
          const SizedBox(height: 16),
          
          // Message
          Text(
            'Lengkapi profilmu sekarang agar siap dilihat HRD.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kelengkapan Profil',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                  Text(
                    '$_completionPercentage%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _isProfileComplete ? Colors.green : Color(0xFF1A365D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _completionPercentage / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isProfileComplete ? Colors.green : Color(0xFF1A365D),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _showEditButtons = !_showEditButtons;
                });
                // Scroll to buttons if showing
                if (_showEditButtons) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Scrollable.ensureVisible(
                      _completionCardKey.currentContext!,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                }
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Color(0xFF1A365D), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isProfileComplete ? 'EDIT PROFIL' : 'LENGKAPI PROFIL',
                style: TextStyle(
                  color: Color(0xFF1A365D),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          
          if (_isProfileComplete) ...[
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Profil siap untuk melamar',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildForm() {
    // Only show edit buttons if showEditButtons is true
    if (!_showEditButtons) {
      return SizedBox.shrink();
    }

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
              
              // Card Edit Detail Profil
              InkWell(
                onTap: () async {
                  await PageTransitions.slideTo(
                    context,
                    const EditProfilDetailPage(),
                  );
                  // Always refresh when returning from edit page
                  _loadProfileData();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1A365D).withOpacity(0.05),
                        Color(0xFF4E4376).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color(0xFF1A365D).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon Container
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF1A365D),
                              Color(0xFF4E4376),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Text Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Detail Profil Lengkap',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A365D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kelola informasi pribadi lengkap',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xFF1A365D).withOpacity(0.5),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Card Edit Informasi Akademik
              InkWell(
                onTap: () async {
                  await PageTransitions.slideTo(
                    context,
                    const EditAcademicInfoPage(),
                  );
                  // Always refresh when returning from edit page
                  _loadProfileData();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1A365D).withOpacity(0.05),
                        Color(0xFF4E4376).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color(0xFF1A365D).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon Container
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF1A365D),
                              Color(0xFF4E4376),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.school_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Text Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Informasi Akademik',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A365D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kelola data akademik lengkap',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xFF1A365D).withOpacity(0.5),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Card Edit Data Keluarga
              InkWell(
                onTap: () async {
                  await PageTransitions.slideTo(
                    context,
                    const EditKeluargaPage(),
                  );
                  // Always refresh when returning from edit page
                  _loadProfileData();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1A365D).withOpacity(0.05),
                        Color(0xFF4E4376).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color(0xFF1A365D).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon Container
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF1A365D),
                              Color(0xFF4E4376),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.family_restroom_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Text Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Data Keluarga',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A365D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kelola informasi keluarga lengkap',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xFF1A365D).withOpacity(0.5),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Card Edit Dokumen Pendukung
              InkWell(
                onTap: () async {
                  await PageTransitions.slideTo(
                    context,
                    const EditDokumenPage(),
                  );
                  // Always refresh when returning from edit page
                  _loadProfileData();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1A365D).withOpacity(0.05),
                        Color(0xFF4E4376).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color(0xFF1A365D).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon Container
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF1A365D),
                              Color(0xFF4E4376),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.attachment_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Text Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Dokumen Pendukung',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A365D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kelola dokumen lengkap (CV, KTP, Ijazah, dll)',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xFF1A365D).withOpacity(0.5),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A365D),
      ),
    );
  }
}
