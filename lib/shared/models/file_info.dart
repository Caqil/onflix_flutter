import 'package:json_annotation/json_annotation.dart';

part 'file_info.g.dart';

@JsonSerializable()
class FileInfo {
  final String name;
  final String path;
  final String mimeType;
  final int size;
  final String? url;
  final String? thumbnailUrl;
  final Map<String, dynamic>? metadata;
  final DateTime uploadedAt;

  const FileInfo({
    required this.name,
    required this.path,
    required this.mimeType,
    required this.size,
    this.url,
    this.thumbnailUrl,
    this.metadata,
    required this.uploadedAt,
  });

  factory FileInfo.fromJson(Map<String, dynamic> json) =>
      _$FileInfoFromJson(json);

  Map<String, dynamic> toJson() => _$FileInfoToJson(this);

  String get extension {
    final lastDot = name.lastIndexOf('.');
    if (lastDot == -1) return '';
    return name.substring(lastDot + 1).toLowerCase();
  }

  String get formattedSize {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var fileSize = size.toDouble();
    var suffixIndex = 0;

    while (fileSize >= 1024 && suffixIndex < suffixes.length - 1) {
      fileSize /= 1024;
      suffixIndex++;
    }

    return '${fileSize.toStringAsFixed(1)} ${suffixes[suffixIndex]}';
  }

  bool get isImage =>
      ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].contains(extension);
  bool get isVideo =>
      ['mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v'].contains(extension);
  bool get isAudio =>
      ['mp3', 'wav', 'aac', 'ogg', 'm4a', 'flac'].contains(extension);

  @override
  String toString() => 'FileInfo(name: $name, size: $formattedSize)';
}
