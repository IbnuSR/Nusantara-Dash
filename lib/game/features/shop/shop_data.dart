import 'shop_item.dart';

class ShopData {
  // Daftar barang di toko
  static final List<ShopItem> availableItems = [
    ShopItem.nusantaraKey(),
    ShopItem.extraLife(),
    ShopItem.helpClue(),
  ];

  // Mengecek apakah uang cukup
  static bool canBuyItem(ShopItem item, int userCoins) {
    return userCoins >= item.price;
  }

  // Kalkulasi sisa uang
  static int calculateRemainingCoins(int userCoins, ShopItem item) {
    return userCoins - item.price;
  }
}
