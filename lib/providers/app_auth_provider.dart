import 'dart:typed_data';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:instagram_clone/exception/custom_exception.dart';
import 'package:instagram_clone/providers/auth_state.dart';
import 'package:instagram_clone/repositories/auth_repository.dart';

class AppAuthProvider extends StateNotifier<AuthState> with LocatorMixin {
  AppAuthProvider() : super(AuthState.init());

  // 로그인
  // Firebase 로그인 작업
  Future<void> signUp({
    required String email,
    required String name,
    required String password,
    required Uint8List? profileImage,
  }) async {
    try {
      await read<AuthRepository>().signUp(
        email: email,
        name: name,
        password: password,
        profileImage: profileImage,
      );
    } on CustomException catch (_) {
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  })async{
    try{
      await read<AuthRepository>().signIn(email: email, password: password);

      state = state.copyWith(
        authStatus: AuthStatus.authenticated);
    }on CustomException catch (_) {
      rethrow;
    }
  }
}
