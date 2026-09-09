import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/gibbs_reflection.dart';

class PdfGeneratorService {
  /// Menghasilkan berkas PDF Laporan Refleksi Klinis Mahasiswa berstandar akademik
  static Future<Uint8List> generateReflectionPdf(GibbsReflection reflection) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');

    final primaryColor = PdfColor.fromHex('0D9488'); // Deep Teal
    final darkNavy = PdfColor.fromHex('0F172A');
    final subtleGrey = PdfColor.fromHex('F1F5F9');
    final borderGrey = PdfColor.fromHex('CBD5E1');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return [
            // HEADER DOKUMEN RESMI
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 12),
              decoration: pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: primaryColor, width: 2.5)),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'REFLECTMED AI · CLINICAL PORTFOLIO',
                        style: pw.TextStyle(
                          color: primaryColor,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'LAPORAN REFLEKSI KLINIS MAHASISWA',
                        style: pw.TextStyle(
                          color: darkNavy,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Berdasarkan Kerangka Gibbs Reflective Cycle (1988) & AMEE Guide No. 44',
                        style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 8.5),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: subtleGrey,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: borderGrey),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Status Portofolio: Siap Asesmen',
                            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                        pw.Text(dateFormat.format(reflection.createdAt),
                            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // TABEL IDENTITAS MAHASISWA & STASE KLINIS
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: subtleGrey,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: borderGrey),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Nama Mahasiswa', reflection.studentName.isNotEmpty ? reflection.studentName : 'dr. Muda / Mahasiswa'),
                        _buildInfoRow('NIM / Stambuk', reflection.studentId.isNotEmpty ? reflection.studentId : '-'),
                        _buildInfoRow('Departemen / Stase', reflection.department),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('RS Pendidikan', reflection.hospital),
                        _buildInfoRow('DPJP / Preseptor', reflection.supervisorName.isNotEmpty ? reflection.supervisorName : 'Dokter Penanggung Jawab'),
                        _buildInfoRow('Tingkat Kedalaman', reflection.depthLabel),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // JUDUL KASUS REFLEKSI
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('E6FFFA'),
                border: pw.Border.all(color: primaryColor, width: 0.8),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                'Topik / Judul: ${reflection.title}',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primaryColor),
              ),
            ),
            pw.SizedBox(height: 14),

            // 6 FASE SIKLUS GIBBS
            _buildGibbsSection(1, 'Description (Apa yang terjadi?)', reflection.description, primaryColor),
            _buildGibbsSection(2, 'Feelings (Apa yang dirasakan?)', reflection.feelings, primaryColor),
            _buildGibbsSection(3, 'Evaluation (Evaluasi: Baik vs Kurang Baik)', reflection.evaluation, primaryColor),
            _buildGibbsSection(4, 'Analysis (Analisis Mendalam: Mengapa terjadi?)', reflection.analysis, primaryColor),
            _buildGibbsSection(5, 'Conclusion (Kesimpulan & Pembelajaran Diri)', reflection.conclusion, primaryColor),
            _buildGibbsSection(6, 'Action Plan (Rencana Tindakan Berkelanjutan)', reflection.actionPlan, primaryColor),

            pw.SizedBox(height: 10),

            // TABEL SMART ACTION PLAN
            pw.Text(
              'KOMITMEN RENCANA AKSI (SMART CRITERIA):',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: darkNavy),
            ),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(color: borderGrey, width: 0.5),
              children: [
                _buildSmartTableRow('S - Specific (Spesifik)', reflection.smartAction.specific),
                _buildSmartTableRow('M - Measurable (Terukur)', reflection.smartAction.measurable),
                _buildSmartTableRow('A - Achievable (Dapat Dicapai)', reflection.smartAction.achievable),
                _buildSmartTableRow('R - Relevant (Relevan)', reflection.smartAction.relevant),
                _buildSmartTableRow('T - Time-Bound (Batas Waktu)', reflection.smartAction.timeBound),
              ],
            ),
            pw.SizedBox(height: 16),

            // LEMBAR PENGESAHAN PRESEPTOR / DPJP
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Mahasiswa Kedokteran,', style: const pw.TextStyle(fontSize: 8.5)),
                    pw.SizedBox(height: 38),
                    pw.Text('(${reflection.studentName})', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                    pw.Text('NIM: ${reflection.studentId}', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Mengetahui / Verifikasi DPJP,', style: const pw.TextStyle(fontSize: 8.5)),
                    pw.SizedBox(height: 38),
                    pw.Text('(${reflection.supervisorName.isNotEmpty ? reflection.supervisorName : "dr. Pembimbing Klinik"})',
                        style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                    pw.Text('NIP/SIP: .......................................', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 95,
            child: pw.Text('$label:', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 8, color: PdfColors.black)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildGibbsSection(int step, String title, String content, PdfColor primaryColor) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColor.fromHex('E2E8F0')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 14,
                height: 14,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Text('$step', style: const pw.TextStyle(color: PdfColors.white, fontSize: 8)),
              ),
              pw.SizedBox(width: 6),
              pw.Text(title, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: primaryColor)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            content.isNotEmpty ? content : 'Belum diisi.',
            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey900, lineSpacing: 1.3),
          ),
        ],
      ),
    );
  }

  static pw.TableRow _buildSmartTableRow(String criteria, String details) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(4.5),
          child: pw.Text(criteria, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4.5),
          child: pw.Text(details.isNotEmpty ? details : '-', style: const pw.TextStyle(fontSize: 7.5)),
        ),
      ],
    );
  }

  /// Menampilkan lembar cetak/simpan langsung di Flutter
  static Future<void> printOrSharePdf(GibbsReflection reflection) async {
    final pdfBytes = await generateReflectionPdf(reflection);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Refleksi_Klinis_${reflection.studentId}_${reflection.department}.pdf',
    );
  }
}

