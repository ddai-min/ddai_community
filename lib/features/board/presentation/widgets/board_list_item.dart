import 'package:ddai_community/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// 게시판 목록의 게시글 한 줄.
///
/// 제목과 내용을 한 줄로 말줄임 처리해 보여준다.
class BoardListItem extends StatelessWidget {
  final String title;
  final String content;
  final GestureTapCallback onTap;

  const BoardListItem({
    super.key,
    required this.title,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
