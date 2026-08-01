import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'weapon_data.dart';
import 'weapon_manager.dart';
import 'weapon_detail_screen.dart';
import 'weapon_model.dart';

class WeaponScreen extends StatefulWidget {
  const WeaponScreen({super.key});

  @override
  State<WeaponScreen> createState() => _WeaponScreenState();
}

class _WeaponScreenState extends State<WeaponScreen> {
  List<Weapon> _weapons = [];
  String _equippedWeaponId = '';
  List<String> _ownedWeapons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeapons();
  }

  Future<void> _loadWeapons() async {
    final owned = await WeaponManager.getOwnedWeapons();
    final equipped = await WeaponManager.getEquippedWeapon();

    if (mounted) {
      setState(() {
        _weapons = WeaponData.allWeapons;
        _ownedWeapons = owned;
        _equippedWeaponId = equipped ?? '';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1B2A),
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    final sacredCount = _ownedWeapons.where((id) {
      final weapon = WeaponData.getWeaponById(id);
      return weapon?.isSacred == true && weapon?.isCombined == false;
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(
          '⚔️ SENJATA SUCI',
          style: GoogleFonts.pressStart2p(fontSize: 14, color: Colors.amber),
        ),
        backgroundColor: const Color(0xFF1A237E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Info header
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1B2845),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory, color: Colors.amber, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Senjata Suci: $sacredCount/5',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: sacredCount / 5,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
                ),
                if (sacredCount == 5) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '🎉 Semua senjata suci telah dikuasai! Nusantara Blade unlocked!',
                    style: TextStyle(color: Color(0xFFFFB300), fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          // Grid senjata
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: _weapons.length,
              itemBuilder: (context, index) {
                final weapon = _weapons[index];
                final isOwned = _ownedWeapons.contains(weapon.id);
                final isEquipped = _equippedWeaponId == weapon.id;
                return _buildWeaponCard(weapon, isOwned, isEquipped);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeaponCard(Weapon weapon, bool isOwned, bool isEquipped) {
    final rarityColor = WeaponData.getRarityColor(weapon.rarity);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeaponDetailScreen(
              weapon: weapon,
              isOwned: isOwned,
              isEquipped: isEquipped,
              onEquip: () => _onEquip(weapon.id),
              onBuy: () => _onBuy(weapon),
            ),
          ),
        ).then((_) => _loadWeapons());
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B2845),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEquipped
                ? const Color(0xFFFFB300)
                : isOwned
                    ? rarityColor
                    : Colors.white24,
            width: isEquipped ? 3 : 2,
          ),
        ),
        child: Column(
          children: [
            // ✅ AREA GAMBAR SENJATA (DIPERBARUI)
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: rarityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isOwned
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          weapon
                              .menuIconPath, // ✅ MENAMPILKAN GAMBAR DENGAN BACKGROUND
                          fit: BoxFit
                              .contain, // ✅ Agar seluruh gambar terlihat proporsional
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback ke icon jika gambar background belum ada/salah path
                            return Icon(
                              _getWeaponIcon(weapon.id),
                              size: 50,
                              color: rarityColor,
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.lock,
                          size: 40,
                          color: Colors.white24,
                        ),
                      ),
              ),
            ),

            // Info nama dan status
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    weapon.name,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8, // Sedikit diperbesar agar lebih terbaca
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (weapon.isCombined)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'GABUNGAN',
                        style: TextStyle(
                          fontSize: 6,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (weapon.isSacred)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: rarityColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'SUCI',
                        style: TextStyle(
                          fontSize: 6,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (isEquipped) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'EQUIPPED',
                        style: TextStyle(
                          fontSize: 6,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeaponIcon(String weaponId) {
    switch (weaponId) {
      case 'rencong_sumatra':
        return Icons.shield;
      case 'keris_jawa':
        return Icons.auto_awesome;
      case 'mandau_kalimantan':
        return Icons.sports_martial_arts;
      case 'badik_sulawesi':
        return Icons.cut;
      case 'belati_papua':
        return Icons.shield;
      case 'nusantara_blade':
        return Icons.star;
      default:
        return Icons.shield;
    }
  }

  Future<void> _onEquip(String weaponId) async {
    await WeaponManager.equipWeapon(weaponId);
    _loadWeapons();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Senjata berhasil dipasangi!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  Future<void> _onBuy(Weapon weapon) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2845),
        title: Text(
          'Beli ${weapon.name}?',
          style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.amber),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Harga: ${weapon.price} 🪙',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              weapon.description,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('BATAL', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Beli di Toko untuk mendapatkan ${weapon.name}'),
                  backgroundColor: const Color(0xFFFF9800),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('BELI', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
