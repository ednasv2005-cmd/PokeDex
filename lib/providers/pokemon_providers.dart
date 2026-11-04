import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/models/pokemon.dart';
import '../data/models/pokemon_detail.dart';
import '../data/services/poke_api_service.dart';

final pokeApiServiceProvider = Provider<PokeApiService>((ref) {
  return PokeApiService();
});

final pokemonDetailProvider = FutureProvider.family<PokemonDetail, int>((
  ref,
  id,
) {
  return ref.watch(pokeApiServiceProvider).fetchPokemonDetail(id);
});

class PokemonListState {
  final List<Pokemon> pokemons;
  final bool isLoading;
  final bool hasMore;
  final Object? error;

  const PokemonListState({
    this.pokemons = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  PokemonListState copyWith({
    List<Pokemon>? pokemons,
    bool? isLoading,
    bool? hasMore,
    Object? error,
  }) {
    return PokemonListState(
      pokemons: pokemons ?? this.pokemons,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class PokemonListNotifier extends StateNotifier<PokemonListState> {
  final PokeApiService _api;

  PokemonListNotifier(this._api) : super(const PokemonListState()) {
    loadMore();
  }

  Future<void> refresh() async {
    await loadMore(reset: true);
  }

  Future<void> loadMore({bool reset = false}) async {
    if (state.isLoading || (!state.hasMore && !reset)) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final offset = reset ? 0 : state.pokemons.length;
      final list = await _api.fetchPokemonList(limit: 20, offset: offset);
      if (list.isEmpty) {
        state = state.copyWith(isLoading: false, hasMore: false);
        return;
      }

      final urls = list
          .map((item) => 'https://pokeapi.co/api/v2/pokemon/${item['name']}')
          .toList();
      final pokemons = await _api.fetchPokemonDetailsBatch(urls);
      final combined = reset ? pokemons : [...state.pokemons, ...pokemons];

      state = state.copyWith(
        pokemons: combined,
        isLoading: false,
        hasMore: list.length == 20,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error);
    }
  }
}

final pokemonListProvider =
    StateNotifierProvider<PokemonListNotifier, PokemonListState>((ref) {
      return PokemonListNotifier(ref.watch(pokeApiServiceProvider));
    });

// ---------- FAVORITOS CON PERSISTENCIA ----------
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<int>>((
  ref,
) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<Set<int>> {
  late Box _box;

  FavoritesNotifier() : super({}) {
    _box = Hive.box('favorites');
    final saved = _box.get('ids', defaultValue: <int>[]);
    state = Set<int>.from(saved);
  }

  void toggle(int id) {
    final newSet = {...state};
    if (newSet.contains(id)) {
      newSet.remove(id);
    } else {
      newSet.add(id);
    }
    state = newSet;
    _box.put('ids', newSet.toList());
  }

  bool isFavorite(int id) => state.contains(id);
}
