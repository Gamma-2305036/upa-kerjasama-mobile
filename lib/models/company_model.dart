import 'dart:convert';
class Company {
  final String id;
  final String userId;
  final String namaPerusahaan;
  final String? logo;
  final String? sektor;
  final String? kontak;
  final String? tautan;
  final String? mulaiKerjasama;
  final String? akhirKerjasama;
  final String createdAt;
  final String updatedAt;
  final List<Job> lowongan;

  Company({
    required this.id,
    required this.userId,
    required this.namaPerusahaan,
    this.logo,
    this.sektor,
    this.kontak,
    this.tautan,
    this.mulaiKerjasama,
    this.akhirKerjasama,
    required this.createdAt,
    required this.updatedAt,
    required this.lowongan,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    List<dynamic> _normalizeLowongan(dynamic v) {
      if (v == null) return [];
      if (v is List) return v;
      if (v is Map) return v.values.toList();
      if (v is String) {
        try {
          final decoded = jsonDecode(v);
          if (decoded is List) return decoded;
          if (decoded is Map) return decoded.values.toList();
        } catch (_) {}
        return [];
      }
      return [];
    }

    final lowonganRaw = _normalizeLowongan(json['lowongan']);

    return Company(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      namaPerusahaan: json['nama_perusahaan'] ?? '',
      logo: json['logo'],
      sektor: json['sektor'],
      kontak: json['kontak'],
      tautan: json['tautan'],
      mulaiKerjasama: json['mulai_kerjasama'],
      akhirKerjasama: json['akhir_kerjasama'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      lowongan: lowonganRaw.map((job) => Job.fromJson(Map<String, dynamic>.from(job))).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nama_perusahaan': namaPerusahaan,
      'logo': logo,
      'sektor': sektor,
      'kontak': kontak,
      'tautan': tautan,
      'mulai_kerjasama': mulaiKerjasama,
      'akhir_kerjasama': akhirKerjasama,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'lowongan': lowongan.map((job) => job.toJson()).toList(),
    };
  }
}

class Job {
  final String id;
  final String mitraId;
  final String judul;
  final String posisi;
  final String deskripsi;
  final String lokasi;
  final String? tanggalMulai;
  final String? tanggalSelesai;
  final String? jenisPekerjaan;
  final String? jenjangPendidikan;
  final List<String>? jurusanDiizinkan;
  final List<String>? persyaratanDokumen;
  final String? rincianLowongan;
  final int jumlahPelamar;
  final bool statusAktif;
  final String? tanggalPenerimaanLamaran;
  final String? tanggalPengumuman;
  final int? gajiMin;
  final int? gajiMax;
  final String? pengalamanMinimal;
  final List<String>? skillRequired;
  final String createdAt;
  final String updatedAt;

  Job({
    required this.id,
    required this.mitraId,
    required this.judul,
    required this.posisi,
    required this.deskripsi,
    required this.lokasi,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.jenisPekerjaan,
    this.jenjangPendidikan,
    this.jurusanDiizinkan,
    this.persyaratanDokumen,
    this.rincianLowongan,
    required this.jumlahPelamar,
    required this.statusAktif,
    this.tanggalPenerimaanLamaran,
    this.tanggalPengumuman,
    this.gajiMin,
    this.gajiMax,
    this.pengalamanMinimal,
    this.skillRequired,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) {
        final s = v.replaceAll('.', '').replaceAll(',', '').trim();
        return int.tryParse(s);
      }
      return null;
    }

    bool _toBool(dynamic v) {
      if (v is bool) return v;
      if (v is int) return v != 0;
      if (v is String) return v == '1' || v.toLowerCase() == 'true';
      return false;
    }

    List<String>? _toStringList(dynamic v) {
      if (v == null) return null;
      if (v is List) {
        return v.map((e) => e.toString()).toList();
      }
      if (v is String) {
        try {
          final decoded = jsonDecode(v);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {}
        return [v];
      }
      return null;
    }

    return Job(
      id: json['id'] ?? '',
      mitraId: json['mitra_id'] ?? '',
      judul: json['judul'] ?? '',
      posisi: json['posisi'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      lokasi: json['lokasi'] ?? '',
      tanggalMulai: json['tanggal_mulai'],
      tanggalSelesai: json['tanggal_selesai'],
      jenisPekerjaan: json['jenis_pekerjaan'],
      jenjangPendidikan: json['jenjang_pendidikan'],
      jurusanDiizinkan: _toStringList(json['jurusan_diizinkan']),
      persyaratanDokumen: _toStringList(json['persyaratan_dokumen']),
      rincianLowongan: json['rincian_lowongan'],
      jumlahPelamar: _toInt(json['jumlah_pelamar']) ?? 0,
      statusAktif: _toBool(json['status_aktif']),
      tanggalPenerimaanLamaran: json['tanggal_penerimaan_lamaran'],
      tanggalPengumuman: json['tanggal_pengumuman'],
      gajiMin: _toInt(json['gaji_min']),
      gajiMax: _toInt(json['gaji_max']),
      pengalamanMinimal: json['pengalaman_minimal'],
      skillRequired: _toStringList(json['skill_required']),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mitra_id': mitraId,
      'judul': judul,
      'posisi': posisi,
      'deskripsi': deskripsi,
      'lokasi': lokasi,
      'tanggal_mulai': tanggalMulai,
      'tanggal_selesai': tanggalSelesai,
      'jenis_pekerjaan': jenisPekerjaan,
      'jenjang_pendidikan': jenjangPendidikan,
      'jurusan_diizinkan': jurusanDiizinkan,
      'persyaratan_dokumen': persyaratanDokumen,
      'rincian_lowongan': rincianLowongan,
      'jumlah_pelamar': jumlahPelamar,
      'status_aktif': statusAktif,
      'tanggal_penerimaan_lamaran': tanggalPenerimaanLamaran,
      'tanggal_pengumuman': tanggalPengumuman,
      'gaji_min': gajiMin,
      'gaji_max': gajiMax,
      'pengalaman_minimal': pengalamanMinimal,
      'skill_required': skillRequired,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
