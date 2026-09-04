// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 이메일 회원가입. 결과로 [AuthResult] 를 반환한다.

@ProviderFor(signUpWithEmail)
final signUpWithEmailProvider = SignUpWithEmailFamily._();

/// 이메일 회원가입. 결과로 [AuthResult] 를 반환한다.

final class SignUpWithEmailProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuthResult>,
          AuthResult,
          FutureOr<AuthResult>
        >
    with $FutureModifier<AuthResult>, $FutureProvider<AuthResult> {
  /// 이메일 회원가입. 결과로 [AuthResult] 를 반환한다.
  SignUpWithEmailProvider._({
    required SignUpWithEmailFamily super.from,
    required SignUpWithEmailParams super.argument,
  }) : super(
         retry: null,
         name: r'signUpWithEmailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$signUpWithEmailHash();

  @override
  String toString() {
    return r'signUpWithEmailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AuthResult> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AuthResult> create(Ref ref) {
    final argument = this.argument as SignUpWithEmailParams;
    return signUpWithEmail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SignUpWithEmailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$signUpWithEmailHash() => r'847709a0f0955c785e3954d72a3d31aaee4f3320';

/// 이메일 회원가입. 결과로 [AuthResult] 를 반환한다.

final class SignUpWithEmailFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<AuthResult>, SignUpWithEmailParams> {
  SignUpWithEmailFamily._()
    : super(
        retry: null,
        name: r'signUpWithEmailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 이메일 회원가입. 결과로 [AuthResult] 를 반환한다.

  SignUpWithEmailProvider call(SignUpWithEmailParams params) =>
      SignUpWithEmailProvider._(argument: params, from: this);

  @override
  String toString() => r'signUpWithEmailProvider';
}

/// 유저 차단. 결과로 성공 여부(bool)를 반환한다.

@ProviderFor(blockUser)
final blockUserProvider = BlockUserFamily._();

/// 유저 차단. 결과로 성공 여부(bool)를 반환한다.

final class BlockUserProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// 유저 차단. 결과로 성공 여부(bool)를 반환한다.
  BlockUserProvider._({
    required BlockUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'blockUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$blockUserHash();

  @override
  String toString() {
    return r'blockUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return blockUser(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BlockUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$blockUserHash() => r'6f6d2ad0a53c36fd498fbe4475efbb7a60c0b977';

/// 유저 차단. 결과로 성공 여부(bool)를 반환한다.

final class BlockUserFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  BlockUserFamily._()
    : super(
        retry: null,
        name: r'blockUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 유저 차단. 결과로 성공 여부(bool)를 반환한다.

  BlockUserProvider call(String userUid) =>
      BlockUserProvider._(argument: userUid, from: this);

  @override
  String toString() => r'blockUserProvider';
}

/// 차단 해제. 결과로 성공 여부(bool)를 반환한다.

@ProviderFor(unblockUser)
final unblockUserProvider = UnblockUserFamily._();

/// 차단 해제. 결과로 성공 여부(bool)를 반환한다.

final class UnblockUserProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// 차단 해제. 결과로 성공 여부(bool)를 반환한다.
  UnblockUserProvider._({
    required UnblockUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'unblockUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$unblockUserHash();

  @override
  String toString() {
    return r'unblockUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return unblockUser(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UnblockUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$unblockUserHash() => r'03a013bf29980dc569cd06584fba559b0f9537a8';

/// 차단 해제. 결과로 성공 여부(bool)를 반환한다.

final class UnblockUserFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  UnblockUserFamily._()
    : super(
        retry: null,
        name: r'unblockUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 차단 해제. 결과로 성공 여부(bool)를 반환한다.

  UnblockUserProvider call(String userUid) =>
      UnblockUserProvider._(argument: userUid, from: this);

  @override
  String toString() => r'unblockUserProvider';
}

/// 차단한 유저 목록. 차단/해제 후에는 `ref.invalidate` 로 다시 읽는다.

@ProviderFor(blockUserList)
final blockUserListProvider = BlockUserListProvider._();

/// 차단한 유저 목록. 차단/해제 후에는 `ref.invalidate` 로 다시 읽는다.

final class BlockUserListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BlockUserModel>>,
          List<BlockUserModel>,
          FutureOr<List<BlockUserModel>>
        >
    with
        $FutureModifier<List<BlockUserModel>>,
        $FutureProvider<List<BlockUserModel>> {
  /// 차단한 유저 목록. 차단/해제 후에는 `ref.invalidate` 로 다시 읽는다.
  BlockUserListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blockUserListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blockUserListHash();

  @$internal
  @override
  $FutureProviderElement<List<BlockUserModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BlockUserModel>> create(Ref ref) {
    return blockUserList(ref);
  }
}

String _$blockUserListHash() => r'f7443865d4ca7dae181baa4432bfb99c67df66c4';
