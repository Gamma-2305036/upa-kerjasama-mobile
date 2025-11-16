import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilDetailPage extends StatefulWidget {
  const EditProfilDetailPage({super.key});

  @override
  State<EditProfilDetailPage> createState() => _EditProfilDetailPageState();
}

class _EditProfilDetailPageState extends State<EditProfilDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _alamatController = TextEditingController();
  final _namaBankController = TextEditingController();
  final _noRekeningController = TextEditingController();
  final _tentangSayaController = TextEditingController();

  String? _jenisKelamin;
  DateTime? _selectedDate;
  String? _fotoProfilPath; // Local file path
  String? _fotoProfilUrl; // Server URL
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _alamatController.dispose();
    _namaBankController.dispose();
    _noRekeningController.dispose();
    _tentangSayaController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  void _loadProfileData() {
    final auth = Provider.of<AuthService>(context, listen: false);
    _nameController.text = auth.user?.name ?? '';
    _emailController.text = auth.user?.email ?? '';

    final profile = auth.profile;
    if (profile != null) {
      // Access fields as dynamic to handle both Map and AlumniProfile model
      final dynamic p = profile;
      
      // Try to access as AlumniProfile model fields first
      String? nik = (p as dynamic)?.nik;
      String? jenisKelamin = (p as dynamic)?.jenisKelamin;
      String? noHp = (p as dynamic)?.noHp;
      String? tempatLahir = (p as dynamic)?.tempatLahir;
      String? tanggalLahir = (p as dynamic)?.tanggalLahir;
      String? alamat = (p as dynamic)?.alamat;
      String? namaBank = (p as dynamic)?.namaBank;
      String? noRekening = (p as dynamic)?.noRekening;
      String? tentangSaya = (p as dynamic)?.tentangSaya;
      String? fotoProfil = (p as dynamic)?.fotoProfil;
      
      // Fallback to Map access if model fields are null
      if (nik == null && p is Map) nik = p['nik']?.toString();
      if (jenisKelamin == null && p is Map) jenisKelamin = p['jenis_kelamin']?.toString();
      if (noHp == null && p is Map) noHp = p['no_hp']?.toString();
      if (tempatLahir == null && p is Map) tempatLahir = p['tempat_lahir']?.toString();
      if (tanggalLahir == null && p is Map) tanggalLahir = p['tanggal_lahir']?.toString();
      if (alamat == null && p is Map) alamat = p['alamat']?.toString();
      if (namaBank == null && p is Map) namaBank = p['nama_bank']?.toString();
      if (noRekening == null && p is Map) noRekening = p['no_rekening']?.toString();
      if (tentangSaya == null && p is Map) tentangSaya = p['tentang_saya']?.toString();
      if (fotoProfil == null && p is Map) fotoProfil = p['foto_profil']?.toString() ?? p['foto_profil_url']?.toString();
      
      // Load foto profil URL
      String? fotoProfilUrl;
      if (fotoProfil != null && fotoProfil.isNotEmpty) {
        if (fotoProfil.startsWith('http')) {
          fotoProfilUrl = fotoProfil;
        } else {
          fotoProfilUrl = '${ApiService.baseUrl.replaceFirst('/api', '')}/storage/$fotoProfil';
        }
      }
      
      setState(() {
        _nikController.text = nik ?? '';
        _jenisKelamin = jenisKelamin;
        _noHpController.text = noHp ?? '';
        _tempatLahirController.text = tempatLahir ?? '';
        _alamatController.text = alamat ?? '';
        _namaBankController.text = namaBank ?? '';
        _noRekeningController.text = noRekening ?? '';
        _tentangSayaController.text = tentangSaya ?? '';
        _fotoProfilUrl = fotoProfilUrl;

        if (tanggalLahir != null) {
          try {
            _selectedDate = DateTime.parse(tanggalLahir.toString());
            _tanggalLahirController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
          } catch (_) {}
        }
      });
    }
  }

  Future<void> _pickFotoProfil() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _fotoProfilPath = image.path;
          _fotoProfilUrl = null; // Clear URL when new image is selected
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    try {
      final DateTime initialDate = _selectedDate ?? DateTime.now().subtract(Duration(days: 365 * 25));
      
      final picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1950),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Color(0xFF1A365D),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );
      
      if (picked != null) {
        setState(() {
          _selectedDate = picked;
          _tanggalLahirController.text = DateFormat('yyyy-MM-dd').format(picked);
        });
      }
    } catch (e) {
      print('Error selecting date: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await ApiService.updateAlumniDetail({
        'name': _nameController.text.trim(),
        'nik': _nikController.text.trim(),
        'jenis_kelamin': _jenisKelamin,
        'email': _emailController.text.trim(),
        'tempat_lahir': _tempatLahirController.text.trim(),
        'tanggal_lahir': _selectedDate?.toIso8601String().split('T').first,
        'no_hp': _noHpController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'nama_bank': _namaBankController.text.trim(),
        'no_rekening': _noRekeningController.text.trim(),
        'tentang_saya': _tentangSayaController.text.trim(),
      }, fotoProfilPath: _fotoProfilPath);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (result['success'] == true) {
        // Update foto profil URL from response if available
        final responseData = result['data']?['profile'];
        if (responseData != null && responseData['foto_profil_url'] != null) {
          setState(() {
            _fotoProfilUrl = responseData['foto_profil_url'].toString();
            _fotoProfilPath = null; // Clear local path since it's now on server
          });
        } else if (responseData != null && responseData['foto_profil'] != null) {
          // Construct URL from foto profil path
          final fotoProfil = responseData['foto_profil'];
          setState(() {
            _fotoProfilUrl = fotoProfil.toString().startsWith('http')
                ? fotoProfil.toString()
                : '${ApiService.baseUrl.replaceFirst('/api', '')}/storage/$fotoProfil';
            _fotoProfilPath = null; // Clear local path since it's now on server
          });
        }
        
        await Provider.of<AuthService>(context, listen: false).refreshUser();
        if (!mounted) return;
        
        // Update foto profil URL from refreshed profile if not already set
        if (_fotoProfilUrl == null || _fotoProfilUrl!.isEmpty) {
          final auth = Provider.of<AuthService>(context, listen: false);
          final profile = auth.profile;
          if (profile != null) {
            final p = profile as dynamic;
            final fotoProfil = p?.fotoProfil ?? (p is Map ? p['foto_profil']?.toString() ?? p['foto_profil_url']?.toString() : null);
            if (fotoProfil != null && fotoProfil.isNotEmpty) {
              setState(() {
                _fotoProfilUrl = fotoProfil.toString().startsWith('http')
                    ? fotoProfil.toString()
                    : '${ApiService.baseUrl.replaceFirst('/api', '')}/storage/$fotoProfil';
              });
            }
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        if (mounted) Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memperbarui profil'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          'Edit Detail Profil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto Profil Section
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickFotoProfil,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                            border: Border.all(
                              color: Color(0xFF1A365D),
                              width: 3,
                            ),
                          ),
                          child: _fotoProfilPath != null
                              ? ClipOval(
                                  child: Image.file(
                                    File(_fotoProfilPath!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : _fotoProfilUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        _fotoProfilUrl!,
                                        fit: BoxFit.cover,
                                        key: ValueKey(_fotoProfilUrl), // Force reload when URL changes
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(Icons.person, size: 60, color: Color(0xFF1A365D));
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(child: CircularProgressIndicator());
                                        },
                                      ),
                                    )
                                  : Icon(Icons.add_photo_alternate, size: 60, color: Color(0xFF1A365D)),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: _pickFotoProfil,
                        icon: Icon(Icons.camera_alt, size: 18, color: Color(0xFF1A365D)),
                        label: Text(
                          'Pilih Foto Profil',
                          style: TextStyle(color: Color(0xFF1A365D)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                _buildSectionTitle('Informasi Personal'),
                SizedBox(height: 10),
                _buildTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline,
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                _buildTextField(
                  controller: _nikController,
                  label: 'NIK',
                  icon: Icons.credit_card_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                _buildDropdownField(
                  label: 'Jenis Kelamin',
                  icon: Icons.person_outline,
                  value: _jenisKelamin,
                  items: ['Laki-laki', 'Perempuan'],
                  onChanged: (value) => setState(() => _jenisKelamin = value),
                  validator: (v) => v == null ? 'Wajib dipilih' : null,
                ),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@') ? 'Email tidak valid' : null,
                ),
                _buildTextField(
                  controller: _noHpController,
                  label: 'No. Handphone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                
                _buildSectionTitle('Data Lahir'),
                SizedBox(height: 10),
                _buildTextField(
                  controller: _tempatLahirController,
                  label: 'Tempat Lahir',
                  icon: Icons.location_city_outlined,
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                _buildTextField(
                  controller: _tanggalLahirController,
                  label: 'Tanggal Lahir',
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (v) => v == null || v.isEmpty ? 'Wajib dipilih' : null,
                ),
                
                _buildSectionTitle('Alamat'),
                SizedBox(height: 10),
                _buildTextField(
                  controller: _alamatController,
                  label: 'Alamat Tempat Tinggal',
                  icon: Icons.location_on_outlined,
                  maxLines: 3,
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                
                _buildSectionTitle('Informasi Bank'),
                SizedBox(height: 10),
                _buildTextField(
                  controller: _namaBankController,
                  label: 'Nama Bank',
                  icon: Icons.account_balance_outlined,
                ),
                _buildTextField(
                  controller: _noRekeningController,
                  label: 'No. Rekening',
                  icon: Icons.credit_card_outlined,
                  keyboardType: TextInputType.number,
                ),
                
                _buildSectionTitle('Tentang Saya'),
                SizedBox(height: 10),
                _buildTextField(
                  controller: _tentangSayaController,
                  label: 'Deskripsi Diri',
                  icon: Icons.description_outlined,
                  maxLines: 5,
                ),
                
                SizedBox(height: 30),
                _buildSaveButton(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A365D),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    Widget textField = TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
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
        fillColor: readOnly ? Colors.grey[100] : Colors.grey[50],
      ),
    );
    
    // Wrap with GestureDetector if onTap is provided
    if (onTap != null && readOnly) {
      return Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: GestureDetector(
          onTap: onTap,
          child: textField,
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: textField,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[50],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
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

  Widget _buildSaveButton() {
    return Container(
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
          onTap: _saveProfile,
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
    );
  }
}
