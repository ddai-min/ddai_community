// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [CommentRepository] 인스턴스 제공.

@ProviderFor(commentRepository)
final commentRepositoryProvider = CommentRepositoryProvider._();

/// [CommentRepository] 인스턴스 제공.

final class CommentRepositoryProvider
    extends
        $FunctionalProvider<
          CommentRepository,
          CommentRepository,
          CommentRepository
        >
    with $Provider<CommentRepository> {
  /// [CommentRepository] 인스턴스 제공.
  CommentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commentRepositoryHash();

  @$internal
  @override
  $ProviderElement<CommentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CommentRepository create(Ref ref) {
    return commentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommentRepository>(value),
    );
  }
}

String _$commentRepositoryHash() => r'58b31dd3ac05b4c1add5872e7f3071423e8cd744';

/// 특정 게시글의 댓글 목록(페이지네이션) Notifier. 게시글 id로 family 생성된다.

@ProviderFor(CommentList)
final commentListProvider = CommentListFamily._();

/// 특정 게시글의 댓글 목록(페이지네이션) Notifier. 게시글 id로 family 생성된다.
final class CommentListProvider
    extends $NotifierProvider<CommentList, PaginationModel<CommentModel>> {
  /// 특정 게시글의 댓글 목록(페이지네이션) Notifier. 게시글 id로 family 생성된다.
  CommentListProvider._({
    required CommentListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'commentListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$commentListHash();

  @override
  String toString() {
    return r'commentListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CommentList create() => CommentList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginationModel<CommentModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginationModel<CommentModel>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CommentListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentListHash() => r'af78b93e3b610c0a6d2736c91640910a5141dd60';

/// 특정 게시글의 댓글 목록(페이지네이션) Notifier. 게시글 id로 family 생성된다.

final class CommentListFamily extends $Family
    with
        $ClassFamilyOverride<
          CommentList,
          PaginationModel<CommentModel>,
          PaginationModel<CommentModel>,
          PaginationModel<CommentModel>,
          String
        > {
  CommentListFamily._()
    : super(
        retry: null,
        name: r'commentListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 특정 게시글의 댓글 목록(페이지네이션) Notifier. 게시글 id로 family 생성된다.

  CommentListProvider call(String boardId) =>
      CommentListProvider._(argument: boardId, from: this);

  @override
  String toString() => r'commentListProvider';
}

/// 특정 게시글의 댓글 목록(페이지네이션) Notifier. 게시글 id로 family 생성된다.

abstract class _$CommentList extends $Notifier<PaginationModel<CommentModel>> {
  late final _$args = ref.$arg as String;
  String get boardId => _$args;

  PaginationModel<CommentModel> build(String boardId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              PaginationModel<CommentModel>,
              PaginationModel<CommentModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                PaginationModel<CommentModel>,
                PaginationModel<CommentModel>
              >,
              PaginationModel<CommentModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// 내가 쓴 댓글 목록.
///
/// [CommentList] 와 달리 부모 게시글로 좁히지 않는다. 원글로 이동하려면
/// 댓글이 `board_id` 를 들고 있어야 해서 [CommentModel] 에 필드를 두었다.

@ProviderFor(MyCommentList)
final myCommentListProvider = MyCommentListProvider._();

/// 내가 쓴 댓글 목록.
///
/// [CommentList] 와 달리 부모 게시글로 좁히지 않는다. 원글로 이동하려면
/// 댓글이 `board_id` 를 들고 있어야 해서 [CommentModel] 에 필드를 두었다.
final class MyCommentListProvider
    extends $NotifierProvider<MyCommentList, PaginationModel<CommentModel>> {
  /// 내가 쓴 댓글 목록.
  ///
  /// [CommentList] 와 달리 부모 게시글로 좁히지 않는다. 원글로 이동하려면
  /// 댓글이 `board_id` 를 들고 있어야 해서 [CommentModel] 에 필드를 두었다.
  MyCommentListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myCommentListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myCommentListHash();

  @$internal
  @override
  MyCommentList create() => MyCommentList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginationModel<CommentModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginationModel<CommentModel>>(
        value,
      ),
    );
  }
}

String _$myCommentListHash() => r'7975191d528f7eb2acf4b1f0fd16c90316c48dc5';

/// 내가 쓴 댓글 목록.
///
/// [CommentList] 와 달리 부모 게시글로 좁히지 않는다. 원글로 이동하려면
/// 댓글이 `board_id` 를 들고 있어야 해서 [CommentModel] 에 필드를 두었다.

abstract class _$MyCommentList
    extends $Notifier<PaginationModel<CommentModel>> {
  PaginationModel<CommentModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              PaginationModel<CommentModel>,
              PaginationModel<CommentModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                PaginationModel<CommentModel>,
                PaginationModel<CommentModel>
              >,
              PaginationModel<CommentModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 댓글 작성. 결과로 성공 여부(bool)를 반환한다.

@ProviderFor(addComment)
final addCommentProvider = AddCommentFamily._();

/// 댓글 작성. 결과로 성공 여부(bool)를 반환한다.

final class AddCommentProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// 댓글 작성. 결과로 성공 여부(bool)를 반환한다.
  AddCommentProvider._({
    required AddCommentFamily super.from,
    required AddCommentParams super.argument,
  }) : super(
         retry: null,
         name: r'addCommentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addCommentHash();

  @override
  String toString() {
    return r'addCommentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as AddCommentParams;
    return addComment(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AddCommentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addCommentHash() => r'2faefc765ce02bd4a706384d803c72c87038f073';

/// 댓글 작성. 결과로 성공 여부(bool)를 반환한다.

final class AddCommentFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, AddCommentParams> {
  AddCommentFamily._()
    : super(
        retry: null,
        name: r'addCommentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 댓글 작성. 결과로 성공 여부(bool)를 반환한다.

  AddCommentProvider call(AddCommentParams params) =>
      AddCommentProvider._(argument: params, from: this);

  @override
  String toString() => r'addCommentProvider';
}

/// 댓글 삭제. 결과로 성공 여부(bool)를 반환한다.

@ProviderFor(deleteComment)
final deleteCommentProvider = DeleteCommentFamily._();

/// 댓글 삭제. 결과로 성공 여부(bool)를 반환한다.

final class DeleteCommentProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// 댓글 삭제. 결과로 성공 여부(bool)를 반환한다.
  DeleteCommentProvider._({
    required DeleteCommentFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deleteCommentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteCommentHash();

  @override
  String toString() {
    return r'deleteCommentProvider'
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
    return deleteComment(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteCommentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteCommentHash() => r'ee6e5d0788e9c58524f39ebe894dc965f757a0d0';

/// 댓글 삭제. 결과로 성공 여부(bool)를 반환한다.

final class DeleteCommentFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  DeleteCommentFamily._()
    : super(
        retry: null,
        name: r'deleteCommentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 댓글 삭제. 결과로 성공 여부(bool)를 반환한다.

  DeleteCommentProvider call(String searchId) =>
      DeleteCommentProvider._(argument: searchId, from: this);

  @override
  String toString() => r'deleteCommentProvider';
}
