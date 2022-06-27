import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_quiz_app/controllers/quiz_editor_controller.dart';
import 'package:stream_quiz_app/models/models.dart';
import 'package:stream_quiz_app/repositories/quiz_repository.dart';

class QuizEditorPage extends StatefulWidget {
  const QuizEditorPage({
    Key? key,
    this.quizState,
  }) : super(key: key);

  /// Optional quiz value. To edit an already existing quiz;
  final QuizEditorState? quizState;

  @override
  State<QuizEditorPage> createState() => _QuizEditorPageState();
}

class _QuizEditorPageState extends State<QuizEditorPage> {
  late final QuizEditorController _quizController = QuizEditorController(
    state: widget.quizState,
    repository: context.read<QuizRepository>(),
  );

  @override
  void dispose() {
    super.dispose();
    _quizController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QuizEditorController>.value(
      value: _quizController,
      child: Builder(builder: (context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Create New Quiz'),
            ),
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints.loose(const Size.fromWidth(600)),
                        child: const QuizNameTextField(),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Row(
                      children: [
                        Text(
                          'Questions',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        const Spacer(),
                        const _SaveButton(),
                      ],
                    ),
                  ),
                ),
                const QuestionsSection(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: ElevatedButton(
                        onPressed: () {
                          context.read<QuizEditorController>().addNewQuestion();
                        },
                        child: const Text('Add question')),
                  ),
                ),
                const SliverFillRemaining(),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPublished = context
        .select<QuizEditorController, bool>((quiz) => quiz.state.isPublished);

    String text = isPublished ? 'Save' : 'Publish';
    return ElevatedButton(
      onPressed: () {
        context.read<QuizEditorController>().saveChanges();
      },
      child: Text(text),
    );
  }
}

class QuizNameTextField extends StatefulWidget {
  const QuizNameTextField({
    Key? key,
  }) : super(key: key);

  @override
  State<QuizNameTextField> createState() => _QuizNameTextFieldState();
}

class _QuizNameTextFieldState extends State<QuizNameTextField> {
  late final TextEditingController _nameTextController = TextEditingController(
      text: context.read<QuizEditorController>().state.name);

  @override
  void dispose() {
    super.dispose();
    _nameTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _nameTextController,
      decoration: const InputDecoration(
        hintText: 'Quiz Name',
      ),
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
      onChanged: (value) {
        context.read<QuizEditorController>().state.name = value;
      },
    );
  }
}

class QuestionsSection extends StatelessWidget {
  const QuestionsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quizEditorState = context.watch<QuizEditorController>().state;
    final questions = quizEditorState.questions;
    return SliverPadding(
      padding: const EdgeInsets.only(right: 32.0),
      sliver: SliverReorderableList(
        itemBuilder: (context, index) {
          return Row(
            key: ValueKey(questions[index].id),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 16.0, left: 16, right: 16),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '$index.',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Icon(Icons.drag_handle),
                      ],
                    ),
                  )),
              Expanded(
                child: _QuestionWidget(
                  question: questions[index],
                  index: index,
                ),
              ),
            ],
          );
        },
        itemCount: questions.length,
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) newIndex--;
          final item = questions.removeAt(oldIndex);
          questions.insert(newIndex, item);
        },
      ),
    );
  }
}

class _QuestionWidget extends StatefulWidget {
  const _QuestionWidget({
    Key? key,
    required this.question,
    required this.index,
  }) : super(key: key);

  final Question question;
  final int index;

  @override
  State<_QuestionWidget> createState() => __QuestionWidgetState();
}

class __QuestionWidgetState extends State<_QuestionWidget> {
  late final TextEditingController _questionTextController =
      TextEditingController(text: widget.question.question);

  @override
  void dispose() {
    super.dispose();
    _questionTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _questionTextController,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Input question'),
            onChanged: (value) {
              widget.question.question = value;
            },
          ),
          ReorderableList(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final option = widget.question.options[index];
              return Row(
                key: ValueKey(option),
                children: [
                  ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_indicator_outlined)),
                  Expanded(
                    child: _OptionWidget(
                      option: option,
                      questionId: widget.question.id,
                    ),
                  ),
                ],
              );
            },
            itemCount: widget.question.options.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;

              final item = widget.question.options.removeAt(oldIndex);
              widget.question.options.insert(newIndex, item);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16),
            child: ElevatedButton(
              onPressed: () {
                context
                    .read<QuizEditorController>()
                    .addNewOption(widget.question.id);
              },
              child: const Text('Add option'),
            ),
          )
        ],
      ),
    );
  }
}

class _OptionWidget extends StatefulWidget {
  const _OptionWidget({
    Key? key,
    required this.option,
    required this.questionId,
  }) : super(key: key);

  final Option option;
  final String questionId;

  @override
  State<_OptionWidget> createState() => _OptionWidgetState();
}

class _OptionWidgetState extends State<_OptionWidget> {
  late final TextEditingController _optionTextController =
      TextEditingController(text: widget.option.value);

  @override
  void dispose() {
    _optionTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        title: TextField(
          maxLines: 4,
          controller: _optionTextController,
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (value) {
            widget.option.value = value;
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                    onTap: () {
                      context
                          .read<QuizEditorController>()
                          .removeOption(widget.questionId, widget.option.id);
                    },
                    child: const Icon(Icons.delete)),
              ),
            ),
            Checkbox(
              value: widget.option.isChecked,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  widget.option.isChecked = value;
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
