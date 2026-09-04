import 'package:ddai_community/core/models/model_with_id.dart';
import 'package:ddai_community/core/models/pagination_cursor.dart';

/// 페이지네이션 목록의 상태를 담는 불변 모델.
///
/// 조회된 [items] 와 함께 로딩 여부([isLoading]), 다음 페이지 존재 여부([hasMore]),
/// 다음 요청의 시작점이 되는 커서([lastCursor])를 함께 보관한다.
class PaginationModel<T extends ModelWithId> {
  /// 현재까지 조회된 항목 목록.
  final List<T> items;

  /// 추가 페이지를 불러오는 중인지 여부.
  final bool isLoading;

  /// 더 불러올 페이지가 남아 있는지 여부.
  final bool hasMore;

  /// 다음 페이지 조회의 시작점이 되는 커서.
  final PaginationCursor? lastCursor;

  /// 마지막 조회가 실패했는지 여부.
  ///
  /// repository 는 예외를 삼키고 빈 목록을 돌려주는 규칙이라, 이 플래그가 없으면
  /// 화면이 **"글이 없다"와 "불러오지 못했다"를 구분할 수 없다.**
  /// 네트워크가 끊긴 채로 첫 화면을 열면 앱이 고장난 것처럼 보인다.
  final bool hasError;

  PaginationModel({
    required this.items,
    this.isLoading = false,
    this.hasMore = true,
    this.lastCursor,
    this.hasError = false,
  });

  /// 일부 필드만 교체한 새 인스턴스를 반환한다. (불변 상태 갱신용)
  ///
  /// [lastCursor] 를 null 로 되돌릴 수는 없다. 목록을 처음으로 되감을 때는
  /// copyWith 대신 새 인스턴스를 만든다. ([PaginationMixin.refresh] 참고)
  PaginationModel<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? hasMore,
    PaginationCursor? lastCursor,
    bool? hasError,
  }) {
    return PaginationModel<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      lastCursor: lastCursor ?? this.lastCursor,
      hasError: hasError ?? this.hasError,
    );
  }
}
