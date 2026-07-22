import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nusantara_dash/game/data/museum_item_model.dart';
import 'package:nusantara_dash/game/managers/museum_manager.dart';

/// Museum Item Detail Screen — Menampilkan rincian Cultural Item.
///
/// Refined & Polished (Sprint 4.5):
/// - Komposisi seimbang antara gambar (Hero animation) dan informasi.
/// - Layout responsif yang beradaptasi dengan Landscape Mobile, Tablet & Desktop.
/// - Badges & typography rapi dengan pembatas lembut.
class MuseumItemDetailScreen extends StatefulWidget {
  final String itemId;

  const MuseumItemDetailScreen({super.key, required this.itemId});

  @override
  State<MuseumItemDetailScreen> createState() => _MuseumItemDetailScreenState();
}

class _MuseumItemDetailScreenState extends State<MuseumItemDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  CulturalItem? _item;
  bool _isUnlocked = false;

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
    final item = await MuseumManager.instance.getItem(widget.itemId);
    final isUnlocked = await MuseumManager.instance.isItemUnlocked(widget.itemId);

    if (!mounted) return;
    setState(() {
      _item = item;
      _isUnlocked = isUnlocked;
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
    final title = _isUnlocked && _item != null ? _item!.name : 'Item Budaya';
    return AppBar(
      backgroundColor: const Color(0xFF1A237E),
      elevation: 8,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Color(0xFFFFB300)),
      title: Text(
        '📜 $title',
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
    if (_item == null) {
      return const Center(
        child: Text('Item tidak ditemukan.',
            style: TextStyle(color: Colors.white54)),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1B2A), Color(0xFF1A237E)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 800;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sisi Kiri: Artwork Image Frame (Flex 4, Max Width 320)
                Expanded(
                  flex: isWide ? 4 : 5,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: _buildImageFrame(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Sisi Kanan: Detail Information Card (Flex 6)
                Expanded(
                  flex: isWide ? 6 : 5,
                  child: _buildInfoCard(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Artwork Image Frame (Hero Animation)
  // ---------------------------------------------------------------------------

  Widget _buildImageFrame() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF162238),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isUnlocked
              ? const Color(0xFFFFB300).withOpacity(0.8)
              : Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _isUnlocked
                ? const Color(0xFFFFB300).withOpacity(0.2)
                : Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: _isUnlocked
            ? Hero(
                tag: 'item_img_${_item!.id}',
                child: Image.asset(
                  _item!.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.museum_rounded,
                      color: Color(0xFFFFB300),
                      size: 64,
                    ),
                  ),
                ),
              )
            : Container(
                color: Colors.black.withOpacity(0.5),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      color: Colors.white.withOpacity(0.35),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '🔒 Belum Ditemukan',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Jelajahi petualangan untuk menemukan item budaya ini!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Info Card
  // ---------------------------------------------------------------------------

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E).withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFB300).withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Item Name
          Text(
            _isUnlocked ? _item!.name : '???',
            style: GoogleFonts.pressStart2p(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),

          // Status & Location Badges
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildBadge(
                label: '📍 ${_item!.province}',
                bgColor: Colors.blue.withOpacity(0.2),
                textColor: Colors.lightBlueAccent,
              ),
              _buildBadge(
                label: '🏝️ ${_item!.island}',
                bgColor: Colors.purple.withOpacity(0.2),
                textColor: Colors.purpleAccent,
              ),
              _buildBadge(
                label: _isUnlocked ? '✅ TERBUKA' : '🔒 TERKUNCI',
                bgColor: _isUnlocked
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                textColor: _isUnlocked ? Colors.greenAccent : Colors.redAccent,
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 20),

          // Scrollable Cultural Description
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                _isUnlocked
                    ? _item!.description
                    : 'Informasi dan sejarah mengenai item budaya ini masih terkunci. Temukan item budaya ini dalam permainan untuk membuka pengetahuannya di Museum Nusantara!',
                style: TextStyle(
                  color: _isUnlocked
                      ? Colors.white.withOpacity(0.85)
                      : Colors.white.withOpacity(0.4),
                  fontSize: 11.5,
                  height: 1.6,
                  fontStyle: _isUnlocked ? FontStyle.normal : FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
