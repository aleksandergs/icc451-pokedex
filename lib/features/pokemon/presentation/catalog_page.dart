import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_provider.dart';
import '../../../../app/providers.dart';
import '../../../../core/errors/failure.dart';
import '../../../../app/localization/strings.dart';
import '../../../../core/sync/sync_state.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../domain/pokemon.dart';
import '../../settings/presentation/catalog_view_provider.dart';
import 'pokemon_card.dart';

/// Catalogo/Pokedex
class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PokemonSummary>> catalog = ref.watch(catalogProvider);
    final SyncState sync =
        ref.watch(syncStateProvider).value ?? const SyncState();
    final bool isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final ViewMode viewMode = ref.watch(catalogViewProvider);
    final bool isGrid = viewMode == ViewMode.grid;

    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [Text(AppStrings.appTitle)]),
        actions: <Widget>[
          /// Boton de view (grid/list)
          IconButton(
            tooltip: isGrid ? AppStrings.gridView : AppStrings.listView,
            onPressed: () => ref.read(catalogViewProvider.notifier).toggle(),
            icon: Icon(isGrid ? Icons.grid_view : Icons.list),
          ),

          /// Boton de light/dark mode
          IconButton(
            tooltip: isDark ? AppStrings.darkMode : AppStrings.lightMode,
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          ),

          /// Boton de sincronización
          IconButton(
            tooltip: AppStrings.refresh,
            onPressed: () => ref.read(syncServiceProvider).syncCatalog(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      /// Body: barra de progreso + pokedex.
      body: Column(
        children: <Widget>[
          // Barra de progreso mientras hay una descarga en curso.
          if (sync.syncing) const LinearProgressIndicator(minHeight: 2),

          Expanded(child: _buildBody(ref, catalog, sync, viewMode)),
        ],
      ),
    );
  }

  Widget _buildBody(
    WidgetRef ref,
    AsyncValue<List<PokemonSummary>> catalog,
    SyncState sync,
    ViewMode viewMode,
  ) {
    final List<PokemonSummary> items =
        catalog.value ?? const <PokemonSummary>[];

    /// Error al leer la db local
    if (catalog.hasError && items.isEmpty) {
      return ErrorState(
        title: AppStrings.errorTitle,
        message: AppStrings.errorLocal,
        retryLabel: AppStrings.retry,
        onRetry: () => ref.read(syncServiceProvider).syncCatalog(),
      );
    }

    /// Si la db local no tiene datos los descargamos
    if (items.isEmpty) {
      /// Pantalla de carga
      if (sync.syncing) {
        return const Center(child: CircularProgressIndicator());
      }

      /// Si la última descarga fallo mostramos error con "Reintentar"
      final AppFailure? failure = sync.error;
      if (failure != null) {
        return ErrorState(
          title: AppStrings.errorTitle,
          message: failure.isConnectionIssue
              ? AppStrings.errorOffline
              : AppStrings.errorService,
          retryLabel: AppStrings.retry,
          onRetry: () => ref.read(syncServiceProvider).syncCatalog(),
        );
      }

      /// Catalogo vacio
      return ErrorState(
        title: AppStrings.errorTitle,
        message: AppStrings.errorOffline,
        retryLabel: AppStrings.retry,
        onRetry: () => ref.read(syncServiceProvider).syncCatalog(),
      );
    }

    /// Lista con pokemons con reflesh al tirar hacia abajo
    final bool isGrid = viewMode == ViewMode.grid;
    return RefreshIndicator(
      onRefresh: () => ref.read(syncServiceProvider).syncCatalog(),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final int columns = isGrid
              ? (constraints.maxWidth / 180).floor().clamp(1, 6)
              : 1;

          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: isGrid ? 8 : 0,
              crossAxisSpacing: 8,
              childAspectRatio: 0.8,
              mainAxisExtent: isGrid ? null : 88,
            ),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              final PokemonSummary pokemon = items[index];
              return PokemonCard(
                key: ValueKey<int>(pokemon.id),
                pokemon: pokemon,
                viewMode: viewMode,
              );
            },
          );
        },
      ),
    );
  }
}
