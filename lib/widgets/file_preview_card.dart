import 'dart:io';
import 'package:flutter/material.dart';
import '../models/file_transfer.dart';
import '../utils/constants.dart';

class FilePreviewCard extends StatelessWidget {
  final FileTransfer file;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FilePreviewCard({
    super.key,
    required this.file,
    required this.isSelected,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final fileIcon = _getFileIcon(file.type);
    final fileSize = _formatFileSize(file.size);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(fileIcon, size: 40, color: AppConstants.primaryColor),
        title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(fileSize),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => onTap(),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onRemove,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _getFileIcon(FileTypeEnum type) {
    switch (type) {
      case FileTypeEnum.image:
        return Icons.image;
      case FileTypeEnum.video:
        return Icons.videocam;
      case FileTypeEnum.audio:
        return Icons.audiotrack;
      case FileTypeEnum.document:
        return Icons.description;
      case FileTypeEnum.other:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int size) {
    if (size >= AppConstants.gb) {
      return '${(size / AppConstants.gb).toStringAsFixed(2)} GB';
    } else if (size >= AppConstants.mb) {
      return '${(size / AppConstants.mb).toStringAsFixed(2)} MB';
    } else if (size >= AppConstants.kb) {
      return '${(size / AppConstants.kb).toStringAsFixed(2)} KB';
    } else {
      return '$size B';
    }
  }
}
