import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import 'collections.dart';
import 'isar_provider.dart';

const _uuid = Uuid();

// ── Default categories (Decision — Work, Personal, Study, Health, Break) ─────
final _defaultCategories = [
  (name: 'Work',     nameJP: '仕事',   color: const Color(0xFF4A90D9), order: 0),
  (name: 'Personal', nameJP: '個人',   color: const Color(0xFF7F77DD), order: 1),
  (name: 'Study',    nameJP: '勉強',   color: const Color(0xFF1D9E75), order: 2),
  (name: 'Health',   nameJP: '健康',   color: const Color(0xFFD44C3A), order: 3),
  (name: 'Break',    nameJP: '休憩',   color: const Color(0xFFEF9F27), order: 4),
];

class CategoryRepository {
  CategoryRepository(this._isar);
  final Isar _isar;

  Future<List<Category>> getAllCategories() async {
    final all = await _isar.categorys.where().findAll();
    all.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return all;
  }

  Stream<List<Category>> watchAllCategories() {
    return _isar.categorys
        .where()
        .watch(fireImmediately: true)
        .map((list) {
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return list;
    });
  }

  /// Seeds the 5 default categories if they don't exist yet.
  /// Safe to call on every app start — checks first, inserts only if empty.
  Future<void> seedDefaultsIfNeeded() async {
    final existing = await _isar.categorys.count();
    if (existing > 0) return;

    final categories = _defaultCategories.map((c) {
      return Category()
        ..uuid = _uuid.v4()
        ..name = c.name
        ..nameJP = c.nameJP
        ..colorValue = c.color.toARGB32()
        ..sortOrder = c.order
        ..isBuiltIn = true
        ..createdAt = DateTime.now();
    }).toList();

    await _isar.writeTxn(() async {
      await _isar.categorys.putAll(categories);
    });
  }

  Future<Category?> getCategoryByUuid(String uuid) async {
    return _isar.categorys.filter().uuidEqualTo(uuid).findFirst();
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return CategoryRepository(isar);
});

// ── Stream of all categories for filter chips ─────────────────────────────────
final allCategoriesProvider = StreamProvider<List<Category>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchAllCategories();
});