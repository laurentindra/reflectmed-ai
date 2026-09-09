import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/gibbs_reflection.dart';

class SmartActionCard extends StatelessWidget {
  final SmartActionPlan plan;
  final Function(SmartActionPlan)? onEdit;

  const SmartActionCard({
    Key? key,
    required this.plan,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.flag_outlined, color: AppTheme.primaryTeal, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'SMART Action Plan (Slide 19)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: plan.isComplete ? Colors.green.withOpacity(0.12) : Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    plan.isComplete ? 'Lengkap' : 'Perlu Diisi',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: plan.isComplete ? Colors.green[700] : Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildCriterion('S', 'Specific', 'Tindakan konkret yang dilakukan', plan.specific),
                const SizedBox(height: 10),
                _buildCriterion('M', 'Measurable', 'Ukuran keberhasilan', plan.measurable),
                const SizedBox(height: 10),
                _buildCriterion('A', 'Achievable', 'Kelayakan dalam rotasi stase', plan.achievable),
                const SizedBox(height: 10),
                _buildCriterion('R', 'Relevant', 'Keterkaitan dengan kasus', plan.relevant),
                const SizedBox(height: 10),
                _buildCriterion('T', 'Time-bound', 'Batas target waktu pelaksanaan', plan.timeBound),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriterion(String letter, String title, String subtitle, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: pwCenter,
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTeal,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($subtitle)',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                content.isNotEmpty ? content : 'Belum dirumuskan.',
                style: TextStyle(
                  fontSize: 12,
                  color: content.isNotEmpty ? Colors.grey[800] : Colors.grey[400],
                  fontStyle: content.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const pwCenter = Alignment.center;
}
