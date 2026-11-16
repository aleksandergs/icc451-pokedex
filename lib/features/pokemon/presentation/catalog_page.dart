import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/failure.dart';
import '../../../../app/localization/strings.dart';
import '../../../../core/sync/sync_state.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../domain/pokemon.dart';
import 'pokemon_card.dart';

/// Catalogo/Pokedex
class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PokemonSummary>> catalog = ref.watch(catalogProvider);
    final SyncState sync =
        ref.watch(syncStateProvider).value ?? const SyncState();

    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [Text(AppStrings.appTitle)]),
        actions: <Widget>[
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

          Expanded(child: _buildBody(ref, catalog, sync)),
        ],
      ),
    );
  }

  Widget _buildBody(
    WidgetRef ref,
    AsyncValue<List<PokemonSummary>> catalog,
    SyncState sync,
  ) {
    final List<PokemonSummary> items = catalog.value ?? const <PokemonSummary>[];

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

      // Catalogo vacio
      return EmptyState(
        icon: Icons.catching_pokemon,
        title: AppStrings.emptyCatalogTitle,
        message: sync.isOnline
            ? AppStrings.emptyCatalogMessage
            : AppStrings.emptyCatalogOfflineMessage,
        actionLabel: AppStrings.retry,
        onAction: () => ref.read(syncServiceProvider).syncCatalog(),
      );
    }

    // Lista con pokemons con reflesh al tirar hacia abajo
    return RefreshIndicator(
      onRefresh: () => ref.read(syncServiceProvider).syncCatalog(),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Diseño responsivo para distintos tamaños de pantalla
          // (RF-CAT-06).
          final int columns = (constraints.maxWidth / 180).floor().clamp(2, 6);
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.74,
            ),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              final PokemonSummary pokemon = items[index];
              return PokemonCard(
                key: ValueKey<int>(pokemon.id),
                pokemon: pokemon,
              );
            },
          );
        },
      ),
    );
  }
}
