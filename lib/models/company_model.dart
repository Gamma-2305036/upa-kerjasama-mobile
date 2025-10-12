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
      lowongan: (json['lowongan'] as List<dynamic>?)
          ?.map((job) => Job.fromJson(job))
          .toList() ?? [],
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
      jurusanDiizinkan: json['jurusan_diizinkan'] != null 
          ? List<String>.from(json['jurusan_diizinkan']) 
          : null,
      persyaratanDokumen: json['persyaratan_dokumen'] != null 
          ? List<String>.from(json['persyaratan_dokumen']) 
          : null,
      rincianLowongan: json['rincian_lowongan'],
      jumlahPelamar: json['jumlah_pelamar'] ?? 0,
      statusAktif: json['status_aktif'] ?? false,
      tanggalPenerimaanLamaran: json['tanggal_penerimaan_lamaran'],
      tanggalPengumuman: json['tanggal_pengumuman'],
      gajiMin: json['gaji_min'],
      gajiMax: json['gaji_max'],
      pengalamanMinimal: json['pengalaman_minimal'],
      skillRequired: json['skill_required'] != null 
          ? List<String>.from(json['skill_required']) 
          : null,
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
