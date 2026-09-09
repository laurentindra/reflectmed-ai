import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/constants/prompt_templates.dart';
import '../models/chat_message.dart';
import '../models/gibbs_reflection.dart';
import '../models/student_profile.dart';

class GibbsExtractorService {
  final String? apiKey;

  GibbsExtractorService({this.apiKey});

  /// Mengekstrak seluruh riwayat percakapan menjadi dokumen Gibbs terstruktur
  Future<GibbsReflection> extractReflection({
    required List<ChatMessage> messages,
    required StudentProfile profile,
    String? customTitle,
  }) async {
    final transcript = messages.map((m) {
      final sender = m.isUser ? "Mahasiswa" : "AI Mentor";
      return "$sender: ${m.text}";
    }).join("\n\n");

    // Jika API Key tersedia, gunakan Gemini untuk parsing mendalam
    if (apiKey != null && apiKey!.trim().isNotEmpty) {
      try {
        final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey!.trim(),
          generationConfig: GenerationConfig(responseMimeType: 'application/json'),
        );

        final prompt = "${PromptTemplates.gibbsExtractionPrompt}\n\nTRANSKRIP CURHAT MAHASISWA:\n$transcript";
        final response = await model.generateContent([Content.text(prompt)]);

        if (response.text != null && response.text!.isNotEmpty) {
          final jsonMap = jsonDecode(response.text!) as Map<String, dynamic>;
          return _buildFromJson(jsonMap, profile);
        }
      } catch (e) {
        // Fallback ke extractor lokal jika gagal API
      }
    }

    // Default: Local Intelligent Rule-Based Extractor
    return _buildFromLocalHeuristics(messages, profile, customTitle);
  }

  GibbsReflection _buildFromJson(Map<String, dynamic> json, StudentProfile profile) {
    ReflectionDepth depth = ReflectionDepth.analytical;
    final depthStr = (json['depthLevel'] ?? '').toString().toLowerCase();
    if (depthStr.contains('transformative')) {
      depth = ReflectionDepth.transformative;
    } else if (depthStr.contains('superficial')) {
      depth = ReflectionDepth.superficial;
    }

    final smartMap = json['smartAction'] is Map<String, dynamic>
        ? json['smartAction'] as Map<String, dynamic>
        : <String, dynamic>{};

    return GibbsReflection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      title: json['title'] ?? 'Refleksi Kasus Rotasi Klinik',
      studentName: profile.fullName,
      studentId: profile.studentId,
      department: profile.currentDepartment,
      hospital: profile.teachingHospital,
      supervisorName: profile.supervisorName,
      description: json['description'] ?? '',
      feelings: json['feelings'] ?? '',
      evaluation: json['evaluation'] ?? '',
      analysis: json['analysis'] ?? '',
      conclusion: json['conclusion'] ?? '',
      actionPlan: json['actionPlan'] ?? '',
      smartAction: SmartActionPlan(
        specific: smartMap['specific'] ?? '',
        measurable: smartMap['measurable'] ?? '',
        achievable: smartMap['achievable'] ?? '',
        relevant: smartMap['relevant'] ?? '',
        timeBound: smartMap['timeBound'] ?? '',
      ),
      depthLevel: depth,
      depthRationale: json['depthRationale'] ?? 'Refleksi telah mencakup evaluasi diri dan rencana perbaikan terukur.',
      keyTakeaway: json['keyTakeaway'] ?? 'Pengalaman klinis bermakna adalah jembatan menuju profesionalisme berkelanjutan.',
    );
  }

  GibbsReflection _buildFromLocalHeuristics(
    List<ChatMessage> messages,
    StudentProfile profile,
    String? customTitle,
  ) {
    final userMessages = messages.where((m) => m.isUser).map((m) => m.text).toList();
    
    String desc = userMessages.isNotEmpty ? userMessages.first : 'Belum ada deskripsi peristiwa.';
    String feel = '';
    String eval = '';
    String ana = '';
    String conc = '';
    String plan = '';

    if (userMessages.length >= 2) feel = userMessages[1];
    if (userMessages.length >= 3) eval = userMessages[2];
    if (userMessages.length >= 4) ana = userMessages[3];
    if (userMessages.length >= 5) conc = userMessages[4];
    if (userMessages.length >= 6) {
      plan = userMessages.sublist(5).join(' ');
    } else if (userMessages.length >= 2) {
      plan = "Mempersiapkan SOP dan melakukan simulasi teknik mandiri sebelum menghadapi rotasi jaga berikutnya.";
    }

    // Deteksi kedalaman refleksi
    final fullText = userMessages.join(' ').toLowerCase();
    ReflectionDepth depth = ReflectionDepth.analytical;
    String rationale = "Mahasiswa mampu mengevaluasi faktor pendukung dan penghambat secara kritis.";

    if (fullText.contains('asumsi') || fullText.contains('menyadari keliru') || fullText.contains('perspektif') || fullText.contains('merombak') || fullText.contains('paradigma')) {
      depth = ReflectionDepth.transformative;
      rationale = "Refleksi mencapai tingkat transformatif: terdapat pergeseran perspektif mendasar dan perombakan model mental (Mezirow, 1981).";
    } else if (userMessages.length <= 2) {
      depth = ReflectionDepth.superficial;
      rationale = "Refleksi masih didominasi deskripsi kejadian murni; disarankan memperdalam analisis mengapa peristiwa terjadi (AMEE Guide 44).";
    }

    return GibbsReflection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      title: customTitle ?? 'Laporan Refleksi Kasus: ${profile.currentDepartment}',
      studentName: profile.fullName,
      studentId: profile.studentId,
      department: profile.currentDepartment,
      hospital: profile.teachingHospital,
      supervisorName: profile.supervisorName,
      description: desc,
      feelings: feel.isNotEmpty ? feel : "Merasa cemas dan tertekan namun termotivasi untuk belajar dari kekurangan.",
      evaluation: eval.isNotEmpty ? eval : "Komunikasi awal dengan perawat berjalan cukup baik, namun persiapan instrumen belum optimal.",
      analysis: ana.isNotEmpty ? ana : "Situasi terjadi akibat beban kerja yang tinggi serta kurangnya latihan 'deliberate practice' sebelum tindakan.",
      conclusion: conc.isNotEmpty ? conc : "Kompetensi klinis memerlukan ketenangan metakognitif dan penguasaan langkah teknis yang matang.",
      actionPlan: plan.isNotEmpty ? plan : "Melakukan briefing 5 menit sebelum ronde dan meminta umpan balik langsung kepada DPJP.",
      smartAction: SmartActionPlan(
        specific: "Membaca kembali panduan klinis dan berlatih prosedur mandiri sebelum dinas.",
        measurable: "Mampu melakukan prosedur tanpa keraguan minimal pada 2 pasien rotasi berikutnya.",
        achievable: "Dapat dilakukan di skill lab kampus pada hari persiapan.",
        relevant: "Terkait langsung dengan kebutuhan kompetensi stase ${profile.currentDepartment}.",
        timeBound: "Diterapkan mulai dinas jaga minggu depan.",
      ),
      depthLevel: depth,
      depthRationale: rationale,
      keyTakeaway: "Refleksi yang jujur mengubah pengalaman klinis biasa menjadi keahlian profesional sejati.",
    );
  }
}
