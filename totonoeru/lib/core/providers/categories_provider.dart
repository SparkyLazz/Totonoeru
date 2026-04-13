// lib/core/providers/categories_provider.dart
//
// Task 3.06 — CategoriesProvider: Riverpod, watches Isar categories

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category.dart';
import '../../data/repositories/category_repository.dart';

// ── Live stream provider ───────────────────────────────────────────────────────

/// Watches the Isar categories collection — rebuilds any widget that reads it
/// whenever a category is added, updated, reordered, or deleted.
final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return CategoryRepository.instance.watchAllCategories();
});

// ── Convenience async provider (for one-off reads) ────────────────────────────

final categoriesFutureProvider = FutureProvider.autoDispose<List<Category>>((ref) {
  return CategoryRepository.instance.getAllCategories();
});