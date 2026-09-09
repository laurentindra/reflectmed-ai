import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/student_profile.dart';
import '../services/storage_service.dart';
import 'ai_training_studio_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  StudentProfile _profile = StudentProfile();
  bool _remindersEnabled = true;
  bool _darkMode = false;
  bool _researchConsent = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await StorageService.loadProfile();
    setState(() {
      _profile = profile;
    });
  }

  void _openEditDialog() {
    final nameCtrl = TextEditingController(text: _profile.fullName);
    final nimCtrl = TextEditingController(text: _profile.studentId);
    final univCtrl = TextEditingController(text: _profile.university);
    final deptCtrl = TextEditingController(text: _profile.currentDepartment);
    final hospCtrl = TextEditingController(text: _profile.teachingHospital);
    final supCtrl = TextEditingController(text: _profile.supervisorName);
    final keyCtrl = TextEditingController(text: _profile.geminiApiKey);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profil & Pengaturan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
              TextField(controller: nimCtrl, decoration: const InputDecoration(labelText: 'NIM')),
              TextField(controller: deptCtrl, decoration: const InputDecoration(labelText: 'Stase Aktif')),
              TextField(controller: hospCtrl, decoration: const InputDecoration(labelText: 'RS Pendidikan')),
              TextField(controller: supCtrl, decoration: const InputDecoration(labelText: 'Nama DPJP')),
              TextField(controller: keyCtrl, decoration: const InputDecoration(labelText: 'Gemini API Key (Opsional)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              _profile.fullName = nameCtrl.text.trim();
              _profile.studentId = nimCtrl.text.trim();
              _profile.currentDepartment = deptCtrl.text.trim();
              _profile.teachingHospital = hospCtrl.text.trim();
              _profile.supervisorName = supCtrl.text.trim();
              _profile.geminiApiKey = keyCtrl.text.trim();
              await StorageService.saveProfile(_profile);
              setState(() {});
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TEAL HEADER (Matching AI Reflection App Design-1.png)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryTeal, AppTheme.primaryTealDark],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
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
                        IconButton(
                          icon: const Icon(Icons.edit_note, color: Colors.white, size: 22),
                          onPressed: _openEditDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // User Profile Card
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.person_outline, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _profile.fullName,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Mahasiswa Koas · NIM ${_profile.studentId}',
                                style: const TextStyle(color: Color(0xFFE0F2FE), fontSize: 11),
                              ),
                              Text(
                                '${_profile.university} · ${_profile.currentDepartment}',
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 3 Metric Pills
                    Row(
                      children: [
                        _buildStatPill('24', 'Refleksi'),
                        const SizedBox(width: 8),
                        _buildStatPill('3/8', 'Rotasi Selesai'),
                        const SizedBox(width: 8),
                        _buildStatPill('82%', 'Kompetensi'),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. SETTINGS CONTENT
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Data Protection Notice
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF99F6E4)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.shield_outlined, color: AppTheme.primaryTeal, size: 22),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Data Anda Terlindungi',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Refleksi Anda dienkripsi end-to-end dan tidak pernah dibagikan tanpa persetujuan Anda. Sesuai UU PDP & standar etika medis.',
                                  style: TextStyle(fontSize: 10, color: Color(0xFF334155), height: 1.35),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Group: AKUN
                    _buildGroupCard('AKUN', [
                      _buildMenuItem(Icons.person_outline, 'Profil & Identitas', 'Nama, NIM, institusi', onTap: _openEditDialog),
                      _buildMenuItem(Icons.verified_user_outlined, 'Autentikasi SSO', 'Terhubung: ID Kampus', statusTag: 'Aktif'),
                      _buildMenuItem(Icons.lock_outline, 'Privasi & Keamanan', 'Enkripsi data, sesi login'),
                    ]),
                    const SizedBox(height: 12),

                    // Group: REFLEKSI & PEMBELAJARAN
                    _buildGroupCard('REFLEKSI & PEMBELAJARAN', [
                      _buildMenuItem(
                        Icons.model_training,
                        'Studio Pelatihan AI (Educator)',
                        'Kalibrasi persona, bank kasus & fine-tuning dataset',
                        statusTag: 'Mode Edukator',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AiTrainingStudioScreen()),
                          );
                        },
                      ),
                      _buildToggleItem(Icons.notifications_none, 'Pengingat Refleksi', 'Setelah rotasi & kasus penting', _remindersEnabled, (v) => setState(() => _remindersEnabled = v)),
                      _buildMenuItem(Icons.bookmark_border, 'Model Refleksi', 'Saat ini: Siklus Gibbs'),
                    ]),
                    const SizedBox(height: 12),

                    // Group: TAMPILAN
                    _buildGroupCard('TAMPILAN', [
                      _buildToggleItem(Icons.dark_mode_outlined, 'Mode Gelap', 'Tampilan malam hari', _darkMode, (v) => setState(() => _darkMode = v)),
                      _buildMenuItem(Icons.star_outline, 'Aksesibilitas', 'Ukuran teks & kontras'),
                    ]),
                    const SizedBox(height: 12),

                    // Group: BANTUAN & KESEJAHTERAAN
                    _buildGroupCard('BANTUAN & KESEJAHTERAAN', [
                      _buildMenuItem(Icons.favorite_border, 'Layanan Konseling', 'wellbeing@fk.unair.ac.id'),
                      _buildMenuItem(Icons.help_outline, 'Panduan Pengguna', 'Tutorial & FAQ'),
                    ]),
                    const SizedBox(height: 12),

                    // Group: KONTRIBUSI RISET
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(14, 12, 14, 4),
                            child: Text('KONTRIBUSI RISET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            child: Text(
                              'Data refleksi Anda (anonim) membantu pendidik memahami tren pembelajaran kohort untuk perbaikan kurikulum.',
                              style: TextStyle(fontSize: 10.5, color: Color(0xFF475569), height: 1.35),
                            ),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                            title: const Text('Izinkan data anonim untuk riset', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                            value: _researchConsent,
                            activeColor: AppTheme.primaryTeal,
                            onChanged: (v) => setState(() => _researchConsent = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Logout Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        backgroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.logout, size: 16),
                      label: const Text('Keluar dari Akun', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 12),

                    const Center(
                      child: Text(
                        'MedReflect v1.0.0 · FK President University / FK Unair\nSesuai UU PDP & Standar Etika Medis Indonesia',
                        style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8), height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill(String val, String lbl) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(val, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            Text(lbl, style: const TextStyle(color: Colors.white70, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(String title, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, {String? statusTag, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: AppTheme.primaryTeal),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
            ),
            if (statusTag != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                child: Text(statusTag, style: const TextStyle(color: Color(0xFF059669), fontSize: 9.5, fontWeight: FontWeight.bold)),
              )
            else
              const Icon(Icons.chevron_right, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: AppTheme.primaryTeal),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppTheme.primaryTeal,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
