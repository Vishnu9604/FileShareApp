import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../models/file_transfer.dart';
import '../providers/history_provider.dart';

class ReceivedHistoryScreen extends ConsumerWidget {
  const ReceivedHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final receivedTransfers = history.where((t) => t.direction == TransferDirection.received).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Files 📥'),
      ),
      body: _buildTransferList(receivedTransfers, 'No received files yet 📥', 'assets/animations/receive_screen.json'),
    );
  }

  Widget _buildTransferList(List<FileTransfer> transfers, String emptyMessage, String animationPath) {
    if (transfers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(animationPath, width: 150, height: 150),
            const SizedBox(height: 20),
            Text(
              emptyMessage,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: transfers.length,
      itemBuilder: (context, index) {
        return _buildTransferTile(transfers[index]);
      },
    );
  }

  Widget _buildTransferTile(FileTransfer transfer) {
    return ListTile(
      leading: Icon(_getIconForFileType(transfer.type)),
      title: Text(transfer.name),
      subtitle: Text(
        '${transfer.deviceName ?? 'Unknown device'} - ${transfer.timestamp != null ? transfer.timestamp!.toLocal().toString().split('.')[0] : 'Unknown time'}',
      ),
      trailing: _buildStatusIcon(transfer.status),
    );
  }

  IconData _getIconForFileType(FileTypeEnum type) {
    switch (type) {
      case FileTypeEnum.image:
        return Icons.image;
      case FileTypeEnum.video:
        return Icons.videocam;
      case FileTypeEnum.audio:
        return Icons.audiotrack;
      case FileTypeEnum.document:
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildStatusIcon(FileTransferStatus status) {
    switch (status) {
      case FileTransferStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case FileTransferStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
      case FileTransferStatus.cancelled:
        return const Icon(Icons.cancel, color: Colors.grey);
      case FileTransferStatus.transferring:
        return const Icon(Icons.sync, color: Colors.blue);
      default:
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
    }
  }
}
