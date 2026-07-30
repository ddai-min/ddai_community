import 'package:ddai_community/user/model/report_parameter.dart';
import 'package:ddai_community/user/repository/report_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'report_provider.g.dart';

/// 신고. 결과로 성공 여부(bool)를 반환한다.
@riverpod
Future<bool> report(Ref ref, ReportParams params) =>
    ReportRepository.report(reportParams: params);
