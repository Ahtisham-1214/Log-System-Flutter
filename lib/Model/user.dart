// lib/user.dart
class UserDTO {
  late String id; // Nullable for when it's not yet in the DB (auto-incremented)
  late String _userName;
  late String _email;
  late String _role;

  UserDTO({
    required this.id,
    required String userName,
    required String email,
    required String role,
  }) : _userName = userName,
        _email = email,
        _role = role;


  String get role => _role;

  set role(String value) {
    if (value.trim().isEmpty) {
      _role = "Driver"; // Basic validation for object creation
    }else {
      _role = value;
    }
  }

  String get email => _email;
  set email(String email) {
    if (email.trim().isEmpty) {
      throw Exception('email cannot be empty'); // Basic validation for object creation
    }
    _email = email;
  }

  String get userName => _userName;
  set userName(String userName) {
    if (userName.trim().isEmpty) {
      throw Exception('Username cannot be empty'); // Basic validation for object creation
    }
    _userName = userName;
  }

  // Convert a User object into a Map for database insertion/update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': _userName,
      'email': _email,
      'role': _role,
    };
  }

  // Create a User object from a Map (read from database)
  factory UserDTO.fromMap(Map<String, dynamic> map) {
    return UserDTO(
      id: map['id'],
      userName: map['username'],
      email: map['email'],
      role: map['role'],
    );
  }

  // For debugging
  @override
  String toString() {
    return 'User(id: $id, username: $_userName, email: $_email, role: $role)';
  }
}