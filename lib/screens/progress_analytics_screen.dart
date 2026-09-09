import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ProgressAnalyticsScreen extends StatelessWidget {
  const ProgressAnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // TEAL HEADER
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
                      const Text(
                        'Progress & Analitik',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.white, size: 20),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 4 Stats Grid
                  Row(
                    children: [
                      _buildStatPill('24', 'Refleksi', Icons.bookmark_border),
                      const SizedBox(width: 6),
                      _buildStatPill('79%', 'Avg Depth', Icons.trending_up),
                      const SizedBox(width: 6),
                      _buildStatPill('7h', 'Streak', Icons.radio_button_checked),
                      const SizedBox(width: 6),
                      _buildStatPill('4/6', 'Badge', Icons.military_tech_outlined),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Segmented Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Row(
                      children: [
                        Expanded(child: _buildSegTab('Ringkasan', true)),
                        Expanded(child: _buildSegTab('Riwayat', false)),
                        Expanded(child: _buildSegTab('Badge', false)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CARD 1: TREN KEDALAMAN REFLEKSI
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
                              const Text('Tren Kedalaman Refleksi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text('+43% bulan ini', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Custom Painter Line Graph
                          SizedBox(
                            height: 120,
                            width: double.infinity,
                            child: CustomPaint(painter: _TrendLinePainter()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // CARD 2: PROFIL KOMPETENSI (RADAR)
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
                          const Text('Profil Kompetensi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const Text('Berdasarkan tema refleksi Anda', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                          const SizedBox(height: 14),
                          // Custom Painter Radar Chart
                          Center(
                            child: SizedBox(
                              width: 260,
                              height: 200,
                              child: CustomPaint(painter: _CompetencyRadarPainter()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // TOPIC TAGS
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: const [
                        _TopicTag('komunikasi', true),
                        _TopicTag('empati', true),
                        _TopicTag('pasien', false),
                        _TopicTag('keputusan klinis', false),
                        _TopicTag('tim medis', false),
                        _TopicTag('refleksi diri', false),
                        _TopicTag('profesionalisme', true),
                        _TopicTag('patient safety', false),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // CARD 3: INSIGHT AI GUIDE
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF99F6E4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.star_outline, size: 16, color: AppTheme.primaryTeal),
                              SizedBox(width: 6),
                              Text('Insight AI Guide', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryTealDark)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Refleksi Anda menunjukkan peningkatan signifikan dalam kedalaman analisis (+43% bulan ini). Tema komunikasi paling sering muncul — pertimbangkan mengeksplorasi SPIKES protocol lebih dalam. Area yang perlu perhatian: empati dalam situasi kritis.',
                            style: TextStyle(fontSize: 11.5, color: Color(0xFF334155), height: 1.4),
                          ),
                        ],
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

  Widget _buildStatPill(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 8.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSegTab(String title, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          color: active ? AppTheme.primaryTeal : Colors.white70,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TopicTag extends StatelessWidget {
  final String label;
  final bool highlight;
  const _TopicTag(this.label, this.highlight, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFE0F2FE) : Colors.white,
        border: Border.all(color: highlight ? const Color(0xFF7DD3FC) : const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
          color: highlight ? const Color(0xFF0369A1) : const Color(0xFF475569),
        ),
      ),
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = AppTheme.primaryTeal
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final paintDot = Paint()..color = AppTheme.primaryTeal;
    final paintWhite = Paint()..color = Colors.white;

    final points = [
      Offset(10, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.58),
      Offset(size.width * 0.4, size.height * 0.52),
      Offset(size.width * 0.6, size.height * 0.40),
      Offset(size.width * 0.8, size.height * 0.32),
      Offset(size.width - 10, size.height * 0.22),
    ];

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paintLine);

    for (var pt in points) {
      canvas.drawCircle(pt, 4, paintDot);
      canvas.drawCircle(pt, 2, paintWhite);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompetencyRadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height * 0.42;

    final webPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final fillPaint = Paint()
      ..color = AppTheme.primaryTeal.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppTheme.primaryTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 6 Axis Polygons
    const sides = 6;
    for (int ring = 1; ring <= 3; ring++) {
      final r = (radius / 3) * ring;
      final path = Path();
      for (int i = 0; i < sides; i++) {
        final angle = (i * 3.14159 * 2 / sides) - (3.14159 / 2);
        final pt = Offset(center.dx + r * (angle).toDouble(), center.dy + r * (angle).toDouble());
        // Simplified polygon web
      }
    }

    // Draw centered circle indicator
    canvas.drawCircle(center, radius, webPaint);
    canvas.drawCircle(center, radius * 0.66, webPaint);
    canvas.drawCircle(center, radius * 0.33, webPaint);

    final polyPath = Path();
    polyPath.moveTo(center.dx, center.dy - radius * 0.85);
    polyPath.lineTo(center.dx + radius * 0.8, center.dy - radius * 0.4);
    polyPath.lineTo(center.dx + radius * 0.85, center.dy + radius * 0.5);
    polyPath.lineTo(center.dx, center.dy + radius * 0.75);
    polyPath.lineTo(center.dx - radius * 0.8, center.dy + radius * 0.45);
    polyPath.lineTo(center.dx - radius * 0.75, center.dy - radius * 0.35);
    polyPath.close();

    canvas.drawPath(polyPath, fillPaint);
    canvas.drawPath(polyPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
