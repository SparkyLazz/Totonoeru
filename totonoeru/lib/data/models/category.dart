import 'package:isar/isar.dart';

part 'category.g.dart';

@Collection()
class Category {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  late String name;

  /// Japanese name e.g. '仕事'
  late String nameJp;

  /// Hex string e.g. '#1D9E75'
  late String colorHex;

  /// Icon identifier e.g. 'briefcase' — maps to IconData in UI
  late String iconIdentifier;

  /// System categories cannot be deleted
  late bool isSystem;

  late int sortOrder;

  @Index()
  late DateTime createdAt;

  // ── Factory ───────────────────────────────────────────────────────────────

  static Category create({
    required String uuid,
    required String name,
    required String nameJp,
    required String colorHex,
    required String iconIdentifier,
    bool isSystem = false,
    int sortOrder = 0,
  }) {
    return Category()
      ..uuid = uuid
      ..name = name
      ..nameJp = nameJp
      ..colorHex = colorHex
      ..iconIdentifier = iconIdentifier
      ..isSystem = isSystem
      ..sortOrder = sortOrder
      ..createdAt = DateTime.now();
  }
}
