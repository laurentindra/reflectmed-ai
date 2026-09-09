class StudentProfile {
  String fullName;
  String studentId; // NIM
  String university;
  String currentDepartment; // Stase / Rotasi Aktif
  String teachingHospital;
  String supervisorName; // Nama DPJP / Dosen Pembimbing
  String geminiApiKey;

  StudentProfile({
    this.fullName = 'dr. Muda / Mahasiswa Kedokteran',
    this.studentId = '2024010099',
    this.university = 'Fakultas Kedokteran',
    this.currentDepartment = 'Ilmu Penyakit Dalam',
    this.teachingHospital = 'RSUP Pendidikan Utama',
    this.supervisorName = 'dr. Sp.PD, Subsp. (K)',
    this.geminiApiKey = '',
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'studentId': studentId,
    'university': university,
    'currentDepartment': currentDepartment,
    'teachingHospital': teachingHospital,
    'supervisorName': supervisorName,
    'geminiApiKey': geminiApiKey,
  };

  factory StudentProfile.fromJson(Map<String, dynamic> json) => StudentProfile(
    fullName: json['fullName'] ?? 'dr. Muda / Mahasiswa Kedokteran',
    studentId: json['studentId'] ?? '2024010099',
    university: json['university'] ?? 'Fakultas Kedokteran',
    currentDepartment: json['currentDepartment'] ?? 'Ilmu Penyakit Dalam',
    teachingHospital: json['teachingHospital'] ?? 'RSUP Pendidikan Utama',
    supervisorName: json['supervisorName'] ?? 'dr. Sp.PD, Subsp. (K)',
    geminiApiKey: json['geminiApiKey'] ?? '',
  );
}
