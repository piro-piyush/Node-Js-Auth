import 'package:flutter/material.dart';
import 'package:nodejs_auth/providers/user_provider.dart';
import 'package:nodejs_auth/screens/home_screen.dart';
import 'package:nodejs_auth/screens/login_screen.dart';
import 'package:nodejs_auth/services/auth_service.dart';
import 'package:provider/provider.dart';

/// Entry point of the application
void main() {
  runApp(
    MultiProvider(
      providers: [
        /// Register UserProvider to manage user state across app
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Root widget of the application
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Service to handle authentication & user data
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    /// Fetch user data after first frame is rendered
    /// This ensures ScaffoldMessenger is available for SnackBars
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authService.getUserData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Access the current user from UserProvider
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return MaterialApp(
      title: 'Flutter Demo',

      /// App theme using Material 3 color scheme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      /// Show LoginScreen if user is not logged in (token empty)
      /// Otherwise show HomeScreen
      home: user.token.isEmpty ? const LoginScreen() : const HomeScreen(),
    );
  }
}
