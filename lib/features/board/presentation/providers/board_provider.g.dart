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

/// 게시글 검색 목록. 검색어별로 생성된다.
///
/// 목록 화면의 [boardListProvider] 를 family 로 바꾸지 않고 따로 둔다.
/// 새로고침을 부르는 곳이 여럿이라(작성·삭제·차단) 인자가 붙으면 전부 바뀐다.

@ProviderFor(BoardSearchList)
final boardSearchListProvider = BoardSearchListFamily._();

/// 게시글 검색 목록. 검색어별로 생성된다.
///
/// 목록 화면의 [boardListProvider] 를 family 로 바꾸지 않고 따로 둔다.
/// 새로고침을 부르는 곳이 여럿이라(작성·삭제·차단) 인자가 붙으면 전부 바뀐다.
final class BoardSearchListProvider
    extends $NotifierProvider<BoardSearchList, PaginationModel<BoardModel>> {
  /// 게시글 검색 목록. 검색어별로 생성된다.
  ///
  /// 목록 화면의 [boardListProvider] 를 family 로 바꾸지 않고 따로 둔다.
  /// 새로고침을 부르는 곳이 여럿이라(작성·삭제·차단) 인자가 붙으면 전부 바뀐다.
  BoardSearchListProvider._({
    required BoardSearchListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'boardSearchListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$boardSearchListHash();

  @override
  String toString() {
    return r'boardSearchListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BoardSearchList create() => BoardSearchList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginationModel<BoardModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginationModel<BoardModel>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BoardSearchListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$boardSearchListHash() => r'1623d822525e6dc00b2d9a469a249081855ba25c';

/// 게시글 검색 목록. 검색어별로 생성된다.
///
/// 목록 화면의 [boardListProvider] 를 family 로 바꾸지 않고 따로 둔다.
/// 새로고침을 부르는 곳이 여럿이라(작성·삭제·차단) 인자가 붙으면 전부 바뀐다.

final class BoardSearchListFamily extends $Family
    with
        $ClassFamilyOverride<
          BoardSearchList,
          PaginationModel<BoardModel>,
          PaginationModel<BoardModel>,
          PaginationModel<BoardModel>,
          String
        > {
  BoardSearchListFamily._()
    : super(
        retry: null,
        name: r'boardSearchListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 게시글 검색 목록. 검색어별로 생성된다.
  ///
  /// 목록 화면의 [boardListProvider] 를 family 로 바꾸지 않고 따로 둔다.
  /// 새로고침을 부르는 곳이 여럿이라(작성·삭제·차단) 인자가 붙으면 전부 바뀐다.

  BoardSearchListProvider call(String searchKeyword) =>
      BoardSearchListProvider._(argument: searchKeyword, from: this);

  @override
  String toString() => r'boardSearchListProvider';
}

/// 게시글 검색 목록. 검색어별로 생성된다.
///
/// 목록 화면의 [boardListProvider] 를 family 로 바꾸지 않고 따로 둔다.
/// 새로고침을 부르는 곳이 여럿이라(작성·삭제·차단) 인자가 붙으면 전부 바뀐다.

abstract class _$BoardSearchList
    extends $Notifier<PaginationModel<BoardModel>> {
  late final _$args = ref.$arg as String;
  String get searchKeyword => _$args;

  PaginationModel<BoardModel> build(String searchKeyword);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// 내가 쓴 게시글 목록.

@ProviderFor(MyBoardList)
final myBoardListProvider = MyBoardListProvider._();

/// 내가 쓴 게시글 목록.
final class MyBoardListProvider
    extends $NotifierProvider<MyBoardList, PaginationModel<BoardModel>> {
  /// 내가 쓴 게시글 목록.
  MyBoardListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myBoardListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myBoardListHash();

  @$internal
  @override
  MyBoardList create() => MyBoardList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginationModel<BoardModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginationModel<BoardModel>>(value),
    );
  }
}

String _$myBoardListHash() => r'c556f6a6d0b56a261b1d7d6bfac2c84183d4892c';

/// 내가 쓴 게시글 목록.

abstract class _$MyBoardList extends $Notifier<PaginationModel<BoardModel>> {
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

/// 게시글 하나의 좋아요 상태. 게시글 id 별로 생성된다.
///
/// 서버 왕복을 기다리지 않고 **먼저 그린 뒤** 반영한다. 실패하면 되돌린다 —
/// 하트는 누르자마자 반응해야 하는데 왕복이 눈에 띄기 때문이다.

@ProviderFor(BoardLike)
final boardLikeProvider = BoardLikeFamily._();

/// 게시글 하나의 좋아요 상태. 게시글 id 별로 생성된다.
///
/// 서버 왕복을 기다리지 않고 **먼저 그린 뒤** 반영한다. 실패하면 되돌린다 —
/// 하트는 누르자마자 반응해야 하는데 왕복이 눈에 띄기 때문이다.
final class BoardLikeProvider
    extends $AsyncNotifierProvider<BoardLike, BoardLikeModel> {
  /// 게시글 하나의 좋아요 상태. 게시글 id 별로 생성된다.
  ///
  /// 서버 왕복을 기다리지 않고 **먼저 그린 뒤** 반영한다. 실패하면 되돌린다 —
  /// 하트는 누르자마자 반응해야 하는데 왕복이 눈에 띄기 때문이다.
  BoardLikeProvider._({
    required BoardLikeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'boardLikeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$boardLikeHash();

  @override
  String toString() {
    return r'boardLikeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BoardLike create() => BoardLike();

  @override
  bool operator ==(Object other) {
    return other is BoardLikeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$boardLikeHash() => r'6e5c584941117be35f80512cd84190e54112f0fe';

/// 게시글 하나의 좋아요 상태. 게시글 id 별로 생성된다.
///
/// 서버 왕복을 기다리지 않고 **먼저 그린 뒤** 반영한다. 실패하면 되돌린다 —
/// 하트는 누르자마자 반응해야 하는데 왕복이 눈에 띄기 때문이다.

final class BoardLikeFamily extends $Family
    with
        $ClassFamilyOverride<
          BoardLike,
          AsyncValue<BoardLikeModel>,
          BoardLikeModel,
          FutureOr<BoardLikeModel>,
          String
        > {
  BoardLikeFamily._()
    : super(
        retry: null,
        name: r'boardLikeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 게시글 하나의 좋아요 상태. 게시글 id 별로 생성된다.
  ///
  /// 서버 왕복을 기다리지 않고 **먼저 그린 뒤** 반영한다. 실패하면 되돌린다 —
  /// 하트는 누르자마자 반응해야 하는데 왕복이 눈에 띄기 때문이다.

  BoardLikeProvider call(String boardId) =>
      BoardLikeProvider._(argument: boardId, from: this);

  @override
  String toString() => r'boardLikeProvider';
}

/// 게시글 하나의 좋아요 상태. 게시글 id 별로 생성된다.
///
/// 서버 왕복을 기다리지 않고 **먼저 그린 뒤** 반영한다. 실패하면 되돌린다 —
/// 하트는 누르자마자 반응해야 하는데 왕복이 눈에 띄기 때문이다.

abstract class _$BoardLike extends $AsyncNotifier<BoardLikeModel> {
  late final _$args = ref.$arg as String;
  String get boardId => _$args;

  FutureOr<BoardLikeModel> build(String boardId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<BoardLikeModel>, BoardLikeModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BoardLikeModel>, BoardLikeModel>,
              AsyncValue<BoardLikeModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// 게시글 수정. 결과로 성공 여부(bool)를 반환한다.

@ProviderFor(updateBoard)
final updateBoardProvider = UpdateBoardFamily._();

/// 게시글 수정. 결과로 성공 여부(bool)를 반환한다.

final class UpdateBoardProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// 게시글 수정. 결과로 성공 여부(bool)를 반환한다.
  UpdateBoardProvider._({
    required UpdateBoardFamily super.from,
    required UpdateBoardParams super.argument,
  }) : super(
         retry: null,
         name: r'updateBoardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$updateBoardHash();

  @override
  String toString() {
    return r'updateBoardProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as UpdateBoardParams;
    return updateBoard(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateBoardProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateBoardHash() => r'8bd40273dfba6ffedd0523294e5e55e6c4600f25';

/// 게시글 수정. 결과로 성공 여부(bool)를 반환한다.

final class UpdateBoardFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, UpdateBoardParams> {
  UpdateBoardFamily._()
    : super(
        retry: null,
        name: r'updateBoardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 게시글 수정. 결과로 성공 여부(bool)를 반환한다.

  UpdateBoardProvider call(UpdateBoardParams params) =>
      UpdateBoardProvider._(argument: params, from: this);

  @override
  String toString() => r'updateBoardProvider';
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
