import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui/splash_screen.dart';
import 'utils/audio_manager.dart';
import 'utils/game_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );

  try {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('music_volume') ||
        !prefs.containsKey('sfx_volume')) {
      await GamePrefs.resetAudioSettings();
      print('🎵 Audio settings reset to 100% (first run)');
    }
  } catch (e) {
    print('⚠️ Failed to reset audio settings: $e');
  }

  try {
    await AudioManager.instance.initialize();
    print('✅ Audio Manager ready');
  } catch (e) {
    print('❌ Audio initialization failed: $e');
  }

  runApp(const NusantaraDashApp());
}

class NusantaraDashApp extends StatelessWidget {
  const NusantaraDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nusantara Dash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        primaryColor: const Color(0xFFFFB300),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFB300),
          secondary: Color(0xFF4CAF50),
          error: Color(0xFFE65100),
          surface: Color(0xFF1A237E),
          background: Color(0xFF0D1B2A),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB300),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFFFB300)),
        ),
      ),
      initialRoute: '/',
      routes: {'/': (context) => const SplashScreen()},
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}
