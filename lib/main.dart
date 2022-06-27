import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_quiz_app/controllers/auth_controller.dart';
import 'package:stream_quiz_app/firebase_options.dart';
import 'package:stream_quiz_app/pages/chat_users_page.dart';
import 'package:stream_quiz_app/pages/error_page.dart';
import 'package:stream_quiz_app/pages/home_page.dart';
import 'package:stream_quiz_app/pages/loading_page.dart';
import 'package:stream_quiz_app/pages/quiz_editor_page.dart';
import 'package:stream_quiz_app/pages/sign_in_page.dart';
import 'package:stream_quiz_app/repositories/quiz_repository.dart';
import 'package:stream_quiz_app/routes.dart';

import 'repositories/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const StreamQuizApp());
}

class StreamQuizApp extends StatefulWidget {
  const StreamQuizApp({Key? key}) : super(key: key);

  @override
  State<StreamQuizApp> createState() => _StreamQuizAppState();
}

class _StreamQuizAppState extends State<StreamQuizApp> {
  final authRepository = AuthRepository();
  final quizRepository = QuizRepository();
  final client = StreamChatClient('zgcaa47zh79p');
  late final AuthController authController;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        print(
            'forcing setstate'); // TODO investigate. Otherwise gorouter keeps loading
      });
    });
    authController = AuthController(
        authRepository: authRepository, streamChatClient: client);
    _router = GoRouter(
      errorBuilder: (context, state) => ErrorPage(exception: state.error),
      refreshListenable: authController,
      initialLocation: AppRoutes.login,
      redirect: (state) {
        print('something');
        final loggedIn = authController.user != null;
        final loggingIn = state.subloc == AppRoutes.login;
        if (!loggedIn) return loggingIn ? null : AppRoutes.login;

        // if the user is logged in but still on the login page, send them to
        // the home page
        if (loggingIn) return AppRoutes.home;

        // no need to redirect at all
        return null;
      },
      navigatorBuilder: (context, state, child) {
        if (authController.isLoading) return const LoadingPage();
        return child;
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const SignInPage(),
        ),
        GoRoute(
          path: AppRoutes.chatUsers,
          builder: (context, state) => const ChatUsersPage(),
        ),
        GoRoute(
          path: AppRoutes.newQuiz,
          builder: (context, state) => const QuizEditorPage(),
        ),
      ],
    );
  }

  late GoRouter _router;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: authRepository),
        Provider.value(value: quizRepository),
        ChangeNotifierProvider.value(value: authController),
      ],
      child: MaterialApp.router(
        builder: (context, child) {
          return StreamChat(
            client: client,
            child: child!,
          );
        },
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        routeInformationProvider: _router.routeInformationProvider,
      ),
    );
  }
}
