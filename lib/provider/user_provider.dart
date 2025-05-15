import 'package:bloom/modals/user_modal.dart';
import 'package:bloom/repo/user_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileRepositoryProvider =
    Provider((ref) => UserProfileRepository());

class UserProfileNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final UserProfileRepository _repo;

  UserProfileNotifier(this._repo) : super(const AsyncValue.loading()) {
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      final user = await _repo.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateUser(UserModel updatedUser) async {
    try {
      await _repo.updateUser(updatedUser);
      state = AsyncValue.data(updatedUser); // update local state
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserModel?>>(
        (ref) => UserProfileNotifier(ref.watch(userProfileRepositoryProvider)));
