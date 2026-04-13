// lib/data/repositories/category_repository.dart
//
// Task 3.05 — CategoryRepository: CRUD, system category protection

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../services/database_service.dart';

class CategoryRepository {
  CategoryRepository._();
  static final CategoryRepository instance = CategoryRepository._();

  Isar get _isar => DatabaseService.instance.isar;
  static const _uuid = Uuid();

  // ── Create ────────────────────────────────────────────────────────────────

  Future<Category> createCategory({
    required String name,
    required String nameJp,
    required String colorHex,
    required String iconIdentifier,
  }) async {
    final count = await _isar.categorys.count();
    final cat = Category.create(
      uuid: _uuid.v4(),
      name: name,
      nameJp: nameJp,
      colorHex: colorHex,
      iconIdentifier: iconIdentifier,
      isSystem: false,
      sortOrder: count,
    );
    await _isar.writeTxn(() => _isar.categorys.put(cat));
    return cat;
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<List<Category>> getAllCategories() async {
    final cats = await _isar.categorys.where().findAll();
    cats.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return cats;
  }

  Future<Category?> getCategoryByUuid(String uuid) =>
      _isar.categorys.getByUuid(uuid);

  /// Stream for Riverpod watch
  Stream<List<Category>> watchAllCategories() {
    return _isar.categorys
        .where()
        .watch(fireImmediately: true)
        .map((cats) => cats..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)));
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<Category> updateCategory(
      Category cat, {
        String? name,
        String? nameJp,
        String? colorHex,
        String? iconIdentifier,
      }) async {
    if (name != null) cat.name = name;
    if (nameJp != null) cat.nameJp = nameJp;
    if (colorHex != null) cat.colorHex = colorHex;
    if (iconIdentifier != null) cat.iconIdentifier = iconIdentifier;
    await _isar.writeTxn(() => _isar.categorys.put(cat));
    return cat;
  }

  // ── Reorder (task 3.09) ───────────────────────────────────────────────────

  /// Persist new sort order after drag reorder.
  Future<void> reorder(List<Category> reordered) async {
    for (var i = 0; i < reordered.length; i++) {
      reordered[i].sortOrder = i;
    }
    await _isar.writeTxn(() => _isar.categorys.putAll(reordered));
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  /// Throws [StateError] if the category is a system category.
  Future<void> deleteCategory(Category cat) async {
    if (cat.isSystem) {
      throw StateError('Cannot delete a system category: ${cat.name}');
    }
    await _isar.writeTxn(() => _isar.categorys.delete(cat.id));
  }
}