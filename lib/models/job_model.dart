import 'user_model.dart';

class Job {
  final String id;
  final String mitraId;
  final String judul;
  final String? posisi;
  final String deskripsi;
  final String lokasi;
  final String? gajiMin;
  final String? gajiMax;
  final String? jenisPekerjaan;
  final String? pengalamanMinimal;
  final String? jenjangPendidikan;
  final String? skillRequired;
  final String? rincianLowongan;
  final String? tanggalPenerimaanLamaran;
  final String? tanggalSelesai;
  final bool? statusAktif;
  final String? createdAt;
  final String? updatedAt;
  final MitraCompany? mitraPerusahaan;

  Job({
    required this.id,
    required this.mitraId,
    required this.judul,
    this.posisi,
    required this.deskripsi,
    required this.lokasi,
    this.gajiMin,
    this.gajiMax,
    this.jenisPekerjaan,
    this.pengalamanMinimal,
    this.jenjangPendidikan,
    this.skillRequired,
    this.rincianLowongan,
    this.tanggalPenerimaanLamaran,
    this.tanggalSelesai,
    this.statusAktif,
    this.createdAt,
    this.updatedAt,
    this.mitraPerusahaan,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? '',
      mitraId: json['mitra_id']?.toString() ??
          (json['mitraPerusahaanId']?.toString() ?? ''),
      judul: json['judul'] ?? '',
      posisi: json['posisi'],
      deskripsi: json['deskripsi'] ?? '',
      lokasi: json['lokasi'] ?? '',
      gajiMin: json['gaji_min'],
      gajiMax: json['gaji_max'],
      jenisPekerjaan: json['jenis_pekerjaan'],
      pengalamanMinimal: json['pengalaman_minimal'],
      jenjangPendidikan: json['jenjang_pendidikan'],
      skillRequired: json['skill_required'],
      rincianLowongan: json['rincian_lowongan'],
      tanggalPenerimaanLamaran: json['tanggal_penerimaan_lamaran'],
      tanggalSelesai: json['tanggal_selesai'],
      statusAktif: json['status_aktif'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      mitraPerusahaan: json['mitra_perusahaan'] != null 
          ? MitraCompany.fromJson(json['mitra_perusahaan'])
          : null,
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
      'gaji_min': gajiMin,
      'gaji_max': gajiMax,
      'jenis_pekerjaan': jenisPekerjaan,
      'pengalaman_minimal': pengalamanMinimal,
      'jenjang_pendidikan': jenjangPendidikan,
      'skill_required': skillRequired,
      'rincian_lowongan': rincianLowongan,
      'tanggal_penerimaan_lamaran': tanggalPenerimaanLamaran,
      'tanggal_selesai': tanggalSelesai,
      'status_aktif': statusAktif,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'mitra_perusahaan': mitraPerusahaan?.toJson(),
    };
  }
}

class MitraCompany {
  final String id;
  final String namaPerusahaan;
  final String? logo;
  final String? sektor;
  final String? kontak;
  final String? tautan;
  final User? user;

  MitraCompany({
    required this.id,
    required this.namaPerusahaan,
    this.logo,
    this.sektor,
    this.kontak,
    this.tautan,
    this.user,
  });

  factory MitraCompany.fromJson(Map<String, dynamic> json) {
    return MitraCompany(
      id: json['id'] ?? '',
      namaPerusahaan: json['nama_perusahaan'] ?? '',
      logo: json['logo'],
      sektor: json['sektor'],
      kontak: json['kontak'],
      tautan: json['tautan'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_perusahaan': namaPerusahaan,
      'logo': logo,
      'sektor': sektor,
      'kontak': kontak,
      'tautan': tautan,
      'user': user?.toJson(),
    };
  }
}
