const _home = '/';
const _login = '/login';
// const _register = '/register';
// const _document = '/document';
const _newQuiz = '/newQuiz';
const _quizes = '/quizes';
const _chat = '/chat';
const _chatUsers = '/chatUsers';

abstract class AppRoutes {
  static String get home => _home;
  static String get login => _login;
  static String get newQuiz => _newQuiz;
  static String get quizes => _quizes;
  static String get chat => _chat;
  static String get chatUsers => _chatUsers;
}
