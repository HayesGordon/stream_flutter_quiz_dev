import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_quiz_app/controllers/auth_controller.dart';
import 'package:stream_quiz_app/controllers/game.controller.dart';
import 'package:stream_quiz_app/models/quiz_result.dart';
import 'package:stream_quiz_app/repositories/quiz_repository.dart';
import 'package:stream_quiz_app/widgets/widgets.dart';
import 'package:collection/collection.dart';

import '../models/models.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final StreamMessageInputController _messageInputController =
      StreamMessageInputController();

  final GameController gameController = GameController();

  @override
  void dispose() {
    _messageInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: gameController,
      child: Scaffold(
        appBar: const StreamChannelHeader(),
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamMessageListView(
                messageBuilder: (_, messageDetails, ___, defaultMessageWidget) {
                  bool hasQuiz = false;
                  if (messageDetails.message.attachments.isNotEmpty &&
                      messageDetails.message.attachments[0].type == 'quiz') {
                    hasQuiz = true;
                  }

                  bool isOwner = messageDetails.message.user ==
                      StreamChat.of(context).currentUser;

                  StreamMessageThemeData? theme;
                  if (hasQuiz) {
                    if (isOwner) {
                      theme = StreamChatTheme.of(context).ownMessageTheme;
                    } else {
                      theme = StreamChatTheme.of(context)
                          .otherMessageTheme
                          .copyWith(messageBackgroundColor: Colors.red);
                    }
                  }

                  return defaultMessageWidget.copyWith(
                    showReactions: false,
                    // messageTheme:
                    //     theme?.copyWith(messageBackgroundColor: Colors.red),
                    customAttachmentBuilders: {
                      'quiz': (_, message, attachments) => MessageBackground(
                            child: QuizStartAttachment(
                              message: message,
                              attachment: attachments[0],
                            ),
                          ),
                      'quiz-question': (_, message, attachments) =>
                          MessageBackground(
                            child: QuizQuestionAttachment(
                              attachment: attachments[0],
                              message: message,
                            ),
                          ),
                      'quiz-result': (_, message, attachments) =>
                          MessageBackground(
                            child: QuizResultAttachment(
                              attachment: attachments[0],
                            ),
                          ),
                    },
                    showEditMessage: false,
                    showFlagButton: false,
                    showReactionPickerIndicator: false,
                  );
                },
              ),
            ),
            StreamMessageInput(messageInputController: _messageInputController),
          ],
        ),
      ),
    );
  }
}

/// Widget to display the final quiz result.
class QuizResultAttachment extends StatefulWidget {
  const QuizResultAttachment({
    Key? key,
    required this.attachment,
  }) : super(key: key);

  final Attachment attachment;

  @override
  State<QuizResultAttachment> createState() => _QuizResultAttachmentState();
}

class _QuizResultAttachmentState extends State<QuizResultAttachment> {
  late final quizResult = QuizResult.fromMap(widget.attachment.extraData);
  late final scores = quizResult.scores;
  late final sortedScoreKeys = _organizeResults();

  List<String> _organizeResults() {
    final sorted = scores.keys.toList()
      ..sort((a, b) {
        final scoreA = scores[a]!;
        final scoreB = scores[b]!;
        return scoreA.compareTo(scoreB);
      });
    return sorted.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    _organizeResults();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Quiz Result',
            style: Theme.of(context).textTheme.headline6,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Game: ${quizResult.game.quiz.name}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pos',
                style: Theme.of(context).textTheme.caption,
              ),
              Text(
                'Player',
                style: Theme.of(context).textTheme.caption,
              ),
              Text(
                'Score (${quizResult.game.quiz.questions.length})',
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          ...sortedScoreKeys.map(
            (e) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: UserQuizResult(
                uid: e,
                position: sortedScoreKeys.indexOf(e) + 1,
                score: quizResult.scores[e]!.toDouble(),
              ),
            ),
          )
        ],
      ),
    );
  }
}

/// Display individual [User] quiz result.
class UserQuizResult extends StatelessWidget {
  const UserQuizResult({
    Key? key,
    required this.uid,
    required this.position,
    required this.score,
  }) : super(key: key);

  final String uid;
  final int position;
  final double score;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$position',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        _UserProfilePicture(uid: uid),
        Text(
          score.toStringAsFixed(2),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Display a [User] profile picture from [uid].
class _UserProfilePicture extends StatefulWidget {
  const _UserProfilePicture({
    Key? key,
    required this.uid,
  }) : super(key: key);

  final String uid;

  @override
  State<_UserProfilePicture> createState() => _UserProfilePictureState();
}

class _UserProfilePictureState extends State<_UserProfilePicture> {
  late final user = _getUserFromChannel(widget.uid);

  User? _getUserFromChannel(String uid) {
    final member = StreamChannel.of(context)
        .channel
        .state!
        .members
        .firstWhereOrNull((element) => element.userId == uid);
    return member?.user;
  }

  @override
  Widget build(BuildContext context) {
    return StreamUserAvatar(user: user!);
  }
}

/// Widget to display a quiz question.
class QuizQuestionAttachment extends StatefulWidget {
  const QuizQuestionAttachment({
    Key? key,
    required this.attachment,
    required this.message,
  }) : super(key: key);

  final Attachment attachment;
  final Message message;

  @override
  State<QuizQuestionAttachment> createState() => _QuizQuestionAttachmentState();
}

class _QuizQuestionAttachmentState extends State<QuizQuestionAttachment> {
  late final questionMessage =
      QuestionMessage.fromMap(widget.attachment.extraData);
  late final currentQuestion = game.quiz.questions[questionMessage.question];
  late final gameFuture = getGame();
  late final Game game;

  Future<void> getGame() async {
    if (context.read<GameController>().games[questionMessage.gameID] != null) {
      game = context.read<GameController>().games[questionMessage.gameID]!;
    } else {
      game = await context
          .read<QuizRepository>()
          .getGame(questionMessage.gameID) as Game;
      context.read<GameController>().games[questionMessage.gameID] = game;
    }
  }

  Set<String> answers = {};

  void _onSelect(Option option, bool selected) {
    if (selected) {
      answers.add(option.id);
    } else {
      answers.remove(option.id);
    }
  }

  Reaction? getYourAnsweredReaction() {
    return widget.message.ownReactions
        ?.firstWhereOrNull((element) => element.type == 'answered');
  }

  List<Reaction>? getAnsweredReactions() {
    return widget.message.latestReactions
        ?.where((element) => element.type == 'answered')
        .toList();
  }

  bool _hasAnswered() {
    final reaction = getYourAnsweredReaction();
    if (reaction != null) {
      return true;
    } else {
      return false;
    }
  }

  bool _isOwner() {
    return game.host.uid == context.read<AuthController>().user!.uid;
  }

  bool _isLastQuestion() {
    return questionMessage.question == game.quiz.questions.length - 1;
  }

  Future<void> _onNextOrFinish() async {
    if (_isLastQuestion()) {
      final channel = StreamChannel.of(context).channel;
      await context.read<QuizRepository>().endGame(game.id);
      if (mounted) {
        final results =
            await context.read<QuizRepository>().calulateGameResults(game.id);

        await channel.sendMessage(
          Message(
            attachments: [
              Attachment(
                uploadState: const UploadState.success(),
                type: 'quiz-result',
                extraData: results.toMap(),
              ),
            ],
          ),
        );
      }
    } else {
      await StreamChannel.of(context).channel.sendMessage(
            Message(
              attachments: [
                Attachment(
                  uploadState: const UploadState.success(),
                  type: 'quiz-question',
                  extraData: QuestionMessage(
                    question: questionMessage.question + 1,
                    gameID: questionMessage.gameID,
                  ).toMap(),
                ),
              ],
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: gameFuture,
      builder: ((context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const SizedBox.shrink();
          default:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final hasAnswered = _hasAnswered();
              final reaction = getYourAnsweredReaction();
              List<String?> selectedAnswers = [];
              if (reaction != null &&
                  reaction.extraData.containsKey('answers') &&
                  reaction.extraData['answers'] != null) {
                selectedAnswers = List<String>.from(
                    reaction.extraData['answers'] as List<dynamic>);
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Question ${questionMessage.question + 1}/${game.quiz.questions.length}',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          child: Markdown(
                            shrinkWrap: true,
                            data: currentQuestion.question,
                          ),
                        )),
                  ),
                  ...currentQuestion.options.map(
                    (e) {
                      if (_isOwner()) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('- ${e.value}'),
                          ),
                        );
                      }
                      return _QuizOption(
                        option: e,
                        onSelect: _onSelect,
                        canSelect: !hasAnswered,
                        selectedValue: selectedAnswers.contains(e.id),
                      );
                    },
                  ).toList(),
                  Wrap(
                    children: getAnsweredReactions()?.map((reaction) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: StreamUserAvatar(
                              user: reaction.user!,
                            ),
                          );
                        }).toList() ??
                        [],
                  ),
                  if (!hasAnswered && !_isOwner())
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ActionButton(
                          onPressed: () async {
                            final channel = StreamChannel.of(context).channel;
                            final userId =
                                context.read<AuthController>().user!.uid;
                            await context.read<QuizRepository>().answerQuestion(
                                  gameId: questionMessage.gameID,
                                  userId: userId,
                                  questionNr: questionMessage.question,
                                  answers: answers,
                                );
                            await channel.sendReaction(
                              widget.message,
                              'answered',
                              extraData: {
                                'game_id': questionMessage.gameID,
                                'user_id': userId,
                                'question_nr': questionMessage.question,
                                'answers': answers.toList(),
                              },
                              enforceUnique: true,
                            );
                          },
                          emphasize: true,
                          text: 'answer',
                        ),
                      ),
                    ),
                  if (_isOwner()) ...[
                    const Divider(),
                    Text(
                      'Host controls',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    ActionButton(
                      onPressed: _onNextOrFinish,
                      emphasize: true,
                      text: _isLastQuestion() ? 'Finish Quiz' : 'Next Question',
                    )
                  ]
                ],
              );
            }
        }
      }),
    );
  }
}

typedef QuizOptionCallback = void Function(Option option, bool selected);

class _QuizOption extends StatefulWidget {
  const _QuizOption({
    Key? key,
    required this.option,
    required this.onSelect,
    this.canSelect = true,
    this.selectedValue = false,
  }) : super(key: key);

  final Option option;
  final QuizOptionCallback onSelect;
  final bool canSelect;
  final bool selectedValue;

  @override
  State<_QuizOption> createState() => _QuizOptionState();
}

class _QuizOptionState extends State<_QuizOption> {
  late bool isSelected = widget.selectedValue;

  @override
  void didUpdateWidget(covariant _QuizOption oldWidget) {
    if (widget.selectedValue != oldWidget.selectedValue) {
      isSelected = widget.selectedValue;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isSelected,
          onChanged: widget.canSelect
              ? (value) {
                  setState(() {
                    isSelected = value ?? false;
                  });
                  widget.onSelect(widget.option, isSelected);
                }
              : null,
        ),
        Expanded(child: Text(widget.option.value))
      ],
    );
  }
}

/// Widget to display a quiz attachment.
class QuizStartAttachment extends StatelessWidget {
  const QuizStartAttachment({
    Key? key,
    required this.message,
    required this.attachment,
  }) : super(key: key);

  final Message message;
  final Attachment attachment;

  @override
  Widget build(BuildContext context) {
    final streamChannel = StreamChannel.of(context);
    if (attachment.actions != null && attachment.actions!.isNotEmpty) {
      final command = attachment.extraData['quiz_command'];
      if (command == "play") {
        return QuizAttachmentPlay(
          streamChannel: streamChannel,
          message: message,
        );
      } else {
        return _buildCreateAttachment(streamChannel, context);
      }
    } else {
      return QuizAttachmentGame(
        attachment: attachment,
        message: message,
      );
    }
  }

  Widget _buildCreateAttachment(
      StreamChannelState streamChannel, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Creating',
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: TextButton(
                  onPressed: () {
                    streamChannel.channel.sendAction(message, {
                      'action': 'cancel',
                    });
                  },
                  child: Text(
                    'cancel',
                    style:
                        StreamChatTheme.of(context).textTheme.bodyBold.copyWith(
                              color: StreamChatTheme.of(context)
                                  .colorTheme
                                  .textHighEmphasis
                                  .withOpacity(0.5),
                            ),
                  ),
                ),
              ),
            ),
            Container(
              width: 0.5,
              color: StreamChatTheme.of(context)
                  .colorTheme
                  .textHighEmphasis
                  .withOpacity(0.2),
              height: 50,
            ),
            Container(
              width: 0.5,
              color: StreamChatTheme.of(context)
                  .colorTheme
                  .textHighEmphasis
                  .withOpacity(0.2),
              height: 50,
            ),
            Expanded(
              child: SizedBox(
                height: 50,
                child: TextButton(
                  onPressed: () {
                    streamChannel.channel.sendAction(message, {
                      'action': 'create',
                    });
                  },
                  child: Text(
                    'create',
                    style: TextStyle(
                      color:
                          StreamChatTheme.of(context).colorTheme.accentPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const StreamVisibleFootnote(),
      ],
    );
  }
}

class QuizAttachmentPlay extends StatefulWidget {
  const QuizAttachmentPlay({
    Key? key,
    required this.message,
    required this.streamChannel,
  }) : super(key: key);

  final Message message;
  final StreamChannelState streamChannel;

  @override
  State<QuizAttachmentPlay> createState() => _QuizAttachmentPlayState();
}

class _QuizAttachmentPlayState extends State<QuizAttachmentPlay> {
  late final futureQuizes = context.read<QuizRepository>().getUserQuizes();

  int index = 0;

  void _next(List<Quiz> quizes) {
    if (index + 1 < quizes.length) {
      index++;
    } else {
      index = 0;
    }
    setState(() {});
  }

  Future<void> _play(Quiz quiz) async {
    final gameId = await context.read<QuizRepository>().createGame(
        Player.fromFirebaseUser(context.read<AuthController>().user!), quiz.id);
    await widget.streamChannel.channel.sendAction(
      widget.message,
      {
        'action': 'play',
        'game_id': gameId,
        'quiz_id': quiz.id,
        'quiz_name': quiz.name,
        'quiz_questions_count': quiz.questions.length.toString(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Quiz>>(
      future: futureQuizes,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final quizes = snapshot.data;
              if (quizes?.isEmpty ?? true) {
                return const Text('You have not created any quizes');
              } else {
                final quiz = quizes![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        quiz.name,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Questions: ${quiz.questions.length}',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'ID: ${quiz.id}',
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              ?.copyWith(overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ActionButton(
                              onPressed: () {
                                widget.streamChannel.channel
                                    .sendAction(widget.message, {
                                  'action': 'cancel',
                                });
                              },
                              text: 'cancel',
                            ),
                          ),
                          Container(
                            width: 0.5,
                            color: StreamChatTheme.of(context)
                                .colorTheme
                                .textHighEmphasis
                                .withOpacity(0.2),
                            height: 50,
                          ),
                          Expanded(
                            child: ActionButton(
                                onPressed: () {
                                  _next(quizes);
                                },
                                text: 'next'),
                          ),
                          Container(
                            width: 0.5,
                            color: StreamChatTheme.of(context)
                                .colorTheme
                                .textHighEmphasis
                                .withOpacity(0.2),
                            height: 50,
                          ),
                          Expanded(
                            child: ActionButton(
                              onPressed: () {
                                _play(quiz);
                              },
                              text: 'play',
                              emphasize: true,
                            ),
                          ),
                        ],
                      ),
                      const StreamVisibleFootnote(),
                    ],
                  ),
                );
              }
            }
        }
      },
    );
  }
}

class QuizAttachmentGame extends StatefulWidget {
  const QuizAttachmentGame({
    Key? key,
    required this.attachment,
    required this.message,
  }) : super(key: key);

  final Attachment attachment;
  final Message message;

  @override
  State<QuizAttachmentGame> createState() => _QuizAttachmentGameState();
}

class _QuizAttachmentGameState extends State<QuizAttachmentGame> {
  late final gameId = widget.attachment.extraData['game_id'] as String;
  late final quizId = widget.attachment.extraData['quiz_id'] as String;
  late final quizName = widget.attachment.extraData['quiz_name'] as String?;
  late final quizQuestionCount =
      widget.attachment.extraData['quiz_questions_count'] as String;

  late final Stream<Game> gameStream =
      context.read<QuizRepository>().gameStream(gameId);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Quiz',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  quizName ?? 'No name',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Questions: $quizQuestionCount',
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            ),
            StreamBuilder<Game>(
              stream: gameStream,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());
                  default:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final game = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            _Players(game: game),
                            if (game.completed) const Text('Game completed'),
                            if (game.started && !game.completed)
                              const Text('Game has started'),
                            if (snapshot.data!.host.uid ==
                                context.read<AuthController>().user!.uid)
                              _AdminControls(game: game),
                          ],
                        ),
                      );
                    }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Players extends StatefulWidget {
  const _Players({
    Key? key,
    required this.game,
  }) : super(key: key);

  final Game game;

  @override
  State<_Players> createState() => __PlayersState();
}

class __PlayersState extends State<_Players> {
  late final Stream<List<Player>> playerStream =
      context.read<QuizRepository>().gamePlayerStream(widget.game.id);

  bool _hasUserJoined(List<Player> players, String currentUserId) {
    final player =
        players.firstWhereOrNull((player) => player.uid == currentUserId);
    if (player != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthController>().user!;
    return StreamBuilder<List<Player>>(
      stream: playerStream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final players = snapshot.data ?? [];

              return Column(
                children: [
                  if (!_hasUserJoined(players, currentUser.uid) &&
                      widget.game.host.uid != currentUser.uid)
                    ActionButton(
                      onPressed: () async {
                        final quizRepo = context.read<QuizRepository>();
                        final gameController = context.read<GameController>();
                        await quizRepo.joinGame(
                          gameId: widget.game.id,
                          user: Player.fromFirebaseUser(
                              context.read<AuthController>().user!),
                        );
                        gameController.games[widget.game.id] = widget.game;
                      },
                      emphasize: true,
                      text: 'join',
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Players (${players.length})',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                  Wrap(
                    children: players
                        .map((e) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _UserProfilePicture(uid: e.uid),
                            ))
                        .toList(),
                  ),
                ],
              );
            }
        }
      },
    );
  }
}

// class _PlayerAvatar extends StatelessWidget {
//   const _PlayerAvatar({
//     Key? key,
//     required this.player,
//   }) : super(key: key);

//   final Player player;

//   @override
//   Widget build(BuildContext context) {
//     final image = player.photoUrl;
//     if (image != null) {
//       return CircleAvatar(
//         backgroundImage: Image.network(image).image,
//       );
//     }
//     return const Icon(Icons.person);
//   }
// }

class _AdminControls extends StatelessWidget {
  const _AdminControls({
    Key? key,
    required this.game,
  }) : super(key: key);

  final Game game;

  @override
  Widget build(BuildContext context) {
    if (game.started & !game.completed) {
      return ActionButton(
        onPressed: () async {
          await context.read<QuizRepository>().endGame(game.id);
        },
        text: 'end game',
        emphasize: true,
      );
    } else if (!game.completed) {
      return ActionButton(
        onPressed: () async {
          final channel = StreamChannel.of(context).channel;
          await context.read<QuizRepository>().startGame(game.id);
          await channel.sendMessage(
            Message(
              attachments: [
                Attachment(
                  uploadState: const UploadState.success(),
                  type: 'quiz-question',
                  extraData:
                      QuestionMessage(question: 0, gameID: game.id).toMap(),
                ),
              ],
            ),
          );
        },
        text: 'start game',
        emphasize: true,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
