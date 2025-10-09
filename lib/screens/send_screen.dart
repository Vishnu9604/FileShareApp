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
  String? _selectedFile;
  String? _ipAddress;
  bool _isServerRunning = false;

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
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = result.files.single.path;
      });
    }
  }

  Future<void> _startServer() async {
    if (_selectedFile != null) {
      try {
        // Use the fileName extension method which handles both / and \ path separators
        final fileName = _selectedFile!.fileName;
        await _service.startServer(_selectedFile!, fileName, onFileDownloaded: _addToHistoryAfterShare);
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
  }

  // Call this method when the file is actually shared successfully
  void _addToHistoryAfterShare() async {
    if (_selectedFile != null) {
      final file = File(_selectedFile!);
      final size = await file.length();
      final fileName = _selectedFile!.fileName;
      final type = _service.getFileType(fileName);
      final fileTypeEnum = _mapFileType(type);
      final transfer = FileTransfer(
        id: DateTime.now().toIso8601String(),
        name: fileName,
        path: _selectedFile!,
        size: size,
        type: fileTypeEnum,
        status: FileTransferStatus.completed,
        timestamp: DateTime.now(),
        direction: TransferDirection.sent,
        deviceName: 'Shared via Server',
      );
      ref.read(historyProvider.notifier).addTransfer(transfer);
    }
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
                if (_selectedFile != null) ...[
                  const SizedBox(height: 24),
                  _buildFileCard(),
                  const SizedBox(height: 24),
                  Lottie.asset('assets/animations/send_screen.json', width: 150, height: 150),
                ],
                const SizedBox(height: 32),
                _buildStartSharingButton(),
                if (_isServerRunning && _ipAddress != null) ...[
                  const SizedBox(height: 32),
                  _buildServerInfo(),
                  const SizedBox(height: 24),
                  _buildQRCode(),
                  const SizedBox(height: 16),
                  const Text(
                    'Scan this QR code to download the file',
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
        label: const Text('Pick File', style: TextStyle(fontSize: 18)),
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

  Widget _buildFileCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.deepPurpleAccent.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepPurple.withOpacity(0.15),
              child: Icon(
                _service.getFileTypeIcon(_service.getFileType(_selectedFile!.fileName)),
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
                    _selectedFile!.fileName,
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
                    _service.getFileTypeName(_service.getFileType(_selectedFile!.fileName)),
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
        onPressed: _isServerRunning ? null : _startServer,
        icon: const Icon(Icons.share, size: 24),
        label: const Text('Start Sharing', style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isServerRunning ? Colors.grey : Colors.green.shade600,
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
