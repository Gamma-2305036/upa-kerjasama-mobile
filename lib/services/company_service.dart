import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/company_model.dart';

class CompanyService extends ChangeNotifier {
  List<Company> _companies = [];
  bool _isLoading = false;
  String? _error;

  List<Company> get companies => _companies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load companies from API
  Future<void> loadCompanies({String? search}) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await ApiService.getCompanies(search: search);
      
      if (result['success']) {
        _companies = (result['data'] as List<dynamic>)
            .map((company) => Company.fromJson(company))
            .toList();
        notifyListeners();
      } else {
        _setError(result['message']);
      }
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Get company detail
  Future<Company?> getCompanyDetail(String companyId) async {
    try {
      final result = await ApiService.getCompanyDetail(companyId);
      
      if (result['success']) {
        return Company.fromJson(result['data']);
      } else {
        _setError(result['message']);
        return null;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
      return null;
    }
  }

  // Search companies
  Future<void> searchCompanies(String query) async {
    await loadCompanies(search: query);
  }

  // Refresh companies
  Future<void> refreshCompanies() async {
    await loadCompanies();
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
}
