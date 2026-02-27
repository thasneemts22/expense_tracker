import 'package:uuid/uuid.dart';

class Category {
  String id;
  String name;
  int isSynced;
  int isDeleted;

  Category({
    String? id,
    required this.name,
    this.isSynced = 0,
    this.isDeleted = 0,
  }) : id = id ?? const Uuid().v4(); 

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'is_synced': isSynced,
      'is_deleted': isDeleted,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
  return Category(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    isSynced: map['is_synced'] ?? 0,
    isDeleted: map['is_deleted'] ?? 0,
  );
}
}