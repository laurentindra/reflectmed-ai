/// Model untuk Contoh Kasus Pelatihan AI (Few-Shot Training Exemplar)
/// Digunakan oleh Medireflect AI Studio untuk mengkalibrasi respons AI Mentor
/// sesuai AMEE Guide No. 44 (Sandars, 2009) dan Siklus Gibbs (1988).

class TrainingExemplar {
  final String id;
  final String title;
  final String department; // misal: "Ilmu Kesehatan Anak", "Ilmu Bedah", "IPD"
  final String clinicalScenario; // Kronologi kasus singkat
  final String studentInput; // Contoh curhat mahasiswa
  final String idealMentorResponse; // Respons ideal mentor reflektif
  final String targetGibbsPhase; // "Description", "Feelings", "Evaluation", dll
  final String targetDepthLevel; // "Superficial", "Analytical", "Transformative"
  final List<String> tags; // misal: ["Komunikasi", "Emosi", "Keselamatan Pasien"]
  final bool isDefault; // bawaan sistem vs ditambahkan oleh edukator

  TrainingExemplar({
    required this.id,
    required this.title,
    required this.department,
    required this.clinicalScenario,
    required this.studentInput,
    required this.idealMentorResponse,
    required this.targetGibbsPhase,
    required this.targetDepthLevel,
    this.tags = const [],
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'department': department,
      'clinicalScenario': clinicalScenario,
      'studentInput': studentInput,
      'idealMentorResponse': idealMentorResponse,
      'targetGibbsPhase': targetGibbsPhase,
      'targetDepthLevel': targetDepthLevel,
      'tags': tags,
      'isDefault': isDefault,
    };
  }

  factory TrainingExemplar.fromJson(Map<String, dynamic> json) {
    return TrainingExemplar(
      id: json['id'] as String,
      title: json['title'] as String,
      department: json['department'] as String,
      clinicalScenario: json['clinicalScenario'] as String,
      studentInput: json['studentInput'] as String,
      idealMentorResponse: json['idealMentorResponse'] as String,
      targetGibbsPhase: json['targetGibbsPhase'] as String,
      targetDepthLevel: json['targetDepthLevel'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  /// Format untuk fine-tuning Gemini / OpenAI JSONL
  Map<String, dynamic> toFineTuningFormat(String systemPrompt) {
    return {
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {
          'role': 'user',
          'content': '[Konteks Stase: $department - $title]\n$studentInput'
        },
        {'role': 'model', 'content': idealMentorResponse},
      ]
    };
  }
}

/// Konfigurasi Kalibrasi Persona AI Mentor
class MentorPersonaConfig {
  double empathyLevel; // 1.0 (Objektif/Ketat) - 5.0 (Sangat Empatik & Validatif)
  double socraticChallenge; // 1.0 (Menyetujui) - 5.0 (Kritis Menantang Asumsi)
  double academicScaffolding; // 1.0 (Santai) - 5.0 (Sangat Terstruktur Gibbs & SMART)
  String activeFramework; // "Gibbs 1988", "Schön 1983", "Mezirow Transformative"
  bool autoSuggestLiterature; // Sertakan referensi AMEE / EBM bila relevan
  bool detectAssessmentTension; // Redam kecemasan mahasiswa terhadap penilaian

  MentorPersonaConfig({
    this.empathyLevel = 4.5,
    this.socraticChallenge = 4.0,
    this.academicScaffolding = 4.2,
    this.activeFramework = 'Gibbs 1988 (AMEE Guide 44)',
    this.autoSuggestLiterature = true,
    this.detectAssessmentTension = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'empathyLevel': empathyLevel,
      'socraticChallenge': socraticChallenge,
      'academicScaffolding': academicScaffolding,
      'activeFramework': activeFramework,
      'autoSuggestLiterature': autoSuggestLiterature,
      'detectAssessmentTension': detectAssessmentTension,
    };
  }

  factory MentorPersonaConfig.fromJson(Map<String, dynamic> json) {
    return MentorPersonaConfig(
      empathyLevel: (json['empathyLevel'] as num?)?.toDouble() ?? 4.5,
      socraticChallenge: (json['socraticChallenge'] as num?)?.toDouble() ?? 4.0,
      academicScaffolding: (json['academicScaffolding'] as num?)?.toDouble() ?? 4.2,
      activeFramework: json['activeFramework'] as String? ?? 'Gibbs 1988 (AMEE Guide 44)',
      autoSuggestLiterature: json['autoSuggestLiterature'] as bool? ?? true,
      detectAssessmentTension: json['detectAssessmentTension'] as bool? ?? true,
    );
  }
}
