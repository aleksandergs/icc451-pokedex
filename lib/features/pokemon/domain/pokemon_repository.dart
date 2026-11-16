import 'pokemon.dart';

abstract class PokemonRepository {
  /// observa la pokedex y emite una nueva lista cada vez que la base local cambia
  Stream<List<PokemonSummary>> watchCatalog();

  /// sincroniza la pokedex remota con el local
  Future<void> syncCatalog();
}
