// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:framerapp/utils/appcolors.dart';

class TreatmentDetailScreen extends StatelessWidget {
  final String cropName;
  final String diseaseName;

  const TreatmentDetailScreen({
    super.key,
    required this.cropName,
    required this.diseaseName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Recommended Treatment",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildTreatmentSteps(),
            const SizedBox(height: 24),
            const Text(
              "Recommended Products",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildProductList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.eco, color: primaryColor, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cropName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  diseaseName,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentSteps() {
    final steps = [
      "1️⃣ Remove and destroy infected leaves to stop spread.",
      "2️⃣ Apply Mancozeb fungicide every 7 days during infection.",
      "3️⃣ Avoid overhead watering and ensure good air circulation.",
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Treatment Steps",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          ...steps.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                e,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(context) {
    final products = [
      {
        "name": "Mancozeb Fungicide (250g)",
        "description": "Effective against fungal leaf spots & blight.",
        "image":
            "https://cdn-icons-png.flaticon.com/512/7665/7665831.png",
      },
      {
        "name": "Neem Oil Spray (100ml)",
        "description": "Organic pesticide for various pests & diseases.",
        "image":
            "https://cdn-icons-png.flaticon.com/512/883/883407.png",
      },
      {
        "name": "Copper Oxychloride (200g)",
        "description": "Prevents fungal & bacterial infections on crops.",
        "image":
            "https://cdn-icons-png.flaticon.com/512/4379/4379413.png",
      },
    ];

    return Column(
      children: products.map((product) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: primaryColor.withOpacity(0.1),
              backgroundImage: NetworkImage(product["image"]!),
            ),
            title: Text(
              product["name"]!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                product["description"]!,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
            trailing: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Opening ${product["name"]} details..."),
                    backgroundColor: primaryColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Buy Now",
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
