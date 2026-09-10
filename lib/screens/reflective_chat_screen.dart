import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/chat_message.dart';
import '../models/student_profile.dart';
import '../services/gemini_ai_service.dart';
import '../services/gibbs_extractor_service.dart';
import '../services/storage_service.dart';
import 'gibbs_report_screen.dart';

class ReflectiveChatScreen extends StatefulWidget {
  const ReflectiveChatScreen({Key? key}) : super(key: key);

  @override
  State<ReflectiveChatScreen> createState() => _ReflectiveChatScreenState();
}

class _ReflectiveChatScreenState extends State<ReflectiveChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiAiService _aiService = GeminiAiService();

  StudentProfile _profile = StudentProfile();
  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isExtracting = false;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final profile = await StorageService.loadProfile();
    final savedChat = await StorageService.loadActiveChat();

    setState(() {
      _profile = profile;
      _aiService.updateApiKey(profile.geminiApiKey);
      _messages = savedChat;
    });

    if (_messages.isEmpty) {
      final welcomeMsg = ChatMessage(
        id: 'welcome',
        text: 'Halo! Saya AI Guide Refleksi Anda.\n\nSaya di sini untuk membantu Anda mengeksplorasi pengalaman klinis lebih dalam — bukan untuk menulis refleksi, tapi untuk membantu Anda menemukan insight sendiri melalui pertanyaan.\n\nCeritakan pengalaman klinis terbaru Anda yang berkesan di stase ${_profile.currentDepartment}. Apa yang terjadi?',
        isUser: false,
        timestamp: DateTime.now(),
        estimatedPhase: GibbsPhase.description,
      );
      setState(() {
        _messages = [welcomeMsg];
      });
      StorageService.saveActiveChat(_messages);
    }
  }

  Future<void> _sendMessage([String? presetText]) async {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    if (presetText == null) _textController.clear();

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });

    _scrollToBottom();
    await StorageService.saveActiveChat(_messages);

    final aiReplyText = await _aiService.sendMessage(text, _messages);

    final aiMsg = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      text: aiReplyText,
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(aiMsg);
      _isTyping = false;
    });

    _scrollToBottom();
    await StorageService.saveActiveChat(_messages);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _extractAndGenerateReport() async {
    if (_messages.where((m) => m.isUser).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan curhat terlebih dahulu sebelum menyusun laporan.')),
      );
      return;
    }

    setState(() => _isExtracting = true);

    final extractor = GibbsExtractorService(apiKey: _profile.geminiApiKey);
    final reflection = await extractor.extractReflection(
      messages: _messages,
      profile: _profile,
    );

    await StorageService.saveReflection(reflection);
    setState(() => _isExtracting = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GibbsReportScreen(reflection: reflection)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userCount = _messages.where((m) => m.isUser).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F8),
      body: SafeArea(
        child: Column(
          children: [
            // TEAL HEADER (Matching CHATBOT CONSULT.png)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryTeal, AppTheme.primaryTealDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 32),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/logoo.png',
                            height: 22,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/logo.png',
                              height: 22,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.psychology, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('AI Guide · Aktif', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                        onPressed: () {
                          StorageService.clearActiveChat();
                          _initChat();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.assignment_outlined, size: 12, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          'Konteks: Siklus Refleksi Gibbs · Rotasi ${_profile.currentDepartment}',
                          style: const TextStyle(color: Colors.white, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // PRIVACY & ENCRYPTION NOTICE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              color: const Color(0xFFF0FDFA),
              child: const Text(
                'Percakapan ini bersifat privat dan terenkripsi. AI memfasilitasi refleksi — bukan pengganti diskusi dengan supervisor Anda.',
                style: TextStyle(fontSize: 9.5, color: Color(0xFF0F766E), height: 1.3),
                textAlign: TextAlign.center,
              ),
            ),

            // CHAT MESSAGES
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(14),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildChatBubble(msg);
                },
              ),
            ),

            if (_isTyping)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: const [
                    SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryTeal)),
                    SizedBox(width: 8),
                    Text('AI Guide sedang merenung & merespons...', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                  ],
                ),
              ),

            // SUGGESTIONS CHIPS ("Mulai dengan:")
            if (userCount <= 1)
              Container(
                height: 38,
                margin: const EdgeInsets.only(bottom: 6),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Text('Mulai dengan:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    _buildChip('Saya punya kasus yang ingin saya refleksikan'),
                    _buildChip('Bantu saya memahami perasaan saya'),
                    _buildChip('Apa yang bisa saya pelajari dari situasi ini?'),
                    _buildChip('Bagaimana cara meningkatkan komunikasi klinis saya?'),
                  ],
                ),
              ),

            // COUNSELING CALLOUT BANNER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.favorite_border, size: 14, color: Color(0xFFC2410C)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text('Butuh dukungan? Layanan konseling tersedia.', style: TextStyle(fontSize: 10.5, color: Color(0xFF9A3412))),
                  ),
                  Text('Hubungi', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFC2410C))),
                ],
              ),
            ),

            // SYNTHESIZE BUTTON
            if (userCount >= 2)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentAmber,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isExtracting
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Sintesis Laporan Gibbs & PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: _isExtracting ? null : _extractAndGenerateReport,
                ),
              ),

            // INPUT BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.mic, color: AppTheme.primaryTeal),
                        onPressed: () {
                          _sendMessage('Voice Note 60 Detik: Saat dinas jaga tadi, pasien sempat menolak diperiksa karena merasa belum kenal denganku. Setelah aku perkenalkan diri secara ramah, pasien menjadi kooperatif.');
                        },
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            controller: _textController,
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              hintText: 'Ceritakan pengalaman Anda...',
                              hintStyle: TextStyle(fontSize: 11.5, color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primaryTeal,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_upward, size: 16, color: Colors.white),
                          onPressed: () => _sendMessage(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text('AI tidak menyimpan identitas pasien · Enter untuk kirim', style: TextStyle(fontSize: 8.5, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: msg.isUser ? AppTheme.primaryTeal : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(msg.isUser ? 14 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 14),
          ),
          border: msg.isUser ? null : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            fontSize: 12,
            color: msg.isUser ? Colors.white : const Color(0xFF0F172A),
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        backgroundColor: const Color(0xFFF0FDFA),
        side: const BorderSide(color: Color(0xFF99F6E4)),
        label: Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0xFF0F766E))),
        onPressed: () => _sendMessage(label),
      ),
    );
  }
}
