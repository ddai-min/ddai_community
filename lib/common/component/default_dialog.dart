import 'package:ddai_community/common/component/default_elevated_button.dart';
import 'package:flutter/material.dart';

class DefaultDialog extends StatelessWidget {
  final String contentText;
  final String buttonText;
  final VoidCallback onPressed;
  final double height;
  final double width;
  final TextStyle contentTextStyle;

  const DefaultDialog({
    super.key,
    required this.contentText,
    required this.buttonText,
    required this.onPressed,
    this.height = 150,
    this.width = 0,
    this.contentTextStyle = const TextStyle(
      fontSize: 20.0,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: height,
          width: width == 0 ? MediaQuery.of(context).size.width * 0.8 : width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                contentText,
                textAlign: TextAlign.center,
                style: contentTextStyle,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DefaultElevatedButton(
                      onPressed: onPressed,
                      text: buttonText,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
