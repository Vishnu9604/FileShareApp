import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device.dart';
import '../models/file_transfer.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
}

class ConnectionState {
  final ConnectionStatus status;
  final Device? connectedDevice;
  final Map<String, dynamic> transferStatuses;

  const ConnectionState({
    this.status = ConnectionStatus.disconnected,
    this.connectedDevice,
    this.transferStatuses = const {},
  });

  ConnectionState copyWith({
    ConnectionStatus? status,
    Device? connectedDevice,
    Map<String, dynamic>? transferStatuses,
  }) {
    return ConnectionState(
      status: status ?? this.status,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      transferStatuses: transferStatuses ?? this.transferStatuses,
    );
  }
}

class ConnectionNotifier extends StateNotifier<ConnectionState> {
  ConnectionNotifier() : super(const ConnectionState());

  void connectToDevice(Device device) {
    state = state.copyWith(status: ConnectionStatus.connecting, connectedDevice: device);
  }

  void connectionEstablished() {
    state = state.copyWith(status: ConnectionStatus.connected);
  }

  void disconnect() {
    state = const ConnectionState();
  }

  void startFileTransfer(String fileId, String fileName, int fileSize, bool isSending) {
    final newStatuses = Map<String, dynamic>.from(state.transferStatuses);
    newStatuses[fileId] = {
      'fileName': fileName,
      'fileSize': fileSize,
      'isSending': isSending,
      'progress': 0.0,
      'status': 'starting',
    };
    state = state.copyWith(transferStatuses: newStatuses);
  }

  void updateTransferStatus({
    required String fileId,
    required FileTransferStatus status,
    double? progress,
  }) {
    final newStatuses = Map<String, dynamic>.from(state.transferStatuses);
    if (newStatuses.containsKey(fileId)) {
      newStatuses[fileId] = {
        ...newStatuses[fileId],
        'status': status.name,
        if (progress != null) 'progress': progress,
      };
      state = state.copyWith(transferStatuses: newStatuses);
    }
  }
}

final connectionProvider = StateNotifierProvider<ConnectionNotifier, ConnectionState>((ref) {
  return ConnectionNotifier();
});
