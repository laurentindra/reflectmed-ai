import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import '../models/gibbs_reflection.dart';

class EPortfolioSyncScreen extends StatelessWidget {
  final GibbsReflection reflection;

  const EPortfolioSyncScreen({Key? key, required this.reflection}) : super(key: key);

  void _copyToClipboard(BuildContext context, String title, String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('$title berhasil disalin ke clipboard!')),
          ],
        ),
        backgroundColor: AppTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _generateFullEssay() {
    return '''
======================================================
LAPORAN REFLEKSI KLINIS (GIBBS REFLECTIVE CYCLE)
======================================================
Nama Mahasiswa : ${reflection.studentName}
NIM            : ${reflection.studentId}
Stase / Bagian : ${reflection.department}
RS Pendidikan  : ${reflection.hospital}
DPJP           : ${reflection.supervisorName}
Topik          : ${reflection.title}
Tingkat Refleksi: ${reflection.depthLabel}
------------------------------------------------------

1. DESKRIPSI (DESCRIPTION)
${reflection.description}

2. PERASAAN (FEELINGS)
${reflection.feelings}

3. EVALUASI (EVALUATION)
${reflection.evaluation}

4. ANALISIS (ANALYSIS)
${reflection.analysis}

5. KESIMPULAN (CONCLUSION)
${reflection.conclusion}

6. RENCANA TINDAKAN (ACTION PLAN - SMART)
${reflection.actionPlan}

[SMART Criteria]
- Specific    : ${reflection.smartAction.specific}
- Measurable  : ${reflection.smartAction.measurable}
- Achievable  : ${reflection.smartAction.achievable}
- Relevant    : ${reflection.smartAction.relevant}
- Time-bound  : ${reflection.smartAction.timeBound}

Key Takeaway:
"${reflection.keyTakeaway}"
======================================================
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Integrasi e-Portofolio', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BANNER INSTRUKSI
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF99F6E4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.copy_all, color: AppTheme.primaryTeal, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Salin Tanpa Ketik Ulang',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F766E)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Gunakan tombol di bawah untuk menempel teks langsung ke kolom e-Portofolio kampus atau LMS Moodle.',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF334155)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // TOMBOL SALIN UTUH 1-KLIK
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.description, color: Colors.white),
              label: const Text('Salin Seluruh Esai Refleksi (1-Klik)', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => _copyToClipboard(context, 'Seluruh Esai', _generateFullEssay()),
            ),
            const SizedBox(height: 10),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.darkSurface,
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.data_object, size: 18),
              label: const Text('Ekspor Data JSON (Untuk API LMS / SIM Portofolio)'),
              onPressed: () => _copyToClipboard(context, 'Data JSON', jsonEncode(reflection.toJson())),
            ),
            const SizedBox(height: 20),

            const Text(
              'Salin Per Kolom Isian e-Portofolio:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),

            _buildCopyField(context, '1. Deskripsi Kejadian (Description)', reflection.description),
            _buildCopyField(context, '2. Perasaan & Emosi (Feelings)', reflection.feelings),
            _buildCopyField(context, '3. Evaluasi Positif & Negatif (Evaluation)', reflection.evaluation),
            _buildCopyField(context, '4. Analisis Mendalam (Analysis)', reflection.analysis),
            _buildCopyField(context, '5. Kesimpulan (Conclusion)', reflection.conclusion),
            _buildCopyField(context, '6. Rencana Aksi (Action Plan)', reflection.actionPlan),
            _buildCopyField(
              context,
              'Rencana Aksi SMART (Specific - Measurable - Achievable - Relevant - Time-bound)',
              'Specific: ${reflection.smartAction.specific}\nMeasurable: ${reflection.smartAction.measurable}\nAchievable: ${reflection.smartAction.achievable}\nRelevant: ${reflection.smartAction.relevant}\nTime-bound: ${reflection.smartAction.timeBound}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyField(BuildContext context, String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ),
              InkWell(
                onTap: () => _copyToClipboard(context, title, content),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.copy, size: 13, color: AppTheme.primaryTeal),
                      SizedBox(width: 4),
                      Text('Salin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content.isNotEmpty ? content : 'Belum diisi.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5, color: Colors.grey[700], height: 1.3),
          ),
        ],
      ),
    );
  }
}
