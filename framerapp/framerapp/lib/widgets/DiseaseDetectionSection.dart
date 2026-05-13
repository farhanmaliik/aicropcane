// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class DiseaseDetectionSection extends StatelessWidget {
  final VoidCallback onScanPlant;

  const DiseaseDetectionSection({super.key, required this.onScanPlant});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Plant Disease Detection",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          "Scan your plants and detect diseases instantly",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onScanPlant,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage(
                  "https://images.unsplash.com/photo-1470058869958-2a77ade41c02?q=80&w=1170",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withOpacity(0.4),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.camera, color: Colors.green),
                      SizedBox(width: 8),
                      Text("Scan Plant for Disease",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      SizedBox(width: 8),
                      Icon(Iconsax.arrow_right_3, color: Colors.green),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
