import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chatapp/data/models/pinned_users_model.dart';

final pinnedDataProvider = NotifierProvider<PinnedMenuController, PinnedMenuState>(
  () => PinnedMenuController(),
);

class PinnedMenuState {
  final Set<String> selectedIds;
  final bool? isPinning; // true for pin, false for unpin, null = idle
  final bool isMenuOpen;

  PinnedMenuState({
    required this.selectedIds,
    required this.isPinning,
    required this.isMenuOpen,
  });

  factory PinnedMenuState.initial() =>
      PinnedMenuState(selectedIds: {}, isPinning: null, isMenuOpen: false);

  PinnedMenuState copyWith({
    Set<String>? selectedIds,
    bool? isPinning,
    bool? isMenuOpen,
  }) {
    return PinnedMenuState(
      selectedIds: selectedIds ?? this.selectedIds,
      isPinning: isPinning ?? this.isPinning,
      isMenuOpen: isMenuOpen ?? this.isMenuOpen,
    );
  }
}

class PinnedMenuController extends Notifier<PinnedMenuState> {
  @override
  PinnedMenuState build() => PinnedMenuState.initial();

  void togglePinMode(bool pinning) {
    state = state.copyWith(
      isPinning: pinning,
      isMenuOpen: true,
      selectedIds: {},
    );
  }

  void addToMenu(String id) {
    state = state.copyWith(
      selectedIds: {...state.selectedIds, id},
    );
  }

  void removeFromMenu(String id) {
    final updated = {...state.selectedIds}..remove(id);
    state = state.copyWith(selectedIds: updated);
  }

  void applyPin() {
    ref.read(PinnedUsersModelProvider.notifier).addToPin(state.selectedIds.toList());
    closeMenu();
  }

  void removePin() {
    ref.read(PinnedUsersModelProvider.notifier).removeFromPin(state.selectedIds.toList());
    closeMenu();
  }

  void closeMenu() {
    state = PinnedMenuState.initial();
  }
  bool contains(String id){
    return state.selectedIds.contains(id);
  }
}
