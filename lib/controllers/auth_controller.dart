import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_quiz_app/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository authRepository;
  final StreamChatClient streamChatClient;

  AuthController({
    required this.authRepository,
    required this.streamChatClient,
  }) {
    authStateListener = authRepository.authState().listen(_authStateChanged);
  }

  StreamSubscription<auth.User?>? authStateListener;

  bool isLoading = true;
  auth.User? user;
  String? streamToken;

  Future<void> _authStateChanged(auth.User? us) async {
    isLoading = false;
    if (us != null) {
      user = us;
      await _setStreamChatToken();
      notifyListeners();
    }
  }

  Future<void> dummySignIn() async {
    await authRepository.dummySignIn();
    // user = creds.user;
    // streamToken = await authRepository.getToken();
    // notifyListeners();
  }

  Future<void> dummySignIn2() async {
    await authRepository.dummySignIn2();
    // user = creds.user;
    // streamToken = await authRepository.getToken();
    // notifyListeners();
  }

  Future<void> signOut() async {
    await streamChatClient.disconnectUser();
    await authRepository.signOut();
    user = null;
    streamToken = null;
    notifyListeners();
  }

  Future<void> _setStreamChatToken() async {
    streamToken = await authRepository.getToken();
    await Future.delayed(const Duration(milliseconds: 500));
    await streamChatClient.connectUser(
        User(
          id: user!.uid,
          // name: user!.displayName ?? user!.email,
          // image: user?.photoURL,
        ),
        streamToken!);
  }

  @override
  void dispose() {
    authStateListener?.cancel();
    super.dispose();
  }
}
