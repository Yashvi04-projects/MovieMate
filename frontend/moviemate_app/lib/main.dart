import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/providers.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MovieMateApp());
}

class MovieMateApp extends StatelessWidget {
  const MovieMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProxyProvider<AuthProvider, MovieProvider>(
          create: (ctx) => MovieProvider(ctx.read<AuthProvider>().apiService),
          update: (_, auth, previous) =>
              previous ?? MovieProvider(auth.apiService),
        ),
        ChangeNotifierProxyProvider<AuthProvider, BookingProvider>(
          create: (ctx) => BookingProvider(ctx.read<AuthProvider>().apiService),
          update: (_, auth, previous) =>
              previous ?? BookingProvider(auth.apiService),
        ),
      ],
      child: MaterialApp(
        title: 'MovieMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/home': (_) => const MainShell(),
        },
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          );
        },
      ),
    );
  }
}
