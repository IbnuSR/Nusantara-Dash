import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nusantara_dash/game/data/museum_item_model.dart';
import 'package:nusantara_dash/game/managers/museum_manager.dart';
import 'museum_item_detail_screen.dart';
import 'widgets/cultural_item_card.dart';
import 'widgets/museum_header_card.dart';

/// Museum Province Screen — Menampilkan grid Cultural Item dalam satu provinsi.
///
/// Refined & Polished (Sprint 4.5):
/// - Menggunakan reusable [MuseumHeaderCard] & [CulturalItemCard].
/// - Grid responsif menyesuaikan ukuran layar (Mobile Landscape / Tablet / Desktop).
/// - Transisi Fade saat dimuat.
class MuseumProvinceScreen extends StatefulWidget {
  final String provinceId;

  const MuseumProvinceScreen({super.key, required this.provinceId});

  @override
  State<MuseumProvinceScreen> createState() => _MuseumProvinceScreenState();
}

class _MuseumProvinceScreenState extends State<MuseumProvinceScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  MuseumProvince? _province;
  MuseumProgress _provinceProgress = const MuseumProgress(collected: 0, total: 0);
  final Map<String, bool> _unlockedMap = {};

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

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

    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final province = await MuseumManager.instance.getProvince(widget.provinceId);
    final progress = await MuseumManager.instance.getProvinceProgress(widget.provinceId);

    final Map<String, bool> unlockedMap = {};
    if (province != null) {
      for (final item in province.items) {
        unlockedMap[item.id] = await MuseumManager.instance.isItemUnlocked(item.id);
      }
    }

    if (!mounted) return;
    setState(() {
      _province = province;
      _provinceProgress = progress;
      _unlockedMap.addAll(unlockedMap);
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
    final name = _province?.name ?? '...';
    return AppBar(
      backgroundColor: const Color(0xFF1A237E),
      elevation: 8,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Color(0xFFFFB300)),
      title: Text(
        '🏛️ $name',
        style: GoogleFonts.pressStart2p(
          color: const Color(0xFFFFB300),
          fontSize: 11,
          shadows: const [
            Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFFFB300)),
    );
  }

  Widget _buildBody() {
    if (_province == null) {
      return const Center(
        child: Text('Provinsi tidak ditemukan.',
            style: TextStyle(color: Colors.white54)),
      );
    }

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
          // Header Card
          MuseumHeaderCard(
            title: 'Koleksi ${_province!.name}',
            iconEmoji: '📍',
            progress: _provinceProgress,
            accentColor: const Color(0xFFFFB300),
          ),
          Expanded(child: _buildItemGrid()),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Responsive Cultural Item Grid
  // ---------------------------------------------------------------------------

  Widget _buildItemGrid() {
    final items = _province!.items;

    if (items.isEmpty) {
      return const Center(
        child: Text('Belum ada item budaya di provinsi ini.',
            style: TextStyle(color: Colors.white54)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final int crossAxisCount = screenWidth > 900 ? 4 : 3;
        final double childAspectRatio = screenWidth > 900 ? 2.6 : 2.4;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isUnlocked = _unlockedMap[item.id] ?? false;

            return CulturalItemCard(
              item: item,
              isUnlocked: isUnlocked,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MuseumItemDetailScreen(itemId: item.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
