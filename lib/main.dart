import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'ui/splash_screen.dart';
import 'utils/audio_manager.dart'; // Nanti kita buat

void main() async {
  // ✅ 1. Inisialisasi Flutter Binding (WAJIB untuk async operations)
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 2. Lock Orientasi Landscape (Game runner wajib landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // ✅ 3. Fullscreen Mode (Hide status bar & navigation bar)
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [], // Hide semua overlay
  );

  // ✅ 4. Prevent screen from sleeping (Game harus selalu active)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // ✅ 5. Inisialisasi Audio Manager (Untuk BGM & SFX)
  try {
    await AudioManager.instance.initialize();
  } catch (e) {
    print('Audio initialization failed: $e');
  }

  // ✅ 6. Run App dengan Error Handling
  runApp(const NusantaraDashApp());
}

class NusantaraDashApp extends StatelessWidget {
  const NusantaraDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nusantara Dash',
      debugShowCheckedModeBanner: false,

      // ✅ Theme yang lebih lengkap untuk game
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1B2A), // Navy black
        primaryColor: const Color(0xFFFFB300), // Amber/Gold
        // Color scheme untuk game
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFB300), // Gold
          secondary: Color(0xFF4CAF50), // Green
          error: Color(0xFFE65100), // Orange/Red
          surface: Color(0xFF1A237E), // Deep blue
          background: Color(0xFF0D1B2A), // Navy black
        ),

        // Button theme
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

        // Text button theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFFFB300)),
        ),
      ),

      // ✅ Route management
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        // Nanti tambahkan route lain:
        // '/home': (context) => const HomeScreen(),
        // '/game': (context) => const GameScreen(),
        // '/museum': (context) => const MuseumScreen(),
        // '/shop': (context) => const ShopScreen(),
      },

      // ✅ Error handling untuk production
      builder: (context, child) {
        return MediaQuery(
          // Prevent text scaling (penting untuk game UI)
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}
