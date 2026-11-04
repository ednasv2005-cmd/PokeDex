import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/colors.dart';
import '../../providers/team_providers.dart';
import '../../providers/pokemon_providers.dart';
import 'team_detail_screen.dart';

class TeamsScreen extends ConsumerWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(teamsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Equipos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.casino),
            tooltip: 'Equipo aleatorio',
            onPressed: () async {
              final nameController = TextEditingController(
                text: 'Equipo Random',
              );
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Equipo Aleatorio'),
                  content: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del equipo',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Generar'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                final api = ref.read(pokeApiServiceProvider);
                await ref
                    .read(teamsProvider.notifier)
                    .createRandomTeam(nameController.text, api);
              }
            },
          ),
        ],
      ),
      body: teams.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.groups, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aún no tienes equipos', style: TextStyle(fontSize: 18)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.pokeRed,
                      child: Text(
                        '${team.pokemonIds.length}/6',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      team.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${team.pokemonIds.length} Pokémon'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final controller = TextEditingController(
                              text: team.name,
                            );
                            final newName = await showDialog<String>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Renombrar equipo'),
                                content: TextField(controller: controller),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, controller.text),
                                    child: const Text('Guardar'),
                                  ),
                                ],
                              ),
                            );
                            if (newName != null && newName.isNotEmpty) {
                              ref
                                  .read(teamsProvider.notifier)
                                  .renameTeam(team.id, newName);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Eliminar equipo'),
                                content: Text(
                                  '¿Eliminar "${team.name}" y sus Pokémon?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              ref
                                  .read(teamsProvider.notifier)
                                  .deleteTeam(team.id);
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeamDetailScreen(teamId: team.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.pokeRed,
        onPressed: () async {
          final controller = TextEditingController();
          final name = await showDialog<String>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Nuevo equipo'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Nombre del equipo',
                ),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, controller.text),
                  child: const Text('Crear'),
                ),
              ],
            ),
          );

          if (name != null && name.trim().isNotEmpty) {
            ref.read(teamsProvider.notifier).createTeam(name.trim());
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Crear equipo',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
