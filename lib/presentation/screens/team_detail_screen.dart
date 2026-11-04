import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/colors.dart';
import '../../providers/team_providers.dart';
import 'pokemon_detail_screen.dart';

class TeamDetailScreen extends ConsumerWidget {
  final String teamId;
  const TeamDetailScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(teamsProvider);
    final team = teams.firstWhere((t) => t.id == teamId);

    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
        backgroundColor: AppColors.pokeRed,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Integrantes (${team.pokemonIds.length}/6)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  if (index < team.pokemonIds.length) {
                    final id = team.pokemonIds[index];
                    return _PokemonSlot(
                      id: id,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PokemonDetailScreen(id: id),
                          ),
                        );
                      },
                      onRemove: () {
                        ref
                            .read(teamsProvider.notifier)
                            .removePokemon(teamId, id);
                      },
                    );
                  } else {
                    return _EmptySlot(
                      onTap: () {
                        // Aquí podrías abrir un selector de Pokémon
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Ve a la Pokédex y agrega desde el detalle',
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PokemonSlot extends StatelessWidget {
  final int id;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PokemonSlot({
    required this.id,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onRemove,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.pokeRed, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: ApiConstants.spriteUrl(id),
              height: 70,
              placeholder: (_, _) =>
                  const CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(height: 4),
            Text('#$id', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text(
              'Mantén para quitar',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptySlot({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[400]!,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text('Vacío', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
