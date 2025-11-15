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

  // Get jobs list (public)
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

  // Get jobs for current mitra only
  Future<void> getMyJobs({bool refresh = false, bool archived = false, String? search}) async {
    if (refresh) {
      _jobs.clear();
      notifyListeners(); // Notify immediately when clearing
    }

    _setLoading(true);
    _clearError();
    notifyListeners(); // Notify loading state

    try {
      final result = await ApiService.getMyJobs(archived: archived, search: search);

      if (result['success']) {
        try {
          final jobsData = result['data'];
          if (jobsData is List) {
            _jobs = jobsData.map((job) {
              try {
                return Job.fromJson(job as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing job: $e');
                return null;
              }
            }).whereType<Job>().toList();
          } else {
            _jobs = [];
          }
          _pagination = null;
        } catch (e) {
          print('Error processing jobs data: $e');
          _setError('Gagal memproses data lowongan. Silakan refresh halaman.');
        }
      } else {
        _setError(result['message'] ?? 'Gagal mengambil data lowongan');
      }
    } catch (e) {
      print('Error in getMyJobs: $e');
      _setError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      _setLoading(false);
      notifyListeners(); // Always notify after loading completes
    }
  }

  Future<Map<String, dynamic>> createJob(Map<String, dynamic> payload) async {
    try {
      _setLoading(true);
      final result = await ApiService.createJob(payload);
      if (result['success'] == true) {
        await getMyJobs(refresh: true);
      } else {
        _setError(result['message'] ?? 'Gagal membuat lowongan');
      }
      return result;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> deleteJob(String jobId) async {
    try {
      _setLoading(true);
      final result = await ApiService.deleteJob(jobId);
      if (result['success'] == true) {
        await getMyJobs(refresh: true);
      } else {
        _setError(result['message'] ?? 'Gagal menghapus lowongan');
      }
      return result;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> updateJob(String jobId, Map<String, dynamic> payload) async {
    try {
      _setLoading(true);
      final result = await ApiService.updateJob(jobId, payload);
      if (result['success'] == true) {
        await getMyJobs(refresh: true);
      } else {
        _setError(result['message'] ?? 'Gagal memperbarui lowongan');
      }
      return result;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> activateJob(String jobId) async {
    try {
      _setLoading(true);
      final result = await ApiService.activateJob(jobId);
      if (result['success'] == true) {
        // Don't auto-refresh here, let UI handle it with correct archived parameter
        // This prevents data from being overwritten
      } else {
        _setError(result['message'] ?? 'Gagal mengaktifkan lowongan');
      }
      return result;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> updateJobStatus(String jobId, {bool? statusAktif, String? tanggalSelesai}) async {
    try {
      _setLoading(true);
      final result = await ApiService.updateJobStatus(jobId, statusAktif: statusAktif, tanggalSelesai: tanggalSelesai);
      if (result['success'] == true) {
        // Don't auto-refresh here, let UI handle it with correct archived parameter
        // This prevents data from being overwritten
      } else {
        _setError(result['message'] ?? 'Gagal memperbarui status lowongan');
      }
      return result;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> archiveJob(String jobId) async {
    try {
      _setLoading(true);
      final result = await ApiService.archiveJob(jobId);
      if (result['success'] == true) {
        // Don't auto-refresh here, let UI handle it with correct archived parameter
        // This prevents data from being overwritten
      } else {
        _setError(result['message'] ?? 'Gagal mengarsipkan lowongan');
      }
      return result;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> unarchiveJob(String jobId) async {
    try {
      _setLoading(true);
      final result = await ApiService.unarchiveJob(jobId);
      if (result['success'] == true) {
        // Don't auto-refresh here, let UI handle it with correct archived parameter
        // This prevents data from being overwritten
      } else {
        _setError(result['message'] ?? 'Gagal mengembalikan lowongan dari arsip');
      }
      return result;
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
