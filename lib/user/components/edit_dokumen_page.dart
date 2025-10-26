import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'pdf_viewer_page.dart';

class EditDokumenPage extends StatefulWidget {
  const EditDokumenPage({super.key});

  @override
  State<EditDokumenPage> createState() => _EditDokumenPageState();
}

class _EditDokumenPageState extends State<EditDokumenPage> {
  final Map<String, String?> _filePaths = {};
  final Map<String, String?> _fileUrls = {};
  final Map<String, String?> _documentIds = {};
  bool _isLoading = false;
  bool _hasChanges = false;

  final Map<String, String> _dokumenTypes = {
    'cv': 'CV',
    'ktp': 'KTP',
    'ijazah': 'Ijazah/SKL',
    'transkrip': 'Transkrip Nilai',
    'sertifikat': 'Sertifikat',
    'portofolio': 'Portofolio',
    'lainnya': 'Dokumen Lainnya',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDocumentsWithLoading();
    });
  }

  Future<void> _loadDocuments() async {
    try {
      print('Loading documents...');
      final result = await ApiService.getDocuments();
      print('Documents result: $result');
      
      if (result['success'] == true && result['data'] != null) {
        final documents = result['data'] as List;
        print('Found ${documents.length} documents');
        for (var doc in documents) {
          final jenisDokumen = doc['jenis_dokumen'] as String?;
          if (jenisDokumen != null) {
            _fileUrls[jenisDokumen] = doc['file_url'] as String?;
            _documentIds[jenisDokumen] = doc['id']?.toString();
            print('Loaded document: $jenisDokumen -> ${doc['file_url']}');
          }
        }
        setState(() {});
      } else {
        print('Failed to load documents: ${result['message']}');
      }
    } catch (e) {
      print('Error loading documents: $e');
    }
  }

  Future<void> _loadDocumentsWithLoading() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _loadDocuments();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadFile(String jenisDokumen) async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (res != null && res.files.single.path != null) {
        setState(() {
          _filePaths[jenisDokumen] = res.files.single.path;
          _hasChanges = true;
        });

        // Upload file
        await _uploadFile(jenisDokumen, res.files.single.path!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadFile(String jenisDokumen, String filePath) async {
    try {
      print('Uploading file: $filePath for jenis: $jenisDokumen');
      final result = await ApiService.uploadDocument(jenisDokumen, filePath);
      print('Upload result: $result');

      if (result['success'] == true) {
        setState(() {
          _filePaths.remove(jenisDokumen);
          _fileUrls[jenisDokumen] = result['data']['file_url'] as String?;
          _documentIds[jenisDokumen] = result['data']['id']?.toString();
          _hasChanges = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dokumen berhasil diunggah!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh the page to show updated data
        _loadDocuments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal mengunggah dokumen'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteFile(String jenisDokumen, String? documentId) async {
    if (documentId == null) return;

    try {
      final result = await ApiService.deleteDocument(documentId);

      if (result['success'] == true) {
        setState(() {
          _fileUrls.remove(jenisDokumen);
          _documentIds.remove(jenisDokumen);
          _hasChanges = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dokumen berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh the page to show updated data
        _loadDocuments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal menghapus dokumen'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Reload documents to ensure we have the latest state
      await _loadDocuments();
      
      setState(() {
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perubahan berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmation(String jenisDokumen, String? documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus dokumen ${_dokumenTypes[jenisDokumen]}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteFile(jenisDokumen, documentId);
              },
              child: Text(
                'Hapus',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _viewDocument(String jenisDokumen) {
    final fileUrl = _fileUrls[jenisDokumen];
    if (fileUrl == null || fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('URL dokumen tidak tersedia'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(
          url: fileUrl,
          title: _dokumenTypes[jenisDokumen] ?? 'Dokumen PDF',
        ),
      ),
    );
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
          'Edit Dokumen Pendukung',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveChanges,
              child: Text(
                'Simpan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Upload dokumen PDF (maks 5MB)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 20),
                    ..._dokumenTypes.entries.map((entry) => 
                      _buildDocumentCard(entry.key, entry.value)
                    ).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDocumentCard(String jenisDokumen, String label) {
    final hasFile = _filePaths[jenisDokumen] != null || _fileUrls[jenisDokumen] != null;
    
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Color(0xFF1A365D)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A365D),
                  ),
                ),
              ),
              if (_filePaths[jenisDokumen] != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'File dipilih',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else if (_fileUrls[jenisDokumen] != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Tersimpan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickAndUploadFile(jenisDokumen),
                  icon: Icon(Icons.cloud_upload_outlined),
                  label: Text(hasFile ? 'Ganti File' : 'Unggah PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF1A365D),
                    side: BorderSide(color: Color(0xFF1A365D)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              if (_fileUrls[jenisDokumen] != null) ...[
                SizedBox(width: 10),
                IconButton(
                  onPressed: () => _viewDocument(jenisDokumen),
                  icon: Icon(Icons.visibility),
                  color: Color(0xFF1A365D),
                  tooltip: 'Lihat dokumen',
                ),
                SizedBox(width: 5),
                IconButton(
                  onPressed: () {
                    _showDeleteConfirmation(jenisDokumen, _documentIds[jenisDokumen]);
                  },
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                  tooltip: 'Hapus dokumen',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

