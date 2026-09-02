import 'package:ddai_community/core/data/supabase_client.dart';
import 'package:ddai_community/core/models/model_with_id.dart';
import 'package:ddai_community/core/models/pagination_cursor.dart';
import 'package:ddai_community/core/models/pagination_model.dart';
import 'package:ddai_community/core/utils/logger.dart';

/// 목록 조회 대상 Postgres 테이블 이름 모음.
///
/// enum 의 `name`(`board`/`comment`/`chat`)이 실제 테이블 이름으로 사용된다.
enum TablePath {
  board,
  comment,
  chat,
}

/// 목록 조회 로직을 공통화한 제네릭 Supabase repository.
///
/// 게시판/채팅 목록과 게시글별 댓글 목록이 모두 이 클래스를 통해 동일한 방식
/// (`created_at` keyset 페이지네이션)으로 조회된다. 각 도메인 repository
/// ([BoardRepository] 등)는 이 클래스를 상속해 [table] 과 [fromJson] 만 지정한다.
///
/// **차단 필터링 로직은 없다.** Firestore 때는 클라이언트가 차단 목록을 먼저 조회해
/// `whereNotIn` 으로 걸렀지만(값 10개 제한이 있었다), 지금은 RLS 정책 `is_blocked()`
/// 가 서버에서 강제하므로 여기서 할 일이 없다.
class PaginationRepository<T extends ModelWithId> {
  /// 조회 대상 테이블.
  final TablePath table;

  /// 부모 행으로 범위를 좁힐 때 사용하는 FK 컬럼. (댓글: `board_id`)
  ///
  /// Firestore 의 하위 컬렉션(`board/{id}/comment`)을 대체한다.
  final String? parentColumn;

  /// 조회 결과 행(Map)을 모델 [T] 로 변환하는 함수.
  final T Function(Map<String, dynamic> data) fromJson;

  PaginationRepository({
    required this.table,
    required this.fromJson,
    this.parentColumn,
  });

  /// 한 페이지 분량의 행을 조회한다.
  ///
  /// - [parentId] 가 주어지면 [parentColumn] 으로 범위를 좁힌다. (특정 게시글의 댓글)
  /// - [cursor] 가 주어지면 그 지점 다음부터 이어서 조회한다.
  /// - 오류가 발생하면 빈 목록을 반환해 UI 크래시를 방지한다.
  Future<PaginationModel<T>> fetchData({
    String? parentId,
    int pageSize = 30,
    PaginationCursor? cursor,
  }) async {
    try {
      var query = supabase.from(table.name).select();

      if (parentColumn != null && parentId != null) {
        query = query.eq(parentColumn!, parentId);
      }

      if (cursor != null) {
        // `created_at desc, id desc` 정렬에 대응하는 keyset 조건.
        // 같은 시각에 만들어진 행이 있어도 경계에서 누락/중복이 생기지 않는다.
        // 값에 `.` 과 `:` 이 있어 PostgREST 파싱이 흔들리지 않도록 큰따옴표로 감싼다.
        final createdAt = cursor.createdAt.toUtc().toIso8601String();

        query = query.or(
          'created_at.lt."$createdAt",'
          'and(created_at.eq."$createdAt",id.lt."${cursor.id}")',
        );
      }

      // board_cursor_idx 등 (created_at desc, id desc) 인덱스가 이 정렬을 받쳐준다.
      final rows = await query
          .order('created_at', ascending: false)
          .order('id', ascending: false)
          .limit(pageSize);

      final items = rows.map(fromJson).toList();

      final lastRow = rows.isNotEmpty ? rows.last : null;
      final nextCursor = lastRow == null
          ? null
          : PaginationCursor(
              createdAt: DateTime.parse(lastRow['created_at'] as String),
              id: lastRow['id'] as String,
            );

      // 조회 개수가 요청한 pageSize 와 같으면 다음 페이지가 더 있다고 판단한다.
      final hasMore = rows.length == pageSize;

      return PaginationModel<T>(
        items: items,
        hasMore: hasMore,
        lastCursor: nextCursor,
      );
    } catch (error) {
      logger.e(error);

      return PaginationModel(
        items: [],
      );
    }
  }

  /// 테이블을 실시간 구독하는 스트림을 반환한다. (채팅에서 사용)
  ///
  /// 커서 페이지네이션 없이 최신 [pageSize] 개를 최신순으로 지속 수신한다.
  /// Firestore 의 `snapshots()` 와 마찬가지로 **매번 목록 전체**를 내보내므로
  /// 수신 측은 증분 병합 없이 그대로 교체하면 된다.
  Stream<List<T>> streamData({
    int pageSize = 100,
  }) {
    return supabase
        .from(table.name)
        .stream(primaryKey: ['id'])
        .order('created_at')
        .limit(pageSize)
        .map((rows) => rows.map(fromJson).toList());
  }
}
