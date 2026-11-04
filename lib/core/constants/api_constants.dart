class ApiConstants {
  static const String baseUrl = 'https://pokeapi.co/api/v2';
  static const String pokemonEndpoint = '$baseUrl/pokemon';
  static const String speciesEndpoint = '$baseUrl/pokemon-species';
  static const String typeEndpoint = '$baseUrl/type';
  static const String generationEndpoint = '$baseUrl/generation';

  // Sprites oficiales (más ligeros para la lista)
  static String spriteUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

  // Artwork oficial (para detalle)
  static String artworkUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  // Shiny
  static String shinyArtworkUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/$id.png';
}
