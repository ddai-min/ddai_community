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

@ProviderFor(ChatList)
final chatListProvider = ChatListProvider._();

/// 채팅 목록 Notifier. 실시간 스트림으로 동기화된다.
final class ChatListProvider
    extends $NotifierProvider<ChatList, PaginationModel<ChatModel>> {
  /// 채팅 목록 Notifier. 실시간 스트림으로 동기화된다.
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

String _$chatListHash() => r'e41ac7cd3b0ea09acc4a57ff19942d77a2d960c4';

/// 채팅 목록 Notifier. 실시간 스트림으로 동기화된다.

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

/// 채팅 메시지 전송.

@ProviderFor(addChat)
final addChatProvider = AddChatFamily._();

/// 채팅 메시지 전송.

final class AddChatProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 채팅 메시지 전송.
  AddChatProvider._({
    required AddChatFamily super.from,
    required AddChatParams super.argument,
  }) : super(
         retry: null,
         name: r'addChatProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addChatHash();

  @override
  String toString() {
    return r'addChatProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as AddChatParams;
    return addChat(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AddChatProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addChatHash() => r'295392303387e173e97c317f2aa4935a80b22abe';

/// 채팅 메시지 전송.

final class AddChatFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, AddChatParams> {
  AddChatFamily._()
    : super(
        retry: null,
        name: r'addChatProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 채팅 메시지 전송.

  AddChatProvider call(AddChatParams params) =>
      AddChatProvider._(argument: params, from: this);

  @override
  String toString() => r'addChatProvider';
}
