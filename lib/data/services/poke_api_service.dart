import 'package:dio/dio.dart';

import '../models/pokemon.dart';
import '../models/pokemon_detail.dart';
import '../../core/constants/api_constants.dart';

class PokeApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // 1. Listado básico (solo nombres + urls) - muy ligero
  Future<List<Map<String, dynamic>>> fetchPokemonList({
    required int limit,
    required int offset,
  }) async {
    final response = await _dio.get(
      '/pokemon',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return List<Map<String, dynamic>>.from(response.data['results']);
  }

  // 2. Obtener detalles de varios Pokémon en paralelo (clave del rendimiento)
  Future<List<Pokemon>> fetchPokemonDetailsBatch(List<String> urls) async {
    final futures = urls.map((url) => _dio.get(url));
    final responses = await Future.wait(futures);

    return responses.map((res) {
      return Pokemon.fromJson(res.data);
    }).toList();
  }

  // 3. Detalle completo de un Pokémon
  Future<PokemonDetail> fetchPokemonDetail(int id) async {
    final pokemonRes = await _dio.get('/pokemon/$id');
    final speciesRes = await _dio.get('/pokemon-species/$id');

    String? description;
    final flavorTexts = speciesRes.data['flavor_text_entries'] as List;
    final spanish = flavorTexts.firstWhere(
      (e) => e['language']['name'] == 'es',
      orElse: () =>
          flavorTexts.firstWhere((e) => e['language']['name'] == 'en'),
    );
    description = (spanish['flavor_text'] as String)
        .replaceAll('\n', ' ')
        .replaceAll('\f', ' ');

    final evolutionUrl = speciesRes.data['evolution_chain']['url'];

    return PokemonDetail.fromJson(
      pokemonRes.data,
      description: description,
      evolutionUrl: evolutionUrl,
    );
  }

  // 4. Cadena evolutiva
  Future<List<Map<String, dynamic>>> fetchEvolutionChain(String url) async {
    final response = await _dio.get(url);
    final chain = response.data['chain'];
    List<Map<String, dynamic>> evolutions = [];

    void parseChain(Map<String, dynamic> node) {
      final species = node['species'];
      final id = int.parse(species['url'].split('/')[6]);
      evolutions.add({'id': id, 'name': species['name']});
      if (node['evolves_to'] != null &&
          (node['evolves_to'] as List).isNotEmpty) {
        for (var e in node['evolves_to']) {
          parseChain(e);
        }
      }
    }

    parseChain(chain);
    return evolutions;
  }

  // 5. Tipos y generaciones (para filtros)
  Future<List<String>> fetchTypes() async {
    final response = await _dio.get('/type');
    return (response.data['results'] as List)
        .map((t) => t['name'] as String)
        .where((t) => t != 'unknown' && t != 'shadow')
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchGenerations() async {
    final response = await _dio.get('/generation');
    return List<Map<String, dynamic>>.from(response.data['results']);
  }
}
