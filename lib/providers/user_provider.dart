import 'package:flutter/cupertino.dart';
import 'package:nodejs_auth/models/user.dart';

/// UserProvider manages the current logged-in user's state across the app
class UserProvider extends ChangeNotifier {
  /// Private user object
  User _user = User.dummy();

  /// Public getter for the current user
  User get user => _user;

  /// Update user from a JSON string
  ///
  /// Example:
  /// ```dart
  /// userProvider.userFromString(jsonString);
  /// ```
  void userFromString(String userJson) {
    _user = User.fromJson(userJson);
    notifyListeners(); // notify all listeners about change
  }

  /// Update user from a User model directly
  ///
  /// Example:
  /// ```dart
  /// userProvider.userFromModel(userModel);
  /// ```
  void userFromModel(User user) {
    _user = user;
    notifyListeners(); // notify all listeners about change
  }
}
