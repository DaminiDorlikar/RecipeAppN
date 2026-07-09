import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/recipe_repository.dart';
import '../../domain/recipe.dart';

sealed class RecipeDetailState {
  const RecipeDetailState();
}

class RecipeDetailLoading extends RecipeDetailState {
  const RecipeDetailLoading();
}

class RecipeDetailSuccess extends RecipeDetailState {
  const RecipeDetailSuccess(this.recipe);
  final Recipe recipe;
}

class RecipeDetailError extends RecipeDetailState {
  const RecipeDetailError(this.message);
  final String message;
}

class RecipeDetailCubit extends Cubit<RecipeDetailState> {
  RecipeDetailCubit(this._repository) : super(const RecipeDetailLoading());

  final RecipeRepository _repository;

  Future<void> load(int id) async {
    final cached = await _repository.getCachedRecipeDetail(id);
    if (cached != null) {
      emit(RecipeDetailSuccess(cached));
    } else {
      emit(const RecipeDetailLoading());
    }
    try {
      final fresh = await _repository.getRecipeDetail(id);
      emit(RecipeDetailSuccess(fresh));
    } catch (e) {
      if (cached == null) {
        emit(RecipeDetailError('$e'));
      }
    }
  }
}
