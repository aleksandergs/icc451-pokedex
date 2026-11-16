import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Cache de imagenes en disco
class ImageStore {
  ImageStore._();

  static final ImageStore instance = ImageStore._();

  Directory? _directory;

  final Map<String, String> _memory = <String, String>{};

  Future<Directory> _dir() async {
    final Directory? cached = _directory;
    if (cached != null) return cached;
    final Directory support = await getApplicationSupportDirectory();
    final Directory dir = Directory(p.join(support.path, 'sprites'));
    if (!await dir.exists()) await dir.create(recursive: true);
    _directory = dir;
    return dir;
  }

  Future<String?> resolve(String url) async {
    final String? cached = _memory[url];
    if (cached != null) return cached;

    final Directory dir = await _dir();
    final String fileName =
        '${url.hashCode.toRadixString(16)}_${p.url.basename(Uri.parse(url).path)}';
    final File file = File(p.join(dir.path, fileName));

    if (await file.exists()) {
      _memory[url] = file.path;
      return file.path;
    }

    try {
      final http.Response response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        await file.writeAsBytes(response.bodyBytes, flush: true);
        _memory[url] = file.path;
        return file.path;
      }
    } on Object {
      /// Sin red o fallo del servidor de imagenes: se usa el respaldo.
    }
    return null;
  }
}
