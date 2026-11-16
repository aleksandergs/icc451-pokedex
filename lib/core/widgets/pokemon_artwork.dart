import 'dart:io';

import 'package:flutter/material.dart';

import '../cache/image_store.dart';
import '../../app/localization/strings.dart';
import '../network/pokeapi_urls.dart';

/// Imagen de un Pokemon con cache en disco y recurso de respaldo.
/// La cadena de respaldo es artwork oficial -> sprite -> icono de imagen no disponible
class PokemonArtwork extends StatefulWidget {
  const PokemonArtwork({required this.pokemonId, this.size, super.key});

  final int pokemonId;
  final double? size;

  @override
  State<PokemonArtwork> createState() => _PokemonArtworkState();
}

class _PokemonArtworkState extends State<PokemonArtwork> {
  late Future<String?> _future;

  @override
  void initState() {
    super.initState();
    _future = _resolve();
  }

  @override
  void didUpdateWidget(PokemonArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pokemonId != widget.pokemonId) {
      _future = _resolve();
    }
  }

  Future<String?> _resolve() async {
    final List<String> urls = <String>[
      PokeApiUrls.artwork(widget.pokemonId),
      PokeApiUrls.sprite(widget.pokemonId),
    ];
    for (final String url in urls) {
      final String? path = await ImageStore.instance.resolve(url);
      if (path != null) return path;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double side = widget.size ?? 96;

    return SizedBox(
      width: side,
      height: side,
      child: FutureBuilder<String?>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          final String? path = snapshot.data;
          if (path == null) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return _ImageFallback(size: side);
          }

          return Image.file(
            File(path),
            width: side,
            height: side,
            fit: BoxFit.contain,
            errorBuilder: (
              BuildContext context,
              Object error,
              StackTrace? stackTrace,
            ) => _ImageFallback(size: side),
          );
        },
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: AppStrings.imageUnavailable,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported_outlined,
          size: size * 0.4,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
