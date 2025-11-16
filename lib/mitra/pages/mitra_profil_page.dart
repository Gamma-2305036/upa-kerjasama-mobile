import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/page_transitions.dart';
import '../../services/auth_service.dart';
import '../../user/components/detail_perusahaan_page.dart';
import '../../services/api_service.dart';

class MitraProfilPage extends StatelessWidget {
  const MitraProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A365D), Color(0xFF4E4376)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer<AuthService>(
            builder: (context, auth, _) {
              final companyName = (auth.profile?.namaPerusahaan ?? 'Perusahaan Anda').toString();
              final email = auth.user?.email ?? 'admin@perusahaan.com';
              final logo = auth.profile?.logo;
              String? logoUrl;
              if (logo != null && logo.isNotEmpty) {
                if (logo.startsWith('http')) {
                  logoUrl = logo;
                } else {
                  logoUrl = '${ApiService.baseUrl.replaceFirst('/api', '')}/storage/$logo';
                }
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              logoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.business, color: Color(0xFF1A365D), size: 36);
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              },
                            ),
                          )
                        : const Icon(Icons.business, color: Color(0xFF1A365D), size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(companyName, 
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 6),
                        Text(email, 
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTile({required IconData icon, required String title, String? subtitle, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1A365D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.settings, color: Color(0xFF1A365D)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A365D))),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTile(icon: Icons.info_outline, title: 'Informasi Perusahaan', subtitle: 'Profil dan legalitas', onTap: () {
            PageTransitions.slideTo(context, const _InformasiPerusahaanPage());
          }),
          _buildTile(icon: Icons.edit_outlined, title: 'Edit Profil Perusahaan', subtitle: 'Ubah data perusahaan', onTap: () {
            PageTransitions.slideTo(context, const _EditProfilPerusahaanPage());
          }),
          _buildTile(icon: Icons.people_outline, title: 'Pengelola Akun', subtitle: 'Tim HR dan akses', onTap: () {
            PageTransitions.slideTo(context, const _PengelolaAkunPage());
          }),
          _buildTile(icon: Icons.lock_outline, title: 'Keamanan', subtitle: 'Ubah kata sandi', onTap: () {
            PageTransitions.slideTo(context, const _KeamananPage());
          }),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('Konfirmasi Keluar', style: TextStyle(color: Color(0xFF1A365D), fontWeight: FontWeight.w700)),
                      content: const Text('Apakah Anda yakin ingin keluar dari akun Mitra?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('Batal', style: TextStyle(color: Colors.grey[700])),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await Provider.of<AuthService>(context, listen: false).logout();
                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                            }
                          },
                          child: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  );
                },
                child: Center(
                  child: Text('Keluar', style: TextStyle(color: Colors.red[600], fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfilPerusahaanPage extends StatefulWidget {
  const _EditProfilPerusahaanPage({super.key});

  @override
  State<_EditProfilPerusahaanPage> createState() => _EditProfilPerusahaanPageState();
}

class _EditProfilPerusahaanPageState extends State<_EditProfilPerusahaanPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _website = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _about = TextEditingController();
  final TextEditingController _visi = TextEditingController();
  final TextEditingController _misi = TextEditingController();
  final TextEditingController _keunggulan = TextEditingController();
  
  String? _logoPath; // Local file path for selected image
  String? _logoUrl; // Current logo URL from server
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Prefill from current auth profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthService>(context, listen: false);
      _name.text = auth.profile?.namaPerusahaan ?? _name.text;
      _email.text = auth.user?.email ?? _email.text;
      _phone.text = auth.profile?.kontak ?? _phone.text;
      _website.text = auth.profile?.tautan ?? _website.text;
      _address.text = auth.profile?.alamat ?? _address.text;
      _about.text = (auth.profile != null && (auth.profile as dynamic).tentang != null)
          ? (auth.profile as dynamic).tentang
          : _about.text;
      // Optional fields
      _visi.text = (auth.profile as dynamic)?.visi ?? _visi.text;
      _misi.text = (auth.profile as dynamic)?.misi ?? _misi.text;
      final k = (auth.profile as dynamic)?.keunggulan;
      if (k != null) {
        if (k is List) {
          _keunggulan.text = k.join('\n');
        } else {
          _keunggulan.text = k.toString();
        }
      }
      
      // Load current logo URL
      final logo = auth.profile?.logo;
      if (logo != null && logo.isNotEmpty) {
        // If logo is a full URL, use it; otherwise construct it
        if (logo.toString().startsWith('http')) {
          setState(() {
            _logoUrl = logo.toString();
          });
        } else {
          setState(() {
            _logoUrl = '${ApiService.baseUrl.replaceFirst('/api', '')}/storage/$logo';
          });
        }
      }
    });
  }

  Future<void> _pickLogo() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _logoPath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A365D),
        elevation: 0.5,
        title: const Text('Edit Profil Perusahaan', style: TextStyle(color: Color(0xFF1A365D))),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Logo upload section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Logo Perusahaan', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A365D))),
                    const SizedBox(height: 8),
                    Center(
                      child: GestureDetector(
                        onTap: _pickLogo,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                          ),
                          child: _logoPath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    File(_logoPath!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : _logoUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.network(
                                        _logoUrl!,
                                        key: ValueKey(_logoUrl), // Force reload when URL changes
                                        fit: BoxFit.cover,
                                        cacheWidth: 240, // Cache optimization
                                        cacheHeight: 240,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.business, size: 50, color: Color(0xFF1A365D));
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const Center(child: CircularProgressIndicator());
                                        },
                                      ),
                                    )
                                  : const Icon(Icons.add_photo_alternate, size: 50, color: Color(0xFF1A365D)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: _pickLogo,
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: const Text('Pilih Logo'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF1A365D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                _input('Nama Perusahaan', _name, validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null),
                const SizedBox(height: 12),
                _input('Email', _email, keyboardType: TextInputType.emailAddress, readOnly: true, enabled: false),
                const SizedBox(height: 12),
                _input('No. Telepon', _phone, keyboardType: TextInputType.phone, validator: (v) => v == null || v.trim().length < 8 ? 'Nomor telepon tidak valid' : null),
                const SizedBox(height: 12),
                _input('Website', _website),
                const SizedBox(height: 12),
                _input('Alamat', _address, maxLines: 2),
                const SizedBox(height: 12),
                _input('Tentang Perusahaan', _about, maxLines: 4),
                const SizedBox(height: 12),
                _input('Visi', _visi, maxLines: 3),
                const SizedBox(height: 12),
                _input('Misi', _misi, maxLines: 3),
                const SizedBox(height: 12),
                _input('Keunggulan (pisahkan baris baru)', _keunggulan, maxLines: 4),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A365D), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final payload = {
                          'nama_perusahaan': _name.text.trim(),
                          'kontak': _phone.text.trim(),
                          'tautan': _website.text.trim(),
                          'alamat': _address.text.trim(),
                          'tentang': _about.text.trim(),
                          'visi': _visi.text.trim(),
                          'misi': _misi.text.trim(),
                          'keunggulan': _keunggulan.text
                              .split('\n')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList(),
                        };

                        final result = await ApiService.updateCompanyProfile(
                          payload,
                          logoPath: _logoPath,
                        );
                        if (!mounted) return;

                        if (result['success'] == true) {
                          // Update logo URL from response FIRST (before refresh) - this is immediate
                          final responseData = result['data'];
                          String? newLogoUrl;
                          if (responseData != null && responseData['logo_url'] != null) {
                            newLogoUrl = responseData['logo_url'].toString();
                          } else if (responseData != null && responseData['logo'] != null) {
                            // Construct URL from logo path
                            final logo = responseData['logo'];
                            newLogoUrl = logo.toString().startsWith('http')
                                ? logo.toString()
                                : '${ApiService.baseUrl.replaceFirst('/api', '')}/storage/$logo';
                          }
                          
                          // Immediately update UI with new logo URL if available
                          if (newLogoUrl != null && newLogoUrl.isNotEmpty) {
                            // Add timestamp query parameter to force reload if same URL
                            final timestamp = DateTime.now().millisecondsSinceEpoch;
                            final logoUrlWithTimestamp = newLogoUrl.contains('?')
                                ? '$newLogoUrl&_t=$timestamp'
                                : '$newLogoUrl?_t=$timestamp';
                            
                            setState(() {
                              _logoUrl = logoUrlWithTimestamp;
                              _logoPath = null; // Clear local path since it's now on server
                            });
                          }
                          
                          // Then refresh user/company profile in background for other screens
                          await Provider.of<AuthService>(context, listen: false).refreshUser();
                          if (!mounted) return;
                          
                          // Double-check logo from refreshed profile (in case response didn't have it)
                          if (newLogoUrl == null || newLogoUrl.isEmpty) {
                            final auth = Provider.of<AuthService>(context, listen: false);
                            final updatedLogo = auth.profile?.logo;
                            if (updatedLogo != null && updatedLogo.isNotEmpty) {
                              final profileLogoUrl = updatedLogo.toString().startsWith('http')
                                  ? updatedLogo.toString()
                                  : '${ApiService.baseUrl.replaceFirst('/api', '')}/storage/$updatedLogo';
                              if (profileLogoUrl != _logoUrl) {
                                setState(() {
                                  _logoUrl = profileLogoUrl;
                                });
                              }
                            }
                          }
                          
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil perusahaan berhasil disimpan')));
                          // Don't close immediately, let user see the updated logo
                          // Navigator.pop(context); // close editor and show refreshed profile immediately
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Gagal menyimpan'), backgroundColor: Colors.red));
                        }
                      }
                    },
                    child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller, {TextInputType? keyboardType, int maxLines = 1, String? Function(String?)? validator, bool readOnly = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A365D))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            readOnly: readOnly,
            enabled: enabled,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _InformasiPerusahaanPage extends StatelessWidget {
  const _InformasiPerusahaanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A365D),
        elevation: 0.5,
        title: const Text('Informasi Perusahaan', style: TextStyle(color: Color(0xFF1A365D))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Consumer<AuthService>(
          builder: (context, auth, _) {
            final nama = auth.profile?.namaPerusahaan ?? '-';
            final email = auth.user?.email ?? '-';
            final alamat = auth.profile?.alamat ?? '-';
            return Column(
              children: [
                _ReadOnlyRow(title: 'Nama', value: nama),
                const SizedBox(height: 10),
                _ReadOnlyRow(title: 'Email', value: email),
                const SizedBox(height: 10),
                _ReadOnlyRow(title: 'Alamat', value: alamat),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PengelolaAkunPage extends StatelessWidget {
  const _PengelolaAkunPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A365D),
        elevation: 0.5,
        title: const Text('Pengelola Akun', style: TextStyle(color: Color(0xFF1A365D))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.separated(
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: const Color(0xFF1A365D).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.person, color: Color(0xFF1A365D)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('HR Admin', style: TextStyle(fontWeight: FontWeight.w600))),
                  Text('Admin', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _KeamananPage extends StatefulWidget {
  const _KeamananPage({super.key});

  @override
  State<_KeamananPage> createState() => _KeamananPageState();
}

class _KeamananPageState extends State<_KeamananPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _current = TextEditingController();
  final TextEditingController _new = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A365D),
        elevation: 0.5,
        title: const Text('Keamanan', style: TextStyle(color: Color(0xFF1A365D))),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _passwordInput(label: 'Kata sandi saat ini', controller: _current, obscure: !_showCurrent, toggle: () => setState(() => _showCurrent = !_showCurrent), validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null),
                const SizedBox(height: 12),
                _passwordInput(label: 'Kata sandi baru', controller: _new, obscure: !_showNew, toggle: () => setState(() => _showNew = !_showNew), validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null),
                const SizedBox(height: 12),
                _passwordInput(label: 'Ulangi kata sandi baru', controller: _confirm, obscure: !_showConfirm, toggle: () => setState(() => _showConfirm = !_showConfirm), validator: (v) => (v != _new.text) ? 'Tidak cocok' : null),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A365D), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kata sandi berhasil diubah')));
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordInput({required String label, required TextEditingController controller, required bool obscure, required VoidCallback toggle, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A365D))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            validator: validator,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF1A365D)),
                onPressed: toggle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  final String title;
  final String value;
  const _ReadOnlyRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(color: Colors.grey[600]))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}


