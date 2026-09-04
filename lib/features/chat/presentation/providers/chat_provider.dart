import 'package:ddai_community/core/data/pagination_repository.dart';
import 'package:ddai_community/core/models/pagination_model.dart';
import 'package:ddai_community/core/providers/pagination_provider.dart';
import 'package:ddai_community/features/chat/data/chat_repository.dart';
import 'package:ddai_community/features/chat/domain/chat_model.dart';
import 'package:ddai_community/features/chat/domain/chat_parameter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_provider.g.dart';

/// [ChatRepository] 인스턴스 제공.
@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) => ChatRepository();

/// 채팅 메시지 삭제. 결과로 성공 여부(bool)를 반환한다.
@riverpod
Future<bool> deleteChat(Ref ref, String searchId) =>
    ChatRepository.deleteChat(searchId: searchId);

/// 채팅 목록 Notifier. 실시간 스트림으로 동기화된다.
///
/// 전송한 메시지가 스트림을 타고 돌아오기까지 평균 450ms 가 걸리는데,
/// 그동안 화면이 비어 보이지 않도록 **임시 말풍선을 먼저 그린다.**
/// (낙관적 렌더링 — 실제 행이 도착하면 조용히 교체된다)
@riverpod
class ChatList extends _$ChatList with PaginationMixin<ChatModel> {
  /// 임시 말풍선 id 앞에 붙는 접두사. 서버가 만드는 uuid 와 겹칠 수 없는 값이다.
  static const String _localIdPrefix = 'local-';

  /// 아직 서버에 도착하지 않은 임시 말풍선인지.
  ///
  /// 이 메시지는 서버에 지울 행이 없으므로 화면이 삭제 메뉴를 막는 데 쓴다.
  /// 접두사 규칙이 [sendChat] 안에만 있으면 화면이 `'local-'` 을 직접 알아야 해서
  /// 여기로 꺼내 둔다.
  static bool isPending(String id) => id.startsWith(_localIdPrefix);

  /// 스트림이 마지막으로 내보낸 서버 목록. (최신순)
  List<ChatModel> _serverChats = const [];

  /// 아직 스트림으로 돌아오지 않은 내 메시지. (보낸 순서)
  final List<ChatModel> _pendingChats = [];

  /// 임시 말풍선의 id 를 만드는 일련번호. 실제 행이 오면 진짜 id 로 교체된다.
  int _localSeq = 0;

  @override
  PaginationModel<ChatModel> build() {
    // 세션이 바뀌면 build() 가 다시 도는데 인스턴스는 재사용된다. 이전 목록이
    // 남아 다른 유저의 화면에 섞이지 않도록 여기서 비운다.
    _serverChats = const [];
    _pendingChats.clear();

    subscribeStream();

    return initialState();
  }

  @override
  PaginationRepository<ChatModel> get paginationRepository =>
      ref.read(chatRepositoryProvider);

  /// 스트림이 목록 전체를 새로 내보낼 때마다 임시 말풍선을 다시 얹는다.
  ///
  /// 그냥 교체해 버리면, 내 메시지가 돌아오기 전에 **다른 사람의 메시지**가 도착한
  /// 순간 내 임시 말풍선이 사라졌다가 다시 나타난다.
  @override
  List<ChatModel> mergeStreamData(List<ChatModel> rows) {
    // 서버에 도착이 확인된 것은 임시 목록에서 걷어낸다. (id 로 대조)
    final arrivedIds = rows.map((row) => row.id).toSet();
    _pendingChats.removeWhere((chat) => arrivedIds.contains(chat.id));

    _serverChats = rows;

    return _visibleChats();
  }

  /// 메시지를 전송한다. 성공 여부를 반환한다.
  ///
  /// 서버 왕복을 기다리지 않고 임시 말풍선을 **먼저** 그린 뒤 전송한다.
  /// 실패하면 그 말풍선을 걷어내므로 화면에 유령 메시지가 남지 않는다.
  Future<bool> sendChat({
    required String content,
    required String userName,
    required String userUid,
  }) async {
    final pending = ChatModel(
      id: '$_localIdPrefix${_localSeq++}',
      content: content,
      userName: userName,
      userUid: userUid,
      date: DateTime.now(),
    );

    _pendingChats.add(pending);
    state = state.copyWith(items: _visibleChats());

    final saved = await ChatRepository.addChat(
      addChatParams: AddChatParams(
        content: content,
        userName: userName,
        userUid: userUid,
      ),
    );

    final index = _pendingChats.indexOf(pending);

    // 전송 도중 build() 가 다시 돌아 목록이 비워진 경우. 스트림이 알아서 채운다.
    if (index == -1) {
      return saved != null;
    }

    if (saved == null) {
      _pendingChats.removeAt(index);
    } else if (_serverChats.any((chat) => chat.id == saved.id)) {
      // insert 응답보다 스트림이 먼저 도착한 드문 경우. 그대로 두면 두 번 그려진다.
      _pendingChats.removeAt(index);
    } else {
      // 실제 id 로 바꿔 둬야 스트림이 같은 행을 실어 왔을 때 중복 없이 걷힌다.
      _pendingChats[index] = saved;
    }

    state = state.copyWith(items: _visibleChats());

    return saved != null;
  }

  /// 화면에 보여줄 목록. 전송 중인 메시지가 항상 맨 앞(= 최신)에 온다.
  ///
  /// 스트림이 최신순이라 목록도 최신순이며, 화면은 `reverse: true` 로 뒤집어 그린다.
  List<ChatModel> _visibleChats() => [
    ..._pendingChats.reversed,
    ..._serverChats,
  ];
}
