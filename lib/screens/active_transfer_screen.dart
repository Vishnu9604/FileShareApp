import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/active_transfers_provider.dart';
import '../models/file_transfer.dart';

class ActiveTransferScreen extends ConsumerWidget {
  const ActiveTransferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTransfers = ref.watch(activeTransfersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Transfers'),
        backgroundColor: Colors.deepPurple,
        elevation: 6,
        shadowColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              ref.read(activeTransfersProvider.notifier).clearCompleted();
            },
            tooltip: 'Clear Completed',
          ),
        ],
      ),
      body: activeTransfers.isEmpty
          ? const Center(
              child: Text('No active transfers'),
            )
          : ListView.builder(
              itemCount: activeTransfers.length,
              itemBuilder: (context, index) {
                final transfer = activeTransfers[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Icon(
                      transfer.direction == TransferDirection.sent ? Icons.send : Icons.download,
                      color: Colors.deepPurple,
                    ),
                    title: Text(transfer.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${transfer.status.name}'),
                        if (transfer.status == FileTransferStatus.transferring)
                          LinearProgressIndicator(value: transfer.progress),
                        Text('${(transfer.progress * 100).toStringAsFixed(1)}%'),
                      ],
                    ),
                    trailing: transfer.status == FileTransferStatus.completed
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : transfer.status == FileTransferStatus.failed
                            ? const Icon(Icons.error, color: Colors.red)
                            : const Icon(Icons.sync, color: Colors.blue),
                  ),
                );
              },
            ),
    );
  }
}
