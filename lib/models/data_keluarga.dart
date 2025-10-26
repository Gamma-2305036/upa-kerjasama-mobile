class DataKeluarga {
  final String? id;
  final String? alumniId;
  final String? namaAyah;
  final String? pekerjaanAyah;
  final String? namaIbu;
  final String? pekerjaanIbu;
  final String? namaWali;
  final String? pekerjaanWali;
  final String? alamatKeluarga;
  final int? jumlahSaudara;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DataKeluarga({
    this.id,
    this.alumniId,
    this.namaAyah,
    this.pekerjaanAyah,
    this.namaIbu,
    this.pekerjaanIbu,
    this.namaWali,
    this.pekerjaanWali,
    this.alamatKeluarga,
    this.jumlahSaudara,
    this.createdAt,
    this.updatedAt,
  });

  factory DataKeluarga.fromJson(Map<String, dynamic> json) {
    return DataKeluarga(
      id: json['id']?.toString(),
      alumniId: json['alumni_id']?.toString(),
      namaAyah: json['nama_ayah']?.toString(),
      pekerjaanAyah: json['pekerjaan_ayah']?.toString(),
      namaIbu: json['nama_ibu']?.toString(),
      pekerjaanIbu: json['pekerjaan_ibu']?.toString(),
      namaWali: json['nama_wali']?.toString(),
      pekerjaanWali: json['pekerjaan_wali']?.toString(),
      alamatKeluarga: json['alamat_keluarga']?.toString(),
      jumlahSaudara: json['jumlah_saudara'] != null ? int.tryParse(json['jumlah_saudara'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alumni_id': alumniId,
      'nama_ayah': namaAyah,
      'pekerjaan_ayah': pekerjaanAyah,
      'nama_ibu': namaIbu,
      'pekerjaan_ibu': pekerjaanIbu,
      'nama_wali': namaWali,
      'pekerjaan_wali': pekerjaanWali,
      'alamat_keluarga': alamatKeluarga,
      'jumlah_saudara': jumlahSaudara,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  DataKeluarga copyWith({
    String? id,
    String? alumniId,
    String? namaAyah,
    String? pekerjaanAyah,
    String? namaIbu,
    String? pekerjaanIbu,
    String? namaWali,
    String? pekerjaanWali,
    String? alamatKeluarga,
    int? jumlahSaudara,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DataKeluarga(
      id: id ?? this.id,
      alumniId: alumniId ?? this.alumniId,
      namaAyah: namaAyah ?? this.namaAyah,
      pekerjaanAyah: pekerjaanAyah ?? this.pekerjaanAyah,
      namaIbu: namaIbu ?? this.namaIbu,
      pekerjaanIbu: pekerjaanIbu ?? this.pekerjaanIbu,
      namaWali: namaWali ?? this.namaWali,
      pekerjaanWali: pekerjaanWali ?? this.pekerjaanWali,
      alamatKeluarga: alamatKeluarga ?? this.alamatKeluarga,
      jumlahSaudara: jumlahSaudara ?? this.jumlahSaudara,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DataKeluarga(id: $id, namaAyah: $namaAyah, pekerjaanAyah: $pekerjaanAyah, namaIbu: $namaIbu, pekerjaanIbu: $pekerjaanIbu, jumlahSaudara: $jumlahSaudara)';
  }
}

