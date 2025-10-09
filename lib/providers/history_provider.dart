import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_transfer.dart';

class HistoryNotifier extends StateNotifier<List<FileTransfer>> {
  HistoryNotifier() : super([]);

  void addTransfer(FileTransfer transfer) {
    state = [transfer, ...state];
  }

  void clearHistory() {
    state = [];
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, List<FileTransfer>>((ref) {
  return HistoryNotifier();
});
