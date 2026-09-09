import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/gibbs_reflection.dart';
import '../models/student_profile.dart';
import '../services/storage_service.dart';
import 'gibbs_report_screen.dart';

class GibbsFormScreen extends StatefulWidget {
  const GibbsFormScreen({Key? key}) : super(key: key);

  @override
  State<GibbsFormScreen> createState() => _GibbsFormScreenState();
}

class _GibbsFormScreenState extends State<GibbsFormScreen> {
  int _currentStep = 1; // 1 to 6
  final TextEditingController _caseNameController = TextEditingController(text: 'Pasien sesak napas akut dengan hipertensi emergensi');
  final TextEditingController _rotationController = TextEditingController(text: 'Rotasi Interna — RSUD Dr. Soetomo');
  final TextEditingController _stageTextController = TextEditingController();

  String _selectedMood = 'Cemas';
  bool _showGuide = false;

  final Map<int, String> _stageTexts = {
    1: 'Hari ini saya merawat Tn. X, 58 tahun, datang dengan sesak napas mendadak. Saat visite pagi, tekanan darahnya 180/110 mmHg. Saya sempat panik saat pasien tampak gelisah dan saturasinya turun ke 89%.',
    2: 'Saya merasa sangat tegang dan khawatir membuat keputusan yang keliru. Ada perasaan ragu apakah harus langsung memberi antihipertensi parenteral atau menunggu instruksi konsulen.',
    3: 'Hal baik: Saya segera memposisikan pasien semi-fowler dan memasang kanul oksigen 4 lpm. Hal kurang baik: Saya terlambat melaporkan perburukan klinis ini ke dokter jaga ruangan.',
    4: 'Kepanikan terjadi karena saya belum terlatih dalam algoritma crisis resource management dan komunikasi darurat SBAR dalam situasi kritis akut.',
    5: 'Saya menyadari bahwa komunikasi eskalasi segera (calling for help) adalah prioritas keselamatan pasien nomor satu, di atas rasa takut atau sungkan.',
    6: 'Saya akan menghafal algoritma hipertensi emergensi dan mempraktikkan simulasi SBAR sebelum giliran dinas jaga berikutnya.',
  };

  final List<Map<String, String>> _stepMeta = [
    {'tag': 'Deskripsi', 'sub': 'Description', 'q': 'Apa yang terjadi?', 'guide': 'Ceritakan kronologi kejadian faktual: apa yang terjadi, siapa saja yang ada di ruangan, apa tugas Anda, dan bagaimana situasi klinis berkembang.'},
    {'tag': 'Perasaan', 'sub': 'Feelings', 'q': 'Apa yang Anda rasakan?', 'guide': 'Jelaskan emosi dan respon internal Anda saat peristiwa terjadi maupun setelahnya.'},
    {'tag': 'Evaluasi', 'sub': 'Evaluation', 'q': 'Apa yang baik dan buruk?', 'guide': 'Tinjau secara jujur apa aspek yang berjalan lancar, dan apa yang terasa kurang berhasil.'},
    {'tag': 'Analisis', 'sub': 'Analysis', 'q': 'Mengapa hal itu terjadi?', 'guide': 'Gali lebih dalam akar penyebabnya. Apakah ada faktor beban kerja, komunikasi tim, atau SOP?'},
    {'tag': 'Kesimpulan', 'sub': 'Conclusion', 'q': 'Apa pelajaran bagi diri Anda?', 'guide': 'Apa insight dan pemahaman baru tentang diri Anda sebagai calon dokter?'},
    {'tag': 'Rencana Aksi', 'sub': 'Action Plan', 'q': 'Apa komitmen tindakan ke depan?', 'guide': 'Rumuskan rencana konkret (SMART: Specific, Measurable, Achievable, Relevant, Time-bound).'},
  ];

  @override
  void initState() {
    super.initState();
    _stageTextController.text = _stageTexts[_currentStep] ?? '';
  }

  void _switchStep(int step) {
    _stageTexts[_currentStep] = _stageTextController.text.trim();
    setState(() {
      _currentStep = step;
      _stageTextController.text = _stageTexts[step] ?? '';
      _showGuide = false;
    });
  }

  void _nextStep() async {
    _stageTexts[_currentStep] = _stageTextController.text.trim();
    if (_currentStep < 6) {
      _switchStep(_currentStep + 1);
    } else {
      // Selesai -> Compile to GibbsReflection & Open Report
      final profile = await StorageService.loadProfile();
      final reflection = GibbsReflection(
        id: 'ref-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        title: _caseNameController.text.trim().isNotEmpty ? _caseNameController.text.trim() : 'Refleksi Kasus Klinis',
        studentName: profile.fullName,
        studentId: profile.studentId,
        department: profile.currentDepartment,
        hospital: profile.teachingHospital,
        supervisorName: profile.supervisorName,
        description: _stageTexts[1] ?? '',
        feelings: _stageTexts[2] ?? '',
        evaluation: _stageTexts[3] ?? '',
        analysis: _stageTexts[4] ?? '',
        conclusion: _stageTexts[5] ?? '',
        actionPlan: _stageTexts[6] ?? '',
        smartAction: SmartActionPlan(
          specific: 'Menghafal format SBAR dan mengaplikasikannya pada setiap pergantian shift jaga.',
          measurable: 'Mampu menyampaikan laporan kasus gawat darurat secara ringkas dalam < 90 detik.',
          achievable: 'Bisa dilatih bersama rekan sesama dokter muda sebelum visite.',
          relevant: 'Terkait langsung dengan keselamatan pasien dan kompetensi stase Interna.',
          timeBound: 'Diterapkan mulai putaran dinas jaga minggu ini.',
        ),
        depthLevel: ReflectionDepth.analytical,
        depthRationale: 'Refleksi mencapai level Analytical: Mahasiswa menguraikan 6 fase Gibbs secara lengkap dan menyusun rencana tindakan terukur.',
        keyTakeaway: 'Refleksi yang jujur mengubah pengalaman klinis biasa menjadi keahlian profesional sejati.',
      );

      await StorageService.saveReflection(reflection);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GibbsReportScreen(reflection: reflection)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = _stepMeta[_currentStep - 1];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // TEAL HEADER (matching REFLEKSI.png)
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
                      const Text(
                        'Medireflect AI',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Tahap $_currentStep / 6',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _currentStep / 6.0,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 6 Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(6, (idx) {
                        final sNum = idx + 1;
                        final isActive = sNum == _currentStep;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => _switchStep(sNum),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.white : Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                _stepMeta[idx]['tag']!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                  color: isActive ? AppTheme.primaryTeal : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // FORM BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CARD 1: INFO KASUS
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
                            children: const [
                              Icon(Icons.folder_open, size: 16, color: AppTheme.primaryTeal),
                              SizedBox(width: 6),
                              Text('Info Kasus', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _caseNameController,
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              labelText: 'Nama / Deskripsi Kasus',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _rotationController,
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              labelText: 'Rotasi / Stase',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text('Mood saat ini', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMoodBtn('🌧️', 'Berat'),
                              _buildMoodBtn('😟', 'Cemas'),
                              _buildMoodBtn('😐', 'Netral'),
                              _buildMoodBtn('😊', 'Baik'),
                              _buildMoodBtn('😁', 'Positif'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // CARD 2: GIBBS STAGE
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
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTeal.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  meta['tag']!,
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(meta['sub']!, style: TextStyle(fontSize: 10.5, color: Colors.grey[600])),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            meta['q']!,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 8),

                          // Accordion Guide
                          InkWell(
                            onTap: () => setState(() => _showGuide = !_showGuide),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDFA),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFCCFBF1)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.lightbulb_outline, size: 14, color: AppTheme.primaryTealDark),
                                  const SizedBox(width: 6),
                                  const Text('Panduan refleksi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTealDark)),
                                  const Spacer(),
                                  Icon(_showGuide ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: AppTheme.primaryTealDark),
                                ],
                              ),
                            ),
                          ),
                          if (_showGuide)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(meta['guide']!, style: TextStyle(fontSize: 11, color: Colors.grey[700], height: 1.35)),
                              ),
                            ),
                          const SizedBox(height: 10),

                          TextField(
                            controller: _stageTextController,
                            maxLines: 5,
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              hintText: 'Ketik refleksi Anda di sini...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(10),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_stageTextController.text.length} karakter',
                                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                              ),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                icon: const Icon(Icons.mic, size: 13, color: AppTheme.primaryTeal),
                                label: const Text('Suara', style: TextStyle(fontSize: 10.5, color: AppTheme.primaryTeal)),
                                onPressed: () {
                                  setState(() {
                                    _stageTextController.text = 'Saat visite bersama DPJP, saya merasa tegang ketika ditanya mengenai diferensial diagnosis pasien sesak napas. Namun saya berusaha menyampaikan penemuan ronkhi.';
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Lanjut Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        icon: Icon(_currentStep == 6 ? Icons.check_circle : Icons.arrow_forward, size: 16),
                        label: Text(
                          _currentStep == 6 ? 'Selesai & Ekspor Laporan' : 'Lanjut Tahap Berikutnya',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        onPressed: _nextStep,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodBtn(String emoji, String label) {
    final isSelected = _selectedMood == label;
    return InkWell(
      onTap: () => setState(() => _selectedMood = label),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 54,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDFA) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppTheme.primaryTeal : const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: isSelected ? AppTheme.primaryTeal : Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}
