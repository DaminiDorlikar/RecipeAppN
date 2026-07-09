part of 'recipe_bloc.dart';

enum RecipeStatus { initial, loading, success, error }

class RecipeState extends Equatable {
  const RecipeState({
    this.status = RecipeStatus.initial,
    this.recipes = const [],
    this.query = '',
    this.sortByRating = true,
    this.fromCache = false,
    this.errorMessage = '',
  });

  final RecipeStatus status;
  final List<Recipe> recipes;
  final String query;
  final bool sortByRating;
  final bool fromCache;
  final String errorMessage;

  RecipeState copyWith({
    RecipeStatus? status,
    List<Recipe>? recipes,
    String? query,
    bool? sortByRating,
    bool? fromCache,
    String? errorMessage,
  }) {
    return RecipeState(
      status: status ?? this.status,
      recipes: recipes ?? this.recipes,
      query: query ?? this.query,
      sortByRating: sortByRating ?? this.sortByRating,
      fromCache: fromCache ?? this.fromCache,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    recipes,
    query,
    sortByRating,
    fromCache,
    errorMessage,
  ];
}
