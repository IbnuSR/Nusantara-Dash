import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nusantara_dash/game/data/museum_item_model.dart';
import 'package:nusantara_dash/game/managers/museum_manager.dart';
import 'museum_province_screen.dart';
import 'widgets/museum_header_card.dart';
import 'widgets/province_card.dart';

/// Museum Island Screen — Menampilkan daftar provinsi dalam satu pulau.
///
/// Refined & Polished (Sprint 4.5):
/// - Memanfaatkan reusable [MuseumHeaderCard] & [ProvinceCard].
/// - Alignment rapi & efek tekan animasi pada kartu provinsi.
/// - Animasi Fade saat halaman dimuat.
class MuseumIslandScreen extends StatefulWidget {
  final String islandId;

  const MuseumIslandScreen({super.key, required this.islandId});

  @override
  State<MuseumIslandScreen> createState() => _MuseumIslandScreenState();
}

class _MuseumIslandScreenState extends State<MuseumIslandScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  MuseumIsland? _island;
  MuseumProgress _islandProgress = const MuseumProgress(collected: 0, total: 0);
  final Map<String, MuseumProgress> _provinceProgressMap = {};

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const Map<String, Color> _islandColors = {
    'sumatra': Color(0xFF2E7D32),
    'jawa': Color(0xFF1565C0),
    'kalimantan': Color(0xFFBF360C),
    'sulawesi': Color(0xFF6A1B9A),
    'papua': Color(0xFF00695C),
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    // Subscribe: refresh tampilan ketika ada item baru yang di-unlock
    MuseumManager.instance.addListener(_onMuseumChanged);
    _loadData();
  }

  @override
  void dispose() {
    MuseumManager.instance.removeListener(_onMuseumChanged);
    _animController.dispose();
    super.dispose();
  }

  /// Dipanggil oleh MuseumManager.notifyListeners() ketika terjadi unlock.
  void _onMuseumChanged() {
    if (mounted) _silentRefresh();
  }

  /// Memperbarui data progress tanpa menampilkan loading spinner.
  Future<void> _silentRefresh() async {
    if (_island == null) return;
    final islandProgress =
        await MuseumManager.instance.getIslandProgress(widget.islandId);
    final Map<String, MuseumProgress> progressMap = {};
    for (final province in _island!.provinces) {
      progressMap[province.id] =
          await MuseumManager.instance.getProvinceProgress(province.id);
    }
    if (!mounted) return;
    setState(() {
      _islandProgress = islandProgress;
      _provinceProgressMap
        ..clear()
        ..addAll(progressMap);
    });
  }

  Future<void> _loadData() async {
    final island = await MuseumManager.instance.getIsland(widget.islandId);
    final islandProgress =
        await MuseumManager.instance.getIslandProgress(widget.islandId);

    final Map<String, MuseumProgress> progressMap = {};
    if (island != null) {
      for (final province in island.provinces) {
        progressMap[province.id] =
            await MuseumManager.instance.getProvinceProgress(province.id);
      }
    }

    if (!mounted) return;
    setState(() {
      _island = island;
      _islandProgress = islandProgress;
      _provinceProgressMap.addAll(progressMap);
      _isLoading = false;
    });

    _animController.forward();
  }

  Color get _accentColor =>
      _islandColors[widget.islandId] ?? const Color(0xFF1A237E);

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
    final name = _island?.name ?? '...';
    return AppBar(
      backgroundColor: _accentColor,
      elevation: 8,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        '🏝️ $name',
        style: GoogleFonts.pressStart2p(
          color: Colors.white,
          fontSize: 11,
          shadows: const [
            Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(color: _accentColor),
    );
  }

  Widget _buildBody() {
    if (_island == null) {
      return const Center(
        child: Text('Pulau tidak ditemukan.',
            style: TextStyle(color: Colors.white54)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF0D1B2A), _accentColor.withOpacity(0.25)],
        ),
      ),
      child: Column(
        children: [
          // Reusable Header Card
          MuseumHeaderCard(
            title: 'Progress ${_island!.name}',
            iconEmoji: '🏝️',
            progress: _islandProgress,
            accentColor: _accentColor,
          ),
          Expanded(child: _buildProvinceList()),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Province List
  // ---------------------------------------------------------------------------

  Widget _buildProvinceList() {
    final provinces = _island!.provinces;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: provinces.length,
      itemBuilder: (context, index) {
        final province = provinces[index];
        final progress = _provinceProgressMap[province.id] ??
            const MuseumProgress(collected: 0, total: 0);

        return ProvinceCard(
          province: province,
          progress: progress,
          accentColor: _accentColor,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MuseumProvinceScreen(provinceId: province.id),
            ),
          ),
        );
      },
    );
  }
}
