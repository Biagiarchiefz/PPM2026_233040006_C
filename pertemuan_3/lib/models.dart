import 'dart:typed_data';

class Experience {
  final String title;
  final String description;
  final Uint8List? imageBytes;

  const Experience({
    required this.title,
    required this.description,
    this.imageBytes,
  });
}
