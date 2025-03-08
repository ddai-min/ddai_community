import 'package:flutter/material.dart';

class DefaultAvatar extends StatelessWidget {
  final Image? image;
  final double? width;
  final double? height;

  const DefaultAvatar({
    super.key,
    this.image,
    this.width = 50,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CircleAvatar(
        backgroundImage: image != null
            ? image!.image
            : Image.asset(
                'asset/img/avatar_default.png',
              ).image,
        backgroundColor: Colors.grey[300],
      ),
    );
  }
}
