class Weapon {
  final String id;
  final String name;
  final String description;
  final String history;
  final String imagePath; // ✅ Gambar polosan (untuk di dalam game & popup/detail)
  final String backgroundImage; // ✅ Gambar dengan background (untuk di menu koleksi)
  final int damage;
  final int price;
  final bool isLocked;
  final String rarity;
  final String origin;
  final bool isSacred;
  final bool isCombined;

  // Getters untuk backward compatibility
  String get iconPath => imagePath;
  String get menuIconPath => backgroundImage;

  Weapon({
    required this.id,
    required this.name,
    required this.description,
    required this.history,
    required this.imagePath,
    required this.backgroundImage,
    required this.damage,
    required this.price,
    this.isLocked = true,
    required this.rarity,
    required this.origin,
    this.isSacred = false,
    this.isCombined = false,
  });

  Weapon copyWith({bool? isLocked}) {
    return Weapon(
      id: id,
      name: name,
      description: description,
      history: history,
      imagePath: imagePath,
      backgroundImage: backgroundImage,
      damage: damage,
      price: price,
      isLocked: isLocked ?? this.isLocked,
      rarity: rarity,
      origin: origin,
      isSacred: isSacred,
      isCombined: isCombined,
    );
  }
}
