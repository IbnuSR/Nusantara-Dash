import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nusantara_dash/game/data/museum_item_model.dart';
import 'package:nusantara_dash/game/managers/museum_manager.dart';
import 'museum_island_screen.dart';
import 'widgets/museum_header_card.dart';
import 'widgets/museum_progress_bar.dart';

/// Museum Home Screen — Entry point fitur Museum Nusantara.
///
/// Refined & Polished (Sprint 4.5):
/// - Kartu pulau 20-25% lebih ramping (childAspectRatio: 3.8).
/// - Avatar pulau lebih utuh & proporsional.
/// - Progress Bar & Counter rapi & mudah dibaca.
/// - Animasi Fade & Scale saat awal dimuat.
/// - Responsif untuk Landscape Mobile, Tablet, dan Desktop.
class MuseumHomeScreen extends StatefulWidget {
  const MuseumHomeScreen({super.key});

  @override
  State<MuseumHomeScreen> createState() => _MuseumHomeScreenState();
}

class _MuseumHomeScreenState extends State<MuseumHomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<MuseumIsland> _islands = [];
  MuseumProgress _indonesiaProgress = const MuseumProgress(collected: 0, total: 0);
  final Map<String, MuseumProgress> _islandProgressMap = {};

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await MuseumManager.instance.loadMuseum();

    final islands = await MuseumManager.instance.getAllIslands();
    final indProgress = await MuseumManager.instance.getIndonesiaProgress();

    final Map<String, MuseumProgress> progressMap = {};
    for (final island in islands) {
      progressMap[island.id] =
          await MuseumManager.instance.getIslandProgress(island.id);
    }

    if (!mounted) return;
    setState(() {
      _islands = islands;
      _indonesiaProgress = indProgress;
      _islandProgressMap.addAll(progressMap);
      _isLoading = false;
    });

    _animController.forward();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoading()
          : FadeTransition(
              opacity: _fadeAnim,
              child: _buildBody(),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A237E),
      elevation: 8,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Color(0xFFFFB300)),
      title: Text(
        '🏛️ Museum Nusantara',
        style: GoogleFonts.pressStart2p(
          color: const Color(0xFFFFB300),
          fontSize: 12,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFFFFB300)),
          SizedBox(height: 14),
          Text(
            'Memuat Museum...',
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1B2A), Color(0xFF1A237E)],
        ),
      ),
      child: Column(
        children: [
          // Reusable Header Card untuk Indonesia Progress
          MuseumHeaderCard(
            title: 'Progress Indonesia',
            iconEmoji: '🇮🇩',
            progress: _indonesiaProgress,
            accentColor: const Color(0xFFFFB300),
          ),
          Expanded(child: _buildIslandGrid()),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Island Grid (Responsive & Optimized Height)
  // ---------------------------------------------------------------------------

  Widget _buildIslandGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tentukan jumlah kolom & perbandingan tinggi berdasarkan lebar layar
        final double screenWidth = constraints.maxWidth;
        final int crossAxisCount = screenWidth > 900 ? 3 : 2;
        final double childAspectRatio = screenWidth > 900 ? 3.4 : 3.8;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 10,
          ),
          itemCount: _islands.length,
          itemBuilder: (context, index) {
            final island = _islands[index];
            final progress = _islandProgressMap[island.id] ??
                const MuseumProgress(collected: 0, total: 0);

            return _RefinedIslandCard(
              island: island,
              progress: progress,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MuseumIslandScreen(islandId: island.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// =============================================================================
// Private Island Card Widget (Sprint 4.5 Refinement)
// =============================================================================

class _RefinedIslandCard extends StatefulWidget {
  final MuseumIsland island;
  final MuseumProgress progress;
  final VoidCallback onTap;

  const _RefinedIslandCard({
    required this.island,
    required this.progress,
    required this.onTap,
  });

  @override
  State<_RefinedIslandCard> createState() => _RefinedIslandCardState();
}

class _RefinedIslandCardState extends State<_RefinedIslandCard> {
  bool _isPressed = false;

  static const Map<String, Color> _islandColors = {
    'sumatra': Color(0xFF2E7D32),
    'jawa': Color(0xFF1565C0),
    'kalimantan': Color(0xFFBF360C),
    'sulawesi': Color(0xFF6A1B9A),
    'papua': Color(0xFF00695C),
  };

  static const Map<String, String> _islandAvatars = {
    'sumatra': 'assets/images/ui/avatar_sumatra.png',
    'jawa': 'assets/images/ui/avatar_jawa.png',
    'kalimantan': 'assets/images/ui/avatar_kalimantan.png',
    'sulawesi': 'assets/images/ui/avatar_sulawesi.png',
    'papua': 'assets/images/ui/avatar_papua.png',
  };

  @override
  Widget build(BuildContext context) {
    final color = _islandColors[widget.island.id] ?? const Color(0xFF1A237E);
    final avatarPath = _islandAvatars[widget.island.id];

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.65)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFFB300).withOpacity(0.5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar Pulau (Tampilan Utuh / Tidak Terpotong Berat)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                child: Container(
                  width: 58,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.2),
                  padding: const EdgeInsets.all(2),
                  child: avatarPath != null
                      ? Image.asset(
                          avatarPath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              _buildAvatarFallback(color),
                        )
                      : _buildAvatarFallback(color),
                ),
              ),

              // Detail Info Pulau
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nama Pulau Dominan
                      Text(
                        widget.island.name,
                        style: GoogleFonts.pressStart2p(
                          color: Colors.white,
                          fontSize: 9,
                          shadows: const [
                            Shadow(color: Colors.black45, blurRadius: 3),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),

                      // Modern Progress Bar
                      MuseumProgressBar(
                        progress: widget.progress,
                        activeColor: const Color(0xFFFFD54F),
                        height: 6,
                      ),
                      const SizedBox(height: 4),

                      // Counter Item
                      Row(
                        children: [
                          Text(
                            widget.progress.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            ' Item',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                            ),
                          ),
                          if (widget.progress.isComplete)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Text('✅', style: TextStyle(fontSize: 8)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Chevron Icon
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.5),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(Color color) {
    return Container(
      color: color.withOpacity(0.4),
      child: const Icon(
        Icons.landscape_rounded,
        color: Colors.white38,
        size: 24,
      ),
    );
  }
}
