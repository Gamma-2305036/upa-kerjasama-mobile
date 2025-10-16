import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;
  static String? _token;

  // Initialize token from shared preferences
  static Future<void> initializeToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
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
      final response = await http
          .post(
        Uri.parse('$baseUrl/login'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 15));

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

  // Check if user is logged in
  static bool isLoggedIn() {
    return _token != null;
  }
}
