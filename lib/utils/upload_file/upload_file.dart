import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A file picked for upload, usable on every platform: mobile/desktop
/// pickers give a [path], web pickers only give [bytes].
class UploadFile {
  const UploadFile({required this.filename, this.path, this.bytes})
    : assert(path != null || bytes != null, 'Provide a path or bytes');

  final String filename;
  final String? path;
  final Uint8List? bytes;

  Future<MultipartFile> toMultipart() async {
    if (bytes != null) {
      return MultipartFile.fromBytes(bytes!, filename: filename);
    }
    return MultipartFile.fromFile(path!, filename: filename);
  }
}
