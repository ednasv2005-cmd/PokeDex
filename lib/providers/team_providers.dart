import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'dart:math';

import '../data/models/team.dart';
import '../data/services/poke_api_service.dart';

enum AddPokemonResult { added, alreadyAdded, teamFull, teamNotFound }

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
    if (data is! List) {
      state = [];
      return;
    }
    state = data
        .whereType<Map>()
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

  AddPokemonResult addPokemon(String teamId, int pokemonId) {
    final matches = state.where((team) => team.id == teamId);
    if (matches.isEmpty) return AddPokemonResult.teamNotFound;
    final team = matches.first;
    if (team.pokemonIds.length >= 6) return AddPokemonResult.teamFull;
    if (team.pokemonIds.contains(pokemonId)) {
      return AddPokemonResult.alreadyAdded;
    }

    state = [
      for (final t in state)
        if (t.id == teamId)
          Team(id: t.id, name: t.name, pokemonIds: [...t.pokemonIds, pokemonId])
        else
          t,
    ];
    _save();
    return AddPokemonResult.added;
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
    final random = Random.secure();
    while (randomIds.length < 6) {
      randomIds.add(random.nextInt(1025) + 1);
    }

    final team = Team(name: name, pokemonIds: randomIds.toList());
    state = [...state, team];
    _save();
  }
}
