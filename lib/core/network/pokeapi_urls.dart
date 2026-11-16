/// URLs de imagen de PokeAPI.
class PokeApiUrls {
  const PokeApiUrls._();

  /// las rutas son deterministas a partir del id, por lo que no es necesario pedirlas por GraphQL
  static const String _spritesBase = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon';

  static String artwork(int id) => '$_spritesBase/other/official-artwork/$id.png';

  static String sprite(int id) => '$_spritesBase/$id.png';
}