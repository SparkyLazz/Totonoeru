// lib/features/tasks/add_task_sheet.dart
//
// Redesigned to match AddTimeBlockSheet visual style exactly:
// - Same container/handle/header pattern
// - Same UPPERCASE section labels
// - Same filled text fields (not borderless)
// - Same category + priority chip rows
// - Same save button

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/categories_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/category.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../shared/widgets/app_toast.dart';

class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key, this.editTask, this.parentTaskId});

  final Task? editTask;
  final String? parentTaskId;

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _subtaskCtrl;

  String _priority = 'medium';
  String? _categoryId;
  DateTime? _dueDate;
  DateTime? _reminderTime;
  final List<String> _subtaskTitles = [];
  bool _saving = false;

  bool get _isEditing => widget.editTask != null;

  @override
  void initState() {
    super.initState();
    final t = widget.editTask;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _notesCtrl = TextEditingController(text: t?.notes ?? '');
    _subtaskCtrl = TextEditingController();
    _priority = t?.priority ?? 'medium';
    _categoryId = t?.categoryId;
    _dueDate = t?.dueDate;
    _reminderTime = t?.reminderTime;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _subtaskCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      AppToast.show(context, 'Title is required');
      return;
    }
    if (_categoryId == null) {
      AppToast.show(context, 'Please select a category');
      return;
    }
    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await TaskRepository.instance.updateTask(
          widget.editTask!,
          title: title,
          categoryId: _categoryId,
          priority: _priority,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          dueDate: _dueDate,
          reminderTime: _reminderTime,
        );
      } else {
        final task = await TaskRepository.instance.createTask(
          title: title,
          categoryId: _categoryId!,
          priority: _priority,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          dueDate: _dueDate,
          reminderTime: _reminderTime,
          parentTaskId: widget.parentTaskId,
        );
        for (final st in _subtaskTitles) {
          await TaskRepository.instance.createTask(
            title: st,
            categoryId: _categoryId!,
            priority: _priority,
            parentTaskId: task.uuid,
          );
        }
      }
      HapticFeedback.lightImpact();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) AppToast.show(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addSubtask() {
    final text = _subtaskCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subtaskTitles.add(text);
      _subtaskCtrl.clear();
    });
  }

  Future<void> _pickDueDate() async {
    HapticFeedback.lightImpact();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  Future<void> _pickReminder() async {
    HapticFeedback.lightImpact();
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderTime ?? DateTime.now()),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (time == null) return;
    setState(() {
      _reminderTime = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = scheme.primary;
    final textPrimary = scheme.onSurface;
    final textSecondary = scheme.onSurface.withOpacity(0.5);
    final catsAsync = ref.watch(categoriesProvider);

    // Auto-select first category if none chosen yet
    final cats = catsAsync.valueOrNull ?? [];
    if (_categoryId == null && cats.isNotEmpty) {
      // schedule for next frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_categoryId == null && mounted) {
          setState(() => _categoryId = cats.first.uuid);
        }
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle ──────────────────────────────────────────────
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurface.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Header ──────────────────────────────────────────────
              Text(
                _isEditing ? 'Edit Task' : 'New Task',
                style: AppTypography.headingMedium.copyWith(color: textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                _isEditing ? 'タスクを編集' : 'タスクを追加',
                style: AppTypography.jpLight.copyWith(color: textSecondary),
              ),
              const SizedBox(height: 20),

              // ── Title field ──────────────────────────────────────────
              _SectionLabel('Title', textSecondary),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                autofocus: !_isEditing,
                maxLength: 120,
                style: AppTypography.bodyMedium.copyWith(color: textPrimary),
                decoration: _inputDec(scheme, hint: 'What needs to be done?'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // ── Category chips ───────────────────────────────────────
              _SectionLabel('Category', textSecondary),
              const SizedBox(height: 8),
              catsAsync.when(
                data: (cats) => _CategoryChips(
                  categories: cats,
                  selectedId: _categoryId,
                  onSelect: (id) => setState(() => _categoryId = id),
                ),
                loading: () => const SizedBox(height: 40),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 18),

              // ── Priority chips ───────────────────────────────────────
              _SectionLabel('Priority', textSecondary),
              const SizedBox(height: 8),
              _PriorityChips(
                selected: _priority,
                onSelect: (p) => setState(() => _priority = p),
              ),
              const SizedBox(height: 18),

              // ── Due date row ─────────────────────────────────────────
              _SectionLabel('Due date', textSecondary),
              const SizedBox(height: 8),
              _DateTile(
                icon: Icons.calendar_today_outlined,
                label: _dueDate == null ? 'None' : _fmtDate(_dueDate!),
                isSet: _dueDate != null,
                accent: accent,
                scheme: scheme,
                onTap: _pickDueDate,
                onClear: _dueDate != null
                    ? () => setState(() => _dueDate = null)
                    : null,
              ),
              const SizedBox(height: 12),

              // ── Reminder row ─────────────────────────────────────────
              _SectionLabel('Reminder', textSecondary),
              const SizedBox(height: 8),
              _DateTile(
                icon: Icons.notifications_outlined,
                label: _reminderTime == null
                    ? 'None'
                    : '${_fmtDate(_reminderTime!)}  ${_fmtTime(_reminderTime!)}',
                isSet: _reminderTime != null,
                accent: accent,
                scheme: scheme,
                onTap: _pickReminder,
                onClear: _reminderTime != null
                    ? () => setState(() => _reminderTime = null)
                    : null,
              ),
              const SizedBox(height: 18),

              // ── Subtasks (create mode only) ──────────────────────────
              if (!_isEditing) ...[
                _SectionLabel('Subtasks', textSecondary),
                const SizedBox(height: 8),

                // Existing subtask list
                ..._subtaskTitles.asMap().entries.map((e) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: scheme.onSurface.withOpacity(0.08)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_box_outline_blank_rounded,
                            size: 16,
                            color: scheme.onSurface.withOpacity(0.3)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(e.value,
                              style: AppTypography.bodyMedium
                                  .copyWith(color: textPrimary)),
                        ),
                        GestureDetector(
                          onTap: () => setState(
                                  () => _subtaskTitles.removeAt(e.key)),
                          child: Icon(Icons.close_rounded,
                              size: 16,
                              color: scheme.onSurface.withOpacity(0.3)),
                        ),
                      ],
                    ),
                  );
                }),

                // Add subtask input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _subtaskCtrl,
                        style: AppTypography.bodyMedium
                            .copyWith(color: textPrimary),
                        decoration: _inputDec(scheme,
                            hint: 'Add a subtask…'),
                        onSubmitted: (_) => _addSubtask(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _addSubtask,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.add_rounded,
                            size: 20, color: accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],

              // ── Notes ────────────────────────────────────────────────
              _SectionLabel('Notes (optional)', textSecondary),
              const SizedBox(height: 8),
              TextField(
                controller: _notesCtrl,
                maxLines: 3,
                maxLength: 500,
                style: AppTypography.bodyMedium.copyWith(color: textPrimary),
                decoration:
                _inputDec(scheme, hint: 'Add notes…', counter: true),
              ),
              const SizedBox(height: 24),

              // ── Save button ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : Text(
                    _isEditing ? 'Save Changes' : 'Add Task',
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(
      ColorScheme scheme, {
        required String hint,
        bool counter = false,
      }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyMedium
            .copyWith(color: scheme.onSurface.withOpacity(0.3)),
        counterText: counter ? null : '',
        filled: true,
        fillColor: scheme.onSurface.withOpacity(0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          BorderSide(color: scheme.onSurface.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          BorderSide(color: scheme.onSurface.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );

  String _fmtDate(DateTime dt) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ── Section label — identical to AddTimeBlockSheet ────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.labelSmall.copyWith(
        color: color,
        letterSpacing: 0.6,
      ),
    );
  }
}

// ── Date/reminder tile — styled like _TimeTile ────────────────────────────────

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.icon,
    required this.label,
    required this.isSet,
    required this.accent,
    required this.scheme,
    required this.onTap,
    this.onClear,
  });
  final IconData icon;
  final String label;
  final bool isSet;
  final Color accent;
  final ColorScheme scheme;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSet
              ? accent.withOpacity(0.06)
              : scheme.onSurface.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSet
                ? accent.withOpacity(0.2)
                : scheme.onSurface.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: isSet
                    ? accent
                    : scheme.onSurface.withOpacity(0.4)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSet
                      ? accent
                      : scheme.onSurface.withOpacity(0.45),
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded,
                    size: 16,
                    color: scheme.onSurface.withOpacity(0.3)),
              )
            else
              Icon(Icons.chevron_right_rounded,
                  size: 16,
                  color: scheme.onSurface.withOpacity(0.25)),
          ],
        ),
      ),
    );
  }
}

// ── Category chips — identical to AddTimeBlockSheet ───────────────────────────

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });
  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final color = AppColors.accentFromHex(cat.colorHex);
        final isSelected = cat.uuid == selectedId;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onSelect(cat.uuid);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected ? color : color.withOpacity(0.25),
              ),
            ),
            child: Text(
              cat.name,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Priority chips — identical to AddTimeBlockSheet ───────────────────────────

class _PriorityChips extends StatelessWidget {
  const _PriorityChips(
      {required this.selected, required this.onSelect});
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    const options = [
      ('high', 'High', AppColors.priorityHigh),
      ('medium', 'Medium', AppColors.priorityMedium),
      ('low', 'Low', AppColors.priorityLow),
    ];
    return Row(
      children: options.map((opt) {
        final (value, label, color) = opt;
        final isSelected = selected == value;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onSelect(value);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected ? color : color.withOpacity(0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flag_rounded,
                      size: 12,
                      color: isSelected ? Colors.white : color),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected ? Colors.white : color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}