enum AuthStateEnum {
  authenticated,
  unauthenticated,
}

class AuthState {
  final AuthStateEnum authState;

  const AuthState({required this.authState});

  factory AuthState.init() {
    return AuthState(
      authState: AuthStateEnum.unauthenticated,
    );
  }

  AuthState copyWith({
    AuthStateEnum? authState,
  }) {
    return AuthState(
      authState: authState ?? this.authState,
    );
  }
}
