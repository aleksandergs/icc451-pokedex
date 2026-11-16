/// Entidades del dominio de Pokemon.
library;

// 'PokemonType' hace conflicto con el nombre de la tabla
class PokeType {
  const PokeType({required this.id, required this.name});

  final int id;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is PokeType && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}

/// Resumen basico de los datos del pokemon (vistos desde la pokedex)
class PokemonSummary {
  const PokemonSummary({
    required this.id,
    required this.name,
    required this.speciesId,
    required this.pokedexNumber,
    required this.generationId,
    required this.generationName,
    required this.types,
  });

  final int id;
  final String name;
  final int speciesId;
  final int pokedexNumber;
  final int generationId;
  final String generationName;
  final List<PokeType> types;

  String get displayName {
    if (name.isEmpty) return name;

    /// Primera letra en mayuscula
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }

  /// #xxxx con padding de 0s
  String get formattedDex => '#${pokedexNumber.toString().padLeft(4, '0')}';
}
