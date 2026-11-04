import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/type_colors.dart';
import '../../data/models/pokemon.dart';
import '../../providers/pokemon_providers.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  String? _selectedType;
  String? _selectedGeneration;
  List<Pokemon> _results = [];
  bool _isLoading = false;
  List<String> _types = [];
  List<Map<String, dynamic>> _generations = [];

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    final api = ref.read(pokeApiServiceProvider);
    final types = await api.fetchTypes();
    final gens = await api.fetchGenerations();
    setState(() {
      _types = types;
      _generations = gens;
    });
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      setState(() => _query = value.trim().toLowerCase());
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    if (_query.isEmpty &&
        _selectedType == null &&
        _selectedGeneration == null) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ref.read(pokeApiServiceProvider);

      // Búsqueda simple por nombre o número (usamos el listado base)
      // Para producción real se recomienda tener el listado completo cacheado
      final list = await api.fetchPokemonList(
        limit: 100,
        offset: 0,
      ); // ejemplo limitado

      List<Pokemon> filtered = [];

      for (var item in list) {
        final name = item['name'] as String;
        final url = item['url'] as String;
        final id = int.parse(url.split('/')[6]);

        bool matchQuery =
            _query.isEmpty || name.contains(_query) || id.toString() == _query;

        if (!matchQuery) continue;

        // Aquí podrías filtrar también por tipo/generación si tienes más datos
        filtered.add(Pokemon.basic(id: id, name: name));
      }

      // Si hay tipo seleccionado, pedimos detalles (limitado para no saturar)
      if (_selectedType != null && filtered.isNotEmpty) {
        final urls = filtered
            .take(30)
            .map((p) => 'https://pokeapi.co/api/v2/pokemon/${p.id}')
            .toList();
        final detailed = await api.fetchPokemonDetailsBatch(urls);
        filtered = detailed
            .where((p) => p.types.contains(_selectedType))
            .toList();
      }

      setState(() {
        _results = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar & Filtros')),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Nombre o número...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
              ),
            ),
          ),

          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // Tipos
                ..._types.map((type) {
                  final selected = _selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type.toUpperCase()),
                      selected: selected,
                      selectedColor: TypeColors.get(type),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) {
                        setState(() {
                          _selectedType = val ? type : null;
                        });
                        _performSearch();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Generaciones (dropdown simple)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedGeneration,
              decoration: InputDecoration(
                labelText: 'Generación',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todas')),
                ..._generations.map(
                  (g) => DropdownMenuItem(
                    value: g['name'],
                    child: Text(g['name']),
                  ),
                ),
              ],
              onChanged: (val) {
                setState(() => _selectedGeneration = val);
                _performSearch();
              },
            ),
          ),

          const SizedBox(height: 12),

          // Resultados
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? const Center(
                    child: Text('Escribe para buscar o aplica filtros'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final pokemon = _results[index];
                      return PokemonCard(
                        pokemon: pokemon,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PokemonDetailScreen(id: pokemon.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
