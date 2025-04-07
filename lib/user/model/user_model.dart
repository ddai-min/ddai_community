import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

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
