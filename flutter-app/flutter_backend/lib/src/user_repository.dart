
import 'package:bcrypt/bcrypt.dart';

class UserRepository {
  // In-memory user storage (replace with a real database in production)
  final Map<String, Map<String, dynamic>> _users = {};

  Future<void> createUser(String email, String password) async {
    final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
    _users[email] = {
      'email': email,
      'password': hashedPassword,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };
  }

  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    return _users[email];
  }

  Future<bool> verifyPassword(String email, String password) async {
    final user = await findUserByEmail(email);
    if (user == null) {
      return false;
    }
    return BCrypt.checkpw(password, user['password'] as String);
  }
}
