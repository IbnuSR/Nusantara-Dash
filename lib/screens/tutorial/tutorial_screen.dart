import 'package:flutter/material.dart';
import 'tutorial_controller.dart';
import 'tutorial_data.dart';
import 'tutorial_indicator.dart';
import 'tutorial_page.dart';

/// Screen Utama "📖 Buku Penjelajah Nusantara" (How To Play / Tutorial)
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  late final TutorialController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TutorialController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E100D),
      body: Stack(
        children: [
          // 1. Interactive PageView Slider
          PageView.builder(
            controller: _controller.pageController,
            onPageChanged: _controller.onPageChanged,
            itemCount: _controller.totalPages,
            itemBuilder: (context, index) {
              final pageData = TutorialData.pages[index];
              return TutorialPage(page: pageData);
            },
          ),

          // 2. Top Action Bar (Tombol Close / Lewati)
          Positioned(
            top: 16.0,
            right: 16.0,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1B18).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 6.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20.0),
                    onTap: () => _controller.completeAndClose(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.close, color: Color(0xFFFFD700), size: 16.0),
                          SizedBox(width: 4.0),
                          Text(
                            'Tutup',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Bottom Navigation Bar (Kembali - Indicator - Next / Mulai Petualangan)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1B18).withOpacity(0.95),
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFFFFD700).withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                ),
                child: ValueListenableBuilder<int>(
                  valueListenable: _controller.currentIndexNotifier,
                  builder: (context, currentIndex, child) {
                    final isFirst = currentIndex == 0;
                    final isLast = currentIndex == _controller.totalPages - 1;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tombol KEMBALI
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isFirst ? 0.0 : 1.0,
                          child: IgnorePointer(
                            ignoring: isFirst,
                            child: ElevatedButton.icon(
                              onPressed: _controller.previousPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3A231D),
                                foregroundColor: Colors.white,
                                elevation: 4.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  side: BorderSide(
                                    color: Colors.amber.shade400,
                                    width: 1.2,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                  vertical: 8.0,
                                ),
                              ),
                              icon: const Icon(Icons.arrow_back, size: 16.0),
                              label: const Text(
                                'Kembali',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Indikator Halaman (Dots)
                        TutorialIndicator(
                          count: _controller.totalPages,
                          currentIndex: currentIndex,
                        ),

                        // Tombol NEXT / MULAI PETUALANGAN
                        ElevatedButton.icon(
                          onPressed: () => _controller.nextPage(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLast
                                ? const Color(0xFF4CAF50) // Hijau Sukses di Halaman Akhir
                                : const Color(0xFFFF9800), // Oranye Mas di Halaman Biasa
                            foregroundColor: Colors.white,
                            elevation: 6.0,
                            shadowColor: isLast ? Colors.green.shade900 : Colors.amber.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              side: const BorderSide(
                                color: Color(0xFFFFD700),
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                          ),
                          icon: Icon(
                            isLast ? Icons.play_arrow : Icons.arrow_forward,
                            size: 18.0,
                          ),
                          label: Text(
                            isLast ? 'Mulai Petualangan' : 'Lanjut',
                            style: const TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
