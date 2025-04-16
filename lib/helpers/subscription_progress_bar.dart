import 'package:flutter/material.dart';

class SubscriptionProgressBar extends StatelessWidget {
  final DateTime createdAt;
  final DateTime expiredDate;
  final int period; // total hari
  final double height;

  const SubscriptionProgressBar({
    super.key,
    required this.createdAt,
    required this.expiredDate,
    required this.period,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final totalDays = expiredDate.difference(createdAt).inDays;
    final remainingDays = expiredDate.difference(now).inDays;
    final usedDays = totalDays - remainingDays;

    final progress = (usedDays / totalDays).clamp(0.0, 1.0);

    Color getProgressColor() {
      if (progress < 0.6) return Colors.green;
      if (progress < 0.85) return Colors.orange;
      return Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Stack(
            children: [
              Container(
                height: height,
                width: double.infinity,
                color: Colors.grey[300],
              ),
              Container(
                height: height,
                width: MediaQuery.of(context).size.width * progress,
                color: getProgressColor(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "$remainingDays days remaining",
          style: TextStyle(
            fontSize: 12,
            color: getProgressColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
