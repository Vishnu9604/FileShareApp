 import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import '../services/file_share_service.dart';
import '../models/file_transfer.dart';
import '../providers/history_provider.dart';

class ReceiveScreen extends ConsumerStatefulWidget {
  const ReceiveScreen({super.key});

  @override
  ConsumerState<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends ConsumerState<ReceiveScreen> {
  final FileShareService _service = FileShareService();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: '8080');
  bool _isDownloading = false;
  bool _isScanning = false;
  List<Map<String, dynamic>> _availableFiles = [];
  bool _isFetchingFiles = false;
  String? _downloadingFile;

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

  Future<void> _fetchAvailableFiles() async {
    final ip = _ipController.text;
    final port = _portController.text;
    if (ip.isNotEmpty && port.isNotEmpty) {
      setState(() {
        _isFetchingFiles = true;
      });
      try {
        final response = await http.get(Uri.parse('http://$ip:$port/files'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _availableFiles = List<Map<String, dynamic>>.from(data['files']);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch available files')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching files: $e')),
        );
      } finally {
        setState(() {
          _isFetchingFiles = false;
        });
      }
    }
  }

  Future<void> _downloadFile([String? fileName]) async {
    final ip = _ipController.text;
    final port = _portController.text;
    if (ip.isNotEmpty && port.isNotEmpty) {
      setState(() {
        _isDownloading = true;
        _downloadingFile = fileName;
      });
      final hasPermission = await _service.requestStoragePermission();
      if (hasPermission) {
        final basePath = await _service.getDownloadPath('temp_file');
        final downloadedPath = await _service.downloadFile(ip, port, basePath, fileName: fileName);
        setState(() {
          _isDownloading = false;
          _downloadingFile = null;
        });
        if (downloadedPath != null) {
          // Add to history
          final file = File(downloadedPath);
          final size = await file.length();
          final name = downloadedPath.split('/').last.split('\\').last;
          final type = _service.getFileType(name);
          final fileTypeEnum = _mapFileType(type);
          final transfer = FileTransfer(
            id: DateTime.now().toIso8601String(),
            name: name,
            path: downloadedPath,
            size: size,
            type: fileTypeEnum,
            status: FileTransferStatus.completed,
            timestamp: DateTime.now(),
            direction: TransferDirection.received,
            deviceName: _ipController.text.isNotEmpty ? _ipController.text : 'Sender Device',
          );
          ref.read(historyProvider.notifier).addTransfer(transfer);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File downloaded successfully to $downloadedPath')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to download file')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    }
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
    });
  }

  void _stopScan() {
    setState(() {
      _isScanning = false;
    });
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null) {
        Uri? uri = Uri.tryParse(code);
        if (uri != null && uri.host.isNotEmpty) {
          _ipController.text = uri.host;
          _portController.text = uri.port.toString();
          _stopScan();

          // Fetch available files after successful QR scan
          _fetchAvailableFiles();
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive File'),
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
          child: _isScanning
              ? _buildScannerView()
              : _availableFiles.isNotEmpty
                  ? _buildFilesListView()
                  : SingleChildScrollView(child: _buildInputView()),
        ),
      ),
    );
  }

  Widget _buildScannerView() {
    return Column(
      children: [
        const Text(
          'Scan QR Code',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        const SizedBox(height: 16),
        const Text(
          'Point your camera at the QR code from the sender',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.deepPurple, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: MobileScanner(
                onDetect: _onDetect,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _stopScan,
            icon: const Icon(Icons.cancel, size: 24),
            label: const Text('Cancel Scan', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Enter Sender Details',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple, fontFamily: 'Montserrat'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Get the IP address and port from the sender',
          style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Montserrat'),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Lottie.asset('assets/animations/receive_screen.json', width: 150, height: 150),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _ipController,
          label: 'Sender IP Address',
          hint: 'e.g., 192.168.1.100',
          icon: Icons.wifi,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _portController,
          label: 'Port',
          hint: '8080',
          icon: Icons.settings_input_component,
        ),
        const SizedBox(height: 40),
        _buildDownloadButton(),
        const SizedBox(height: 24),
        const Text(
          'or',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        _buildScanQRButton(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isDownloading ? null : _downloadFile,
        icon: _isDownloading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.download, size: 24),
        label: Text(
          _isDownloading ? 'Downloading...' : 'Download File',
          style: const TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isDownloading ? Colors.grey : Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 6,
        ),
      ),
    );
  }

  Widget _buildScanQRButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _startScan,
        icon: const Icon(Icons.qr_code_scanner, size: 24),
        label: const Text('Scan QR Code', style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildFilesListView() {
    return Column(
      children: [
        const Text(
          'Available Files',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _availableFiles.length,
            itemBuilder: (context, index) {
              final file = _availableFiles[index];
              final fileName = file['name'] as String;
              final fileType = file['type'] as String;
              final isDownloadingThis = _downloadingFile == fileName;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(
                    _getFileIcon(fileType),
                    color: Colors.deepPurple,
                    size: 32,
                  ),
                  title: Text(fileName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Type: $fileType'),
                  trailing: ElevatedButton.icon(
                    onPressed: (_isDownloading && !isDownloadingThis) ? null : () => _downloadFile(fileName),
                    icon: isDownloadingThis
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.download, size: 20),
                    label: Text(isDownloadingThis ? 'Downloading...' : 'Download'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDownloadingThis ? Colors.grey : Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _availableFiles = [];
              });
            },
            icon: const Icon(Icons.refresh, size: 24),
            label: const Text('Back to Input', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_file;
      case 'audio':
        return Icons.music_note;
      case 'document':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}
