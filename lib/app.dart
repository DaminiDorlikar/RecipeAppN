import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/recipes/presentation/screens/recipe_list_screen.dart';
import 'features/splash/splash_screen.dart';

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: locator.authRepository),
        RepositoryProvider.value(value: locator.recipeRepository),
      ],
      child: BlocProvider(
        create: (_) => AuthBloc(authRepository: locator.authRepository),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Recipe App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          routes: {
            '/login': (_) => const LoginScreen(),
            '/recipes': (_) => const RecipeListScreen(),
          },
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
