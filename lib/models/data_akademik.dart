class DataAkademik {
  final String? id;
  final String? alumniId;
  final String? nim;
  final String? programStudi;
  final int? tahunMasuk;
  final int? tahunLulus;
  final double? ipk;
  final String? universitas;
  final String? hardSkill;
  final String? softSkill;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DataAkademik({
    this.id,
    this.alumniId,
    this.nim,
    this.programStudi,
    this.tahunMasuk,
    this.tahunLulus,
    this.ipk,
    this.universitas,
    this.hardSkill,
    this.softSkill,
    this.createdAt,
    this.updatedAt,
  });

  factory DataAkademik.fromJson(Map<String, dynamic> json) {
    return DataAkademik(
      id: json['id']?.toString(),
      alumniId: json['alumni_id']?.toString(),
      nim: json['nim']?.toString(),
      programStudi: json['program_studi']?.toString(),
      tahunMasuk: json['tahun_masuk'] != null ? int.tryParse(json['tahun_masuk'].toString()) : null,
      tahunLulus: json['tahun_lulus'] != null ? int.tryParse(json['tahun_lulus'].toString()) : null,
      ipk: json['ipk'] != null ? double.tryParse(json['ipk'].toString()) : null,
      universitas: json['universitas']?.toString(),
      hardSkill: json['hard_skill']?.toString(),
      softSkill: json['soft_skill']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alumni_id': alumniId,
      'nim': nim,
      'program_studi': programStudi,
      'tahun_masuk': tahunMasuk,
      'tahun_lulus': tahunLulus,
      'ipk': ipk,
      'universitas': universitas,
      'hard_skill': hardSkill,
      'soft_skill': softSkill,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  DataAkademik copyWith({
    String? id,
    String? alumniId,
    String? nim,
    String? programStudi,
    int? tahunMasuk,
    int? tahunLulus,
    double? ipk,
    String? universitas,
    String? hardSkill,
    String? softSkill,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DataAkademik(
      id: id ?? this.id,
      alumniId: alumniId ?? this.alumniId,
      nim: nim ?? this.nim,
      programStudi: programStudi ?? this.programStudi,
      tahunMasuk: tahunMasuk ?? this.tahunMasuk,
      tahunLulus: tahunLulus ?? this.tahunLulus,
      ipk: ipk ?? this.ipk,
      universitas: universitas ?? this.universitas,
      hardSkill: hardSkill ?? this.hardSkill,
      softSkill: softSkill ?? this.softSkill,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DataAkademik(id: $id, alumniId: $alumniId, nim: $nim, programStudi: $programStudi, tahunMasuk: $tahunMasuk, tahunLulus: $tahunLulus, ipk: $ipk, universitas: $universitas, hardSkill: $hardSkill, softSkill: $softSkill, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataAkademik &&
        other.id == id &&
        other.alumniId == alumniId &&
        other.nim == nim &&
        other.programStudi == programStudi &&
        other.tahunMasuk == tahunMasuk &&
        other.tahunLulus == tahunLulus &&
        other.ipk == ipk &&
        other.universitas == universitas &&
        other.hardSkill == hardSkill &&
        other.softSkill == softSkill &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        alumniId.hashCode ^
        nim.hashCode ^
        programStudi.hashCode ^
        tahunMasuk.hashCode ^
        tahunLulus.hashCode ^
        ipk.hashCode ^
        universitas.hashCode ^
        hardSkill.hashCode ^
        softSkill.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
