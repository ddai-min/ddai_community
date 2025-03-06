import 'package:flutter/material.dart';

class DefaultAvatar extends StatelessWidget {
  final Image? image;

  const DefaultAvatar({
    super.key,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: image != null
          ? image!.image
          : Image.asset(
              'asset/img/avatar_default.png',
            ).image,
      backgroundColor: Colors.grey[300],
    );
  }
}
