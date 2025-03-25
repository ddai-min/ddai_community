import 'package:ddai_community/common/model/pagination_model.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paginationProvider =
    StateNotifierProvider<PaginationRepository, PaginationModel>(
  (ref) => PaginationRepository(),
);
