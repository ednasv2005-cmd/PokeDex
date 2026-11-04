import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/models/team.dart';
import '../data/services/poke_api_service.dart';

final teamsProvider = StateNotifierProvider<TeamsNotifier, List<Team>>((ref) {
  return TeamsNotifier();
});

class TeamsNotifier extends StateNotifier<List<Team>> {
  late Box _box;

  TeamsNotifier() : super([]) {
    _box = Hive.box('teams');
    _loadTeams();
  }

  void _loadTeams() {
    final data = _box.get('teams_list', defaultValue: <Map>[]);
    state = data
        .map((e) => Team.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  void _save() {
    _box.put('teams_list', state.map((t) => t.toJson()).toList());
  }

  void createTeam(String name) {
    final team = Team(name: name);
    state = [...state, team];
    _save();
  }

  void deleteTeam(String id) {
    state = state.where((t) => t.id != id).toList();
    _save();
  }

  void renameTeam(String id, String newName) {
    state = [
      for (final t in state)
        if (t.id == id)
          Team(id: t.id, name: newName, pokemonIds: t.pokemonIds)
        else
          t,
    ];
    _save();
  }

  void addPokemon(String teamId, int pokemonId) {
    state = [
      for (final t in state)
        if (t.id == teamId &&
            t.pokemonIds.length < 6 &&
            !t.pokemonIds.contains(pokemonId))
          Team(id: t.id, name: t.name, pokemonIds: [...t.pokemonIds, pokemonId])
        else
          t,
    ];
    _save();
  }

  void removePokemon(String teamId, int pokemonId) {
    state = [
      for (final t in state)
        if (t.id == teamId)
          Team(
            id: t.id,
            name: t.name,
            pokemonIds: t.pokemonIds.where((id) => id != pokemonId).toList(),
          )
        else
          t,
    ];
    _save();
  }

  // Equipo aleatorio
  Future<void> createRandomTeam(String name, PokeApiService api) async {
    final randomIds = <int>{};
    while (randomIds.length < 6) {
      randomIds.add(
        (1 + (DateTime.now().millisecondsSinceEpoch % 1025)).toInt(),
      );
      await Future.delayed(
        const Duration(milliseconds: 1),
      ); // para variar el seed
    }

    final team = Team(name: name, pokemonIds: randomIds.toList());
    state = [...state, team];
    _save();
  }
}
