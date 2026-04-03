import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nodejs_auth/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:nodejs_auth/providers/user_provider.dart';
import 'package:nodejs_auth/screens/home_screen.dart';
import 'package:nodejs_auth/screens/login_screen.dart';
import 'package:nodejs_auth/utils/constants.dart';
import 'package:nodejs_auth/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle authentication (signup, login, logout, token validation)
class AuthService {
  /// ========================================
  /// Sign up a new user
  /// ========================================
  Future<void> signup(
      BuildContext context, {
        required String name,
        required String email,
        required String password,
      }) async {
    try {
      // Create user object
      User user = User(
        id: '',
        name: name,
        email: email,
        token: '',
        password: password,
      );

      // Send POST request to backend
      http.Response response = await http.post(
        Uri.parse('${Constants.uri}/api/signup'),
        body: user.toJson(),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      // Handle response
      httpErrorHandle(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(
            context,
            "Account created! Login with the same credentials",
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  /// ========================================
  /// Login user
  /// ========================================
  Future<void> login(
      BuildContext context, {
        required String email,
        required String password,
      }) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      final navigator = Navigator.of(context);

      // Send login request
      http.Response response = await http.post(
        Uri.parse('${Constants.uri}/api/login'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      httpErrorHandle(
        response: response,
        context: context,
        onSuccess: () async {
          // Store user and token locally
          SharedPreferences preferences = await SharedPreferences.getInstance();
          userProvider.userFromString(response.body);

          await preferences.setString(
            'x-auth-token',
            jsonDecode(response.body)['token'],
          );

          // Navigate to HomeScreen and remove all previous routes
          await navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
          );

          showSnackBar(context, "Login successful!");
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  /// ========================================
  /// Sign out user
  /// ========================================
  Future<void> signOut(BuildContext context) async {
    try {
      final navigator = Navigator.of(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();

      // Clear token
      await preferences.setString('x-auth-token', '');

      // Navigate to LoginScreen
      await navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  /// ========================================
  /// Get user data if token is valid
  /// ========================================
  Future<void> getUserData(BuildContext context) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      SharedPreferences preferences = await SharedPreferences.getInstance();

      // Get token from SharedPreferences
      String? token = preferences.getString('x-auth-token');
      if (token == null) {
        await preferences.setString('x-auth-token', '');
        token = '';
      }

      // Validate token with backend
      http.Response tokenRes = await http.post(
        Uri.parse('${Constants.uri}/api/isTokenValid'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      bool isValid = jsonDecode(tokenRes.body);
      if (isValid) {
        // Fetch user details from backend
        http.Response userRes = await http.get(
          Uri.parse('${Constants.uri}/api/'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
        );

        userProvider.userFromString(userRes.body);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
