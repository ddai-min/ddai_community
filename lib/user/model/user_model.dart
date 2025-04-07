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

  UserModel copyWith({
    String? id,
    String? userName,
    bool? isAnonymous,
    String? email,
    String? imageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
