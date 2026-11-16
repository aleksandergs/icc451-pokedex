import '../../../../core/network/graphql_client.dart';
import '../../../../core/network/pokeapi_queries.dart';
import 'pokemon_dto.dart';

/// fuente remota GraphQL (PokeAPI).
class PokemonRemoteDataSource {
  PokemonRemoteDataSource(this._client);

  final GraphQlClient _client;

  /// Cantidad total de Pokémon por defecto en PokeAPI.
  Future<int> catalogTotal() async {
    final Map<String, dynamic> data = await _client.query(kCatalogCountQuery);
    final Map<String, dynamic> aggregate =
        (data['pokemon_aggregate'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    final Map<String, dynamic> inner =
        (aggregate['aggregate'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    return (inner['count'] as num?)?.toInt() ?? 0;
  }

  /// Una pagina del catalogo.
  Future<List<PokemonDto>> fetchCatalogPage({
    required int limit,
    required int offset,
  }) async {
    final Map<String, dynamic> data = await _client.query(
      kCatalogQuery,
      variables: <String, dynamic>{'limit': limit, 'offset': offset},
    );
    final List<dynamic> nodes =
        (data['pokemon'] as List<dynamic>?) ?? const <dynamic>[];
    return nodes
        .whereType<Map<String, dynamic>>()
        .map(PokemonDto.fromCatalogNode)
        .toList(growable: false);
  }
}
