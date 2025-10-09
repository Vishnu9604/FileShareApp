import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device.dart';
import '../models/file_transfer.dart';
import '../providers/history_provider.dart';

class FileTransferService {
  final Ref ref;

  FileTransferService(this.ref);

  Future<void> sendFile(Device device, FileTransfer file) async {
    // TODO: Implement actual file transfer logic here
    // This is a placeholder for sending file to the device
    await Future.delayed(const Duration(seconds: 2));
    print('Sending file ${file.name} to device ${device.name}');

    // After sending, add to history
    final transferWithHistory = file.copyWith(
      status: FileTransferStatus.completed,
      timestamp: DateTime.now(),
      direction: TransferDirection.sent,
      deviceName: device.name,
    );
    ref.read(historyProvider.notifier).addTransfer(transferWithHistory);
  }
}

final fileTransferServiceProvider = Provider<FileTransferService>((ref) {
  return FileTransferService(ref);
});
