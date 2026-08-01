import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'weapon_model.dart';
import 'weapon_data.dart';

class WeaponDetailScreen extends StatefulWidget {
  final Weapon weapon;
  final bool isOwned;
  final bool isEquipped;
  final VoidCallback onEquip;
  final VoidCallback onBuy;

  const WeaponDetailScreen({
    super.key,
    required this.weapon,
    required this.isOwned,
    required this.isEquipped,
    required this.onEquip,
    required this.onBuy,
  });

  @override
  State<WeaponDetailScreen> createState() => _WeaponDetailScreenState();
}

class _WeaponDetailScreenState extends State<WeaponDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final rarityColor = WeaponData.getRarityColor(widget.weapon.rarity);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(
          widget.weapon.name,
          style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.amber),
        ),
        backgroundColor: const Color(0xFF1A237E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ✅ GAMBAR SENJATA DETAIL (220 x 220, Fit Contain, Error Handling)
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: rarityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: rarityColor, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.asset(
                  widget.weapon.imagePath,
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        'Image Not Found',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.weapon.name,
              style: GoogleFonts.pressStart2p(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: rarityColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.weapon.isCombined ? 'GABUNGAN' : 'SUCI',
                style: GoogleFonts.pressStart2p(
                  fontSize: 10,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildStatCard('Damage', '${widget.weapon.damage}', Icons.security),
            const SizedBox(height: 12),
            _buildStatCard('Asal', widget.weapon.origin, Icons.location_on),
            const SizedBox(height: 24),

            // Deskripsi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2845),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DESKRIPSI',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.weapon.description,
                    style: const TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sejarah Lengkap
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2845),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: rarityColor, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history, color: rarityColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'SEJARAH',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 10,
                          color: rarityColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.weapon.history,
                    style: const TextStyle(color: Colors.white70, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (widget.isOwned)
              widget.isEquipped ? _buildEquippedButton() : _buildEquipButton()
            else
              _buildBuyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2845),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style:
                  GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.pressStart2p(
              fontSize: 12,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquippedButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 24),
          SizedBox(width: 8),
          Text(
            'SEDANG DIPASANG',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipButton() {
    return ElevatedButton(
      onPressed: () {
        widget.onEquip();
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFB300),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      ),
      child: const Text(
        'PASANG SENJATA',
        style: TextStyle(color: Colors.black, fontSize: 14),
      ),
    );
  }

  Widget _buildBuyButton() {
    return Column(
      children: [
        Text(
          'Harga: ${widget.weapon.price} 🪙',
          style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.amber),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: widget.onBuy,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB300),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
          child: const Text(
            'BELI SENJATA',
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
