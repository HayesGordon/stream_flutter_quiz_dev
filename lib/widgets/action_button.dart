import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.emphasize = false,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: emphasize
            ? TextStyle(
                color: StreamChatTheme.of(context).colorTheme.accentPrimary,
                fontWeight: FontWeight.bold,
              )
            : StreamChatTheme.of(context).textTheme.bodyBold.copyWith(
                  color: StreamChatTheme.of(context)
                      .colorTheme
                      .textHighEmphasis
                      .withOpacity(0.5),
                ),
        maxLines: 1,
      ),
    );
  }
}
