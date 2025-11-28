import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/file_entry.dart';
import '../utils/app_logger.dart';
import 'api_client.dart';

final uploadServiceProvider = Provider<UploadService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return UploadService(apiClient: apiClient);
});

class UploadService {
  UploadService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<FileEntry?> selectAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result == null) return null;

    final filePath = result.files.single.path;
    if (filePath == null) return null;

    final file = File(filePath);
    final compressed = await _compress(file);
    final metadata = await _extractMetadata(compressed);

    final presignResponse = await _apiClient.post<Map<String, dynamic>>(
      '/uploads/presign',
      data: {
        'filename': path.basename(compressed.path),
        'size': await compressed.length(),
        'contentType': lookupMimeType(compressed.path),
        'hash': metadata.perceptualHash,
      },
    );

    final uploadUrl = presignResponse.data?['uploadUrl'] as String;
    final key = presignResponse.data?['key'] as String;

    // Use plain HttpClient to upload to S3.
    final request = await HttpClient().putUrl(Uri.parse(uploadUrl));
    request.headers.contentType =
        ContentType.parse(lookupMimeType(compressed.path) ?? 'application/octet-stream');
    await request.addStream(compressed.openRead());
    final response = await request.close();

    if (response.statusCode >= 400) {
      throw Exception('Upload failed');
    }

    await _apiClient.post('/uploads/confirm', data: {
      'key': key,
      'metadata': metadata.toJson(),
    });

    return FileEntry(
      id: key,
      name: path.basename(compressed.path),
      contentType: lookupMimeType(compressed.path) ?? 'application/octet-stream',
      size: await compressed.length(),
      createdAt: DateTime.now(),
      tags: metadata.tags,
    );
  }

  Future<File> _compress(File file) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath =
        path.join(tempDir.path, 'flexvault-${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}');
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outputPath,
      quality: 80,
    );
    return result ?? file;
  }

  Future<_UploadMetadata> _extractMetadata(File file) async {
    try {
      final inputImage = InputImage.fromFile(file);
      final labeler = ImageLabeler(
        options: ImageLabelerOptions(confidenceThreshold: 0.5),
      );
      final labels = await labeler.processImage(inputImage);
      await labeler.close();

      final textRecognizer = TextRecognizer();
      final recognisedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      final tags = labels.map((l) => l.label).toList();
      final ocrText = recognisedText.text;

      return _UploadMetadata(
        tags: tags,
        ocrText: ocrText,
        perceptualHash: file.lengthSync().toString(),
      );
    } catch (e) {
      appLogger.e('Metadata extraction failed', error: e);
      return const _UploadMetadata();
    }
  }
}

class _UploadMetadata {
  const _UploadMetadata({
    this.tags = const [],
    this.ocrText,
    this.perceptualHash,
  });

  final List<String> tags;
  final String? ocrText;
  final String? perceptualHash;

  Map<String, dynamic> toJson() => {
        'tags': tags,
        'ocrText': ocrText,
        'perceptualHash': perceptualHash,
      };
}

