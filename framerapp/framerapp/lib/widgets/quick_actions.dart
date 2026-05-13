// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../utils/appcolors.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onScanPlant;
  final VoidCallback onPlantHealth;

  const QuickActionsGrid({
    super.key,
    required this.onScanPlant,
    required this.onPlantHealth,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildActionCard(
          icon: Iconsax.camera,
          title: "Scan Plant",
          subtitle: "Detect diseases",
          color: Colors.green,
          onTap: onScanPlant,
        ),
        _buildActionCard(
          icon: Iconsax.health,
          title: "Plant Health",
          subtitle: "Check status",
          color: primaryColor,
          onTap: onPlantHealth,
        ),
        _buildActionCard(
          icon: Iconsax.calendar,
          title: "Schedule",
          subtitle: "Care calendar",
          color: Colors.orange,
          onTap: () {},
        ),
        _buildActionCard(
          icon: Iconsax.book,
          title: "Guide",
          subtitle: "Plant care tips",
          color: Colors.purple,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
