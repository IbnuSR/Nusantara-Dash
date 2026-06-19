import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shop_item.dart';
import 'shop_data.dart';
import 'package:nusantara_dash/utils/coin_manager.dart';

class ShopScreen extends StatefulWidget {
  final VoidCallback? onPurchaseSuccess;

  const ShopScreen({super.key, this.onPurchaseSuccess});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _userCoins = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final coins = await CoinManager.getCoins();
    setState(() {
      _userCoins = coins;
      _isLoading = false;
    });
  }

  Future<void> _buyItem(ShopItem item) async {
    if (!ShopData.canBuyItem(item, _userCoins)) {
      _showSnackbar(
        '❌ Koin tidak cukup! Mainkan game untuk cari koin.',
        Colors.redAccent,
      );
      return;
    }

    final confirmed = await _showConfirmDialog(item);
    if (!confirmed) return;

    final success = await CoinManager.spendCoins(item.price);

    if (success) {
      await _grantItem(item);

      setState(() {
        _userCoins = ShopData.calculateRemainingCoins(_userCoins, item);
      });

      _showSnackbar('✅ Berhasil membeli ${item.name}!', Colors.green);
      widget.onPurchaseSuccess?.call();
    } else {
      _showSnackbar('❌ Transaksi gagal!', Colors.red);
    }
  }

  Future<void> _grantItem(ShopItem item) async {
    switch (item.type) {
      case ShopItemType.life:
        await CoinManager.addExtraLife();
        break;
      case ShopItemType.clue:
        await CoinManager.addClue();
        break;
      case ShopItemType.key:
        // Logika unlock pulau bisa dipasang di sini nanti
        break;
    }
  }

  Future<bool> _showConfirmDialog(ShopItem item) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1A237E),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.amber, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Beli ${item.name}?',
              style: GoogleFonts.pressStart2p(
                color: Colors.amber,
                fontSize: 14,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Harga: ',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 20,
                    ),
                    Text(
                      ' ${item.price}',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'BATAL',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  'BELI',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnackbar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        backgroundColor: bgColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  IconData _getIconData(String iconKey) {
    if (iconKey == 'key') return Icons.vpn_key;
    if (iconKey == 'heart') return Icons.favorite;
    if (iconKey == 'lightbulb') return Icons.lightbulb;
    return Icons.shopping_bag;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1B2A),
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(
          '🛒 Toko Nusantara',
          style: GoogleFonts.pressStart2p(color: Colors.amber, fontSize: 14),
        ),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 10,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_userCoins',
                  style: GoogleFonts.pressStart2p(
                    color: Colors.amber,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1A237E)],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: ShopData.availableItems.length,
          itemBuilder: (ctx, index) {
            final item = ShopData.availableItems[index];
            final canAfford = ShopData.canBuyItem(item, _userCoins);

            return Card(
              color: const Color(0xFF1B2845),
              elevation: 8,
              shadowColor: Colors.black54,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: canAfford
                      ? Colors.amber.withOpacity(0.5)
                      : Colors.grey.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: canAfford
                            ? Colors.amber.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconData(item.icon),
                        color: canAfford ? Colors.amber : Colors.grey,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.pressStart2p(
                              color: canAfford ? Colors.white : Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.monetization_on,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${item.price}',
                                style: GoogleFonts.pressStart2p(
                                  color: canAfford ? Colors.amber : Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: canAfford ? () => _buyItem(item) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canAfford
                            ? Colors.green.shade600
                            : Colors.grey.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'BELI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
