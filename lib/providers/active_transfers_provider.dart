import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_transfer.dart';

class ActiveTransfersNotifier extends StateNotifier<List<FileTransfer>> {
  ActiveTransfersNotifier() : super([]);

  void addTransfer(FileTransfer transfer) {
    state = [...state, transfer];
  }

  void updateTransfer(String id, FileTransfer updatedTransfer) {
    state = state.map((t) => t.id == id ? updatedTransfer : t).toList();
  }

  void removeTransfer(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  void clearCompleted() {
    state = state.where((t) => t.status != FileTransferStatus.completed).toList();
  }
}

final activeTransfersProvider = StateNotifierProvider<ActiveTransfersNotifier, List<FileTransfer>>((ref) => ActiveTransfersNotifier());
