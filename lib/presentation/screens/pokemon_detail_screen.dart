import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../providers/pokemon_providers.dart';
import '../../providers/team_providers.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/type_colors.dart';
import '../widgets/stat_bar.dart';
import '../widgets/type_chip.dart';

class PokemonDetailScreen extends ConsumerStatefulWidget {
  final int id;
  const PokemonDetailScreen({super.key, required this.id});

  @override
  ConsumerState<PokemonDetailScreen> createState() =>
      _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends ConsumerState<PokemonDetailScreen> {
  bool isShiny = false;
  final AudioPlayer _player = AudioPlayer();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playCry(String url) async {
    if (url.isEmpty) return;
    await _player.play(UrlSource(url));
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(pokemonDetailProvider(widget.id));
    final favorites = ref.watch(favoritesProvider);

    return detailAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (pokemon) {
        final primaryType = pokemon.types.first;
        final color = TypeColors.get(primaryType);
        final imageUrl = isShiny
            ? ApiConstants.shinyArtworkUrl(pokemon.id)
            : ApiConstants.artworkUrl(pokemon.id);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: color,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withValues(alpha: 0.6)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Hero(
                        tag: 'pokemon-${pokemon.id}',
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      favorites.contains(pokemon.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      ref.read(favoritesProvider.notifier).toggle(pokemon.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.auto_awesome, color: Colors.white),
                    tooltip: 'Shiny',
                    onPressed: () => setState(() => isShiny = !isShiny),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre y número
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pokemon.name[0].toUpperCase() +
                                pokemon.name.substring(1),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '#${pokemon.id.toString().padLeft(3, '0')}',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Tipos
                      Wrap(
                        spacing: 8,
                        children: pokemon.types
                            .map((t) => TypeChip(type: t))
                            .toList(),
                      ),
                      const SizedBox(height: 20),

                      // Botón de sonido
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _playCry(pokemon.cryUrl),
                        icon: const Icon(Icons.volume_up),
                        label: const Text('Reproducir grito'),
                      ),

                      const SizedBox(height: 24),
                      // Descripción
                      if (pokemon.description != null) ...[
                        const Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(pokemon.description!),
                        const SizedBox(height: 24),
                      ],

                      // Stats
                      const Text(
                        'Estadísticas base',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...pokemon.stats.entries.map((e) {
                        return StatBar(
                          label: e.key,
                          value: e.value,
                          color: color,
                        );
                      }),

                      const SizedBox(height: 24),
                      // Altura y peso
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              title: 'Altura',
                              value: '${pokemon.height / 10} m',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              title: 'Peso',
                              value: '${pokemon.weight / 10} kg',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      // Habilidades
                      const Text(
                        'Habilidades',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: pokemon.abilities
                            .map((a) => Chip(label: Text(a)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: color,
            onPressed: () {
              final teams = ref.read(teamsProvider);
              if (teams.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Primero crea un equipo')),
                );
                return;
              }
              showModalBottomSheet(
                context: context,
                builder: (ctx) {
                  return ListView(
                    children: teams.map((team) {
                      return ListTile(
                        title: Text(team.name),
                        subtitle: Text('${team.pokemonIds.length}/6'),
                        onTap: () {
                          ref
                              .read(teamsProvider.notifier)
                              .addPokemon(team.id, pokemon.id);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Agregado a ${team.name}')),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              );
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Agregar a equipo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
