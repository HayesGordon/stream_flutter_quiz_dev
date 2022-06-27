import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:provider/provider.dart';
import 'package:stream_quiz_app/repositories/auth_repository.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material App Bar'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SignInButton(Buttons.Google, onPressed: () {
                context.read<AuthRepository>().signInWithGoogle();
              }),
              // ElevatedButton(
              //     onPressed: () async {
              //       final authRepo = context.read<AuthRepository>();
              //       await authRepo.dummyRegisterStream(StreamDemoUsers.sahil);
              //       await authRepo.getToken();
              //     },
              //     child: const Text('Register Sahil')),
              // ElevatedButton(
              //     onPressed: () async {
              //       final authRepo = context.read<AuthRepository>();
              //       await authRepo.dummySignInStream(StreamDemoUsers.sahil);
              //       await authRepo.getToken();
              //     },
              //     child: const Text('Sign in Sahil')),
              // const Divider(),
              // Text(
              //   'Development',
              //   style: Theme.of(context).textTheme.caption,
              // ),
              // ElevatedButton(
              //     onPressed: () async {
              //       final authRepo = context.read<AuthRepository>();
              //       await authRepo.dummyRegister();
              //       await authRepo.getToken();
              //     },
              //     child: const Text('Register dummy')),
              // ElevatedButton(
              //     onPressed: () async {
              //       final authRepo = context.read<AuthController>();
              //       await authRepo.dummySignIn();
              //     },
              //     child: const Text('Sign in with dummy')),
              // ElevatedButton(
              //     onPressed: () async {
              //       final authRepo = context.read<AuthController>();
              //       await authRepo.dummySignIn2();
              //     },
              //     child: const Text('Sign in with dummy2')),
              // ElevatedButton(
              //   onPressed: () {
              //     context.read<AuthRepository>().signInAnonymously();
              //   },
              //   child: const Text('Anonymous'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
