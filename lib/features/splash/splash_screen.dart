import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/presentation/bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/recipes');
          } else if (state is AuthUnauthenticated) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FlutterLogo(size: 96),
              SizedBox(height: 16),
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Preparing your recipes...'),
            ],
          ),
        ),
      ),
    );
  }
}
