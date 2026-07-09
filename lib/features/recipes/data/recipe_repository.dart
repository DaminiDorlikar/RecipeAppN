import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/recipe.dart';

class RecipeRepository {
  RecipeRepository({required ApiClient apiClient, required Box box})
    : _dio = apiClient.dio,
      _box = box;

  final Dio _dio;
  final Box _box;

  static const _recipesKey = 'recipes_list';
  static const _recipeDetailsPrefix = 'recipe_detail_';

  Future<List<Recipe>> getCachedRecipes() async {
    final raw = _box.get(_recipesKey) as List?;
    if (raw == null) return [];
    return raw
        .cast<Map>()
        .map((e) => _fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Recipe>> getRecipesRemote() async {
    try {
      final response = await _dio.get(ApiConstants.recipes);
      final recipes = (response.data['recipes'] as List? ?? [])
          .map((e) => _fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      await _box.put(_recipesKey, recipes.map(_toMap).toList());
      return recipes;
    } on DioException catch (_) {
      throw const AppException('Could not load recipes. Please try again.');
    }
  }

  Future<Recipe> getRecipeDetail(int id) async {
    final cacheKey = '$_recipeDetailsPrefix$id';
    try {
      final response = await _dio.get('${ApiConstants.recipes}/$id');
      final recipe = _fromMap(Map<String, dynamic>.from(response.data as Map));
      await _box.put(cacheKey, _toMap(recipe));
      return recipe;
    } on DioException catch (_) {
      final cached = _box.get(cacheKey) as Map?;
      if (cached != null) {
        return _fromMap(Map<String, dynamic>.from(cached));
      }
      throw const AppException('Recipe details unavailable right now.');
    }
  }

  Future<Recipe?> getCachedRecipeDetail(int id) async {
    final cached = _box.get('$_recipeDetailsPrefix$id') as Map?;
    if (cached == null) return null;
    return _fromMap(Map<String, dynamic>.from(cached));
  }

  Recipe _fromMap(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      cuisine: json['cuisine'] as String? ?? 'Unknown',
      ingredients:
          (json['ingredients'] as List?)?.map((e) => '$e').toList() ?? const [],
      instructions:
          (json['instructions'] as List?)?.map((e) => '$e').toList() ??
          const [],
      cookTimeMinutes: json['cookTimeMinutes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> _toMap(Recipe recipe) {
    return {
      'id': recipe.id,
      'name': recipe.name,
      'image': recipe.image,
      'rating': recipe.rating,
      'cuisine': recipe.cuisine,
      'ingredients': recipe.ingredients,
      'instructions': recipe.instructions,
      'cookTimeMinutes': recipe.cookTimeMinutes,
    };
  }
}
