import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user.dart';

final userManagementProvider = StateNotifierProvider<UserManagementNotifier, AsyncValue<List<User>>>((ref) {
  return UserManagementNotifier();
});

class UserManagementNotifier extends StateNotifier<AsyncValue<List<User>>> {
  UserManagementNotifier() : super(const AsyncValue.loading()) {
    loadUsers();
  }
  
  Future<void> loadUsers() async {
    try {
      state = const AsyncValue.loading();
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      state = AsyncValue.data(_generateUserData());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> updateUserStatus(String userId, String status) async {
    state.whenData((users) {
      final updatedUsers = users.map((user) {
        if (user.id == userId) {
          return user.copyWith(status: status);
        }
        return user;
      }).toList();
      state = AsyncValue.data(updatedUsers);
    });
  }
  
  Future<void> resetPassword(String userId) async {
    // Simulate password reset
    await Future.delayed(const Duration(seconds: 1));
  }
  
  Future<void> deleteUser(String userId) async {
    state.whenData((users) {
      final updatedUsers = users.where((user) => user.id != userId).toList();
      state = AsyncValue.data(updatedUsers);
    });
  }
  
  List<User> _generateUserData() {
    return [
      User(
        id: '1',
        name: '홍길동',
        email: 'hong@example.com',
        role: 'admin',
        status: 'active',
        lastActive: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      User(
        id: '2',
        name: '김철수',
        email: 'kim@example.com',
        role: 'manager',
        status: 'active',
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      User(
        id: '3',
        name: '이영희',
        email: 'lee@example.com',
        role: 'user',
        status: 'pending',
        lastActive: null,
      ),
      User(
        id: '4',
        name: '박민수',
        email: 'park@example.com',
        role: 'viewer',
        status: 'inactive',
        lastActive: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
}
