import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'map_selection/map_screen.dart';

class PrologueScreen extends StatefulWidget {
  const PrologueScreen({super.key});

  @override
  State<PrologueScreen> createState() => _PrologueScreenState();
}

class _PrologueScreenState extends State<PrologueScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  bool _showSkipButton = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/videos/prologue.mp4')
      ..initialize()
          .then((_) {
            setState(() => _isVideoInitialized = true);
            _controller.play();

            // Show skip button after 5 seconds
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) setState(() => _showSkipButton = true);
            });

            // Auto-navigate when video ends
            _controller.addListener(() {
              if (_controller.value.position >= _controller.value.duration) {
                _finishPrologue();
              }
            });
          })
          .catchError((error) {
            print('Error loading video: $error');
            // Fallback: navigate to map screen if video fails
            Future.delayed(const Duration(seconds: 2), () {
              _finishPrologue();
            });
          });
  }

  Future<void> _finishPrologue() async {
    // Save that player has watched prologue
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_watched_prologue', true);

    // Navigate to map screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MapScreen()),
      );
    }
  }

  void _skipPrologue() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text(
          'Skip Prologue?',
          style: TextStyle(color: Colors.amber),
        ),
        content: const Text(
          'Yakin mau skip? Kamu akan kehilangan cerita awal game.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _finishPrologue();
            },
            child: const Text('SKIP', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video player
          _isVideoInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                  ),
                ),

          // Dark overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                ),
              ),
            ),
          ),

          // Skip button (muncul setelah 5 detik)
          if (_showSkipButton)
            Positioned(
              top: 20,
              right: 20,
              child: TextButton.icon(
                onPressed: _skipPrologue,
                icon: const Icon(Icons.skip_next, color: Colors.white),
                label: const Text(
                  'SKIP',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),

          // Progress indicator
          Positioned(
            bottom: 20,
            left: 40,
            right: 40,
            child: _isVideoInitialized
                ? VideoProgressIndicator(
                    _controller,
                    allowScrubbing: false,
                    colors: const VideoProgressColors(
                      playedColor: Colors.amber,
                      bufferedColor: Colors.white24,
                      backgroundColor: Colors.white24,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
