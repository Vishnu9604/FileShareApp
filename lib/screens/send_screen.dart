import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart' hide FileType;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lottie/lottie.dart';
import '../services/file_share_service.dart';
import '../models/file_transfer.dart';
import '../providers/history_provider.dart';

extension StringExtension on String {
  String get fileName {
    // Handle both forward slashes (Unix/Android) and backslashes (Windows)
    return this.split('/').last.split('\\').last;
  }
}

class SendScreen extends ConsumerStatefulWidget {
  const SendScreen({super.key});

  @override
  ConsumerState<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends ConsumerState<SendScreen> {
  final FileShareService _service = FileShareService();
  List<String> _selectedFiles = [];
  List<bool> _isSelectedFiles = [];
  String? _ipAddress;
  bool _isServerRunning = false;

  List<String> get _selectedFilePaths {
    return _selectedFiles.asMap().entries
        .where((entry) => _isSelectedFiles[entry.key])
        .map((entry) => entry.value)
        .toList();
  }

  int get _selectedCount {
    return _isSelectedFiles.where((selected) => selected).length;
  }

  Widget _buildSelectionHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.deepPurple, size: 20),
          Expanded(
            child: Text(
              'Selected: ${_selectedCount}/${_selectedFiles.length} files',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
                fontFamily: 'Montserrat',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (_selectedCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isSelectedFiles = List.filled(_selectedFiles.length, true);
                  });
                },
                icon: const Icon(Icons.select_all, size: 16, color: Colors.deepPurple),
                label: const Text('Select All', style: TextStyle(color: Colors.deepPurple, fontSize: 14)),
              ),
            ),
        ],
      ),
    );
  }

  FileTypeEnum _mapFileType(FileType type) {
    switch (type) {
      case FileType.image:
        return FileTypeEnum.image;
      case FileType.video:
        return FileTypeEnum.video;
      case FileType.audio:
        return FileTypeEnum.audio;
      case FileType.document:
        return FileTypeEnum.document;
      default:
        return FileTypeEnum.other;
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      final newPaths = result.paths.where((path) => path != null).cast<String>().where((path) => !_selectedFiles.contains(path)).toList();
      if (newPaths.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(newPaths);
          _isSelectedFiles.addAll(List.filled(newPaths.length, true));
        });
      }
    }
  }

  Future<void> _startServerForSelectedFiles() async {
    try {
      final selectedPaths = _selectedFilePaths;
      final fileNames = selectedPaths.map((path) => path.fileName).toList();
      await _service.startServerForMultipleFiles(selectedPaths, fileNames, onFileDownloaded: (String fileName) => _addToHistory(fileName));
      final ip = await _service.getLocalIpAddress();
      setState(() {
        _ipAddress = ip;
        _isServerRunning = true;
      });
    } catch (e) {
      print('Error starting server: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start server: $e')),
      );
    }
  }

  void _addToHistory(String fileName) async {
    // Find the corresponding file path from _selectedFiles
    final filePath = _selectedFiles.firstWhere((path) => path.fileName == fileName);
    final file = File(filePath);
    final size = await file.length();
    final type = _service.getFileType(fileName);
    final fileTypeEnum = _mapFileType(type);
    final transfer = FileTransfer(
      id: DateTime.now().toIso8601String() + fileName, // unique id
      name: fileName,
      path: filePath,
      size: size,
      type: fileTypeEnum,
      status: FileTransferStatus.completed,
      timestamp: DateTime.now(),
      direction: TransferDirection.sent,
      deviceName: 'Shared via Server',
    );
    ref.read(historyProvider.notifier).addTransfer(transfer);
  }

  @override
  void dispose() {
    _service.stopServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send File'),
        backgroundColor: Colors.deepPurple,
        elevation: 6,
        shadowColor: Colors.deepPurpleAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildPickFileButton(),
                if (_selectedFiles.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSelectionHeader(),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildFileCardWithSelection(_selectedFiles[index], index),
                      );
                    },
                  ),
                  _buildStartSharingButton(),
                  Lottie.asset('assets/animations/send_screen.json', width: 150, height: 150),
                ],
                if (_isServerRunning && _ipAddress != null) ...[
                  const SizedBox(height: 32),
                  _buildServerInfo(),
                  const SizedBox(height: 24),
                  _buildQRCode(),
                  const SizedBox(height: 16),
                  const Text(
                    'Scan this QR code to download the files',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickFileButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _pickFile,
        icon: const Icon(Icons.file_upload, size: 24),
        label: const Text('Pick Files', style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildFileCardWithSelection(String filePath, int index) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.deepPurpleAccent.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Checkbox(
              value: _isSelectedFiles[index],
              onChanged: (bool? value) {
                setState(() {
                  _isSelectedFiles[index] = value ?? false;
                });
              },
              activeColor: Colors.deepPurple,
              checkColor: Colors.white,
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.deepPurple.withOpacity(0.15),
              child: Icon(
                _service.getFileTypeIcon(_service.getFileType(filePath.fileName)),
                color: Colors.deepPurple,
                size: 32,
              ),
              radius: 28,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    filePath.fileName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _service.getFileTypeName(_service.getFileType(filePath.fileName)),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartSharingButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isServerRunning || _selectedCount == 0 ? null : _startServerForSelectedFiles,
        icon: const Icon(Icons.share, size: 24),
        label: Text('Start Sharing Selected (${_selectedCount})', style: const TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isServerRunning || _selectedCount == 0 ? Colors.grey : Colors.green.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 6,
        ),
      ),
    );
  }

  Widget _buildServerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi, color: Colors.green),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              'Server running on $_ipAddress:8080',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCode() {
    final screenWidth = MediaQuery.of(context).size.width;
    final qrSize = screenWidth - 80.0; // Account for padding
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: QrImageView(
        data: 'http://$_ipAddress:8080/download',
        size: qrSize,
        backgroundColor: Colors.white,
      ),
    );
  }
}
