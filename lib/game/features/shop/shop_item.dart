enum ShopItemType { key, life, clue }

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final ShopItemType type;
  final String icon;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.icon,
  });

  factory ShopItem.nusantaraKey() => ShopItem(
        id: 'key_nusantara',
        name: 'Kunci Nusantara',
        description: 'Buka akses pulau baru yang terkunci!',
        price: 500,
        type: ShopItemType.key,
        icon: 'key',
      );

  factory ShopItem.extraLife() => ShopItem(
        id: 'life_extra',
        name: 'Nyawa Tambahan',
        description: 'Kesempatan kedua saat jatuh atau menabrak rintangan.',
        price: 150,
        type: ShopItemType.life,
        icon: 'heart',
      );

  factory ShopItem.helpClue() => ShopItem(
        id: 'clue_help',
        name: 'Clue Bantuan',
        description: 'Memberikan petunjuk untuk menjawab soal kuis.',
        price: 75,
        type: ShopItemType.clue,
        icon: 'lightbulb',
      );
}
