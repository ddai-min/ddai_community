// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [ChatRepository] 인스턴스 제공.

@ProviderFor(chatRepository)
final chatRepositoryProvider = ChatRepositoryProvider._();

/// [ChatRepository] 인스턴스 제공.

final class ChatRepositoryProvider
    extends $FunctionalProvider<ChatRepository, ChatRepository, ChatRepository>
    with $Provider<ChatRepository> {
  /// [ChatRepository] 인스턴스 제공.
  ChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChatRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChatRepository create(Ref ref) {
    return chatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatRepository>(value),
    );
  }
}

String _$chatRepositoryHash() => r'f387326596315816fc6945584a7f7d41b2cf70f2';

/// 채팅 목록 Notifier. 실시간 스트림으로 동기화된다.
///
/// 전송한 메시지가 스트림을 타고 돌아오기까지 평균 450ms 가 걸리는데,
/// 그동안 화면이 비어 보이지 않도록 **임시 말풍선을 먼저 그린다.**
/// (낙관적 렌더링 — 실제 행이 도착하면 조용히 교체된다)

@ProviderFor(ChatList)
final chatListProvider = ChatListProvider._();

/// 채팅 목록 Notifier. 실시간 스트림으로 동기화된다.
///
/// 전송한 메시지가 스트림을 타고 돌아오기까지 평균 450ms 가 걸리는데,
/// 그동안 화면이 비어 보이지 않도록 **임시 말풍선을 먼저 그린다.**
/// (낙관적 렌더링 — 실제 행이 도착하면 조용히 교체된다)
final class ChatListProvider
    extends $NotifierProvider<ChatList, PaginationModel<ChatModel>> {
  /// 채팅 목록 Notifier. 실시간 스트림으로 동기화된다.
  ///
  /// 전송한 메시지가 스트림을 타고 돌아오기까지 평균 450ms 가 걸리는데,
  /// 그동안 화면이 비어 보이지 않도록 **임시 말풍선을 먼저 그린다.**
  /// (낙관적 렌더링 — 실제 행이 도착하면 조용히 교체된다)
  ChatListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatListHash();

  @$internal
  @override
  ChatList create() => ChatList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginationModel<ChatModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginationModel<ChatModel>>(value),
    );
  }
}

String _$chatListHash() => r'a4e6e633c8518639a9d3acd684fca54d17a61e9a';

/// 채팅 목록 Notifier. 실시간 스트림으로 동기화된다.
///
/// 전송한 메시지가 스트림을 타고 돌아오기까지 평균 450ms 가 걸리는데,
/// 그동안 화면이 비어 보이지 않도록 **임시 말풍선을 먼저 그린다.**
/// (낙관적 렌더링 — 실제 행이 도착하면 조용히 교체된다)

abstract class _$ChatList extends $Notifier<PaginationModel<ChatModel>> {
  PaginationModel<ChatModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<PaginationModel<ChatModel>, PaginationModel<ChatModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                PaginationModel<ChatModel>,
                PaginationModel<ChatModel>
              >,
              PaginationModel<ChatModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
