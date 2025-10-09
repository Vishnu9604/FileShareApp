import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class FileShareService {
  HttpServer? _server;
  String? _filePath; 
  String? _fileName;

  Future<String> getLocalIpAddress() async {
    final interfaces = await NetworkInterface.list();
    for (var interface in interfaces) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
          return addr.address;
        }
      }
    }
    return '192.168.1.1'; // fallback
  }

  Future<void> startServer(String filePath, String fileName, {Function()? onFileDownloaded}) async {
    _filePath = filePath;
    _fileName = fileName;

    // Check if file exists before starting server
    final file = File(_filePath!);
    if (!await file.exists()) {
      throw Exception('File does not exist: $_filePath');
    }

    print('Starting server with file: $_filePath');
    print('File name: $_fileName');
    print('File exists: ${await file.exists()}');
    print('File size: ${await file.length()} bytes');

    try {
      // Try to bind to all interfaces first (for network sharing)
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
      final ip = await getLocalIpAddress();
      print('Server started successfully on $ip:8080');
      print('Server is accessible from other devices on the network');
    } catch (e) {
      print('Failed to bind to anyIPv4, trying loopback: $e');
      try {
        // Fallback to loopback for local testing
        _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
        print('Server started on localhost:8080 (local testing only)');
        print('Note: This setup only works for testing on the same device');
      } catch (e2) {
        print('Failed to start server on any interface: $e2');
        rethrow;
      }
    }

    _server!.listen((HttpRequest request) async {
      print('Received request: ${request.method} ${request.uri.path} from ${request.connectionInfo?.remoteAddress}');

      if (request.uri.path == '/download') {
        try {
          final file = File(_filePath!);
          final fileExists = await file.exists();

          print('Serving file: $_filePath');
          print('File exists: $fileExists');

          if (fileExists) {
            final fileSize = await file.length();
            print('File size: $fileSize bytes');

            // Set appropriate content type based on file extension
            final contentType = _getContentType(_fileName!);
            request.response.headers.contentType = ContentType.parse(contentType);
            request.response.headers.add('Content-Disposition', 'attachment; filename="$_fileName"');
            request.response.headers.add('Content-Length', fileSize.toString());

            print('Content-Type: $contentType');
            print('Sending file to client...');

            await request.response.addStream(file.openRead());
            print('File sent successfully');
            onFileDownloaded?.call();
          } else {
            print('File not found: $_filePath');
            request.response.statusCode = 404;
            request.response.write('File not found: $_filePath');
          }
        } catch (e) {
          print('Error serving file: $e');
          request.response.statusCode = 500;
          request.response.write('Error serving file: $e');
        }
      } else {
        request.response.write('Hello from File Share Server');
      }
      await request.response.close();
    });
  }

  void stopServer() {
    _server?.close();
    _server = null;
  }

  // Test method to verify server is working
  Future<bool> testServer() async {
    if (_server == null) {
      return false;
    }

    try {
      final ip = await getLocalIpAddress();
      final response = await http.get(Uri.parse('http://$ip:8080/'));
      return response.statusCode == 200;
    } catch (e) {
      print('Server test failed: $e');
      return false;
    }
  }

  Future<String?> downloadFile(String ip, String port, String basePath) async {
    final url = 'http://$ip:$port/download';
    print('Downloading file from: $url');
    print('Saving to: $basePath');

    try {
      final response = await http.get(Uri.parse(url));
      print('Download response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        String fileName = 'downloaded_file';
        final disposition = response.headers['content-disposition'];
        if (disposition != null) {
          final match = RegExp(r'filename="([^"]+)"').firstMatch(disposition);
          if (match != null) {
            fileName = match.group(1)!;
          }
        }

        final savePath = '$basePath/$fileName';
        print('Saving file as: $savePath');

        // Ensure the directory exists
        final dir = Directory(basePath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }

        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        print('File downloaded successfully: $savePath');
        return savePath;
      } else {
        print('Download failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error downloading file: $e');
    }
    return null;
  }

  Future<String> getDownloadPath(String fileName) async {
    // Always save to the public Downloads directory
    return '/storage/emulated/0/Download';
  }

  Future<bool> requestStoragePermission() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 30) { // Android 11+
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
      }
      return status.isGranted;
    } else {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      return status.isGranted;
    }
  }

  // New utility methods for file type detection
  String _getContentType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;

    switch (extension) {
      // Images
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';

      // Audio
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'flac':
        return 'audio/flac';
      case 'aac':
        return 'audio/aac';
      case 'ogg':
        return 'audio/ogg';
      case 'm4a':
        return 'audio/m4a';

      // Video
      case 'mp4':
        return 'video/mp4';
      case 'avi':
        return 'video/avi';
      case 'mkv':
        return 'video/mkv';
      case 'mov':
        return 'video/quicktime';
      case 'wmv':
        return 'video/wmv';
      case 'flv':
        return 'video/flv';
      case 'webm':
        return 'video/webm';

      // Documents
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'rtf':
        return 'text/rtf';
      case 'csv':
        return 'text/csv';

      // Archives
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/rar';
      case '7z':
        return 'application/7z';
      case 'tar':
        return 'application/tar';
      case 'gz':
        return 'application/gzip';

      default:
        return 'application/octet-stream';
    }
  }

  FileType getFileType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;

    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return FileType.image;
    } else if (['mp3', 'wav', 'flac', 'aac', 'ogg', 'm4a'].contains(extension)) {
      return FileType.audio;
    } else if (['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm'].contains(extension)) {
      return FileType.video;
    } else if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'rtf', 'csv'].contains(extension)) {
      return FileType.document;
    } else if (['zip', 'rar', '7z', 'tar', 'gz'].contains(extension)) {
      return FileType.archive;
    } else {
      return FileType.other;
    }
  }

  IconData getFileTypeIcon(FileType fileType) {
    switch (fileType) {
      case FileType.image:
        return Icons.image;
      case FileType.audio:
        return Icons.music_note;
      case FileType.video:
        return Icons.video_file;
      case FileType.document:
        return Icons.description;
      case FileType.archive:
        return Icons.archive;
      case FileType.other:
        return Icons.insert_drive_file;
    }
  }

  String getFileTypeName(FileType fileType) {
    switch (fileType) {
      case FileType.image:
        return 'Image';
      case FileType.audio:
        return 'Audio';
      case FileType.video:
        return 'Video';
      case FileType.document:
        return 'Document';
      case FileType.archive:
        return 'Archive';
      case FileType.other:
        return 'File';
    }
  }

  // Test connectivity to a server
  Future<bool> testConnection(String ip, String port) async {
    try {
      final url = 'http://$ip:$port/';
      print('Testing connection to: $url');
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      print('Connection test response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // Get all available IP addresses for the device
  Future<List<String>> getAllIpAddresses() async {
    final List<String> addresses = [];
    try {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            addresses.add(addr.address);
          }
        }
      }
    } catch (e) {
      print('Error getting IP addresses: $e');
    }
    return addresses.isEmpty ? ['192.168.1.1'] : addresses;
  }
}

enum FileType {
  image,
  audio,
  video,
  document,
  archive,
  other,
}
