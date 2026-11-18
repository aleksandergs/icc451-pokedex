import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ViewMode { grid, list }

// true = Grid, false = List
class CatalogViewNotifier extends Notifier<ViewMode> {
  @override
  ViewMode build() => ViewMode.grid;

  void toggle() =>
      state = (state == ViewMode.grid ? ViewMode.list : ViewMode.grid);
}

final catalogViewProvider = NotifierProvider<CatalogViewNotifier, ViewMode>(
  CatalogViewNotifier.new,
);
