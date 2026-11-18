import 'package:flutter/material.dart';

import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/pokemon_artwork.dart';
import '../domain/pokemon.dart';
import '../../settings/presentation/catalog_view_provider.dart';

/// Tarjeta del pokemon con su numero, imagen, nombre y tipos.
class PokemonCard extends StatelessWidget {
  const PokemonCard({required this.pokemon, required this.viewMode, super.key});

  final PokemonSummary pokemon;
  final ViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return (viewMode == ViewMode.grid) ? buildGrid(theme) : buildList(theme);
  }

  Widget buildGrid(ThemeData theme) {
    return Semantics(
      container: true,
      label: '${pokemon.formattedDex} ${pokemon.displayName}',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                pokemon.formattedDex,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.6,
                ),
              ),
              Expanded(
                child: Center(
                  child: PokemonArtwork(pokemonId: pokemon.id, size: 84),
                ),
              ),
              Text(
                pokemon.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: pokemon.types
                    .map(
                      (PokeType type) => TypeChip(type: type.name, dense: true),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildList(ThemeData theme) {
    return Semantics(
      container: true,
      label: '${pokemon.formattedDex} ${pokemon.displayName}',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              PokemonArtwork(pokemonId: pokemon.id, size: 84),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    pokemon.formattedDex,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    pokemon.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: pokemon.types
                        .map(
                          (PokeType type) =>
                              TypeChip(type: type.name, dense: true),
                        )
                        .toList(growable: false),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
