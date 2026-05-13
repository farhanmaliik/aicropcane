import 'package:flutter/material.dart';
import 'package:framerapp/chatBot/chat_bot.dart';
import 'package:framerapp/chatBot/chat_provider.dart';
import 'package:framerapp/provider/UserProvider.dart';
import 'package:framerapp/provider/WeatherProvider.dart';
import 'package:framerapp/provider/authprovider.dart';
import 'package:framerapp/provider/community_provider.dart';
import 'package:framerapp/provider/theme_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'views/splashscreen/splashscreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _initLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    debugPrint("⚠️ Location services disabled");
    return;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      debugPrint("⚠️ Location permission denied");
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    debugPrint("⚠️ Location permanently denied");
    return;
  }

  debugPrint("✅ Location permission granted");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>( // ✅ Fixed missing generic type
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Farmer App',
          theme: ThemeData(
            colorScheme: themeProvider.currentColorScheme,
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}