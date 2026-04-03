import 'package:flutter/material.dart';
import 'package:nodejs_auth/providers/user_provider.dart';
import 'package:nodejs_auth/services/auth_service.dart';
import 'package:provider/provider.dart';

/// HomeScreen displays the logged-in user's details and allows logout
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Signs out the current user using AuthService
  void _signOut(BuildContext context) {
    AuthService().signOut(context);
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user from UserProvider
    final user = context.watch<UserProvider>().user;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          // Logout icon button in AppBar
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User avatar placeholder
                  const CircleAvatar(
                    radius: 35,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 16),

                  // User name
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // User email
                  Text(
                    user.email,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // Sign Out button
                  SizedBox(
                    width: size.width,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _signOut(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
