// lib/features/settings/categories_screen.dart
//
// Tasks 3.07 + 3.09 — Category management screen
// • Full CRUD list with ReorderableListView (drag handle = task 3.09)
// • System categories: edit color/icon only, cannot delete
// • Route: /settings/categories

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/categories_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/category.dart';
import '../../data/repositories/category_repository.dart';
import '../../shared/widgets/app_toast.dart';
import 'category_sheet.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  void _openSheet(BuildContext context, {Category? editCategory}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategorySheet(editCategory: editCategory),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context,
      WidgetRef ref,
      Category cat,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete category?',
            style: TextStyle(fontFamily: 'DMSans')),
        content: Text(
          'All tasks in "${cat.name}" will lose their category. This cannot be undone.',
          style: const TextStyle(fontFamily: 'DMSans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.priorityHigh),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await CategoryRepository.instance.deleteCategory(cat);
        if (context.mounted) AppToast.show(context, '${cat.name} deleted');
      } catch (e) {
        if (context.mounted) AppToast.show(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textPrimary = scheme.onSurface;
    final textSecondary = scheme.onSurface.withOpacity(0.5);
    final catsAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categories',
              style: AppTypography.labelMedium.copyWith(
                  color: textPrimary, fontWeight: FontWeight.w600),
            ),
            Text(
              'カテゴリ管理',
              style: AppTypography.jpLight.copyWith(
                  fontSize: 10, color: textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: scheme.primary),
            onPressed: () => _openSheet(context),
            tooltip: 'Add category',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: catsAsync.when(
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cats) {
          if (cats.isEmpty) {
            return const Center(child: Text('No categories'));
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            itemCount: cats.length,
            // Task 3.09 — persist new sort order on drag end
            onReorder: (oldIndex, newIndex) async {
              HapticFeedback.mediumImpact();
              if (newIndex > oldIndex) newIndex--;
              final reordered = List<Category>.from(cats);
              final moved = reordered.removeAt(oldIndex);
              reordered.insert(newIndex, moved);
              await CategoryRepository.instance.reorder(reordered);
            },
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                child: child,
                builder: (context, child) {
                  return Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(12),
                    child: child,
                  );
                },
              );
            },
            itemBuilder: (context, index) {
              final cat = cats[index];
              return _CategoryRow(
                key: ValueKey(cat.uuid),
                cat: cat,
                index: index,
                onEdit: () => _openSheet(context, editCategory: cat),
                onDelete: cat.isSystem
                    ? null
                    : () => _confirmDelete(context, ref, cat),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(context),
        backgroundColor: scheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Add Category',
          style: AppTypography.labelMedium.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

// ── Category row ──────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    super.key,
    required this.cat,
    required this.onEdit,
    required this.onDelete,
    required this.index,
  });

  final Category cat;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = AppColors.accentFromHex(cat.colorHex);
    final icon = _iconForIdentifier(cat.iconIdentifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.onSurface.withOpacity(0.07)),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Row(
          children: [
            Text(
              cat.name,
              style: AppTypography.bodyMedium.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (cat.isSystem) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: scheme.onSurface.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'system',
                  style: AppTypography.labelSmall.copyWith(
                    color: scheme.onSurface.withOpacity(0.35),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: cat.nameJp.isNotEmpty
            ? Text(
          cat.nameJp,
          style: AppTypography.jpLight.copyWith(
            fontSize: 11,
            color: scheme.onSurface.withOpacity(0.4),
          ),
        )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit button
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                size: 18,
                color: scheme.onSurface.withOpacity(0.4),
              ),
              onPressed: onEdit,
            ),
            // Delete button — hidden for system categories
            if (onDelete != null)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: AppColors.priorityHigh,
                ),
                onPressed: onDelete,
              )
            else
              const SizedBox(width: 40),
            // Drag handle (ReorderableListView uses this automatically)
            ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_handle_rounded,
                size: 20,
                color: scheme.onSurface.withOpacity(0.25),
              ),
            ),
          ],
        ),
      ),
    );
  }


  IconData _iconForIdentifier(String id) {
    const map = <String, IconData>{
      'briefcase': Icons.work_outline_rounded,
      'person': Icons.person_outline_rounded,
      'book': Icons.menu_book_rounded,
      'heart': Icons.favorite_border_rounded,
      'coffee': Icons.coffee_rounded,
      'star': Icons.star_border_rounded,
      'home': Icons.home_outlined,
      'cart': Icons.shopping_cart_outlined,
      'fitness': Icons.fitness_center_rounded,
      'music': Icons.music_note_rounded,
      'code': Icons.code_rounded,
      'travel': Icons.flight_outlined,
      'food': Icons.restaurant_outlined,
      'money': Icons.attach_money_rounded,
      'photo': Icons.photo_camera_outlined,
      'game': Icons.sports_esports_outlined,
    };
    return map[id] ?? Icons.category_outlined;
  }
}