import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_quiz_app/controllers/auth_controller.dart';
import 'package:stream_quiz_app/routes.dart';

class ChatUsersPage extends StatefulWidget {
  const ChatUsersPage({Key? key}) : super(key: key);

  @override
  State<ChatUsersPage> createState() => _ChatUsersPageState();
}

class _ChatUsersPageState extends State<ChatUsersPage> {
  late final StreamUserListController _userListController =
      StreamUserListController(
    client: StreamChat.of(context).client,
    limit: 25,
    filter: Filter.and(
      [Filter.notEqual('id', StreamChat.of(context).currentUser!.id)],
    ),
    sort: [
      const SortOption(
        'name',
        direction: 1,
      ),
    ],
  );

  final Set<User> _selectedUsers = {};

  final TextEditingController _channelNameController = TextEditingController();

  Future<void> _createChannel() async {
    final addName = _channelNameController.text.isNotEmpty;
    final extraData = {
      if (addName) 'name': _channelNameController.text,
      "members": [..._selectedUsers, StreamChat.of(context).currentUser!]
          .map((e) => e.id)
          .toList(),
    };
    final channel = StreamChat.of(context).client.channel(
          'messaging',
          id: _channelNameController.text,
          extraData: extraData,
        );

    await channel.create();
  }

  @override
  void dispose() {
    _userListController.dispose();
    _channelNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              context.read<AuthController>().signOut();
            },
            style: ButtonStyle(
                foregroundColor:
                    MaterialStateColor.resolveWith((states) => Colors.white)),
            child: const Text('Sign out'),
          )
        ],
      ),
      floatingActionButton: (_selectedUsers.isNotEmpty)
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return _createChannelDialog(context);
                    });
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: StreamUserListView(
        controller: _userListController,
        itemBuilder: (context, users, index, userListtile) {
          return userListtile.copyWith(
              selected: _selectedUsers.contains(users[index]));
        },
        onUserTap: (user) {
          setState(() {
            if (_selectedUsers.contains(user)) {
              _selectedUsers.removeWhere((element) => element == user);
            } else {
              _selectedUsers.add(user);
            }
          });
        },
      ),
    );
  }

  Dialog _createChannelDialog(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints.loose(const Size(600, 200)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextField(
                controller: _channelNameController,
                decoration: const InputDecoration(hintText: 'Channel name'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _createChannel();
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  context.go(AppRoutes.home);
                },
                child: const Text('Create channel'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
