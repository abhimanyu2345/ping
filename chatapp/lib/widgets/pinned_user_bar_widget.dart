import 'package:chatapp/state_management/riverpods.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chatapp/data/models/user_data_provider.dart';
import 'package:chatapp/data/models/pinned_menu_controller.dart';
import 'package:chatapp/data/models/pinned_users_model.dart';
import 'package:chatapp/pages/chat_page.dart';

class PinnedUserBarWidget extends ConsumerWidget {
  const PinnedUserBarWidget({super.key});

 @override
Widget build(BuildContext context, WidgetRef ref) {
  final pinnedUsersAsync = ref.watch(PinnedUsersModelProvider);
  final profileMap = ref.watch(userDataProvider);
  final pinnedSet = ref.watch(pinnedDataProvider);
  final pinningRef = ref.read(pinnedDataProvider.notifier);

  return pinnedUsersAsync.when(
    loading: () => const SizedBox(),
    error: (e, _) => Text('Error: $e'),
    data: (pinnedUsers) {
      if (pinnedUsers.isEmpty) return const SizedBox();
      final pinnedList = pinnedUsers.toList();
      return SizedBox(
        height: kToolbarHeight * 2.3,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: pinnedList.length,
          itemBuilder: (context, index) {
            final userProfile = profileMap[pinnedList[index]];
            if (userProfile == null) return const SizedBox();

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            chatee: userProfile,
                            chatId: ref.read(chatProvider.notifier).fetchUserChatId(userProfile.id),
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      pinningRef.togglePinMode(false);
                      pinningRef.addToMenu(userProfile.id);
                    },
                    child: Card(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 35,
                              child: userProfile.imageBytes != null
                                  ? Image.memory(userProfile.imageBytes!)
                                  : const Icon(Icons.person),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userProfile.tagName,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (pinnedSet.selectedIds.contains(userProfile.id))
                  const Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(Icons.check_circle, color: Colors.lightGreenAccent),
                  ),
              ],
            );
          },
        ),
      );
    },
  );
}

}
