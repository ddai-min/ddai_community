import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String userName;
  final bool isAnonymous;
  final String? email;
  final String? imageUrl;

  UserModel({
    required this.id,
    required this.userName,
    required this.isAnonymous,
    this.email,
    this.imageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
