import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// 앱 사용자 모델.
///
/// 이메일 가입 유저는 Firestore `user` 컬렉션에도 저장된다.
/// 익명 유저는 [isAnonymous] 가 true 이고 [email] 이 null 이다.
/// 앱 전역의 현재 로그인 유저 상태는 [userMeProvider] 가 보관하며,
/// [id] 가 빈 문자열이면 비로그인 상태를 의미한다.
@JsonSerializable()
class UserModel {
  final String id;
  final String userName;
  final bool isAnonymous;
  final String? email;

  UserModel({
    required this.id,
    required this.userName,
    required this.isAnonymous,
    this.email,
  });

  UserModel copyWith({
    String? id,
    String? userName,
    bool? isAnonymous,
    String? email,
  }) {
    return UserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      email: email ?? this.email,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
