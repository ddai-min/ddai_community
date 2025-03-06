import 'package:ddai_community/common/component/default_avatar.dart';
import 'package:flutter/material.dart';

class CommentListItem extends StatelessWidget {
  final String userName;
  final String content;
  final Image? image;

  const CommentListItem({
    super.key,
    required this.userName,
    required this.content,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          DefaultAvatar(
            image: image,
          ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(content),
            ],
          ),
        ],
      ),
    );
  }
}
