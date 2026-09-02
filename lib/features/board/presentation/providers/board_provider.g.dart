// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [BoardRepository] 인스턴스 제공.

@ProviderFor(boardRepository)
final boardRepositoryProvider = BoardRepositoryProvider._();

/// [BoardRepository] 인스턴스 제공.

final class BoardRepositoryProvider
    extends
        $FunctionalProvider<BoardRepository, BoardRepository, BoardRepository>
    with $Provider<BoardRepository> {
  /// [BoardRepository] 인스턴스 제공.
  BoardRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'boardRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$boardRepositoryHash();

  @$internal
  @override
  $ProviderElement<BoardRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BoardRepository create(Ref ref) {
    return boardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BoardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BoardRepository>(value),
    );
  }
}

String _$boardRepositoryHash() => r'e27df42d66fb62e9863ceb046515043f7b079cbf';

/// 게시글 목록(페이지네이션) Notifier.

@ProviderFor(BoardList)
final boardListProvider = BoardListProvider._();

/// 게시글 목록(페이지네이션) Notifier.
final class BoardListProvider
    extends $NotifierProvider<BoardList, PaginationModel<BoardModel>> {
  /// 게시글 목록(페이지네이션) Notifier.
  BoardListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'boardListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$boardListHash();

  @$internal
  @override
  BoardList create() => BoardList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginationModel<BoardModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginationModel<BoardModel>>(value),
    );
  }
}

String _$boardListHash() => r'7acc66d82b2354707901cc7c6f3a57c839cb0464';

/// 게시글 목록(페이지네이션) Notifier.

abstract class _$BoardList extends $Notifier<PaginationModel<BoardModel>> {
  PaginationModel<BoardModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<PaginationModel<BoardModel>, PaginationModel<BoardModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                PaginationModel<BoardModel>,
                PaginationModel<BoardModel>
              >,
              PaginationModel<BoardModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 게시글 단건 조회. searchId(게시글 id)별로 캐싱된다.

@ProviderFor(getBoard)
final getBoardProvider = GetBoardFamily._();

/// 게시글 단건 조회. searchId(게시글 id)별로 캐싱된다.

final class GetBoardProvider
    extends
        $FunctionalProvider<
          AsyncValue<BoardModel?>,
          BoardModel?,
          FutureOr<BoardModel?>
        >
    with $FutureModifier<BoardModel?>, $FutureProvider<BoardModel?> {
  /// 게시글 단건 조회. searchId(게시글 id)별로 캐싱된다.
  GetBoardProvider._({
    required GetBoardFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'getBoardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getBoardHash();

  @override
  String toString() {
    return r'getBoardProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BoardModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BoardModel?> create(Ref ref) {
    final argument = this.argument as String;
    return getBoard(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetBoardProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getBoardHash() => r'addee8e2eb331cc197c813b1207285f9028840e1';

/// 게시글 단건 조회. searchId(게시글 id)별로 캐싱된다.

final class GetBoardFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BoardModel?>, String> {
  GetBoardFamily._()
    : super(
        retry: null,
        name: r'getBoardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 게시글 단건 조회. searchId(게시글 id)별로 캐싱된다.

  GetBoardProvider call(String searchId) =>
      GetBoardProvider._(argument: searchId, from: this);

  @override
  String toString() => r'getBoardProvider';
}

/// 게시글 작성. 결과로 성공 여부(bool)를 반환한다.

@ProviderFor(addBoard)
final addBoardProvider = AddBoardFamily._();

/// 게시글 작성. 결과로 성공 여부(bool)를 반환한다.

final class AddBoardProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// 게시글 작성. 결과로 성공 여부(bool)를 반환한다.
  AddBoardProvider._({
    required AddBoardFamily super.from,
    required AddBoardParams super.argument,
  }) : super(
         retry: null,
         name: r'addBoardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addBoardHash();

  @override
  String toString() {
    return r'addBoardProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as AddBoardParams;
    return addBoard(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AddBoardProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addBoardHash() => r'dba4287bfc43fecf1a0ae0bfa4e74d32f1c6d327';

/// 게시글 작성. 결과로 성공 여부(bool)를 반환한다.

final class AddBoardFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, AddBoardParams> {
  AddBoardFamily._()
    : super(
        retry: null,
        name: r'addBoardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 게시글 작성. 결과로 성공 여부(bool)를 반환한다.

  AddBoardProvider call(AddBoardParams params) =>
      AddBoardProvider._(argument: params, from: this);

  @override
  String toString() => r'addBoardProvider';
}

/// 게시글 삭제. 결과로 성공 여부(bool)를 반환한다.

@ProviderFor(deleteBoard)
final deleteBoardProvider = DeleteBoardFamily._();

/// 게시글 삭제. 결과로 성공 여부(bool)를 반환한다.

final class DeleteBoardProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// 게시글 삭제. 결과로 성공 여부(bool)를 반환한다.
  DeleteBoardProvider._({
    required DeleteBoardFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deleteBoardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteBoardHash();

  @override
  String toString() {
    return r'deleteBoardProvider'
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
    return deleteBoard(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteBoardProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteBoardHash() => r'4ae7475c8db1b42bbb9ba2a5acccfe6d6d9e7c7a';

/// 게시글 삭제. 결과로 성공 여부(bool)를 반환한다.

final class DeleteBoardFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  DeleteBoardFamily._()
    : super(
        retry: null,
        name: r'deleteBoardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 게시글 삭제. 결과로 성공 여부(bool)를 반환한다.

  DeleteBoardProvider call(String searchId) =>
      DeleteBoardProvider._(argument: searchId, from: this);

  @override
  String toString() => r'deleteBoardProvider';
}
