import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class GibbsProgressStepper extends StatelessWidget {
  final int activeIndex; // 0 to 5
  final Function(int)? onStepTapped;

  const GibbsProgressStepper({
    Key? key,
    required this.activeIndex,
    this.onStepTapped,
  }) : super(key: key);

  static const List<Map<String, String>> steps = [
    {'title': 'Description', 'subtitle': 'Apa yang terjadi?'},
    {'title': 'Feelings', 'subtitle': 'Apa yang dirasakan?'},
    {'title': 'Evaluation', 'subtitle': 'Baik vs Buruk'},
    {'title': 'Analysis', 'subtitle': 'Mengapa terjadi?'},
    {'title': 'Conclusion', 'subtitle': 'Pelajaran diri'},
    {'title': 'Action Plan', 'subtitle': 'Rencana SMART'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: steps.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isCompleted = index < activeIndex;
          final isCurrent = index == activeIndex;

          Color bgColor = const Color(0xFFE2E8F0);
          Color textColor = const Color(0xFF64748B);
          Color borderColor = Colors.transparent;

          if (isCurrent) {
            bgColor = AppTheme.primaryTeal.withOpacity(0.12);
            textColor = AppTheme.primaryTeal;
            borderColor = AppTheme.primaryTeal;
          } else if (isCompleted) {
            bgColor = AppTheme.primaryTeal;
            textColor = Colors.white;
          }

          return InkWell(
            onTap: onStepTapped != null ? () => onStepTapped!(index) : null,
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: isCompleted ? Colors.white : (isCurrent ? AppTheme.primaryTeal : Colors.grey[400]),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 12, color: AppTheme.primaryTeal)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? Colors.white : Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[index]['title']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      Text(
                        steps[index]['subtitle']!,
                        style: TextStyle(
                          fontSize: 9,
                          color: isCompleted ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
