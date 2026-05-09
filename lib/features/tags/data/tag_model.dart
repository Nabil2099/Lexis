import '../../../core/database/app_database.dart';

class Tag {
  final int id;
  final String name;
  final String colorHex;

  Tag({
    required this.id,
    required this.name,
    required this.colorHex,
  });

  factory Tag.fromDrift(TagsTableData data) {
    return Tag(
      id: data.id,
      name: data.name,
      colorHex: data.colorHex,
    );
  }

  Tag copyWith({
    int? id,
    String? name,
    String? colorHex,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}
