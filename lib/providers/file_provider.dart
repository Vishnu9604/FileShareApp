import 'dart:io';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_transfer.dart';

class FileNotifier extends StateNotifier<List<FileTransfer>> {
  FileNotifier() : super([]);

  Future<void> pickImages({bool allowMultiple = false}) async {
    final result = await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.image,
      allowMultiple: allowMultiple,
    );

    if (result != null) {
      final files = result.files.map((file) {
        final filePath = file.path!;
        final fileSize = File(filePath).lengthSync();
        return FileTransfer(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: file.name,
          path: filePath,
          size: fileSize,
          type: FileTypeEnum.image,
        );
      }).toList();

      state = [...state, ...files];
    }
  }

  Future<void> pickFiles({
    file_picker.FileType fileType = file_picker.FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
  }) async {
    final result = await file_picker.FilePicker.platform.pickFiles(
      type: fileType,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
    );

    if (result != null) {
      final files = result.files.map((file) {
        final filePath = file.path!;
        final fileSize = File(filePath).lengthSync();
        final type = _getFileType(file.name);
        return FileTransfer(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_${file.name}',
          name: file.name,
          path: filePath,
          size: fileSize,
          type: type,
        );
      }).toList();

      state = [...state, ...files];
    }
  }

  FileTypeEnum _getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(extension)) {
      return FileTypeEnum.image;
    } else if (['mp4', 'avi', 'mkv', 'mov'].contains(extension)) {
      return FileTypeEnum.video;
    } else if (['mp3', 'wav', 'aac', 'flac'].contains(extension)) {
      return FileTypeEnum.audio;
    } else if (['pdf', 'doc', 'docx', 'txt'].contains(extension)) {
      return FileTypeEnum.document;
    } else {
      return FileTypeEnum.other;
    }
  }

  void toggleFileSelection(String id) {
    state = state.map((file) {
      if (file.id == id) {
        return file.copyWith(selected: !file.selected);
      }
      return file;
    }).toList();
  }

  void removeFile(String id) {
    state = state.where((file) => file.id != id).toList();
  }

  void clearFiles() {
    state = [];
  }

  void selectAllFiles() {
    state = state.map((file) => file.copyWith(selected: true)).toList();
  }

  int getTotalSize() {
    return state.where((file) => file.selected).fold(0, (sum, file) => sum + file.size);
  }
}

final fileProvider = StateNotifierProvider<FileNotifier, List<FileTransfer>>((ref) {
  return FileNotifier();
});
