class User {
  final String id;
  final String name;
  final String email;
  final List<String> roles;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle both old format (roles array) and new format (role string)
    List<String> rolesList = [];
    if (json['roles'] != null) {
      rolesList = List<String>.from(json['roles']);
    } else if (json['role'] != null) {
      rolesList = [json['role']];
    }
    
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roles: rolesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'roles': roles,
    };
  }
}

class AlumniProfile {
  final String? id;
  final String? nim;
  final String? nik;
  final String? noHp;
  final String? programStudi; // added: academic field for prefill
  final String? angkatan; // added: academic field for prefill (tahun masuk)
  final String? cvUrl; // persisted CV link from backend
  final String? tempatLahir;
  final String? tanggalLahir;
  final String? jenisKelamin;
  final String? alamat;
  final String? kota;
  final String? provinsi;
  final String? kodePos;
  final String? tentangSaya;
  final String? namaBank;
  final String? noRekening;
  final String? fileCv;
  final String? fotoProfil;

  AlumniProfile({
    this.id,
    this.nim,
    this.nik,
    this.noHp,
    this.programStudi,
    this.angkatan,
    this.cvUrl,
    this.tempatLahir,
    this.tanggalLahir,
    this.jenisKelamin,
    this.alamat,
    this.kota,
    this.provinsi,
    this.kodePos,
    this.tentangSaya,
    this.namaBank,
    this.noRekening,
    this.fileCv,
    this.fotoProfil,
  });

  factory AlumniProfile.fromJson(Map<String, dynamic> json) {
    return AlumniProfile(
      id: json['id'],
      nim: json['nim'],
      nik: json['nik'],
      noHp: json['no_hp'],
      // Support both flattened keys from API and nested academic relation keys
      programStudi: json['program_studi'] ?? json['data_akademik']?['program_studi'],
      angkatan: (json['angkatan'] ?? json['data_akademik']?['tahun_masuk'])?.toString(),
      cvUrl: json['cv_url'],
      tempatLahir: json['tempat_lahir'],
      tanggalLahir: json['tanggal_lahir'],
      jenisKelamin: json['jenis_kelamin'],
      alamat: json['alamat'],
      kota: json['kota'],
      provinsi: json['provinsi'],
      kodePos: json['kode_pos'],
      tentangSaya: json['tentang_saya'],
      namaBank: json['nama_bank'],
      noRekening: json['no_rekening'],
      fileCv: json['file_cv'],
      fotoProfil: json['foto_profil_url'] ?? json['foto_profil'],
    );
  }
}

class MitraProfile {
  final String? id;
  final String? namaPerusahaan;
  final String? logo;
  final String? sektor;
  final String? kontak;
  final String? tautan;
  final String? alamat;
  final String? tentang;
  final String? visi;
  final String? misi;
  final List<String>? keunggulan;
  final String? mulaiKerjasama;
  final String? akhirKerjasama;

  MitraProfile({
    this.id,
    this.namaPerusahaan,
    this.logo,
    this.sektor,
    this.kontak,
    this.tautan,
    this.alamat,
    this.tentang,
    this.visi,
    this.misi,
    this.keunggulan,
    this.mulaiKerjasama,
    this.akhirKerjasama,
  });

  factory MitraProfile.fromJson(Map<String, dynamic> json) {
    List<String>? _toStringList(dynamic v) {
      if (v == null) return null;
      if (v is List) return v.map((e) => e.toString()).toList();
      if (v is String) {
        // support comma or newline separated text
        final parts = v.contains('\n') ? v.split('\n') : v.split(',');
        return parts.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return null;
    }
    // Support both logo and logo_url - prefer logo_url if available
    final logoValue = json['logo_url'] ?? json['logo'];
    return MitraProfile(
      id: json['id'],
      namaPerusahaan: json['nama_perusahaan'],
      logo: logoValue,
      sektor: json['sektor'],
      kontak: json['kontak'],
      tautan: json['tautan'],
      alamat: json['alamat'],
      tentang: json['tentang'],
      visi: json['visi'],
      misi: json['misi'],
      keunggulan: _toStringList(json['keunggulan']),
      mulaiKerjasama: json['mulai_kerjasama'],
      akhirKerjasama: json['akhir_kerjasama'],
    );
  }
}

class AdminProfile {
  final String? id;
  final String? jabatan;
  final String? noTelepon;
  final String? alamat;

  AdminProfile({
    this.id,
    this.jabatan,
    this.noTelepon,
    this.alamat,
  });

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      id: json['id'],
      jabatan: json['jabatan'],
      noTelepon: json['no_telepon'],
      alamat: json['alamat'],
    );
  }
}
