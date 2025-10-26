import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/data_akademik.dart';

class EditAcademicInfoPage extends StatefulWidget {
  const EditAcademicInfoPage({super.key});

  @override
  State<EditAcademicInfoPage> createState() => _EditAcademicInfoPageState();
}

class _EditAcademicInfoPageState extends State<EditAcademicInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nimController = TextEditingController();
  final _programStudiController = TextEditingController();
  final _tahunMasukController = TextEditingController();
  final _tahunLulusController = TextEditingController();
  final _ipkController = TextEditingController();
  final _universitasController = TextEditingController();
  final _hardSkillController = TextEditingController();
  final _softSkillController = TextEditingController();

  DataAkademik? _academicData;
  bool _isLoading = true;

  @override
  void dispose() {
    _nimController.dispose();
    _programStudiController.dispose();
    _tahunMasukController.dispose();
    _tahunLulusController.dispose();
    _ipkController.dispose();
    _universitasController.dispose();
    _hardSkillController.dispose();
    _softSkillController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAcademicData();
    });
  }

  void _loadAcademicData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.getAcademicData();
      
      if (result['success'] == true && result['data'] != null) {
        _academicData = DataAkademik.fromJson(result['data']);
        _populateFields();
      }
    } catch (e) {
      print('Error loading academic data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateFields() {
    if (_academicData != null) {
      _nimController.text = _academicData!.nim ?? '';
      _programStudiController.text = _academicData!.programStudi ?? '';
      _tahunMasukController.text = _academicData!.tahunMasuk?.toString() ?? '';
      _tahunLulusController.text = _academicData!.tahunLulus?.toString() ?? '';
      _ipkController.text = _academicData!.ipk?.toString() ?? '';
      _universitasController.text = _academicData!.universitas ?? '';
      _hardSkillController.text = _academicData!.hardSkill ?? '';
      _softSkillController.text = _academicData!.softSkill ?? '';
    }
  }

  Future<void> _saveAcademicData() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final payload = {
        'nim': _nimController.text.trim().isEmpty ? null : _nimController.text.trim(),
        'program_studi': _programStudiController.text.trim().isEmpty ? null : _programStudiController.text.trim(),
        'tahun_masuk': _tahunMasukController.text.trim().isEmpty ? null : int.tryParse(_tahunMasukController.text.trim()),
        'tahun_lulus': _tahunLulusController.text.trim().isEmpty ? null : int.tryParse(_tahunLulusController.text.trim()),
        'ipk': _ipkController.text.trim().isEmpty ? null : double.tryParse(_ipkController.text.trim()),
        'universitas': _universitasController.text.trim().isEmpty ? null : _universitasController.text.trim(),
        'hard_skill': _hardSkillController.text.trim().isEmpty ? null : _hardSkillController.text.trim(),
        'soft_skill': _softSkillController.text.trim().isEmpty ? null : _softSkillController.text.trim(),
      };

      final result = await ApiService.updateAcademicData(payload);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (result['success'] == true) {
        await Provider.of<AuthService>(context, listen: false).refreshUser();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data akademik berhasil diperbarui!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memperbarui data akademik'),
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
          'Edit Informasi Akademik',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      _buildSectionTitle('Informasi Akademik'),
                      SizedBox(height: 10),
                      _buildTextField(
                        controller: _nimController,
                        label: 'NIM',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.text,
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      _buildTextField(
                        controller: _programStudiController,
                        label: 'Program Studi',
                        icon: Icons.school_outlined,
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      _buildTextField(
                        controller: _universitasController,
                        label: 'Universitas',
                        icon: Icons.account_balance_outlined,
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      
                      _buildSectionTitle('Periode Pendidikan'),
                      SizedBox(height: 10),
                      _buildTextField(
                        controller: _tahunMasukController,
                        label: 'Tahun Masuk',
                        icon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Wajib diisi';
                          final year = int.tryParse(v);
                          if (year == null) return 'Tahun tidak valid';
                          if (year < 1950 || year > DateTime.now().year) {
                            return 'Tahun harus antara 1950 dan ${DateTime.now().year}';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        controller: _tahunLulusController,
                        label: 'Tahun Lulus',
                        icon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Wajib diisi';
                          final year = int.tryParse(v);
                          if (year == null) return 'Tahun tidak valid';
                          if (year < 1950 || year > DateTime.now().year + 10) {
                            return 'Tahun harus antara 1950 dan ${DateTime.now().year + 10}';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        controller: _ipkController,
                        label: 'IPK',
                        icon: Icons.star_outline,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Wajib diisi';
                          final ipk = double.tryParse(v);
                          if (ipk == null) return 'IPK tidak valid';
                          if (ipk < 0 || ipk > 4.0) {
                            return 'IPK harus antara 0.00 dan 4.00';
                          }
                          return null;
                        },
                      ),
                      
                      _buildSectionTitle('Kemampuan'),
                      SizedBox(height: 10),
                      _buildTextField(
                        controller: _hardSkillController,
                        label: 'Hard Skill',
                        icon: Icons.build_outlined,
                        maxLines: 3,
                        hintText: 'Contoh: Java, Python, React, MySQL, dll.',
                      ),
                      _buildTextField(
                        controller: _softSkillController,
                        label: 'Soft Skill',
                        icon: Icons.people_outline,
                        maxLines: 3,
                        hintText: 'Contoh: Leadership, Communication, Teamwork, dll.',
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
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
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
          onTap: _saveAcademicData,
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
