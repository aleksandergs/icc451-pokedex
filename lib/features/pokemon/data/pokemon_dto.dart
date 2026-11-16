import '../domain/pokemon.dart';

/// DTO de un Pokémon tal como llega de GraphQL.
class PokemonDto {
  const PokemonDto({
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
  final List<PokemonType> types;

  /// nodo de la consulta de catalogo (`kCatalogQuery`).
  factory PokemonDto.fromCatalogNode(Map<String, dynamic> node) {
    final Map<String, dynamic> species = asMap(node['pokemonspecy']);
    final Map<String, dynamic> generation = asMap(species['generation']);
    final int id = asInt(node['id']);

    return PokemonDto(
      id: id,
      name: asString(node['name']),
      speciesId: asInt(node['pokemon_species_id'], fallback: id),
      pokedexNumber: id,
      generationId: asInt(species['generation_id']),
      generationName: asString(generation['name']),
      types: parseTypes(node['pokemontypes']),
    );
  }

  PokemonSummary toSummary() => PokemonSummary(
    id: id,
    name: name,
    speciesId: speciesId,
    pokedexNumber: pokedexNumber,
    generationId: generationId,
    generationName: generationName,
    types: types,
  );

  static List<PokemonType> parseTypes(dynamic raw) =>
      ((raw as List<dynamic>?) ?? const <dynamic>[])
          .map((dynamic entry) {
            final Map<String, dynamic> type = asMap(asMap(entry)['type']);
            return PokemonType(
              id: asInt(type['id']),
              name: asString(type['name']),
            );
          })
          .where((PokemonType type) => type.name.isNotEmpty)
          .toList(growable: false);

  static Map<String, dynamic> asMap(dynamic value) =>
      value is Map<String, dynamic> ? value : const <String, dynamic>{};

  static String asString(dynamic value) => value == null ? '' : '$value';

  static int asInt(dynamic value, {int fallback = 0}) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
}
