library;

/// una pagina del catalogo de la pokedex dado por offset-limit
const String kCatalogQuery = r'''
query CatalogPage($limit: Int!, $offset: Int!) {
  pokemon(
    limit: $limit
    offset: $offset
    where: {is_default: {_eq: true}}
    order_by: {id: asc}
  ) {
    id
    name
    pokemon_species_id
    pokemontypes(order_by: {slot: asc}) {
      slot
      type { id name }
    }
    pokemonspecy {
      generation_id
      generation { name }
    }
  }
}
''';

/// total de Pokemons (para calcular el numero de paginas)
const String kCatalogCountQuery = r'''
query CatalogCount {
  pokemon_aggregate(where: {is_default: {_eq: true}}) {
    aggregate { count }
  }
}
''';
