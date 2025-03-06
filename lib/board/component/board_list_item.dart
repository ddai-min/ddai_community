import 'package:ddai_community/common/const/colors.dart';
import 'package:flutter/material.dart';

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
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          content,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
