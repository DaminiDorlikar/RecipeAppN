part of 'recipe_bloc.dart';

sealed class RecipeEvent extends Equatable {
  const RecipeEvent();

  @override
  List<Object?> get props => [];
}

class RecipesLoaded extends RecipeEvent {
  const RecipesLoaded();
}

class RecipesRefreshed extends RecipeEvent {
  const RecipesRefreshed();
}

class RecipesQueryChanged extends RecipeEvent {
  const RecipesQueryChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class RecipesSortChanged extends RecipeEvent {
  const RecipesSortChanged(this.sortByRating);
  final bool sortByRating;

  @override
  List<Object?> get props => [sortByRating];
}
