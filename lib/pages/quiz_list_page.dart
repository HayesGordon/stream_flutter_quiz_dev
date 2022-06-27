import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stream_quiz_app/controllers/quiz_editor_controller.dart';
import 'package:stream_quiz_app/models/models.dart';
import 'package:stream_quiz_app/pages/quiz_editor_page.dart';
import 'package:stream_quiz_app/repositories/quiz_repository.dart';
import 'package:stream_quiz_app/routes.dart';

class QuizListPage extends StatelessWidget {
  const QuizListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Quizes'),
      ),
      body: const _QuizList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.newQuiz),
        child: const Icon(Icons.add),
      ),
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
