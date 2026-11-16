import 'package:flutter/material.dart';

import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/pokemon_artwork.dart';
import '../domain/pokemon.dart';

/// Tarjeta del pokemon con su numero, imagen, nombre y tipos.
class PokemonCard extends StatelessWidget {
  const PokemonCard({required this.pokemon, super.key});

  final PokemonSummary pokemon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Semantics(
      container: true,
      label: '${pokemon.formattedDex} ${pokemon.displayName}',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
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
}
