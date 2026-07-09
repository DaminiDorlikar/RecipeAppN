import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../bloc/recipe_detail_cubit.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecipeDetailCubit(locator.recipeRepository)..load(id),
      child: Scaffold(
        appBar: AppBar(title: const Text('Recipe Detail')),
        body: BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
          builder: (context, state) {
            if (state is RecipeDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is RecipeDetailError) {
              return Center(child: Text(state.message));
            }
            final success = state as RecipeDetailSuccess;
            final recipe = success.recipe;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      recipe.image,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    recipe.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text('Cuisine: ${recipe.cuisine}'),
                  Text('Rating: ${recipe.rating.toStringAsFixed(1)}'),
                  Text('Cook time: ${recipe.cookTimeMinutes} minutes'),
                  const SizedBox(height: 16),
                  Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...recipe.ingredients.map((e) => Text('• $e')),
                  const SizedBox(height: 16),
                  Text(
                    'Instructions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...recipe.instructions.asMap().entries.map(
                    (e) => Text('${e.key + 1}. ${e.value}'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
