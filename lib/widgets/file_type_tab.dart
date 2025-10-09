import 'package:flutter/material.dart';
import '../models/file_transfer.dart';
import '../utils/constants.dart';

class FileTypeTab extends StatelessWidget {
  final FileTypeEnum type;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const FileTypeTab({
    super.key,
    required this.type,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  String get _label {
    switch (type) {
      case FileTypeEnum.image:
        return 'Images';
      case FileTypeEnum.video:
        return 'Videos';
      case FileTypeEnum.audio:
        return 'Audio';
      case FileTypeEnum.document:
        return 'Documents';
      case FileTypeEnum.other:
        return 'Others';
    }
  }

  IconData get _icon {
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

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppConstants.primaryColor : Colors.grey.shade600;
    final backgroundColor = isSelected ? AppConstants.primaryColor.withOpacity(0.15) : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Row(
          children: [
            Icon(_icon, color: color),
            const SizedBox(width: 8),
            Text(
              '$_label ($count)',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
