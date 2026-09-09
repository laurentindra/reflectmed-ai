import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/constants/prompt_templates.dart';
import '../models/chat_message.dart';
import 'ai_training_service.dart';

class GeminiAiService {
  String? _apiKey;
  GenerativeModel? _model;

  void updateApiKey(String? key) {
    _apiKey = key;
    if (key != null && key.trim().isNotEmpty) {
      final calibratedPrompt = AiTrainingService().buildCalibratedSystemPrompt();
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: key.trim(),
        systemInstruction: Content.system(calibratedPrompt),
      );
    } else {
      _model = null;
    }
  }

  bool get hasApiKey => _apiKey != null && _apiKey!.trim().isNotEmpty;

  /// Mengirim pesan ke AI Mentor (dengan fallback cerdas offline jika tidak ada API key)
  Future<String> sendMessage(String userText, List<ChatMessage> history) async {
    if (_model != null) {
      try {
        final chat = _model!.startChat(
          history: history.map((msg) {
            return msg.isUser
                ? Content.text(msg.text)
                : Content.model([TextPart(msg.text)]);
          }).toList(),
        );

        final response = await chat.sendMessage(Content.text(userText));
        if (response.text != null && response.text!.isNotEmpty) {
          return response.text!;
        }
      } catch (e) {
        // Jika terjadi error kuota/koneksi API, beralih ke Fallback Scaffolding Engine
        return _generateIntelligentScaffoldingResponse(userText, history);
      }
    }

    // Default: Intelligent Clinical Mentor Scaffolding Engine (Built-in AMEE Guide 44 & Gibbs)
    return _generateIntelligentScaffoldingResponse(userText, history);
  }

  /// Engine pedagogis bawaan berbasis aturan AMEE Guide 44 & Siklus Gibbs
  String _generateIntelligentScaffoldingResponse(String text, List<ChatMessage> history) {
    final lower = text.toLowerCase();
    final step = history.where((m) => m.isUser).length;

    // Deteksi emosi & empati awal
    if (lower.contains('grogi') || lower.contains('takut') || lower.contains('gugup') || lower.contains('panik') || lower.contains('stres')) {
      return "Saya sangat mengerti perasaan itu. Sangat manusiawi dan wajar sekali bagi seorang dokter muda merasakan cemas atau grogi saat dihadapkan pada situasi kritis di bangsal. Terima kasih sudah berani jujur mengutarakannya.\n\nBisa ceritakan lebih spesifik, apa yang sebenarnya memicu rasa cemas itu saat kejadian berlangsung? Apakah karena kondisi pasien, kehadiran konsulen, atau rasa takut berbuat keliru?";
    }

    if (lower.contains('gagal') || lower.contains('salah') || lower.contains('marah') || lower.contains('komplain') || lower.contains('marahin')) {
      return "Momen seperti ini memang berat dan seringkali meninggalkan rasa tidak nyaman berhari-hari. Ingat bahwa di pendidikan kedokteran, ketidaknyamanan emosional ini adalah gerbang *transformative learning*.\n\nMari kita urai bersama: selain rasa tertekan itu, menurutmu apa yang sebenarnya menjadi akar penyebab situasi tersebut berkembang seperti itu?";
    }

    // Probing bertahap sesuai Gibbs
    if (step <= 1) {
      return "Terima kasih sudah berbagi pengalaman ini. Kedengarannya situasi tersebut sangat berkesan bagi rotasi klinikmu.\n\nSaat peristiwa itu sedang terjadi di ruangan, apa yang pertama kali kamu rasakan di dalam diri, dan bagaimana reaksimu saat itu?";
    } else if (step == 2) {
      return "Sangat menarik kamu memperhatikan respon emosionalmu sendiri. Sekarang coba kita evaluasi sejenak:\n\nDari seluruh rangkaian kejadian tersebut, apa hal yang menurutmu sudah kamu lakukan dengan baik, dan apa aspek yang terasa kurang berjalan lancar?";
    } else if (step == 3) {
      return "Evaluasi yang sangat jujur dan objektif. Mari kita melangkah ke analisis lebih dalam:\n\nMengapa menurutmu hal tersebut bisa terjadi? Apakah ada faktor komunikasi klinis, beban kerja/kelelahan, kurangnya persiapan sebelum tindakan, atau dinamika tim di ruangan?";
    } else if (step == 4) {
      return "Analisis yang tajam. Ini menyentuh inti dari model mentalmu sebagai calon dokter.\n\nSekarang, apa kesimpulan atau pembelajaran terpenting tentang dirimu dan situasi klinis tersebut yang kamu peroleh dari insiden ini?";
    } else {
      return "Refleksi yang sangat matang. Kita sudah sampai pada tahap terpenting: *Altered Action*.\n\nJika minggu depan kamu berada di situasi atau stase yang serupa, langkah konkret apa yang akan kamu lakukan secara berbeda? Mari kita buat rencanamu menjadi spesifik dan terukur (SMART)!";
    }
  }
}
