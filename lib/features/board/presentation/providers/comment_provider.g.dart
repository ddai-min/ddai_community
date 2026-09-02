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
