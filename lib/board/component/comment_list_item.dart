import 'package:ddai_community/board/model/board_model.dart';
import 'package:ddai_community/common/component/default_avatar.dart';
import 'package:flutter/material.dart';

class CommentListItem extends StatelessWidget {
  final CommentModel commentModel;

  const CommentListItem({
    super.key,
    required this.commentModel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          DefaultAvatar(
            image: _renderAvatarImage(
              imageUrl: commentModel.imageUrl,
            ),
          ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                commentModel.userName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(commentModel.content),
            ],
          ),
        ],
      ),
    );
  }

  Image? _renderAvatarImage({
    String? imageUrl,
  }) {
    if (imageUrl != null) {
      return Image.network(imageUrl);
    } else {
      return null;
    }
  }
}
