import 'package:flutter/material.dart';

class Weapon {
  final String id;
  final String name;
  final String description;
  final String history; // ✅ TAMBAH: Sejarah senjata
  final String iconPath;
  final int damage;
  final int price;
  final bool isLocked;
  final String rarity;
  final String origin;
  final bool isSacred; // ✅ TAMBAH: Apakah senjata suci
  final bool isCombined; // ✅ TAMBAH: Apakah senjata gabungan

  Weapon({
    required this.id,
    required this.name,
    required this.description,
    required this.history,
    required this.iconPath,
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
      iconPath: iconPath,
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
