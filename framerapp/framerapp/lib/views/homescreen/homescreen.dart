






// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher_string.dart';


import 'package:framerapp/provider/UserProvider.dart';
import 'package:framerapp/provider/WeatherProvider.dart';
import 'package:framerapp/utils/appcolors.dart';

import '../diagnosis/diagnosis_camera_screen.dart';
import 'package:framerapp/chatBot/chat_bot.dart';
import 'plant_guide_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isWeatherLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      context.read<UserProvider>().fetchUserData();
      if (!_isWeatherLoaded) {
        await context.read<WeatherProvider>().fetchWeatherData();
        _isWeatherLoaded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            final userData = userProvider.userData;
            return Center(
              child: Text(
                "Good Morning${userData != null ? ', ${userData["username"]}' : ''}!",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
            );
          },
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [
          Consumer<WeatherProvider>(
            builder: (context, weatherProvider, _) => IconButton(
              onPressed: () => weatherProvider.fetchWeatherData(),
              icon: const Icon(Iconsax.refresh),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            );
          }

          
          final weatherData = provider.weatherData;
          final city = provider.cityName;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                _buildCropIconsRow(),

                const SizedBox(height: 16),

                
                _buildWeatherAndInfoRow(weatherData, city),

                const SizedBox(height: 18),

                
                _buildHealYourCropCard(),

                const SizedBox(height: 18),

                _buildPlantGuidesSection(context),

                const SizedBox(height: 18),

                const QuickActionsGrid(),

                const SizedBox(height: 22),

                const DiseaseDetectionSection(),

                const SizedBox(height: 24),

                
                const VideosSection(),
                const SizedBox(height: 80), 
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCropIconsRow() {
    final crops = [
      {
        'asset': "assets/icons/maize.png",
        'title': 'Maize',
        'guide': PlantGuide(
          title: 'Maize Watering Tips',
          subtitle: 'Irrigation timing, soil moisture, and healthy growth.',
          overview: 'Maize thrives when irrigation is matched to key growth stages. Learn how to avoid drought stress and waterlogging for better yield.',
          issues: [
            {'title': 'Drought Stress', 'description': 'Yellow lower leaves and slow growth happen when plants lack water. Irrigate during knee-height and flowering stages.'},
            {'title': 'Root Rot', 'description': 'Too much water causes weak roots and plant collapse. Improve field drainage and avoid saturated soil.'},
          ],
          treatments: [
            'Keep soil evenly moist but not waterlogged.',
            'Use mulch or cover crops to retain moisture.',
            'Apply phosphorus-rich starter fertilizer at planting.',
          ],
          careTips: [
            'Water early in the morning to reduce evaporation.',
            'Monitor soil moisture and only irrigate when needed.',
            'Rotate crops to reduce pests and diseases.',
          ],
        ),
      },
      {
        'asset': "assets/icons/chickenpeas.jpg",
        'title': 'Peas',
        'guide': PlantGuide(
          title: 'Peas Pest Control',
          subtitle: 'Protect peas from aphids, mildew, and root rot.',
          overview: 'Peas are sensitive to pests and wet soil. This guide explains how to keep pea plants healthy with gentle pest control and good soil care.',
          issues: [
            {'title': 'Aphids', 'description': 'Small insects cause sticky leaves and twisted growth. Use neem sprays and natural predators to control them.'},
            {'title': 'Powdery Mildew', 'description': 'White leaf coating from humid conditions. Improve spacing, remove infected foliage, and keep soil dry on the surface.'},
          ],
          treatments: [
            'Spray neem oil when aphids appear.',
            'Remove infected leaves to prevent spread.',
            'Use compost to improve soil health and drainage.',
          ],
          careTips: [
            'Water at the base and avoid wetting leaves.',
            'Support vines with a trellis for better airflow.',
            'Plant peas in cool, well-drained soil.',
          ],
        ),
      },
      {
        'asset': "assets/icons/mango.png",
        'title': 'Mango',
        'guide': PlantGuide(
          title: 'Mango Care & Fertilizer Tips',
          subtitle: 'Nutrient balance, disease prevention, and healthy fruit.',
          overview: 'Mango trees need regular fertilization and disease control to stay productive. This guide shows common mango problems and practical treatments.',
          issues: [
            {'title': 'Anthracnose', 'description': 'Dark spots on leaves and fruit caused by fungi. Prune damaged areas and spray a protective fungicide.'},
            {'title': 'Powdery Mildew', 'description': 'White powder on leaves from humidity and poor air flow. Improve ventilation and avoid wet foliage.'},
          ],
          treatments: [
            'Use balanced NPK fertilizer at flowering and fruit set stages.',
            'Apply neem oil or copper fungicide for fungal issues.',
            'Mulch around the base to keep soil moist and cool.',
          ],
          careTips: [
            'Water deeply once or twice per week based on soil moisture.',
            'Remove dead branches to improve airflow.',
            'Protect young fruits from direct heat during the hottest hours.',
          ],
        ),
      },
      {
        'asset': "assets/icons/rice.jpg",
        'title': 'Rice',
        'guide': PlantGuide(
          title: 'Rice Fertilizer Guide',
          subtitle: 'Field nutrition, disease care, and yield support.',
          overview: 'Rice needs the right fertilizer schedule and water management. This guide helps you choose the best treatments for strong tillers and grain production.',
          issues: [
            {'title': 'Blast Disease', 'description': 'Tan lesions and stem breaks are signs of blast. Use resistant varieties and balanced nutrition.'},
            {'title': 'Brown Spot', 'description': 'Brown leaf spots often mean potassium deficiency. Apply potash and maintain adequate moisture.'},
          ],
          treatments: [
            'Use balanced NPK fertilizer based on soil tests.',
            'Apply potassium if leaf spots appear.',
            'Keep fields level and avoid prolonged deep flooding.',
          ],
          careTips: [
            'Use alternate wetting and drying to save water.',
            'Fertilize in smaller doses rather than one heavy feeding.',
            'Protect seedlings from cold and pests early.',
          ],
        ),
      },
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: crops.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final crop = crops[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlantGuideDetailScreen(guide: crop['guide'] as PlantGuide),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.amber.shade200, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      crop['asset'] as String,
                      width: 36,
                      height: 36,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  crop['title'] as String,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherAndInfoRow(
    Map<String, dynamic>? weatherData,
    String city,
  ) {
    
    final current = weatherData != null ? weatherData["current_weather"] : null;
    final temp = (current != null && current["temperature"] != null)
        ? current["temperature"].round()
        : "--";
    final weatherText = (current != null && current["weathercode"] != null)
        ? _mapWeatherCodeToText(current["weathercode"])
        : "N/A";

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _weatherCard(city, temp.toString(), weatherText),
          const SizedBox(width: 12),
          _permissionCard(),
        ],
      ),
    );
  }

  Widget _weatherCard(String city, String temp, String weatherText) {
    return Container(
      width: 240,
      height: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.95),
            primaryColor.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today, ${_formatDate(DateTime.now())}",
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$temp°C",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Icon(Icons.wb_sunny, color: Colors.white),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  city,
                  style: TextStyle(color: Colors.white.withOpacity(0.95)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _permissionCard() {
    
    return Container(
      width: 250,
      height: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        border: Border.all(color: Colors.amber.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Spraying",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 6),
          Text("Moderate", style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Colors.brown,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Location permission required",
                    style: TextStyle(color: Colors.brown.shade800),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "Allow",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealYourCropCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Text(
                "Heal your crop",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stepItem(
                Icons.camera_alt_outlined,
                "Take a\npicture",
                onTap: () {},
              ),
              const Icon(Icons.chevron_right, size: 28, color: Colors.grey),
              _stepItem(Icons.list_alt, "See\ndiagnosis", onTap: () {}),
              const Icon(Icons.chevron_right, size: 28, color: Colors.grey),
              _stepItem(Icons.medication, "Get\nmedicine", onTap: () {}),
            ],
          ),

          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatBot(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                "Take a picture",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantGuidesSection(BuildContext context) {
    final guides = [
      PlantGuide(
        title: 'Mango Care & Fertilizer Tips',
        subtitle: 'Nutrient balance, disease prevention, and healthy fruit.',
        overview: 'Mango trees need regular fertilization and disease control to stay productive. This guide shows common mango problems and practical treatments.',
        issues: [
          {'title': 'Anthracnose', 'description': 'Dark spots on leaves and fruit caused by fungi. Prune damaged areas and spray a protective fungicide.'},
          {'title': 'Powdery Mildew', 'description': 'White powder on leaves from humidity and poor air flow. Improve ventilation and avoid wet foliage.'},
        ],
        treatments: [
          'Use balanced NPK fertilizer at flowering and fruit set stages.',
          'Apply neem oil or copper fungicide for fungal issues.',
          'Mulch around the base to keep soil moist and cool.',
        ],
        careTips: [
          'Water deeply once or twice per week based on soil moisture.',
          'Remove dead branches to improve airflow.',
          'Protect young fruits from direct heat during the hottest hours.',
        ],
      ),
      PlantGuide(
        title: 'Maize Watering Tips',
        subtitle: 'Irrigation timing, soil moisture, and healthy growth.',
        overview: 'Maize thrives when irrigation is matched to key growth stages. Learn how to avoid drought stress and waterlogging for better yield.',
        issues: [
          {'title': 'Drought Stress', 'description': 'Yellow lower leaves and slow growth happen when plants lack water. Irrigate during knee-height and flowering stages.'},
          {'title': 'Root Rot', 'description': 'Too much water causes weak roots and plant collapse. Improve field drainage and avoid saturated soil.'},
        ],
        treatments: [
          'Keep soil evenly moist but not waterlogged.',
          'Use mulch or cover crops to retain moisture.',
          'Apply phosphorus-rich starter fertilizer at planting.',
        ],
        careTips: [
          'Water early in the morning to reduce evaporation.',
          'Monitor soil moisture and only irrigate when needed.',
          'Rotate crops to reduce pests and diseases.',
        ],
      ),
      PlantGuide(
        title: 'Peas Pest Control',
        subtitle: 'Protect peas from aphids, mildew, and root rot.',
        overview: 'Peas are sensitive to pests and wet soil. This guide explains how to keep pea plants healthy with gentle pest control and good soil care.',
        issues: [
          {'title': 'Aphids', 'description': 'Small insects cause sticky leaves and twisted growth. Use neem sprays and natural predators to control them.'},
          {'title': 'Powdery Mildew', 'description': 'White leaf coating from humid conditions. Improve spacing, remove infected foliage, and keep soil dry on the surface.'},
        ],
        treatments: [
          'Spray neem oil when aphids appear.',
          'Remove infected leaves to prevent spread.',
          'Use compost to improve soil health and drainage.',
        ],
        careTips: [
          'Water at the base and avoid wetting leaves.',
          'Support vines with a trellis for better airflow.',
          'Plant peas in cool, well-drained soil.',
        ],
      ),
      PlantGuide(
        title: 'Rice Fertilizer Guide',
        subtitle: 'Field nutrition, disease care, and yield support.',
        overview: 'Rice needs the right fertilizer schedule and water management. This guide helps you choose the best treatments for strong tillers and grain production.',
        issues: [
          {'title': 'Blast Disease', 'description': 'Tan lesions and stem breaks are signs of blast. Use resistant varieties and balanced nutrition.'},
          {'title': 'Brown Spot', 'description': 'Brown leaf spots often mean potassium deficiency. Apply potash and maintain adequate moisture.',},
        ],
        treatments: [
          'Use balanced NPK fertilizer based on soil tests.',
          'Apply potassium if leaf spots appear.',
          'Keep fields level and avoid prolonged deep flooding.',
        ],
        careTips: [
          'Use alternate wetting and drying to save water.',
          'Fertilize in smaller doses rather than one heavy feeding.',
          'Protect seedlings from cold and pests early.',
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Plant Guides',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap a plant card to open a full-page guide with issues, treatment, and care tips.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: guides.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final guide = guides[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlantGuideDetailScreen(guide: guide),
                    ),
                  );
                },
                child: Container(
                  width: 240,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.eco, color: primaryColor, size: 28),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        guide.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        'Open guide',
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _stepItem(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
              ],
            ),
            child: Icon(icon, size: 30, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    
    final months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${dt.day} ${months[dt.month - 1]}";
  }
}



class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        "title": "Fertilizer\ntips",
        "icon": Icons.local_florist,
        "guide": PlantGuide(
          title: 'Mango Care & Fertilizer Tips',
          subtitle: 'Nutrient balance, disease prevention, and healthy fruit.',
          overview: 'Mango trees need regular fertilization and disease control to stay productive. This guide shows common mango problems and practical treatments.',
          issues: [
            {'title': 'Anthracnose', 'description': 'Dark spots on leaves and fruit caused by fungi. Prune damaged areas and spray a protective fungicide.'},
            {'title': 'Powdery Mildew', 'description': 'White powder on leaves from humidity and poor air flow. Improve ventilation and avoid wet foliage.'},
          ],
          treatments: [
            'Use balanced NPK fertilizer at flowering and fruit set stages.',
            'Apply neem oil or copper fungicide for fungal issues.',
            'Mulch around the base to keep soil moist and cool.',
          ],
          careTips: [
            'Water deeply once or twice per week based on soil moisture.',
            'Remove dead branches to improve airflow.',
            'Protect young fruits from direct heat during the hottest hours.',
          ],
        ),
      },
      {
        "title": "Watering\ntips",
        "icon": Icons.opacity,
        "guide": PlantGuide(
          title: 'Maize Watering Tips',
          subtitle: 'Irrigation timing, soil moisture, and healthy growth.',
          overview: 'Maize thrives when irrigation is matched to key growth stages. Learn how to avoid drought stress and waterlogging for better yield.',
          issues: [
            {'title': 'Drought Stress', 'description': 'Yellow lower leaves and slow growth happen when plants lack water. Irrigate during knee-height and flowering stages.'},
            {'title': 'Root Rot', 'description': 'Too much water causes weak roots and plant collapse. Improve field drainage and avoid saturated soil.'},
          ],
          treatments: [
            'Keep soil evenly moist but not waterlogged.',
            'Use mulch or cover crops to retain moisture.',
            'Apply phosphorus-rich starter fertilizer at planting.',
          ],
          careTips: [
            'Water early in the morning to reduce evaporation.',
            'Monitor soil moisture and only irrigate when needed.',
            'Rotate crops to reduce pests and diseases.',
          ],
        ),
      },
      {
        "title": "Cultivation\nTips",
        "icon": Icons.emoji_nature,
        "guide": PlantGuide(
          title: 'Rice Fertilizer Guide',
          subtitle: 'Field nutrition, disease care, and yield support.',
          overview: 'Rice needs the right fertilizer schedule and water management. This guide helps you choose the best treatments for strong tillers and grain production.',
          issues: [
            {'title': 'Blast Disease', 'description': 'Tan lesions and stem breaks are signs of blast. Use resistant varieties and balanced nutrition.'},
            {'title': 'Brown Spot', 'description': 'Brown leaf spots often mean potassium deficiency. Apply potash and maintain adequate moisture.'},
          ],
          treatments: [
            'Use balanced NPK fertilizer based on soil tests.',
            'Apply potassium if leaf spots appear.',
            'Keep fields level and avoid prolonged deep flooding.',
          ],
          careTips: [
            'Use alternate wetting and drying to save water.',
            'Fertilize in smaller doses rather than one heavy feeding.',
            'Protect seedlings from cold and pests early.',
          ],
        ),
      },
      {
        "title": "Pests and\nDisease Alert",
        "icon": Icons.warning_amber_outlined,
        "guide": PlantGuide(
          title: 'Peas Pest Control',
          subtitle: 'Protect peas from aphids, mildew, and root rot.',
          overview: 'Peas are sensitive to pests and wet soil. This guide explains how to keep pea plants healthy with gentle pest control and good soil care.',
          issues: [
            {'title': 'Aphids', 'description': 'Small insects cause sticky leaves and twisted growth. Use neem sprays and natural predators to control them.'},
            {'title': 'Powdery Mildew', 'description': 'White leaf coating from humid conditions. Improve spacing, remove infected foliage, and keep soil dry on the surface.'},
          ],
          treatments: [
            'Spray neem oil when aphids appear.',
            'Remove infected leaves to prevent spread.',
            'Use compost to improve soil health and drainage.',
          ],
          careTips: [
            'Water at the base and avoid wetting leaves.',
            'Support vines with a trellis for better airflow.',
            'Plant peas in cool, well-drained soil.',
          ],
        ),
      },
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 110,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlantGuideDetailScreen(guide: item['guide'] as PlantGuide),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Color(0xFFEFF3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(item["icon"] as IconData, color: Colors.black87),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item["title"] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DiseaseDetectionSection extends StatelessWidget {
  final VoidCallback? onScanPlant;
  const DiseaseDetectionSection({this.onScanPlant, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Take a picture",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                Text("See diagnosis", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onScanPlant ?? () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatBot()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Text(
                "Take a picture",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VideosSection extends StatelessWidget {
  const VideosSection({super.key});

  @override
  Widget build(BuildContext context) {
    
    final videos = [
      {
        "thumb": "https://img.youtube.com/vi/RdkLuktC6RM/hqdefault.jpg",
        "duration": "05:14",
        "title": "Mango Farming Tips for Higher Yield",
        "url": "https://www.youtube.com/watch?v=RdkLuktC6RM",
      },
      {
        "thumb": "https://img.youtube.com/vi/9V6jLw-5-hg/hqdefault.jpg",
        "duration": "07:08",
        "title": "Maize Cultivation Best Practices",
        "url": "https://www.youtube.com/watch?v=9V6jLw-5-hg",
      },
      {
        "thumb": "https://img.youtube.com/vi/5U1JjNzfEP8/hqdefault.jpg",
        "duration": "06:02",
        "title": "Organic Pest Control for Crops",
        "url": "https://www.youtube.com/watch?v=5U1JjNzfEP8",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              "Top Videos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 8),
            Text("🔥", style: TextStyle(fontSize: 18)),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final v = videos[index];
              return GestureDetector(
                onTap: () async {
                  final url = v["url"] as String;
                  if (await canLaunchUrlString(url)) {
                    await launchUrlString(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open video')),
                    );
                  }
                },
                child: Container(
                  width: 240,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            v["thumb"] as String,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.green[100],
                              child: Center(
                                child: Text(
                                  v["title"] as String,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.12),
                              Colors.black.withOpacity(0.05),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            v["duration"] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


String _mapWeatherCodeToText(int? code) {
  if (code == null) return "Unknown";
  switch (code) {
    case 0:
      return "Clear";
    case 1:
    case 2:
    case 3:
      return "Partly cloudy";
    case 45:
    case 48:
      return "Foggy";
    case 61:
    case 63:
    case 65:
      return "Rain";
    default:
      return "Unknown";
  }
}
