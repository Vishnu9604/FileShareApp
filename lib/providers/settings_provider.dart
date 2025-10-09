import 'package:flutter_riverpod/flutter_riverpod.dart';

class Settings {
  bool autoAcceptTransfers;
  bool encryptTransfers;

  Settings({
    this.autoAcceptTransfers = false,
    this.encryptTransfers = false,
  });

  Settings copyWith({
    bool? autoAcceptTransfers,
    bool? encryptTransfers,
  }) {
    return Settings(
      autoAcceptTransfers: autoAcceptTransfers ?? this.autoAcceptTransfers,
      encryptTransfers: encryptTransfers ?? this.encryptTransfers,
    );
  }
}

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier() : super(Settings());

  void setAutoAcceptTransfers(bool value) {
    state = state.copyWith(autoAcceptTransfers: value);
  }

  void setEncryptTransfers(bool value) {
    state = state.copyWith(encryptTransfers: value);
  }

  Future<void> clearHistory() async {
    // TODO: Implement clear history logic
    // For now, just reset settings or handle history clearing
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  return SettingsNotifier();
});
