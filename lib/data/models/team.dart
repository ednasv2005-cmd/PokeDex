import 'package:uuid/uuid.dart';

class Team {
  final String id;
  String name;
  List<int> pokemonIds; // Solo guardamos IDs

  Team({String? id, required this.name, List<int>? pokemonIds})
    : id = id ?? const Uuid().v4(),
      pokemonIds = pokemonIds ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'pokemonIds': pokemonIds,
  };

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      pokemonIds: List<int>.from(json['pokemonIds'] ?? []),
    );
  }
}
