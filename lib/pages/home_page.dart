import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_quiz_app/controllers/auth_controller.dart';
import 'package:stream_quiz_app/controllers/quiz_editor_controller.dart';
import 'package:stream_quiz_app/models/models.dart';
import 'package:stream_quiz_app/pages/chat_page.dart';
import 'package:stream_quiz_app/pages/quiz_editor_page.dart';
import 'package:stream_quiz_app/repositories/quiz_repository.dart';
import 'package:stream_quiz_app/routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final _controller = StreamChannelListController(
    client: StreamChat.of(context).client,
    filter: Filter.in_(
      'members',
      [StreamChat.of(context).currentUser!.id],
    ),
    sort: const [SortOption('last_message_at')],
  );

  final _pageController = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stream Quiz App'),
        actions: [
          TextButton(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white)),
            onPressed: () {
              context.read<AuthController>().signOut();
            },
            child: const Text('Sign out'),
          )
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: [
          StreamChannelListView(
            controller: _controller,
            onChannelTap: (channel) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StreamChannel(
                  channel: channel,
                  child: const ChatPage(),
                ),
              ),
            ),
          ),
          const _QuizList()
        ],
      ),
      bottomNavigationBar: _BottomBar(pageController: _pageController),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if ((_pageController.page ?? 0) > 0) {
            print('go');
            context.push(AppRoutes.newQuiz);
          } else {
            context.push(AppRoutes.chatUsers);
            print('test');
          }
        },
        // backgroundColor:
        //     (_pageController.page ?? 0) > 0 ? Colors.green : Colors.red,
        // foregroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BottomBar extends StatefulWidget {
  const _BottomBar({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  final PageController pageController;

  @override
  State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> {
  int index = 0;

  void _onTap(int newIndex) {
    widget.pageController.animateToPage(
      newIndex,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
    setState(() {
      index = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: _onTap,
      currentIndex: index,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.question_mark), label: 'Quizes'),
      ],
    );
  }
}

class _QuizList extends StatefulWidget {
  const _QuizList({Key? key}) : super(key: key);

  @override
  State<_QuizList> createState() => _QuizListState();
}

class _QuizListState extends State<_QuizList> {
  late final quizes = getAllQuizes();
  late final stream = context.read<QuizRepository>().yourQuizesStream();

  Future<List<Quiz>> getAllQuizes() {
    return context.read<QuizRepository>().getUserQuizes();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Quiz>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final quizes = snapshot.data!;
        if (quizes.isEmpty) {
          return const Center(
            child: Text('Make your first quiz'),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: ListView.builder(
            itemCount: quizes.length,
            itemBuilder: (context, index) => _QuizItem(
              key: ValueKey(quizes[index].id),
              quiz: quizes[index],
            ),
          ),
        );
      },
    );
  }
}

class _QuizItem extends StatelessWidget {
  const _QuizItem({
    Key? key,
    required this.quiz,
  }) : super(key: key);

  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return QuizEditorPage(
                quizState: QuizEditorState.fromQuiz(quiz),
              );
            },
          ),
        );
      },
      title: Text(quiz.name),
      subtitle: Text('Questions: ${quiz.questions.length}'),
      trailing: MouseRegion(
        child: GestureDetector(
          onTap: () {
            context.read<QuizRepository>().deleteQuiz(quiz);
          },
          child: const Icon(Icons.delete),
        ),
      ),
    );
  }
}
