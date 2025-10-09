import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  final String id;
  final String name;

  const User({required this.id, required this.name});
}

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);

  void setUser(User user) {
    state = user;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});
