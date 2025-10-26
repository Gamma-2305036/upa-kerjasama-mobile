import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static Future<Map<String, dynamic>> getMyJobs() async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/mitra/jobs'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data lowongan mitra',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan data lowongan mitra timeout. Coba lagi.',
      };
    } catch (e) {
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

  // Mitra: get applicants for a specific job
  static Future<Map<String, dynamic>> getApplicantsForJob(String jobId) async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/mitra/jobs/$jobId/applicants'),
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

  // Mitra: update applicant status
  static Future<Map<String, dynamic>> updateApplicantStatus(String applicationId, String status) async {
    try {
      final response = await http
          .put(
        Uri.parse('$baseUrl/applications/$applicationId/status'),
        headers: _getHeaders(),
        body: jsonEncode({'status': status}),
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
  static Future<Map<String, dynamic>> updateCompanyProfile(Map<String, dynamic> payload) async {
    try {
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
  static Future<Map<String, dynamic>> updateAlumniDetail(Map<String, dynamic> payload) async {
    try {
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
