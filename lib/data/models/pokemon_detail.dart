class PokemonDetail {
  final int id;
  final String name;
  final int height;
  final int weight;
  final List<String> types;
  final List<String> abilities;
  final Map<String, int> stats;
  final String cryUrl;
  final String? description;
  final String? evolutionChainUrl;
  final List<String> moves;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.abilities,
    required this.stats,
    required this.cryUrl,
    this.description,
    this.evolutionChainUrl,
    required this.moves,
  });

  factory PokemonDetail.fromJson(
    Map<String, dynamic> json, {
    String? description,
    String? evolutionUrl,
  }) {
    final statsMap = <String, int>{};
    for (var stat in json['stats']) {
      statsMap[stat['stat']['name']] = stat['base_stat'];
    }

    return PokemonDetail(
      id: json['id'],
      name: json['name'],
      height: json['height'],
      weight: json['weight'],
      types: (json['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList(),
      abilities: (json['abilities'] as List)
          .map((a) => a['ability']['name'] as String)
          .toList(),
      stats: statsMap,
      cryUrl: json['cries']?['latest'] ?? json['cries']?['legacy'] ?? '',
      description: description,
      evolutionChainUrl: evolutionUrl,
      moves: (json['moves'] as List)
          .take(10)
          .map((m) => m['move']['name'] as String)
          .toList(),
    );
  }
}
