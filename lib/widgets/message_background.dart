import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class MessageBackground extends StatelessWidget {
  const MessageBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: StreamChatTheme.of(context).ownMessageTheme.messageBackgroundColor,
      child: child,
    );
  }
}
