import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../../game/nusantara_dash_game.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  // Data 5 Pulau Besar
  final List<Map<String, dynamic>> islands = const [
    {
      'name': 'SUMATRA',
      'icon': '🌴',
      'unlocked': true,
      'weapon': 'Rencong',
      'color': Colors.green,
    },
    {
      'name': 'JAWA',
      'icon': '🌾',
      'unlocked': false,
      'weapon': 'Keris',
      'color': Colors.orange,
    },
    {
      'name': 'KALIMANTAN',
      'icon': '🌲',
      'unlocked': false,
      'weapon': 'Mandau',
      'color': Colors.brown,
    },
    {
      'name': 'SULAWESI',
      'icon': '🌊',
      'unlocked': false,
      'weapon': 'Badik',
      'color': Colors.blue,
    },
    {
      'name': 'PAPUA',
      'icon': '🦜',
      'unlocked': false,
      'weapon': 'Busur Kasuari',
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🗺️ Pilih Pulau'),
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.brown[900]!, Colors.brown[700]!],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: islands.length,
          itemBuilder: (context, index) {
            final island = islands[index];
            final isUnlocked = island['unlocked'] as bool;
            final color = island['color'] as Color;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              color: isUnlocked ? color.withOpacity(0.3) : Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: isUnlocked ? color : Colors.grey,
                  width: 2,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Text(
                  island['icon'] as String,
                  style: const TextStyle(fontSize: 48),
                ),
                title: Text(
                  island['name'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: isUnlocked ? Colors.white : Colors.grey,
                  ),
                ),
                subtitle: Text(
                  isUnlocked
                      ? '🗡️ Senjata Suci: ${island['weapon']}'
                      : '🔒 Selesaikan pulau sebelumnya',
                  style: TextStyle(
                    color: isUnlocked ? Colors.white70 : Colors.grey,
                  ),
                ),
                trailing: isUnlocked
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      )
                    : const Icon(Icons.lock, color: Colors.grey, size: 32),
                onTap: isUnlocked
                    ? () {
                        // Launch game dengan parameter pulau
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameWidget(
                              game: NusantaraDashGame(
                                islandName: island['name'] as String,
                              ),
                            ),
                          ),
                        );
                      }
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
