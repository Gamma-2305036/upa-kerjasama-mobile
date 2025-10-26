import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/data_keluarga.dart';

class EditKeluargaPage extends StatefulWidget {
  const EditKeluargaPage({super.key});

  @override
  State<EditKeluargaPage> createState() => _EditKeluargaPageState();
}

class _EditKeluargaPageState extends State<EditKeluargaPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaAyahController = TextEditingController();
  final _pekerjaanAyahController = TextEditingController();
  final _namaIbuController = TextEditingController();
  final _pekerjaanIbuController = TextEditingController();
  final _jumlahSaudaraController = TextEditingController();

  DataKeluarga? _familyData;
  bool _isLoading = true;

  @override
  void dispose() {
    _namaAyahController.dispose();
    _pekerjaanAyahController.dispose();
    _namaIbuController.dispose();
    _pekerjaanIbuController.dispose();
    _jumlahSaudaraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFamilyData();
    });
  }

  void _loadFamilyData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.getFamilyData();
      
      if (result['success'] == true && result['data'] != null) {
        _familyData = DataKeluarga.fromJson(result['data']);
        _populateFields();
      }
    } catch (e) {
      print('Error loading family data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateFields() {
    if (_familyData != null) {
      _namaAyahController.text = _familyData!.namaAyah ?? '';
      _pekerjaanAyahController.text = _familyData!.pekerjaanAyah ?? '';
      _namaIbuController.text = _familyData!.namaIbu ?? '';
      _pekerjaanIbuController.text = _familyData!.pekerjaanIbu ?? '';
      _jumlahSaudaraController.text = _familyData!.jumlahSaudara?.toString() ?? '';
    }
  }

  Future<void> _saveFamilyData() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final payload = {
        'nama_ayah': _namaAyahController.text.trim().isEmpty ? null : _namaAyahController.text.trim(),
        'pekerjaan_ayah': _pekerjaanAyahController.text.trim().isEmpty ? null : _pekerjaanAyahController.text.trim(),
        'nama_ibu': _namaIbuController.text.trim().isEmpty ? null : _namaIbuController.text.trim(),
        'pekerjaan_ibu': _pekerjaanIbuController.text.trim().isEmpty ? null : _pekerjaanIbuController.text.trim(),
        'jumlah_saudara': _jumlahSaudaraController.text.trim().isEmpty ? null : int.tryParse(_jumlahSaudaraController.text.trim()),
      };

      final result = await ApiService.updateFamilyData(payload);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (result['success'] == true) {
        // Refresh user data before closing
        await Provider.of<AuthService>(context, listen: false).refreshUser();
        
        // Close page to go back
        Navigator.pop(context);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data keluarga berhasil diperbarui!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memperbarui data keluarga'),
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
          'Edit Data Keluarga',
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
                      _buildSectionTitle('Data Ayah'),
                      SizedBox(height: 10),
                      _buildTextField(
                        controller: _namaAyahController,
                        label: 'Nama Ayah',
                        icon: Icons.person_outline,
                      ),
                      _buildTextField(
                        controller: _pekerjaanAyahController,
                        label: 'Pekerjaan Ayah',
                        icon: Icons.work_outline,
                      ),
                      
                      _buildSectionTitle('Data Ibu'),
                      SizedBox(height: 10),
                      _buildTextField(
                        controller: _namaIbuController,
                        label: 'Nama Ibu',
                        icon: Icons.person_outline,
                      ),
                      _buildTextField(
                        controller: _pekerjaanIbuController,
                        label: 'Pekerjaan Ibu',
                        icon: Icons.work_outline,
                      ),
                      
                      _buildSectionTitle('Informasi Keluarga'),
                      SizedBox(height: 10),
                      _buildTextField(
                        controller: _jumlahSaudaraController,
                        label: 'Jumlah Saudara',
                        icon: Icons.people_outline,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v != null && v.isNotEmpty) {
                            final val = int.tryParse(v);
                            if (val == null || val < 0) return 'Jumlah saudara harus angka positif';
                          }
                          return null;
                        },
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
          onTap: _saveFamilyData,
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

