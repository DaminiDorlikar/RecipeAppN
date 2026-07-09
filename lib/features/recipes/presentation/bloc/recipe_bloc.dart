import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/recipe_repository.dart';
import '../../domain/recipe.dart';

part 'recipe_event.dart';
part 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  RecipeBloc({required RecipeRepository repository})
    : _repository = repository,
      super(const RecipeState()) {
    on<RecipesLoaded>(_onRecipesLoaded);
    on<RecipesRefreshed>(_onRecipesRefreshed);
    on<RecipesQueryChanged>(_onQueryChanged);
    on<RecipesSortChanged>(_onSortChanged);
  }

  final RecipeRepository _repository;
  List<Recipe> _source = [];

  Future<void> _onRecipesLoaded(
    RecipesLoaded event,
    Emitter<RecipeState> emit,
  ) async {
    emit(state.copyWith(status: RecipeStatus.loading));
    final cached = await _repository.getCachedRecipes();
    if (cached.isNotEmpty) {
      _source = cached;
      emit(
        state.copyWith(
          status: RecipeStatus.success,
          recipes: _applyFilters(cached, state.query, state.sortByRating),
          fromCache: true,
        ),
      );
    }
    try {
      final fresh = await _repository.getRecipesRemote();
      _source = fresh;
      emit(
        state.copyWith(
          status: RecipeStatus.success,
          recipes: _applyFilters(fresh, state.query, state.sortByRating),
          fromCache: false,
        ),
      );
    } catch (e) {
      if (cached.isEmpty) {
        emit(state.copyWith(status: RecipeStatus.error, errorMessage: '$e'));
      }
    }
  }

  Future<void> _onRecipesRefreshed(
    RecipesRefreshed event,
    Emitter<RecipeState> emit,
  ) async {
    try {
      final fresh = await _repository.getRecipesRemote();
      _source = fresh;
      emit(
        state.copyWith(
          status: RecipeStatus.success,
          recipes: _applyFilters(fresh, state.query, state.sortByRating),
          fromCache: false,
        ),
      );
    } catch (_) {}
  }

  void _onQueryChanged(RecipesQueryChanged event, Emitter<RecipeState> emit) {
    emit(
      state.copyWith(
        recipes: _applyFilters(_source, event.query, state.sortByRating),
        query: event.query,
        status: RecipeStatus.success,
      ),
    );
  }

  void _onSortChanged(RecipesSortChanged event, Emitter<RecipeState> emit) {
    emit(
      state.copyWith(
        sortByRating: event.sortByRating,
        recipes: _applyFilters(_source, state.query, event.sortByRating),
        status: RecipeStatus.success,
      ),
    );
  }

  List<Recipe> _applyFilters(
    List<Recipe> recipes,
    String query,
    bool byRating,
  ) {
    var filtered = recipes
        .where(
          (r) =>
              r.name.toLowerCase().contains(query.toLowerCase()) ||
              r.cuisine.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    if (byRating) {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return filtered;
  }
}
