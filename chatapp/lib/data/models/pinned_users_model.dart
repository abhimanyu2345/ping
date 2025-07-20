import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


final PinnedUsersModelProvider = AsyncNotifierProvider<PinnedUsersAsync, Set<String>>(
  () => PinnedUsersAsync(),
);

class PinnedUsersAsync extends AsyncNotifier<Set<String>> {
  final _SHARED_PREF_STRING = 'PINNED_CHATS';

  @override
  Future<Set<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_SHARED_PREF_STRING);
    return data?.toSet() ?? {};
  }

  Future<void> addToPin(List<String> ids) async {
    final updated = {...state.valueOrNull ?? {}, ...ids};
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_SHARED_PREF_STRING, updated.toList());
  }

  Future<void> removeFromPin(List<String> ids) async {
    final updated = (state.valueOrNull ?? {}).where((e) => !ids.contains(e)).toSet();
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_SHARED_PREF_STRING, updated.toList());
  }
}
