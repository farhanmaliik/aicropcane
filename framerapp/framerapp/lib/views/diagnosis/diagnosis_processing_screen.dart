


// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:framerapp/utils/appcolors.dart';
import 'package:lottie/lottie.dart';
import 'diagnosis_result_screen.dart'; 

class DiagnosisProcessingScreen extends StatefulWidget {
  final File imageFile;
  const DiagnosisProcessingScreen({required this.imageFile, super.key});

  @override
  State<DiagnosisProcessingScreen> createState() =>
      _DiagnosisProcessingScreenState();
}

class _DiagnosisProcessingScreenState extends State<DiagnosisProcessingScreen> {
  late Future<void> _analysisFuture;

  @override
  void initState() {
    super.initState();
    _analysisFuture = _simulateAnalysisAndNavigate();
  }

  Future<void> _simulateAnalysisAndNavigate() async {
    
    
    await Future.delayed(const Duration(milliseconds: 500));
    await Future.delayed(const Duration(seconds: 3));

    
    final rnd = Random();
    final demoCrops = ['Tomato', 'Wheat', 'Rice', 'Maize', 'Potato'];
    final demoDiseases = {
      'Tomato': ['Early blight', 'Septoria leaf spot', 'Bacterial spot'],
      'Wheat': ['Rust', 'Powdery mildew', 'Leaf spot'],
      'Rice': ['Blast', 'Brown spot', 'Sheath blight'],
      'Maize': ['Northern corn leaf blight', 'Gray leaf spot'],
      'Potato': ['Late blight', 'Early blight'],
    };

    final crop = demoCrops[rnd.nextInt(demoCrops.length)];
    final diseaseList = demoDiseases[crop]!;
    final disease = diseaseList[rnd.nextInt(diseaseList.length)];
    final confidence = 80 + rnd.nextInt(20); 

    
    final recommendations = {
      'Early blight':
          'Remove infected leaves. Apply Mancozeb or Chlorothalonil as per label. Keep good field sanitation.',
      'Septoria leaf spot':
          'Use copper fungicide. Rotate crops and avoid overhead irrigation.',
      'Bacterial spot':
          'Use certified seeds, copper sprays, and remove infected plants.',
      'Rust':
          'Use resistant varieties if available. Apply recommended fungicides at early signs.',
      'Powdery mildew':
          'Apply sulphur or systemic fungicides; maintain good airflow.',
      'Blast':
          'Use proper water management and apply fungicides recommended for rice blast.',
      'Brown spot':
          'Ensure balanced fertilizer application; manage water properly.',
      'Sheath blight':
          'Use biological control where possible; fungicide spray if severe.',
      'Northern corn leaf blight':
          'Plant resistant hybrids; timely foliar fungicides may help.',
      'Gray leaf spot': 'Crop rotation and fungicide at early stages.',
      'Late blight':
          'Use systemic fungicides and remove infected plants immediately.',
    };

    final recommendation =
        recommendations[disease] ??
        'Follow best practices and consult local agronomist.';

    
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DiagnosisResultScreen(
          imageFile: widget.imageFile,
          cropName: crop,
          diseaseName: disease,
          confidence: confidence,
          recommendation: recommendation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: const Text(
          'Analyzing Plant Health', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: FutureBuilder(
        future: _analysisFuture,
        builder: (_, snapshot) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        
                        Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: primaryColor.withOpacity(0.5),
                              width: 3,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.file(
                              widget.imageFile,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        SizedBox(
                          width: 250, 
                          height: 250,
                          child: Lottie.asset(
                            'assets/icons/Analyzing website.json', 
                            repeat: true,
                            fit: BoxFit.contain, 
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'Evaluating your plant image...', 
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Our advanced AI and botanical experts are working to provide the most accurate diagnosis.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                Column(
                  children: [
                    LinearProgressIndicator(
                      color: primaryColor, 
                      backgroundColor: primaryColor.withOpacity(0.2),
                      minHeight: 8, 
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 15),
                    TextButton.icon(
                      onPressed: () {
                        
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: Icon(
                        Icons.cancel_outlined,
                        color: Colors.grey[600],
                      ),
                      label: Text(
                        'Cancel Analysis',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      style: TextButton.styleFrom(
                        splashFactory: NoSplash
                            .splashFactory, 
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20), 
              ],
            ),
          );
        },
      ),
    );
  }
}
