import 'package:ddai_community/user/model/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userMeProvider = StateProvider<UserModel>(
  (ref) => UserModel(
    id: '',
    userName: '',
  ),
);
