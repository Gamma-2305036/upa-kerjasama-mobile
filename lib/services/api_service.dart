import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../config/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;
  static String? _token;

  // Initialize token from shared preferences
  static Future<void> initializeToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    print('API Service: Token initialized: $_token');
  }

  // Save token to shared preferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
  }

  // Remove token from shared preferences
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
  }

  // Get headers with authorization
  static Map<String, String> _getHeaders() {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  // Google Login
  static Future<Map<String, dynamic>> googleLogin({
    required String idToken,
    required String email,
    required String name,
    required String googleId,
    String? photoUrl,
    String? firebaseIdToken,
  }) async {
    try {
      print('📍 Google Login URL: $baseUrl/auth/google');
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/google'),
        headers: _getHeaders(),
        body: jsonEncode({
          'id_token': idToken,
          'email': email,
          'name': name,
          'google_id': googleId,
          'photo_url': photoUrl,
          if (firebaseIdToken != null) 'firebase_id_token': firebaseIdToken,
        }),
      )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        // Save token
        await saveToken(data['data']['token']);
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login dengan Google gagal',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan login Google timeout. Periksa koneksi Anda.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('📍 Login URL: $baseUrl/login');
      final response = await http
          .post(
        Uri.parse('$baseUrl/login'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        // Save token
        await saveToken(data['data']['token']);
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan login timeout. Periksa koneksi Anda.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/logout'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      
      // Remove token regardless of response
      await removeToken();
      
      return data;
    } on TimeoutException {
      // On timeout, still remove token and consider as logged out locally
      await removeToken();
      return {
        'success': false,
        'message': 'Permintaan logout timeout. Anda telah keluar dari perangkat.',
      };
    } catch (e) {
      // Remove token even if request fails
      await removeToken();
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/profile'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil profil',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan profil timeout. Coba lagi nanti.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Get jobs list
  static Future<Map<String, dynamic>> getJobs({String? search, String? lokasi}) async {
    try {
      String url = '$baseUrl/jobs';
      List<String> params = [];
      
      if (search != null && search.isNotEmpty) {
        params.add('search=${Uri.encodeComponent(search)}');
      }
      
      if (lokasi != null && lokasi.isNotEmpty) {
        params.add('lokasi=${Uri.encodeComponent(lokasi)}');
      }
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http
          .get(
        Uri.parse(url),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data lowongan',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan data lowongan timeout. Coba lagi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Get job detail
  static Future<Map<String, dynamic>> getJobDetail(String jobId) async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/jobs/$jobId'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil detail lowongan',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan detail lowongan timeout. Coba lagi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Apply to a job (alumni)
  static Future<Map<String, dynamic>> applyJob(String jobId) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/jobs/$jobId/apply'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) return data;
      return {'success': false, 'message': data['message'] ?? 'Gagal melamar'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Get saved jobs (alumni)
  static Future<Map<String, dynamic>> getSavedJobs() async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/saved-jobs'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) return data;
      return {'success': false, 'message': data['message'] ?? 'Gagal mengambil lowongan tersimpan'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Save a job (toggle save)
  static Future<Map<String, dynamic>> saveJob(String jobId) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/jobs/$jobId/save'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) return data;
      return {'success': false, 'message': data['message'] ?? 'Gagal menyimpan lowongan'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Remove a saved job
  static Future<Map<String, dynamic>> removeSavedJob(String jobId) async {
    try {
      final response = await http
          .delete(
        Uri.parse('$baseUrl/jobs/$jobId/save'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) return data;
      return {'success': false, 'message': data['message'] ?? 'Gagal menghapus lowongan tersimpan'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Fetch my applications (alumni)
  static Future<Map<String, dynamic>> getMyApplications({String? status}) async {
    try {
      String url = '$baseUrl/applications/my';
      if (status != null && status.isNotEmpty) {
        url += '?status=${Uri.encodeComponent(status)}';
      }
      final response = await http
          .get(
        Uri.parse(url),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) return data;
      return {'success': false, 'message': data['message'] ?? 'Gagal mengambil lamaran'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Get jobs owned by the logged-in mitra
  static Future<Map<String, dynamic>> getMyJobs({bool archived = false, String? search, int retryCount = 0}) async {
    const maxRetries = 2;
    try {
      String url = '$baseUrl/mitra/jobs';
      List<String> params = [];
      
      if (archived) {
        params.add('archived=true');
      }
      
      if (search != null && search.isNotEmpty) {
        params.add('search=${Uri.encodeComponent(search)}');
      }
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }
      final response = await http
          .get(
        Uri.parse(url),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 30)); // Increase timeout

      // Validate response body
      if (response.body.isEmpty) {
        if (retryCount < maxRetries) {
          await Future.delayed(const Duration(seconds: 1));
          return getMyJobs(archived: archived, search: search, retryCount: retryCount + 1);
        }
        return {
          'success': false,
          'message': 'Response kosong dari server',
        };
      }

      // Check if response body looks like valid JSON
      final body = response.body.trim();
      if (!body.startsWith('{') && !body.startsWith('[')) {
        if (retryCount < maxRetries) {
          await Future.delayed(const Duration(seconds: 1));
          return getMyJobs(archived: archived, search: search, retryCount: retryCount + 1);
        }
        return {
          'success': false,
          'message': 'Format response tidak valid',
        };
      }

      // Check if JSON is complete (ends with } or ])
      if (!body.endsWith('}') && !body.endsWith(']')) {
        if (retryCount < maxRetries) {
          await Future.delayed(const Duration(seconds: 1));
          return getMyJobs(archived: archived, search: search, retryCount: retryCount + 1);
        }
        return {
          'success': false,
          'message': 'Response JSON tidak lengkap. Silakan refresh halaman.',
        };
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(body) as Map<String, dynamic>;
      } on FormatException catch (e) {
        // Log untuk debugging
        print('JSON Parse Error: ${e.toString()}');
        print('Response length: ${body.length}');
        print('Response preview: ${body.substring(0, body.length > 500 ? 500 : body.length)}');
        
        // Retry jika masih ada kesempatan
        if (retryCount < maxRetries) {
          await Future.delayed(const Duration(seconds: 1));
          return getMyJobs(archived: archived, search: search, retryCount: retryCount + 1);
        }
        
        return {
          'success': false,
          'message': 'Gagal memparse data dari server. Silakan refresh halaman.',
        };
      }

      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data lowongan mitra',
        };
      }
    } on TimeoutException {
      if (retryCount < maxRetries) {
        await Future.delayed(const Duration(seconds: 1));
        return getMyJobs(archived: archived, search: search, retryCount: retryCount + 1);
      }
      return {
        'success': false,
        'message': 'Permintaan data lowongan mitra timeout. Coba lagi.',
      };
    } catch (e) {
      if (retryCount < maxRetries) {
        await Future.delayed(const Duration(seconds: 1));
        return getMyJobs(archived: archived, search: search, retryCount: retryCount + 1);
      }
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Create job (mitra)
  static Future<Map<String, dynamic>> createJob(Map<String, dynamic> payload) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/mitra/jobs'),
        headers: _getHeaders(),
        body: jsonEncode(payload),
      )
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) return data;
      return {'success': false, 'message': data['message'] ?? 'Gagal membuat lowongan'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Delete job (mitra)
  static Future<Map<String, dynamic>> deleteJob(String jobId) async {
    try {
      final response = await http
          .delete(
        Uri.parse('$baseUrl/mitra/jobs/$jobId'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) return data;
      return {'success': false, 'message': data['message'] ?? 'Gagal menghapus lowongan'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Update job (edit)
  static Future<Map<String, dynamic>> updateJob(String jobId, Map<String, dynamic> payload) async {
    try {
      final response = await http
          .put(
        Uri.parse('$baseUrl/mitra/jobs/$jobId'),
        headers: _getHeaders(),
        body: jsonEncode(payload),
      )
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) return data;
      return {'success': false, 'message': data['message'] ?? 'Gagal memperbarui lowongan'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Activate job
  static Future<Map<String, dynamic>> activateJob(String jobId) async {
    try {
      final response = await http
          .put(
        Uri.parse('$baseUrl/mitra/jobs/$jobId/activate'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) return data;
      return {'success': false, 'message': data['message'] ?? 'Gagal mengaktifkan lowongan'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Update job status/expiry
  static Future<Map<String, dynamic>> updateJobStatus(String jobId, {bool? statusAktif, String? tanggalSelesai}) async {
    try {
      final body = <String, dynamic>{};
      if (statusAktif != null) body['status_aktif'] = statusAktif;
      if (tanggalSelesai != null) body['tanggal_selesai'] = tanggalSelesai;
      final response = await http
          .put(
        Uri.parse('$baseUrl/mitra/jobs/$jobId/status'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) return data;
      return {'success': false, 'message': data['message'] ?? 'Gagal memperbarui status lowongan'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Archive job (mitra)
  static Future<Map<String, dynamic>> archiveJob(String jobId) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/mitra/jobs/$jobId/archive'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) return data;
      return {'success': false, 'message': data['message'] ?? 'Gagal mengarsipkan lowongan'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Unarchive job (mitra)
  static Future<Map<String, dynamic>> unarchiveJob(String jobId) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/mitra/jobs/$jobId/unarchive'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) return data;
      return {'success': false, 'message': data['message'] ?? 'Gagal mengembalikan lowongan dari arsip'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Mitra: get applicants for a specific job
  static Future<Map<String, dynamic>> getApplicantsForJob(String jobId, {bool archived = false, String? search}) async {
    try {
      String url = '$baseUrl/mitra/jobs/$jobId/applicants';
      List<String> params = [];
      
      if (archived) {
        params.add('archived=true');
      }
      
      if (search != null && search.isNotEmpty) {
        params.add('search=${Uri.encodeComponent(search)}');
      }
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }
      
      final response = await http
          .get(
        Uri.parse(url),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) return data;
      return {'success': false, 'message': data['message'] ?? 'Gagal mengambil pelamar'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Mitra: archive an application
  static Future<Map<String, dynamic>> archiveApplication(String applicationId) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/mitra/applications/$applicationId/archive'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) return data;
      return {'success': false, 'message': data['message'] ?? 'Gagal mengarsipkan lamaran'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Mitra: download all applicants data as ZIP
  static Future<Map<String, dynamic>> downloadApplicantsZip(String jobId, {String? status}) async {
    try {
      final uri = Uri.parse('$baseUrl/mitra/jobs/$jobId/download-applicants');
      final url = status != null && status.isNotEmpty
          ? uri.replace(queryParameters: {'status': status})
          : uri;
      // Create client with longer timeout and keep-alive for emulator compatibility
      final client = http.Client();
      http.Response? response;
      int retryCount = 0;
      const maxRetries = 3;
      
      while (retryCount < maxRetries) {
        try {
          response = await client
              .get(
            url,
            headers: _getHeaders(),
          )
              .timeout(const Duration(seconds: 600)); // 10 minutes timeout for large files
          
          // If successful, break out of retry loop
          if (response.statusCode == 200 || response.statusCode >= 400) {
            break;
          }
        } catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) {
            client.close();
            return {
              'success': false,
              'message': 'Gagal mengunduh setelah $maxRetries percobaan. Pastikan koneksi internet stabil.',
            };
          }
          // Wait before retry (exponential backoff)
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }
      }
      
      if (response == null) {
        client.close();
        return {
          'success': false,
          'message': 'Gagal mendapatkan response dari server',
        };
      }
      
      try {
        if (response.statusCode == 200) {
          // Check if response is a ZIP file
          final contentType = response.headers['content-type'] ?? '';
          final contentDisposition = response.headers['content-disposition'] ?? '';
        
          // Extract filename from content-disposition header if available
          String fileName = 'data_pelamar_$jobId.zip';
          if (contentDisposition.isNotEmpty) {
            // Try to extract filename from content-disposition header
            // Format: attachment; filename="filename.zip" or filename=filename.zip
            // Try with double quotes first
            final doubleQuoteMatch = RegExp(r'filename\*?="([^"]+)"').firstMatch(contentDisposition);
            if (doubleQuoteMatch != null && doubleQuoteMatch.groupCount >= 1) {
              final extractedName = doubleQuoteMatch.group(1);
              if (extractedName != null && extractedName.isNotEmpty) {
                fileName = extractedName.trim();
              }
            } else {
              // Try with single quotes
              final singleQuoteMatch = RegExp(r"filename\*?='([^']+)'").firstMatch(contentDisposition);
              if (singleQuoteMatch != null && singleQuoteMatch.groupCount >= 1) {
                final extractedName = singleQuoteMatch.group(1);
                if (extractedName != null && extractedName.isNotEmpty) {
                  fileName = extractedName.trim();
                }
              } else {
                // Try without quotes: filename=filename.zip
                final unquotedMatch = RegExp(r'filename\*?=([^;\n]+)').firstMatch(contentDisposition);
                if (unquotedMatch != null && unquotedMatch.groupCount >= 1) {
                  final extractedName = unquotedMatch.group(1);
                  if (extractedName != null && extractedName.isNotEmpty) {
                    fileName = extractedName.trim();
                  }
                }
              }
            }
          }
          
          if (contentType.contains('application/zip') || 
              contentType.contains('application/x-zip-compressed') ||
              contentType.contains('application/octet-stream') ||
              response.bodyBytes.length > 100) { // Assume it's a ZIP if it's a binary file
            // Save file to device
            final directory = await getApplicationDocumentsDirectory();
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final filePath = '${directory.path}/$fileName';
            final file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);
            
            return {
              'success': true,
              'filePath': filePath,
              'message': 'Data pelamar berhasil diunduh',
            };
          } else {
            // Try to parse as JSON error
            try {
              final data = jsonDecode(response.body);
              return {
                'success': false,
                'message': data['message'] ?? 'Gagal mengunduh data pelamar',
              };
            } catch (e) {
              return {
                'success': false,
                'message': 'Format file tidak valid',
              };
            }
          }
        } else {
          try {
            final data = jsonDecode(response.body);
            return {
              'success': false,
              'message': data['message'] ?? 'Gagal mengunduh data pelamar',
            };
          } catch (e) {
            return {
              'success': false,
              'message': 'Gagal mengunduh data pelamar (Status: ${response.statusCode})',
            };
          }
        }
      } finally {
        client.close();
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Mitra: unarchive an application
  static Future<Map<String, dynamic>> unarchiveApplication(String applicationId) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/mitra/applications/$applicationId/unarchive'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) return data;
      return {'success': false, 'message': data['message'] ?? 'Gagal mengembalikan lamaran dari arsip'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Mitra: update applicant status
  static Future<Map<String, dynamic>> updateApplicantStatus(
    String applicationId,
    String status, {
    String? subject,
    String? message,
  }) async {
    try {
      final Map<String, dynamic> payload = {'status': status};
      if (subject != null && subject.isNotEmpty) payload['subject'] = subject;
      if (message != null && message.isNotEmpty) payload['message'] = message;

      final response = await http
          .put(
        Uri.parse('$baseUrl/applications/$applicationId/status'),
        headers: _getHeaders(),
        body: jsonEncode(payload),
      )
          .timeout(const Duration(seconds: 15));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) return data;
      return {'success': false, 'message': data['message'] ?? 'Gagal memperbarui status pelamar'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Get alumni profile by user id (for mitra viewing applicant)
  static Future<Map<String, dynamic>> getAlumniProfileByUserId(String userId) async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/alumni/$userId'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) return data;
      return {'success': false, 'message': data['message'] ?? 'Gagal mengambil profil alumni'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Check if profile is complete (for application validation)
  static Future<Map<String, dynamic>> checkProfileCompletion() async {
    try {
      final res = await getProfile();
      if (res['success'] != true) {
        return {
          'success': false,
          'isComplete': false,
          'message': res['message'] ?? 'Gagal mengecek kelengkapan profil',
        };
      }

      final data = res['data'];
      final profile = data['profile'] ?? data['alumni'] ?? {};
      final academic = data['data_akademik'] ?? {};
      final family = data['data_keluarga'] ?? {};
      final documents = data['dokumen_pendukung'] ?? [];

      int completed = 0;
      int total = 0;
      List<String> missingFields = [];

      // Check profile data (6 required fields - CV tidak termasuk di sini, NIM ada di data akademik)
      final profileFields = [
        'nik', 'no_hp', 'tempat_lahir', 
        'tanggal_lahir', 'jenis_kelamin', 'alamat'
      ];
      total += profileFields.length;
      for (var field in profileFields) {
        final value = profile[field];
        if (value != null && value.toString().trim().isNotEmpty) {
          completed++;
        } else {
          missingFields.add(_getFieldLabel(field));
        }
      }

      // Check academic data (6 required fields termasuk NIM)
      final academicFields = ['nim', 'program_studi', 'universitas', 'tahun_masuk', 'tahun_lulus', 'ipk'];
      total += academicFields.length;
      for (var field in academicFields) {
        final value = academic[field];
        if (value != null && value.toString().trim().isNotEmpty) {
          completed++;
        } else {
          missingFields.add(_getFieldLabel(field));
        }
      }

      // Check family data (4 required fields)
      final familyFields = ['nama_ayah', 'pekerjaan_ayah', 'nama_ibu', 'pekerjaan_ibu'];
      total += familyFields.length;
      for (var field in familyFields) {
        final value = family[field];
        if (value != null && value.toString().trim().isNotEmpty) {
          completed++;
        } else {
          missingFields.add(_getFieldLabel(field));
        }
      }

      // Check documents - wajib per jenis dokumen
      final requiredDocs = [
        {'keys': ['cv'], 'label': 'CV'},
        {'keys': ['ktp'], 'label': 'KTP'},
        {'keys': ['ijazah', 'skl'], 'label': 'Ijazah/SKL'},
        {'keys': ['transkrip'], 'label': 'Transkrip Nilai'},
        {'keys': ['sertifikat'], 'label': 'Sertifikat'},
        {'keys': ['portofolio'], 'label': 'Portofolio'},
        {'keys': ['lain', 'dokumen lainnya'], 'label': 'Dokumen Lainnya'},
      ];
      
      bool docMatches(Map doc, List<String> keys) {
        final jenisDokumen = doc['jenis_dokumen']?.toString().toLowerCase() ??
            doc['tipe_dokumen']?.toString().toLowerCase() ?? '';
        return keys.any((k) => jenisDokumen.contains(k));
      }
      
      int docCompleted = 0;
      for (final req in requiredDocs) {
        final keys = (req['keys'] as List).cast<String>();
        final found = documents.any((doc) => docMatches((doc as Map), keys));
        if (found) {
          docCompleted++;
        } else {
          missingFields.add(req['label'] as String);
        }
      }
      
      total += requiredDocs.length;
      completed += docCompleted;

      final percentage = total > 0 ? ((completed / total) * 100).round() : 0;
      final isComplete = percentage >= 80;

      return {
        'success': true,
        'isComplete': isComplete,
        'percentage': percentage,
        'missingFields': missingFields,
        'message': isComplete 
            ? 'Profil sudah lengkap' 
            : 'Profil belum lengkap. Silakan lengkapi data yang masih kosong.',
      };
    } catch (e) {
      return {
        'success': false,
        'isComplete': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  static String _getFieldLabel(String field) {
    final labels = {
      'nim': 'NIM',
      'nik': 'NIK',
      'no_hp': 'No. HP',
      'tempat_lahir': 'Tempat Lahir',
      'tanggal_lahir': 'Tanggal Lahir',
      'jenis_kelamin': 'Jenis Kelamin',
      'alamat': 'Alamat',
      'cv_url': 'CV',
      'program_studi': 'Program Studi',
      'universitas': 'Universitas',
      'tahun_masuk': 'Tahun Masuk',
      'tahun_lulus': 'Tahun Lulus',
      'ipk': 'IPK',
      'nama_ayah': 'Nama Ayah',
      'pekerjaan_ayah': 'Pekerjaan Ayah',
      'nama_ibu': 'Nama Ibu',
      'pekerjaan_ibu': 'Pekerjaan Ibu',
    };
    return labels[field] ?? field;
  }

  // Get companies list
  static Future<Map<String, dynamic>> getCompanies({String? search}) async {
    try {
      String url = '$baseUrl/companies';
      
      if (search != null && search.isNotEmpty) {
        url += '?search=${Uri.encodeComponent(search)}';
      }

      final response = await http
          .get(
        Uri.parse(url),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data perusahaan',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan data perusahaan timeout. Coba lagi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Get company detail
  static Future<Map<String, dynamic>> getCompanyDetail(String companyId) async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/companies/$companyId'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil detail perusahaan',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan detail perusahaan timeout. Coba lagi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Update mitra company profile
  static Future<Map<String, dynamic>> updateCompanyProfile(Map<String, dynamic> payload, {String? logoPath}) async {
    try {
      // If logo is provided, use multipart request
      if (logoPath != null && logoPath.isNotEmpty) {
        final uri = Uri.parse('$baseUrl/mitra/company');
        final request = http.MultipartRequest('POST', uri);
        
        // Add headers (except content-type, let multipart set it)
        _getHeaders().forEach((k, v) {
          if (k.toLowerCase() != 'content-type') {
            request.headers[k] = v;
          }
        });
        
        // No need for method override, route already supports POST
        
        // Add text fields
        payload.forEach((key, value) {
          if (value != null && key != 'logo') {
            if (value is List) {
              // Handle array fields like keunggulan - send as JSON string
              // Always send as JSON array (even if empty), Laravel will handle it
              request.fields[key] = jsonEncode(value);
            } else {
              final stringValue = value.toString().trim();
              // Only send non-empty strings (for nullable fields)
              if (stringValue.isNotEmpty || key == 'nama_perusahaan') {
                request.fields[key] = stringValue;
              }
            }
          }
        });
        
        // Add logo file
        request.files.add(await http.MultipartFile.fromPath(
          'logo',
          logoPath,
          contentType: MediaType('image', 'jpeg'),
        ));
        
        final streamed = await request.send().timeout(const Duration(seconds: 20));
        final response = await http.Response.fromStream(streamed);
        final data = jsonDecode(response.body);
        
        if (response.statusCode == 200 && data['success'] == true) {
          return data;
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Gagal memperbarui profil perusahaan',
          };
        }
      } else {
        // No logo, use regular JSON request
        final response = await http
            .put(
          Uri.parse('$baseUrl/mitra/company'),
          headers: _getHeaders(),
          body: jsonEncode(payload),
        )
            .timeout(const Duration(seconds: 15));

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['success'] == true) {
          return data;
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Gagal memperbarui profil perusahaan',
          };
        }
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan update profil perusahaan timeout. Coba lagi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return _token != null;
  }

  // Update alumni profile (basic fields)
  static Future<Map<String, dynamic>> updateAlumniProfile(Map<String, dynamic> payload) async {
    try {
      final response = await http
          .put(
        Uri.parse('$baseUrl/alumni/profile'),
        headers: _getHeaders(),
        body: jsonEncode(payload),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memperbarui profil alumni',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan update profil alumni timeout. Coba lagi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Upload alumni CV (PDF)
  static Future<Map<String, dynamic>> uploadAlumniCv(String filePath) async {
    try {
      final uri = Uri.parse('$baseUrl/alumni/cv');
      final request = http.MultipartRequest('POST', uri);
      _getHeaders().forEach((k, v) {
        if (k.toLowerCase() != 'content-type') {
          request.headers[k] = v; // let multipart set its own content-type
        }
      });
      request.files.add(await http.MultipartFile.fromPath('cv', filePath, contentType: MediaType('application', 'pdf')));
      final streamed = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamed);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) return data;
      return {'success': false, 'message': data['message'] ?? 'Gagal mengunggah CV'};
    } on TimeoutException {
      return {'success': false, 'message': 'Permintaan unggah CV timeout. Coba lagi.'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Update alumni detail profile (comprehensive fields)
  static Future<Map<String, dynamic>> updateAlumniDetail(Map<String, dynamic> payload, {String? fotoProfilPath}) async {
    try {
      // If foto profil is provided, use multipart request
      if (fotoProfilPath != null && fotoProfilPath.isNotEmpty) {
        final uri = Uri.parse('$baseUrl/alumni/profile/detail');
        final request = http.MultipartRequest('POST', uri);
        
        // Add headers (except content-type, let multipart set it)
        _getHeaders().forEach((k, v) {
          if (k.toLowerCase() != 'content-type') {
            request.headers[k] = v;
          }
        });
        
        // Add text fields
        payload.forEach((key, value) {
          if (value != null && key != 'foto_profil') {
            final stringValue = value.toString().trim();
            if (stringValue.isNotEmpty || key == 'name' || key == 'email') {
              request.fields[key] = stringValue;
            }
          }
        });
        
        // Add foto profil file
        request.files.add(await http.MultipartFile.fromPath(
          'foto_profil',
          fotoProfilPath,
          contentType: MediaType('image', 'jpeg'),
        ));
        
        final streamed = await request.send().timeout(const Duration(seconds: 20));
        final response = await http.Response.fromStream(streamed);
        final data = jsonDecode(response.body);
        
        if (response.statusCode == 200 && data['success'] == true) {
          return data;
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Gagal memperbarui detail profil alumni',
          };
        }
      } else {
        // Regular JSON request if no foto profil
        final response = await http
            .put(
          Uri.parse('$baseUrl/alumni/profile/detail'),
          headers: _getHeaders(),
          body: jsonEncode(payload),
        )
            .timeout(const Duration(seconds: 15));

        final data = jsonDecode(response.body);
        if (response.statusCode == 200 && data['success'] == true) {
          return data;
        }
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memperbarui detail profil alumni',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan update detail profil alumni timeout. Coba lagi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Academic Data methods
  static Future<Map<String, dynamic>> getAcademicData() async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/academic-data'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengambil data akademik',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan data akademik timeout. Coba lagi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> createAcademicData(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/academic-data'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      )
          .timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201 && responseData['success'] == true) {
        return responseData;
      }
      return {
        'success': false,
        'message': responseData['message'] ?? 'Gagal membuat data akademik',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan buat data akademik timeout. Coba lagi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> updateAcademicData(Map<String, dynamic> data) async {
    try {
      final response = await http
          .put(
        Uri.parse('$baseUrl/academic-data'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      )
          .timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData;
      }
      return {
        'success': false,
        'message': responseData['message'] ?? 'Gagal memperbarui data akademik',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan update data akademik timeout. Coba lagi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteAcademicData(String id) async {
    try {
      final response = await http
          .delete(
        Uri.parse('$baseUrl/academic-data/$id'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal menghapus data akademik',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan hapus data akademik timeout. Coba lagi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Family Data methods
  static Future<Map<String, dynamic>> getFamilyData() async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/family-data'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengambil data keluarga',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan data keluarga timeout. Coba lagi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Documents methods
  static Future<Map<String, dynamic>> getDocuments() async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/documents'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengambil dokumen',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan dokumen timeout. Coba lagi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> uploadDocument(String jenisDokumen, String filePath) async {
    try {
      print('API Service: Starting upload for jenis: $jenisDokumen, file: $filePath');
      print('API Service: Current token: $_token');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/documents/upload'),
      );
      
      // Add headers (exclude Content-Type for multipart)
      Map<String, String> headers = _getHeaders();
      headers.remove('Content-Type');
      request.headers.addAll(headers);
      
      print('API Service: Headers: $headers');
      
      // Add file
      var file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);
      
      // Add form data
      request.fields['jenis_dokumen'] = jenisDokumen;
      
      print('API Service: Request fields: ${request.fields}');
      print('API Service: Request files count: ${request.files.length}');

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      
      print('API Service: Response status: ${response.statusCode}');
      print('API Service: Response body: ${response.body}');
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData;
      }
      
      return {
        'success': false,
        'message': responseData['message'] ?? 'Gagal mengunggah dokumen',
      };
    } on TimeoutException {
      print('API Service: Upload timeout');
      return {
        'success': false,
        'message': 'Permintaan upload dokumen timeout. Coba lagi.',
      };
    } catch (e) {
      print('API Service: Upload error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteDocument(String documentId) async {
    try {
      final response = await http
          .delete(
        Uri.parse('$baseUrl/documents/$documentId'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal menghapus dokumen',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan hapus dokumen timeout. Coba lagi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> updateFamilyData(Map<String, dynamic> data) async {
    try {
      final response = await http
          .put(
        Uri.parse('$baseUrl/family-data'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      )
          .timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData;
      }
      return {
        'success': false,
        'message': responseData['message'] ?? 'Gagal memperbarui data keluarga',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan update data keluarga timeout. Coba lagi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

}
