import 'package:flutter/material.dart';
import '../../utils/game_prefs.dart';
import 'tutorial_data.dart';

/// Controller mengelola navigasi halaman, state indeks, dan penyelesaian tutorial
class TutorialController {
  final PageController pageController = PageController();
  final ValueNotifier<int> currentIndexNotifier = ValueNotifier<int>(0);

  int get totalPages => TutorialData.pages.length;
  bool get isLastPage => currentIndexNotifier.value == totalPages - 1;
  bool get isFirstPage => currentIndexNotifier.value == 0;

  void onPageChanged(int index) {
    currentIndexNotifier.value = index;
  }

  void nextPage(BuildContext context) {
    if (isLastPage) {
      completeAndClose(context);
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void previousPage() {
    if (!isFirstPage) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> completeAndClose(BuildContext context) async {
    await GamePrefs.setTutorialCompleted(true);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  void dispose() {
    pageController.dispose();
    currentIndexNotifier.dispose();
  }
}
