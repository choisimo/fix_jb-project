
import 'package:dart_frog/dart_frog.dart';
import 'package:flutter_backend/src/user_repository.dart';

final _userRepository = UserRepository();

Handler middleware(Handler handler) {
  return handler.use(provider<UserRepository>((_) => _userRepository));
}
