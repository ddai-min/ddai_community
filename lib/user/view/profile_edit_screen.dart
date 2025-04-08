import 'package:ddai_community/common/component/default_dialog.dart';
import 'package:ddai_community/common/component/default_elevated_button.dart';
import 'package:ddai_community/common/component/default_loading_overlay.dart';
import 'package:ddai_community/common/component/default_text_field.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:ddai_community/common/util/reg_utils.dart';
import 'package:ddai_community/common/view/home_tab.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  static get routeName => 'profile_edit';

  final String userName;
  final String email;

  const ProfileEditScreen({
    super.key,
    required this.userName,
    required this.email,
  });

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController nicknameTextController;
  late TextEditingController emailTextController;

  @override
  void initState() {
    super.initState();

    nicknameTextController = TextEditingController(text: widget.userName);
    emailTextController = TextEditingController(text: widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '프로필 수정',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
            top: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Form(
                        key: formKey,
                        child: _Input(
                          controller: nicknameTextController,
                          validator: _nicknameValidator,
                          onChanged: (value) {
                            setState(() {});
                          },
                          labelText: '닉네임',
                          hintText: '닉네임',
                        ),
                      ),
                      _Input(
                        controller: emailTextController,
                        labelText: '이메일',
                        hintText: '이메일',
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
              ),
              DefaultElevatedButton(
                onPressed: widget.userName == nicknameTextController.text
                    ? null
                    : _editProfile,
                text: '수정하기',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _nicknameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '닉네임을 입력해주세요.';
    } else if (value.length < 2) {
      return '닉네임은 두 글자 이상 입력해주세요.';
    } else if (value.length > 12) {
      return '닉네임은 12글자 이하로 입력해주세요.';
    } else if (!RegUtils.isValidNickname(nickname: value)) {
      return '닉네임은 한글, 영어, 숫자만 가능합니다.';
    }

    return null;
  }

  void _editProfile() async {
    DefaultLoadingOverlay.showLoading(context);

    if (widget.userName != nicknameTextController.text) {
      if (!formKey.currentState!.validate()) {
        DefaultLoadingOverlay.hideLoading(context);

        return;
      }

      await FirebaseAuth.instance.currentUser
          ?.updateDisplayName(nicknameTextController.text);
    }

    DefaultLoadingOverlay.hideLoading(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return DefaultDialog(
          contentText: '프로필이\n수정되었습니다.',
          buttonText: '확인',
          onPressed: () {
            ref.read(userMeProvider.notifier).update(
              (model) {
                return model.copyWith(
                  userName: nicknameTextController.text,
                );
              },
            );

            context.goNamed(
              HomeTab.routeName,
            );
          },
        );
      },
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final String labelText;
  final String? hintText;
  final bool readOnly;

  const _Input({
    this.controller,
    this.validator,
    this.onChanged,
    required this.labelText,
    this.hintText,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DefaultTextField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          labelText: labelText,
          hintText: hintText,
          readOnly: readOnly,
          maxLength: 30,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
