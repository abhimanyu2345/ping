import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_platform/universal_platform.dart';

import 'package:chatapp/widgets/chat_widget.dart';
import 'package:chatapp/widgets/pinned_user_bar_widget.dart';
import 'package:chatapp/widgets/search_widget.dart';
import 'package:chatapp/state_management/riverpods.dart';
import 'package:chatapp/state_management/value_notifers.dart';
import 'package:chatapp/data/models/user_data_provider.dart';
import 'package:chatapp/data/models/pinned_users_model.dart';
import 'package:chatapp/data/models/pinned_menu_controller.dart';
import 'package:chatapp/pages/new_chat_page.dart';
import 'package:chatapp/pages/user_profile_page.dart';

/// ✅ NEW: Initialization provider
final initChatProvider = FutureProvider<void>((ref) async {
  final chatController = ref.read(chatProvider.notifier);
  chatController.build();
  await ref.read(HttpServiceProvider).fetchMessages();

  final chatEntries = ref.read(chatProvider).entries;
  final currentUserId = ref.read(chatProvider.notifier).currentUserId;

  for (var entry in chatEntries) {
    final messages = entry.value;
    if (messages.isEmpty) continue;

    final firstMessage = messages[0];
    final chateeId = (firstMessage.from == currentUserId) ? firstMessage.to : firstMessage.from;

    if (chateeId != null && ref.read(userDataProvider)[chateeId] == null) {
      await ref.read(userDataProvider.notifier).fetchUserProfileData(chateeId);
    }
  }
});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initState = ref.watch(initChatProvider);
    final pinnedSet = ref.watch(PinnedUsersModelProvider);
    final pinningState = ref.watch(pinnedDataProvider);

    final currentUserId = ref.watch(userIdProvider);
    final chatMap = ref.watch(chatProvider);

    return PopScope(
      canPop: !pinningState.isMenuOpen,
      onPopInvoked: (didPop) {
        if (!didPop && pinningState.isMenuOpen) {
          ref.read(pinnedDataProvider.notifier).closeMenu();
        }
      },
      child: initState.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          body: Center(child: Text('Error: $e')),
        ),
        data: (_) {
          return ValueListenableBuilder<Image?>(
            valueListenable: backgroundImage,
            builder: (context, background, __) {
              return Stack(
                children: [
                  if (background != null) Positioned.fill(child: background),
                  SafeArea(
                    child: Scaffold(
                      backgroundColor: background != null
                          ? Colors.transparent
                          : isDark
                              ? Colors.black
                              : Colors.white,
                      appBar: pinningState.isMenuOpen
                          ? AppBar(
                              title: Text(
                                pinningState.isPinning == true
                                    ? 'Pin Profiles'
                                    : 'Unpin Profiles',
                              ),
                              actions: [
                                Text(pinningState.selectedIds.length.toString()),
                                IconButton(
                                  icon: const Icon(Icons.done),
                                  onPressed: () => _handlePin(),
                                ),
                              ],
                            )
                          : AppBar(
                              title: const Text('Connect'),
                              backgroundColor: Colors.black.withAlpha(150),
                              actions: [
                                SearchWidget(onSearched: (query) {}),
                                PopupMenuButton(
                                  icon: const Icon(Icons.more_vert, color: Colors.blue),
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(child: Text('New Group')),
                                    PopupMenuItem(
                                      child: const Text('Profile'),
                                      onTap: () {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const UserProfilePage(),
                                            ),
                                          );
                                        });
                                      },
                                    ),
                                    const PopupMenuItem(child: Text('Settings')),
                                    PopupMenuItem(
                                      child: const Text('Change Background'),
                                      onTap: () async {
                                        final result = await FilePicker.platform.pickFiles(
                                          allowMultiple: false,
                                          type: FileType.image,
                                        );
                                        final path = result?.files.single.path;
                                        if (path != null) {
                                          backgroundImage.value = Image.file(
                                            File(path),
                                            fit: BoxFit.cover,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                      body: Column(
                        children: [
                          const Divider(),
                          pinnedSet.when(
                            data: (pinnedSetData) {
                              return pinnedSetData.isEmpty
                                  ? const SizedBox()
                                  : const PinnedUserBarWidget();
                            },
                            loading: () => const Text('Loading pins...'),
                            error: (e, _) => Text('Error loading pins: $e'),
                          ),
                          Expanded(
                            child: chatMap.isEmpty
                                ? const Center(child: Text('No chats'))
                                : ListView(
                                    children: chatMap.entries.map((entry) {
                                      final messageList = entry.value;
                                      final lastMessage = messageList.last;

                                      final chateeId = lastMessage.from == currentUserId
                                          ? lastMessage.to
                                          : lastMessage.from;

                                      final pinnedIds = pinnedSet.asData?.value ?? {};

                                      if (chateeId == null || pinnedIds.contains(chateeId)) {
                                        return const SizedBox.shrink();
                                      }

                                      final chatee = ref.watch(userDataProvider)[chateeId];

                                      return InkWell(
                                        onLongPress: () {
                                          if (pinningState.isPinning != true) {
                                            ref.read(pinnedDataProvider.notifier).togglePinMode(true);
                                          }
                                          ref.read(pinnedDataProvider.notifier).addToMenu(chateeId);
                                        },
                                        onTap: () {
                                          if (pinningState.isMenuOpen) {
                                            ref.read(pinnedDataProvider.notifier).addToMenu(chateeId);
                                          } else {
                                            // open chat
                                          }
                                        },
                                        child: Stack(
                                          children: [
                                            if (chatee != null)
                                              ChatWidget(
                                                lastMessage: lastMessage,
                                                chatee: chatee,
                                              ),
                                            if (pinningState.selectedIds.contains(chateeId))
                                              const Positioned(
                                                top: 4,
                                                right: 4,
                                                child: Icon(Icons.check_circle,
                                                    color: Colors.greenAccent),
                                              ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                        ],
                      ),
                      floatingActionButton:
                          (UniversalPlatform.isAndroid || UniversalPlatform.isIOS)
                              ? FloatingActionButton(
                                  onPressed: () async {
                                    if (await Permission.contacts.request() ==
                                        PermissionStatus.granted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const NewChatPage(),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Icon(Icons.add),
                                )
                              : null,
                      bottomNavigationBar: NavigationBar(
                        selectedIndex: index,
                        onDestinationSelected: (value) {
                          setState(() => index = value);
                        },
                        destinations: const [
                          NavigationDestination(icon: Icon(Icons.chat_bubble), label: 'Chats'),
                          NavigationDestination(icon: Icon(Icons.history), label: 'Call History'),
                          NavigationDestination(icon: Icon(Icons.person_off), label: 'Tor Mode'),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _handlePin() {
    final pinning = ref.read(pinnedDataProvider.notifier);
    final pinningState = ref.read(pinnedDataProvider);

    if (pinningState.isPinning == true) {
      pinning.applyPin();
    } else if (pinningState.isPinning == false) {
      pinning.removePin();
    }
  }
}
