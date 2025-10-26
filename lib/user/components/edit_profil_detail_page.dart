import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';

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
      
      _nikController.text = nik ?? '';
      _jenisKelamin = jenisKelamin;
      _noHpController.text = noHp ?? '';
      _tempatLahirController.text = tempatLahir ?? '';
      _alamatController.text = alamat ?? '';
      _namaBankController.text = namaBank ?? '';
      _noRekeningController.text = noRekening ?? '';
      _tentangSayaController.text = tentangSaya ?? '';

      if (tanggalLahir != null) {
        try {
          _selectedDate = DateTime.parse(tanggalLahir.toString());
          _tanggalLahirController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
        } catch (_) {}
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalLahirController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
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
      });

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (result['success'] == true) {
        await Provider.of<AuthService>(context, listen: false).refreshUser();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
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
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
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
      ),
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
