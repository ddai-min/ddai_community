import 'dart:io';

import 'package:ddai_community/common/component/default_avatar.dart';
import 'package:ddai_community/common/component/default_dialog.dart';
import 'package:ddai_community/common/component/default_elevated_button.dart';
import 'package:ddai_community/common/component/default_loading_overlay.dart';
import 'package:ddai_community/common/component/default_text_button.dart';
import 'package:ddai_community/common/component/default_text_field.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  static get routeName => 'profile_edit';

  final String? imageUrl;
  final String userName;
  final String email;

  const ProfileEditScreen({
    super.key,
    this.imageUrl,
    required this.userName,
    required this.email,
  });

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late TextEditingController nicknameTextController;
  late TextEditingController emailTextController;

  late String? imageUrl;

  @override
  void initState() {
    super.initState();

    nicknameTextController = TextEditingController(text: widget.userName);
    emailTextController = TextEditingController(text: widget.email);

    imageUrl = widget.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '프로필 수정',
      child: SingleChildScrollView(
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
                DefaultAvatar(
                  image: imageUrl != null
                      ? imageUrl!.startsWith('http')
                          ? Image.network(imageUrl!)
                          : Image.file(
                              File(imageUrl!),
                            )
                      : null,
                  width: 160,
                  height: 160,
                ),
                const SizedBox(height: 10),
                DefaultTextButton(
                  onPressed: () async {
                    final imagePicker = ImagePicker();

                    final image = await imagePicker.pickImage(
                      source: ImageSource.gallery,
                    );

                    if (image == null) {
                      return;
                    }

                    setState(() {
                      imageUrl = image.path;
                    });
                  },
                  text: '프로필 사진 변경',
                ),
                const SizedBox(height: 20),
                _Input(
                  controller: nicknameTextController,
                  onChanged: (value) {
                    setState(() {
                      nicknameTextController.text = value;
                    });
                  },
                  labelText: '닉네임',
                  hintText: '닉네임',
                ),
                _Input(
                  controller: emailTextController,
                  labelText: '이메일',
                  hintText: '이메일',
                  readOnly: true,
                ),
                const Expanded(
                  child: SizedBox(),
                ),
                DefaultElevatedButton(
                  onPressed: widget.imageUrl == imageUrl &&
                          widget.userName == nicknameTextController.text
                      ? null
                      // : _editProfile,
                      : () {},
                  text: '수정하기',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editProfile() async {
    DefaultLoadingOverlay.showLoading(context);

    if (widget.imageUrl != imageUrl) {
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(imageUrl);
    }

    if (widget.userName != nicknameTextController.text) {
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
            this.context.pop();
          },
        );
      },
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String labelText;
  final String? hintText;
  final bool readOnly;

  const _Input({
    this.controller,
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
          onChanged: onChanged,
          labelText: labelText,
          hintText: hintText,
          readOnly: readOnly,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
