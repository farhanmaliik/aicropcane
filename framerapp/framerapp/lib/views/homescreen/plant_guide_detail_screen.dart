// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:framerapp/utils/appcolors.dart';

class PlantGuide {
  final String title;
  final String subtitle;
  final String overview;
  final List<Map<String, String>> issues;
  final List<String> treatments;
  final List<String> careTips;

  PlantGuide({
    required this.title,
    required this.subtitle,
    required this.overview,
    required this.issues,
    required this.treatments,
    required this.careTips,
  });
}

class PlantGuideDetailScreen extends StatelessWidget {
  final PlantGuide guide;

  const PlantGuideDetailScreen({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Plant Guide',
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
            Text(
              guide.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              guide.subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                guide.overview,
                style: const TextStyle(fontSize: 14, height: 1.7),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Common issues'),
            const SizedBox(height: 12),
            ...guide.issues.map((issue) => _buildIssueCard(issue)).toList(),
            const SizedBox(height: 20),
            _buildSectionTitle('Treatment & medicine'),
            const SizedBox(height: 12),
            _buildBulletList(guide.treatments),
            const SizedBox(height: 20),
            _buildSectionTitle('Care tips'),
            const SizedBox(height: 12),
            _buildBulletList(guide.careTips),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
    );
  }

  Widget _buildIssueCard(Map<String, String> issue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            issue['title'] ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            issue['description'] ?? '',
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 18)),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
