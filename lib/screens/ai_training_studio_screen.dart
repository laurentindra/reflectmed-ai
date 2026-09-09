import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import '../models/training_exemplar.dart';
import '../services/ai_training_service.dart';

class AiTrainingStudioScreen extends StatefulWidget {
  const AiTrainingStudioScreen({Key? key}) : super(key: key);

  @override
  State<AiTrainingStudioScreen> createState() => _AiTrainingStudioScreenState();
}

class _AiTrainingStudioScreenState extends State<AiTrainingStudioScreen>
    with SingleTickerProviderStateMixin {
  final AiTrainingService _trainingService = AiTrainingService();
  late TabController _tabController;

  // Form State Kalibrasi Persona
  late double _empathyLevel;
  late double _socraticChallenge;
  late double _academicScaffolding;
  late String _activeFramework;
  late bool _detectAssessmentTension;
  late bool _autoSuggestLiterature;

  // Playground State
  final TextEditingController _testInputController = TextEditingController(
    text: 'Dok, tadi di bangsal bedah saya ditegur residen karena belum hafal hasil lab elektrolit pasien post-op. Saya merasa sangat malu di depan suster dan pasien.',
  );
  String _selectedPlaygroundContext = 'Ilmu Bedah';
  bool _isTestingPlayground = false;
  Map<String, dynamic>? _playgroundResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCurrentConfig();
  }

  void _loadCurrentConfig() {
    final persona = _trainingService.currentPersona;
    _empathyLevel = persona.empathyLevel;
    _socraticChallenge = persona.socraticChallenge;
    _academicScaffolding = persona.academicScaffolding;
    _activeFramework = persona.activeFramework;
    _detectAssessmentTension = persona.detectAssessmentTension;
    _autoSuggestLiterature = persona.autoSuggestLiterature;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _testInputController.dispose();
    super.dispose();
  }

  Future<void> _savePersonaConfig() async {
    final updated = MentorPersonaConfig(
      empathyLevel: _empathyLevel,
      socraticChallenge: _socraticChallenge,
      academicScaffolding: _academicScaffolding,
      activeFramework: _activeFramework,
      detectAssessmentTension: _detectAssessmentTension,
      autoSuggestLiterature: _autoSuggestLiterature,
    );
    await _trainingService.updatePersona(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Kalibrasi persona AI berhasil disimpan ke memori aplikasi!'),
        backgroundColor: AppTheme.primaryTeal,
      ),
    );
  }

  Future<void> _runPlaygroundTest() async {
    setState(() => _isTestingPlayground = true);
    final result = await _trainingService.testPlaygroundPrompt(
      testInput: _testInputController.text,
      clinicalContext: _selectedPlaygroundContext,
    );
    if (!mounted) return;
    setState(() {
      _playgroundResult = result;
      _isTestingPlayground = false;
    });
  }

  void _openAddExemplarDialog() {
    final titleCtrl = TextEditingController();
    final deptCtrl = TextEditingController(text: 'Ilmu Penyakit Dalam');
    final scenarioCtrl = TextEditingController();
    final studentCtrl = TextEditingController();
    final mentorCtrl = TextEditingController();
    String gibbsPhase = 'Feelings & Analysis';
    String depthLevel = 'Analytical';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: const [
              Icon(Icons.add_task, color: AppTheme.primaryTeal),
              SizedBox(width: 8),
              Text('Tambah Kasus Teladan Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Judul Kasus (misal: Salah Jalur Komunikasi)'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: deptCtrl,
                    decoration: const InputDecoration(labelText: 'Departemen / Stase'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: scenarioCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Kronologi Kasus Singkat'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: studentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Curhat / Kalimat Mahasiswa'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: mentorCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Respons Ideal Mentor (AMEE Guide 44)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: gibbsPhase,
                    decoration: const InputDecoration(labelText: 'Fase Siklus Gibbs yang Disasar'),
                    items: const [
                      DropdownMenuItem(value: 'Description', child: Text('Fase 1: Deskripsi')),
                      DropdownMenuItem(value: 'Feelings & Analysis', child: Text('Fase 2 & 4: Perasaan & Analisis')),
                      DropdownMenuItem(value: 'Evaluation', child: Text('Fase 3: Evaluasi')),
                      DropdownMenuItem(value: 'Action Plan', child: Text('Fase 6: Rencana Aksi (SMART)')),
                    ],
                    onChanged: (v) => setDialogState(() => gibbsPhase = v ?? gibbsPhase),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
              onPressed: () async {
                if (titleCtrl.text.isEmpty || studentCtrl.text.isEmpty) return;
                final newEx = TrainingExemplar(
                  id: 'ex-${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text,
                  department: deptCtrl.text,
                  clinicalScenario: scenarioCtrl.text,
                  studentInput: studentCtrl.text,
                  idealMentorResponse: mentorCtrl.text,
                  targetGibbsPhase: gibbsPhase,
                  targetDepthLevel: depthLevel,
                  tags: ['Klinis', deptCtrl.text],
                  isDefault: false,
                );
                await _trainingService.addExemplar(newEx);
                if (!mounted) return;
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kasus teladan berhasil ditambahkan ke Bank Data Pelatihan!')),
                );
              },
              child: const Text('Simpan Kasus', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppTheme.darkTeal,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.model_training, color: AppTheme.accentMint),
            const SizedBox(width: 8),
            const Text('Studio Pelatihan AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentMint.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Educator Mode',
                style: TextStyle(fontSize: 10, color: AppTheme.accentMint, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentMint,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.tune, size: 18), text: 'Persona & Kalibrasi'),
            Tab(icon: Icon(Icons.source_outlined, size: 18), text: 'Bank Kasus (Exemplars)'),
            Tab(icon: Icon(Icons.science_outlined, size: 18), text: 'Playground Uji Coba'),
            Tab(icon: Icon(Icons.download_for_offline_outlined, size: 18), text: 'Ekspor JSONL'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonaTab(),
          _buildExemplarsTab(),
          _buildPlaygroundTab(),
          _buildExportTab(),
        ],
      ),
    );
  }

  // ================= TAB 1: PERSONA & KALIBRASI =================
  Widget _buildPersonaTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Card Info Pedagogis AMEE Guide 44
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDFA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF99F6E4)),
          ),
          child: Row(
            children: const [
              Icon(Icons.psychology, color: AppTheme.primaryTeal, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kalibrasi Pedagogis Berstandar AMEE Guide No. 44',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Atur profil interaksi AI agar menghasilkan "Supportive Challenge" — menantang mental model mahasiswa dengan rasa aman tanpa kecemasan penilaian.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Slider 1: Empati
        _buildSliderCard(
          title: 'Skala Empati & Validasi Emosional',
          icon: Icons.favorite_border,
          value: _empathyLevel,
          min: 1.0,
          max: 5.0,
          labelLeft: 'Objektif / Ketat (1.0)',
          labelRight: 'Sangat Empatik (5.0)',
          description: _getEmpathyDescription(_empathyLevel),
          onChanged: (v) => setState(() => _empathyLevel = v),
        ),
        const SizedBox(height: 14),

        // Slider 2: Socratic Challenge
        _buildSliderCard(
          title: 'Intensitas Tantangan Sokratik (Socratic Challenge)',
          icon: Icons.question_answer_outlined,
          value: _socraticChallenge,
          min: 1.0,
          max: 5.0,
          labelLeft: 'Menyetujui (1.0)',
          labelRight: 'Kritis Menantang (5.0)',
          description: _getSocraticDescription(_socraticChallenge),
          onChanged: (v) => setState(() => _socraticChallenge = v),
        ),
        const SizedBox(height: 14),

        // Slider 3: Ketertiban Akademik Gibbs
        _buildSliderCard(
          title: 'Ketertiban Struktur Akademik Gibbs (6 Fase)',
          icon: Icons.school_outlined,
          value: _academicScaffolding,
          min: 1.0,
          max: 5.0,
          labelLeft: 'Santai / Fleksibel (1.0)',
          labelRight: 'Sangat Terstruktur (5.0)',
          description: _getAcademicDescription(_academicScaffolding),
          onChanged: (v) => setState(() => _academicScaffolding = v),
        ),
        const SizedBox(height: 16),

        // Pengaturan Khusus
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Prinsip Refleksi & Etika', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.darkTeal)),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primaryTeal,
                title: const Text('Redam "Assessment Tension"', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: const Text('AI secara eksplisit menegaskan percakapan ini murni pembelajaran, bukan nilai ujian', style: TextStyle(fontSize: 11)),
                value: _detectAssessmentTension,
                onChanged: (v) => setState(() => _detectAssessmentTension = v),
              ),
              const Divider(height: 1),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primaryTeal,
                title: const Text('Rekomendasikan Literatur EBM / Etika', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: const Text('AI memberikan saran rujukan jurnal atau pedoman klinis terkait kasus yang dicurhatkan', style: TextStyle(fontSize: 11)),
                value: _autoSuggestLiterature,
                onChanged: (v) => setState(() => _autoSuggestLiterature = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryTeal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _savePersonaConfig,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Simpan Kalibrasi Persona ke AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }

  // ================= TAB 2: BANK KASUS TELADAN =================
  Widget _buildExemplarsTab() {
    final exemplars = _trainingService.exemplars;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryTeal,
        onPressed: _openAddExemplarDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Kasus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: exemplars.length,
        itemBuilder: (ctx, i) {
          final ex = exemplars[i];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryTeal.withOpacity(0.12),
                child: Text('${i + 1}', style: const TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
              ),
              title: Text(ex.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              subtitle: Text('${ex.department} · Target: ${ex.targetDepthLevel}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const Text('Skenario Klinis:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Text(ex.clinicalScenario, style: const TextStyle(fontSize: 11.5, color: Colors.black87)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Curhat Mahasiswa:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            const SizedBox(height: 2),
                            Text('"${ex.studentInput}"', style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFF0FDFA), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Respons Ideal Mentor (AMEE Guide 44):', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                            const SizedBox(height: 2),
                            Text(ex.idealMentorResponse, style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F766E))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: ex.tags.map((t) => Chip(
                          label: Text(t, style: const TextStyle(fontSize: 9.5)),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          backgroundColor: const Color(0xFFE0F2FE),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= TAB 3: PLAYGROUND UJI MODEL =================
  Widget _buildPlaygroundTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Uji Coba Respon AI Terkalibrasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  DropdownButton<String>(
                    value: _selectedPlaygroundContext,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'Ilmu Bedah', child: Text('Ilmu Bedah', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Ilmu Penyakit Dalam', child: Text('Ilmu Penyakit Dalam', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Pediatri', child: Text('Pediatri', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'IGD & Emergensi', child: Text('IGD & Emergensi', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (v) => setState(() => _selectedPlaygroundContext = v ?? 'Ilmu Bedah'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _testInputController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Masukkan teks curhat atau situasi klinis yang dialami koas...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isTestingPlayground ? null : _runPlaygroundTest,
                  icon: _isTestingPlayground
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.play_arrow),
                  label: Text(_isTestingPlayground ? 'Mengkalibrasi & Menganalisis...' : 'Uji Respon Model', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Hasil Respons
        if (_playgroundResult != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF99F6E4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.smart_toy_outlined, color: AppTheme.primaryTeal, size: 20),
                        SizedBox(width: 8),
                        Text('Respons Model Terkalibrasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.darkTeal)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppTheme.primaryTeal, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        'Level: ${_playgroundResult!['depth']}',
                        style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _playgroundResult!['response'] as String,
                  style: const TextStyle(fontSize: 12.5, height: 1.45, color: Color(0xFF0F172A)),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fase Gibbs: ${_playgroundResult!['gibbsPhaseDetected']}', style: const TextStyle(fontSize: 11, color: Color(0xFF0F766E), fontWeight: FontWeight.bold)),
                    Text('Skor Keselarasan: ${_playgroundResult!['score']}%', style: const TextStyle(fontSize: 11, color: Color(0xFF0F766E), fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ================= TAB 4: EKSPOR JSONL =================
  Widget _buildExportTab() {
    final jsonlSample = _trainingService.exportToJsonl();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.terminal, color: AppTheme.darkTeal),
                  SizedBox(width: 8),
                  Text('Dataset Fine-Tuning Google Gemini & OpenAI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Dataset ini berisi seluruh pasangan curhat mahasiswa dan respons ideal mentor AMEE Guide 44 dalam format standar JSONL. Siap diunggah ke Google AI Studio atau Vertex AI.',
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Code Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              jsonlSample.length > 600 ? '${jsonlSample.substring(0, 600)}...\n\n[dan seterusnya...]' : jsonlSample,
              style: const TextStyle(color: Color(0xFF38BDF8), fontFamily: 'monospace', fontSize: 10.5),
            ),
          ),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppTheme.primaryTeal),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: jsonlSample));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dataset JSONL berhasil disalin ke clipboard!')),
                  );
                },
                icon: const Icon(Icons.copy, color: AppTheme.primaryTeal, size: 18),
                label: const Text('Salin JSONL', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('File medireflect_dataset.jsonl siap di folder training/ untuk pipeline Vertex AI!'),
                      backgroundColor: AppTheme.primaryTeal,
                    ),
                  );
                },
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Simpan File', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper Slider Card
  Widget _buildSliderCard({
    required String title,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required String labelLeft,
    required String labelRight,
    required String description,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppTheme.primaryTeal, size: 18),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(value.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal, fontSize: 12)),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: 40,
            activeColor: AppTheme.primaryTeal,
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(labelLeft, style: const TextStyle(fontSize: 10, color: Colors.black45)),
              Text(labelRight, style: const TextStyle(fontSize: 10, color: Colors.black45)),
            ],
          ),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(fontSize: 11, color: Color(0xFF0F766E), fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  String _getEmpathyDescription(double v) {
    if (v >= 4.5) return '✨ Sangat Hangat & Validatif: Memprioritaskan penenteraman emosi sebelum masuk ke telaah medis.';
    if (v >= 3.5) return '⚖️ Seimbang & Suportif: Memberikan empati hangat disertai dorongan objektivitas klinis.';
    return '🔬 Objektif & Ketat: Berfokus pada fakta tindakan medis dan kepatuhan prosedur.';
  }

  String _getSocraticDescription(double v) {
    if (v >= 4.0) return '💡 Socratic Probing Mendalam: Menantang asumsi bawah sadar mahasiswa secara intensif.';
    if (v >= 3.0) return '🎯 Pertanyaan Terarah: Menanyakan 1-2 pertanyaan reflektif bertahap.';
    return '🤝 Suportif Pasif: Lebih banyak mendengarkan tanpa menekan mahasiswa.';
  }

  String _getAcademicDescription(double v) {
    if (v >= 4.0) return '📘 Sangat Patuh Gibbs & SMART: Menjamin setiap curhat berakhir dengan rencana aksi terukur.';
    return '💬 Curhat Fleksibel: Mengikuti alur percakapan alami tanpa batasan kaku 6 fase.';
  }
}
