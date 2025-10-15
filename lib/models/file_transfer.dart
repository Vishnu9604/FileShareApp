enum FileTypeEnum {
  image,
  video,
  audio,
  document,
  other,
}

enum FileTransferStatus {
  pending,
  starting,
  transferring,
  completed,
  failed,
  cancelled,
}

enum TransferDirection {
  sent,
  received,
}

class FileTransfer {
  final String id;
  final String name;
  final String path;
  final int size;
  final FileTypeEnum type;
  final bool selected;

  // New fields for history
  final FileTransferStatus status;
  final DateTime? timestamp;
  final TransferDirection? direction;
  final String? deviceName;

  // New field for progress
  final double progress;

  const FileTransfer({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.type,
    this.selected = false,
    this.status = FileTransferStatus.pending,
    this.timestamp,
    this.direction,
    this.deviceName,
    this.progress = 0.0,
  });

  FileTransfer copyWith({
    String? id,
    String? name,
    String? path,
    int? size,
    FileTypeEnum? type,
    bool? selected,
    FileTransferStatus? status,
    DateTime? timestamp,
    TransferDirection? direction,
    String? deviceName,
    double? progress,
  }) {
    return FileTransfer(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      type: type ?? this.type,
      selected: selected ?? this.selected,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      direction: direction ?? this.direction,
      deviceName: deviceName ?? this.deviceName,
      progress: progress ?? this.progress,
    );
  }
}
