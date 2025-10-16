import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'pdf_viewer_page.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nimController = TextEditingController();
  final _prodiController = TextEditingController();
  final _angkatanController = TextEditingController();
  final _alamatController = TextEditingController();
  String? _cvPathLocal; // selected local pdf path
  String? _cvRemoteUrl; // saved cv url from profile

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nimController.dispose();
    _prodiController.dispose();
    _angkatanController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Load initial values from AuthService
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthService>(context, listen: false);
      _nameController.text = auth.user?.name ?? _nameController.text;
      _emailController.text = auth.user?.email ?? _emailController.text;

      // Attempt to fill from alumni profile if present
      final profile = auth.profile;
      try {
        _phoneController.text = profile?.noHp ?? _phoneController.text;
        _alamatController.text = profile?.alamat ?? _alamatController.text;
        // Academic prefill
        if (profile != null) {
          _nimController.text = profile?.nim ?? _nimController.text;
          // Prefer typed fields from model; fallback to map if backend returns raw array
          final dynamic programStudi = (profile as dynamic).programStudi ?? ((profile is Map) ? profile['program_studi'] : null);
          final dynamic angkatan = (profile as dynamic).angkatan ?? ((profile is Map) ? profile['angkatan'] : null);
          if (programStudi != null) _prodiController.text = programStudi.toString();
          if (angkatan != null) _angkatanController.text = angkatan.toString();
          // Persisted CV url for display
          final dynamic cv = (profile as dynamic).cvUrl ?? ((profile is Map) ? profile['cv_url'] : null);
          if (cv != null) setState(() { _cvRemoteUrl = cv.toString(); });
        }
      } catch (_) {}
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan foto profil
            _buildHeader(),
            
            // Form edit profil
            _buildForm(),
          ],
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Foto profil
            Stack(
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
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Color(0xFF1A365D),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Ubah Foto Profil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Informasi Pribadi
              _buildSectionTitle('Informasi Pribadi'),
              const SizedBox(height: 20),
              
              _buildTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama lengkap harus diisi';
                  }
                  return null;
                },
              ),
              
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email harus diisi';
                  }
                  if (!value.contains('@')) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              
              _buildTextField(
                controller: _phoneController,
                label: 'Nomor Telepon',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon harus diisi';
                  }
                  return null;
                },
              ),
              
              _buildTextField(
                controller: _alamatController,
                label: 'Alamat',
                icon: Icons.location_on_outlined,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat harus diisi';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 30),
              
              // Informasi Akademik
              _buildSectionTitle('Informasi Akademik'),
              const SizedBox(height: 20),
              
              _buildTextField(
                controller: _nimController,
                label: 'NIM',
                icon: Icons.badge_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'NIM harus diisi';
                  }
                  return null;
                },
              ),
              
              _buildTextField(
                controller: _prodiController,
                label: 'Program Studi',
                icon: Icons.school_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Program studi harus diisi';
                  }
                  return null;
                },
              ),
              
              _buildTextField(
                controller: _angkatanController,
                label: 'Angkatan',
                icon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Angkatan harus diisi';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 40),
              
              // Tombol Simpan
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
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        _saveProfile();
                      }
                    },
                    child: Center(
                      child: Text(
                        'Simpan Perubahan',
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
              
              const SizedBox(height: 20),
              // Upload CV (PDF only)
              _buildSectionTitle('Curriculum Vitae (PDF)'),
              const SizedBox(height: 12),
              _buildCvUploader(),
            ],
          ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xFF1A365D)),
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  void _saveProfile() {
    final payload = {
      'name': _nameController.text.trim(),
      'no_hp': _phoneController.text.trim(),
      'alamat': _alamatController.text.trim(),
      'nim': _nimController.text.trim(),
      'program_studi': _prodiController.text.trim(),
      'angkatan': _angkatanController.text.trim(),
    };

    ApiService.updateAlumniProfile(payload).then((result) async {
      if (!mounted) return;
      if (result['success'] == true) {
        // Refresh auth user/profile so header reflects latest data
        await Provider.of<AuthService>(context, listen: false).refreshUser();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memperbarui profil'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    });
  }

  Widget _buildCvUploader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Color(0xFF1A365D)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _cvPathLocal != null
                      ? _cvPathLocal!.split('/').last
                      : (_cvRemoteUrl != null ? 'CV tersimpan: ${_cvRemoteUrl!.split('/').last}' : 'Pilih file PDF (maks 5MB)'),
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
              TextButton(
                onPressed: _pickPdf,
                child: const Text('Pilih File'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_cvRemoteUrl != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: OutlinedButton.icon(
                onPressed: () => _openPdf(_cvRemoteUrl!),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Lihat CV Tersimpan'),
              ),
            ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A365D),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _cvPathLocal == null ? null : _uploadCv,
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Unggah CV'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPdf() async {
    try {
      final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (res != null && res.files.isNotEmpty) {
        setState(() {
          _cvPathLocal = res.files.single.path;
        });
      }
    } catch (_) {}
  }

  Future<void> _uploadCv() async {
    if (_cvPathLocal == null) return;
    final res = await ApiService.uploadAlumniCv(_cvPathLocal!);
    if (!mounted) return;
    if (res['success'] == true) {
      await Provider.of<AuthService>(context, listen: false).refreshUser();
      final auth = Provider.of<AuthService>(context, listen: false);
      final dynamic cv = (auth.profile as dynamic)?.cvUrl ?? ((auth.profile is Map) ? auth.profile['cv_url'] : null);
      setState(() { _cvRemoteUrl = cv?.toString(); _cvPathLocal = null; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CV berhasil diunggah'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Gagal mengunggah CV'), backgroundColor: Colors.red),
      );
    }
  }

  void _openPdf(String url) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PdfViewerPage(url: url, title: 'Curriculum Vitae')));
  }
}
