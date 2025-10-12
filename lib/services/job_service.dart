import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/job_model.dart';

class JobService extends ChangeNotifier {
  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _pagination;

  List<Job> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get pagination => _pagination;

  // Get jobs list
  Future<void> getJobs({String? search, String? lokasi, bool refresh = false}) async {
    if (refresh) {
      _jobs.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await ApiService.getJobs(search: search, lokasi: lokasi);
      
      if (result['success']) {
        final List<dynamic> jobsData = result['data'];
        _jobs = jobsData.map((job) => Job.fromJson(job)).toList();
        _pagination = result['pagination'];
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

  // Get job detail
  Future<Job?> getJobDetail(String jobId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await ApiService.getJobDetail(jobId);
      
      if (result['success']) {
        return Job.fromJson(result['data']);
      } else {
        _setError(result['message']);
        return null;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Search jobs
  Future<void> searchJobs(String query) async {
    await getJobs(search: query, refresh: true);
  }

  // Filter by location
  Future<void> filterByLocation(String location) async {
    await getJobs(lokasi: location, refresh: true);
  }

  // Clear search and filters
  Future<void> clearFilters() async {
    await getJobs(refresh: true);
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
