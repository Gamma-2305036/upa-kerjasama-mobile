import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  User? _user;
  dynamic _profile;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  dynamic get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  // Initialize auth service
  Future<void> initialize() async {
    await ApiService.initializeToken();
    
    if (ApiService.isLoggedIn()) {
      await _loadUserProfile();
    } else {
      // Ensure user is null if no token
      _user = null;
      _profile = null;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await ApiService.login(email, password);
      
      if (result['success']) {
        // Set user immediately from login response
        final userData = result['data']['user'];
        if (userData != null) {
          _user = User.fromJson(userData);
          notifyListeners();
        }
        
        // Load fresh profile from backend
        await _loadUserProfile();
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await ApiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    }
    
    _user = null;
    _profile = null;
    _clearError();
    notifyListeners();
    _setLoading(false);
  }

  // Load user profile
  Future<void> _loadUserProfile() async {
    try {
      final result = await ApiService.getProfile();
      
      if (result['success']) {
        // Update user data from profile response if available
        if (result['data']['user'] != null) {
          _user = User.fromJson(result['data']['user']);
        }
        _profile = _parseProfile(result['data']['profile']);
        notifyListeners();
      } else {
        // If profile loading fails, keep user data but clear profile
        // User data from login is still valid
        _profile = null;
        notifyListeners();
      }
    } catch (e) {
      // If profile loading fails, keep user data but clear profile
      // User data from login is still valid
      _profile = null;
      notifyListeners();
    }
  }

  // Parse profile based on user role
  dynamic _parseProfile(Map<String, dynamic>? profileData) {
    if (profileData == null) return null;
    
    if (_user?.roles.contains('alumni') == true) {
      return AlumniProfile.fromJson(profileData);
    } else if (_user?.roles.contains('mitra') == true) {
      return MitraProfile.fromJson(profileData);
    } else if (_user?.roles.contains('admin') == true) {
      return AdminProfile.fromJson(profileData);
    }
    
    return null;
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (isLoggedIn) {
      await _loadUserProfile();
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Check if user has specific role
  bool hasRole(String role) {
    return _user?.roles.contains(role) ?? false;
  }

  // Get user role (first role)
  String? get userRole {
    return _user?.roles.isNotEmpty == true ? _user!.roles.first : null;
  }
}
