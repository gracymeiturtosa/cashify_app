import 'package:crypto/crypto.dart'; // Add to pubspec.yaml: crypto: ^3.0.3
import 'dart:convert';

class User {
  final int id;
  final String username;
  final String password; // Note: Should be hashed in production

  User({required this.id, required this.username, required this.password});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int? ?? 0,
      username: map['username'] as String? ?? '',
      password: map['password'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'username': username, 'password': password};
  }

  // Utility to hash password (optional implementation)
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  User copyWith({int? id, String? username, String? password}) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, password: [hidden])';
  }
}
