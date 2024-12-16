import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:instagram_clone/exception/custom_exception.dart';
import 'package:instagram_clone/providers/auth/auth_state.dart';
import 'package:instagram_clone/repositories/auth_repository.dart';
import 'package:provider/provider.dart';

class AuthProvider extends StateNotifier<AuthState> with LocatorMixin {
  AuthProvider() : super(AuthState.init());

  @override
  void update(Locator watch) {
    final user = watch<User?>();


    if(user != null && !user.emailVerified){
      return;
    }

    if(user == null && state.authStatus == AuthStatus.unauthenticated){
      return;
    }

    if (user != null) {
      state = state.copyWith(
        authStatus: AuthStatus.authenticated,
      );
    } else {
      state = state.copyWith(
        authStatus: AuthStatus.unauthenticated,
      );
    }
  }

  Future<void> signOut() async{
    await read<AuthProvider>().signOut();

  }

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


    }on CustomException catch (_) {
      rethrow;
    }
  }
}
