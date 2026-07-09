import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/recipe_bloc.dart';
import 'recipe_detail_screen.dart';

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RecipeBloc(repository: locator.recipeRepository)
            ..add(const RecipesLoaded()),
      child: const _RecipeListView(),
    );
  }
}

class _RecipeListView extends StatelessWidget {
  const _RecipeListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<RecipeBloc>().add(const RecipesRefreshed());
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search by name or cuisine',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => context.read<RecipeBloc>().add(
                        RecipesQueryChanged(value),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilterChip(
                    label: const Text('Top Rated'),
                    selected: context.select(
                      (RecipeBloc bloc) => bloc.state.sortByRating,
                    ),
                    onSelected: (value) => context.read<RecipeBloc>().add(
                      RecipesSortChanged(value),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<RecipeBloc, RecipeState>(
                builder: (context, state) {
                  if (state.status == RecipeStatus.loading &&
                      state.recipes.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == RecipeStatus.error) {
                    return Center(
                      child: Text(
                        state.errorMessage.isEmpty
                            ? 'Could not load recipes.'
                            : state.errorMessage,
                      ),
                    );
                  }
                  if (state.recipes.isEmpty) {
                    return const Center(child: Text('No recipes found.'));
                  }
                  return Column(
                    children: [
                      if (state.fromCache)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text(
                            'Showing offline cache. Updating in background...',
                          ),
                        ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: .75,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: state.recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = state.recipes[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RecipeDetailScreen(id: recipe.id),
                                  ),
                                );
                              },
                              child: Card(
                                clipBehavior: Clip.hardEdge,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Image.network(
                                        recipe.image,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.image_not_supported,
                                            ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        recipe.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        '⭐ ${recipe.rating.toStringAsFixed(1)} · ${recipe.cuisine}',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
