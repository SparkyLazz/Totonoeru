import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/category_repository.dart';
import '../../core/db/collections.dart';
import '../../core/db/task_repository.dart';
import '../../core/theme/app_accent_colors.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

void showAddTaskSheet(BuildContext context, {Task? existingTask}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => AddTaskSheet(existingTask: existingTask),
  );
}

class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key, this.existingTask});
  final Task? existingTask;

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _titleFocus = FocusNode();

  TaskPriority _priority = TaskPriority.medium;
  String? _selectedCategoryUuid;
  DateTime? _dueDate;
  bool _saving = false;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.existingTask!;
      _titleController.text = t.title;
      _notesController.text = t.notes ?? '';
      _priority = t.priority;
      _selectedCategoryUuid = t.categoryId.isEmpty ? null : t.categoryId;
      _dueDate = t.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _titleFocus.requestFocus();
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(taskRepositoryProvider);

    if (_isEditing) {
      final task = widget.existingTask!;
      task.title = title;
      task.notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();
      task.priority = _priority;
      task.categoryId = _selectedCategoryUuid ?? '';
      task.dueDate = _dueDate;
      await repo.updateTask(task);
    } else {
      await repo.createTask(
        title: title,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        priority: _priority,
        categoryId: _selectedCategoryUuid,
        dueDate: _dueDate,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        final accent = Theme.of(context).extension<AppAccentColors>()!;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: accent.accent,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == tomorrow) return 'Tomorrow';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surfaceVariant = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final accent = Theme.of(context).extension<AppAccentColors>()!;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            decoration: BoxDecoration(
              color: textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditing ? 'Edit Task' : 'New Task',
                    style: AppTextStyles.headingS.copyWith(color: textPrimary),
                  ),
                  const SizedBox(height: 16),

                  _FieldLabel(label: 'TITLE', required: true),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleController,
                    focusNode: _titleFocus,
                    autofocus: !_isEditing,
                    maxLines: 2,
                    minLines: 1,
                    style: AppTextStyles.bodyL.copyWith(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'What needs to be done?',
                      hintStyle: AppTextStyles.bodyL.copyWith(color: textTertiary),
                      filled: true,
                      fillColor: surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: textTertiary, width: 0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: textTertiary, width: 0.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accent.accent, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _FieldLabel(label: 'CATEGORY'),
                  const SizedBox(height: 8),
                  _CategoryChips(
                    selectedUuid: _selectedCategoryUuid,
                    onSelected: (uuid) => setState(() =>
                    _selectedCategoryUuid =
                    uuid == _selectedCategoryUuid ? null : uuid),
                  ),
                  const SizedBox(height: 16),

                  _FieldLabel(label: 'PRIORITY'),
                  const SizedBox(height: 8),
                  _PrioritySelector(
                    selected: _priority,
                    onChanged: (p) => setState(() => _priority = p),
                  ),
                  const SizedBox(height: 16),

                  _FieldLabel(label: 'DUE DATE'),
                  const SizedBox(height: 8),
                  _FieldButton(
                    icon: Icons.calendar_today_outlined,
                    iconBg: const Color(0xFFFCEBEB),
                    iconColor: const Color(0xFFE24B4A),
                    label: 'Due date',
                    value: _dueDate != null ? _formatDate(_dueDate!) : 'None',
                    isActive: _dueDate != null,
                    onTap: _pickDate,
                    onClear: _dueDate != null
                        ? () => setState(() => _dueDate = null)
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _FieldLabel(label: 'NOTES'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    minLines: 2,
                    style: AppTextStyles.bodyM.copyWith(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Add notes…',
                      hintStyle: AppTextStyles.bodyM.copyWith(color: textTertiary),
                      filled: true,
                      fillColor: surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: textTertiary, width: 0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: textTertiary, width: 0.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accent.accent, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(
                top: BorderSide(color: textTertiary, width: 0.5),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 52,
                    height: 48,
                    decoration: BoxDecoration(
                      color: surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: textTertiary, width: 0.5),
                    ),
                    child: Icon(Icons.close_rounded, size: 18, color: textSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent.accent,
                        disabledBackgroundColor: accent.accent.withValues(alpha: 0.5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _saving
                            ? 'Saving…'
                            : _isEditing
                            ? 'Save Changes'
                            : 'Add Task',
                        style: AppTextStyles.bodyM.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FIELD LABEL
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.required = false});
  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    return Row(
      children: [
        Text(label,
            style: AppTextStyles.labelXS.copyWith(
              color: textTertiary,
              letterSpacing: 0.7,
            )),
        if (required) ...[
          const SizedBox(width: 4),
          Text('*',
              style: AppTextStyles.labelXS
                  .copyWith(color: const Color(0xFFE24B4A))),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY CHIPS
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips({
    required this.selectedUuid,
    required this.onSelected,
  });
  final String? selectedUuid;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surfaceVariant = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return categoriesAsync.when(
      data: (cats) => Wrap(
        spacing: 6,
        runSpacing: 6,
        children: cats.map((cat) {
          final color = Color(cat.colorValue);
          final isSelected = selectedUuid == cat.uuid;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onSelected(cat.uuid);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.12) : surfaceVariant,
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                cat.name,
                style: AppTextStyles.bodyS.copyWith(
                  color: isSelected ? color : textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIORITY SELECTOR
// ─────────────────────────────────────────────────────────────────────────────

class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({
    required this.selected,
    required this.onChanged,
  });
  final TaskPriority selected;
  final ValueChanged<TaskPriority> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surfaceVariant = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final accent = Theme.of(context).extension<AppAccentColors>()!;

    final options = [
      (TaskPriority.high, 'High', const Color(0xFFE24B4A), const Color(0xFFFCEBEB)),
      (TaskPriority.medium, 'Medium', const Color(0xFFEF9F27), const Color(0xFFFAEEDA)),
      (TaskPriority.low, 'Low', accent.accent, accent.accentBg),
    ];

    return Row(
      children: options.map((opt) {
        final (priority, label, fg, bg) = opt;
        final isActive = selected == priority;
        final isLast = priority == TaskPriority.low;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onChanged(priority);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: isLast ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? bg : surfaceVariant,
                border: Border.all(
                  color: isActive ? fg : Colors.transparent,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyS.copyWith(
                  color: isActive ? fg : textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FIELD BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _FieldButton extends StatelessWidget {
  const _FieldButton({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.isActive,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    final surfaceVariant = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final accent = Theme.of(context).extension<AppAccentColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: isActive ? accent.accentBg : surfaceVariant,
          border: Border.all(
            color: isActive ? accent.accent : Colors.transparent,
            width: isActive ? 1.5 : 0,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 13, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.labelXS.copyWith(color: textTertiary)),
                  const SizedBox(height: 1),
                  Text(value,
                      style: AppTextStyles.bodyS.copyWith(
                        color: isActive ? accent.accent : textPrimary,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded, size: 16, color: textTertiary),
              ),
          ],
        ),
      ),
    );
  }
}