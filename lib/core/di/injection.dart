import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/recipes/data/recipe_repository.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

late final Locator locator;

class Locator {
  Locator({required this.authRepository, required this.recipeRepository});

  final AuthRepository authRepository;
  final RecipeRepository recipeRepository;
}

Future<void> configureDependencies() async {
  final secureStorage = FlutterSecureStorage(
    aOptions: const AndroidOptions(encryptedSharedPreferences: true),
  );
  final tokenStorage = TokenStorage(secureStorage);
  final logger = Logger();
  final box = await Hive.openBox('recipe_cache');
  final apiClient = ApiClient(
    tokenStorage: tokenStorage,
    logger: logger,
    onForceLogout: () async => tokenStorage.clear(),
  );
  final authRepository = AuthRepository(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );
  final recipeRepository = RecipeRepository(apiClient: apiClient, box: box);
  locator = Locator(
    authRepository: authRepository,
    recipeRepository: recipeRepository,
  );
}
