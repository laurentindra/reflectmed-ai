import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/gibbs_reflection.dart';
import '../models/student_profile.dart';
import '../services/storage_service.dart';
import 'gibbs_report_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  StudentProfile _profile = StudentProfile();
  List<GibbsReflection> _reflections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final profile = await StorageService.loadProfile();
    final list = await StorageService.loadReflections();
    setState(() {
      _profile = profile;
      _reflections = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F8),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. MEDIREFLECT TEAL HEADER (Matching DASHBOARD.png)
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryTeal, AppTheme.primaryTealDark],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 44, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar: Logo & Bell
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/images/logoo.png',
                              height: 32,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/logo.png',
                                height: 32,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Text(
                                  'ReflectMed AI',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: const [
                                  Icon(Icons.notifications_none, color: Colors.white, size: 20),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: CircleAvatar(radius: 3.5, backgroundColor: AppTheme.accentAmber),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Date & Greeting
                        const Text(
                          'Senin, 22 Juni 2026',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Selamat Pagi, ${_profile.fullName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rotasi ${_profile.currentDepartment} — ${_profile.teachingHospital}',
                          style: const TextStyle(color: AppTheme.accentCyan, fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),

                        // Streak & Badges Row
                        Row(
                          children: [
                            _buildStreakBadge(Icons.local_fire_department, '7 hari streak'),
                            const SizedBox(width: 8),
                            _buildStreakBadge(Icons.star, '24 refleksi'),
                            const SizedBox(width: 8),
                            _buildStreakBadge(Icons.military_tech_outlined, 'Level 4'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 2. SCROLLABLE CONTENT BODY
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Floating Reminder Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.alarm, color: Color(0xFFD97706), size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Pengingat Refleksi',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Kasus hipertensi emergensi tadi — tulis sekarang sebelum terlupakan!',
                                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryTeal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  // Switch to reflection form
                                },
                                child: const Text('Mulai', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Section: Mulai Refleksi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Mulai Refleksi',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            Text(
                              'Lihat semua',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // 4 Grid Cards
                        Row(
                          children: [
                            Expanded(child: _buildGridActionCard('Kasus hari ini', Icons.medical_services_outlined, const Color(0xFFE0F2FE), const Color(0xFF0284C7))),
                            const SizedBox(width: 10),
                            Expanded(child: _buildGridActionCard('Momen emosional', Icons.favorite_border, const Color(0xFFE6FFFA), const Color(0xFF0D9488))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _buildGridActionCard('Belajar dari kesalahan', Icons.book_outlined, const Color(0xFFFEF3C7), const Color(0xFFD97706))),
                            const SizedBox(width: 10),
                            Expanded(child: _buildGridActionCard('Kerja tim klinis', Icons.people_outline, const Color(0xFFF3E8FF), const Color(0xFF7E22CE))),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Section: Perkembangan Kompetensi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Perkembangan Kompetensi',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            Text(
                              'Detail',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              _buildCompetencyBar('Clinical Reasoning', 0.78, '78%'),
                              const SizedBox(height: 10),
                              _buildCompetencyBar('Komunikasi Pasien', 0.85, '85%'),
                              const SizedBox(height: 10),
                              _buildCompetencyBar('Profesionalisme', 0.92, '92%'),
                              const SizedBox(height: 10),
                              _buildCompetencyBar('Empati & Humanisme', 0.70, '70%'),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDFA),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF99F6E4)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.chat_bubble_outline, size: 14, color: Color(0xFF0F766E)),
                                      SizedBox(width: 6),
                                      Text(
                                        'Tanya AI Guide untuk insight lebih dalam',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Section: Refleksi Terbaru
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Refleksi Terbaru',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            Text(
                              'Lihat semua',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        _buildRecentReflectCard('Kasus Gagal Jantung Akut', 'Rotasi Kardiologi • Kemarin', 0.85, '85%', Icons.favorite_border, const Color(0xFFFEE2E2), const Color(0xFFEF4444)),
                        const SizedBox(height: 8),
                        _buildRecentReflectCard('Komunikasi Berita Buruk', 'Rotasi Onkologi • 3 hari lalu', 0.72, '72%', Icons.chat_bubble_outline, const Color(0xFFE0F2FE), const Color(0xFF0284C7)),
                        const SizedBox(height: 8),
                        _buildRecentReflectCard('Prosedur Lumbal Pungsi', 'Rotasi Neurologi • 1 minggu lalu', 0.91, '91%', Icons.psychology, const Color(0xFFE0E7FF), const Color(0xFF4338CA)),
                        const SizedBox(height: 16),

                        // Donald Schön Quote Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDFA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF99F6E4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Row(
                                children: [
                                  Icon(Icons.auto_awesome, size: 14, color: AppTheme.primaryTeal),
                                  SizedBox(width: 4),
                                  Text(
                                    'Refleksi Hari Ini',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              Text(
                                '"Refleksi bukan tentang menyalahkan diri sendiri, tapi tentang memahami dan tumbuh bersama pengalaman."',
                                style: TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Color(0xFF0F172A), height: 1.4),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '— Donald Schön, Reflective Practitioner',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStreakBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGridActionCard(String title, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetencyBar(String label, double value, String percentage) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF334155))),
            Text(percentage, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentReflectCard(String title, String subtitle, double progress, String progressText, IconData icon, Color iconBg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(progressText, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}
