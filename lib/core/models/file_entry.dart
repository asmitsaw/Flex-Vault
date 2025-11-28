import 'package:equatable/equatable.dart';

class FileEntry extends Equatable {
  const FileEntry({
    required this.id,
    required this.name,
    required this.contentType,
    required this.size,
    required this.createdAt,
    this.thumbnailUrl,
    this.tags = const [],
    this.folderId,
    this.isShared = false,
  });

  final String id;
  final String name;
  final String contentType;
  final int size;
  final DateTime createdAt;
  final String? thumbnailUrl;
  final List<String> tags;
  final String? folderId;
  final bool isShared;

  FileEntry copyWith({
    String? thumbnailUrl,
    List<String>? tags,
    bool? isShared,
  }) {
    return FileEntry(
      id: id,
      name: name,
      contentType: contentType,
      size: size,
      createdAt: createdAt,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      tags: tags ?? this.tags,
      folderId: folderId,
      isShared: isShared ?? this.isShared,
    );
  }

  factory FileEntry.fromJson(Map<String, dynamic> json) {
    return FileEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      contentType: json['contentType'] as String,
      size: json['size'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
      folderId: json['folderId'] as String?,
      isShared: json['isShared'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contentType': contentType,
      'size': size,
      'createdAt': createdAt.toIso8601String(),
      'thumbnailUrl': thumbnailUrl,
      'tags': tags,
      'folderId': folderId,
      'isShared': isShared,
    };
  }

  @override
  List<Object?> get props =>
      [id, name, contentType, size, createdAt, thumbnailUrl, tags, folderId, isShared];
}

