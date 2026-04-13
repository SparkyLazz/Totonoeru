import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/category.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/services/database_service.dart';

// ── Sheet mode (2.12) ─────────────────────────────────────────────────────────

enum _SheetMode { task, timeBlock }

// ── AddTaskSheet ──────────────────────────────────────────────────────────────

class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key, this.editTask, this.parentTaskId});

  /// If non-null, sheet opens in edit mode pre-filled with this task.
  final Task? editTask;

  /// If set, this is a subtask creation sheet.
  final String? parentTaskId;

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  _SheetMode _mode = _SheetMode.task;
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String _priority = 'medium';
  String? _selectedCategoryId;
  DateTime? _dueDate;
  DateTime? _reminderTime;

  // Subtask inputs (2.14)
  final List<String> _subtaskTitles = [];
  final _subtaskController = TextEditingController();

  List<Category> _categories = [];
  bool _saving = false;

  bool get _isEditMode => widget.editTask != null;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _prefillIfEdit();
  }

  Future<void> _loadCategories() async {
    final cats = await DatabaseService.instance.isar.categorys.where().findAll();
    cats.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    if (mounted) setState(() => _categories = cats);
    // Default category
    if (_selectedCategoryId == null && cats.isNotEmpty) {
      setState(() => _selectedCategoryId = cats.first.uuid);
    }
  }

  void _prefillIfEdit() {
    final t = widget.editTask;
    if (t == null) return;
    _titleController.text = t.title;
    _notesController.text = t.notes ?? '';
    _priority = t.priority;
    _selectedCategoryId = t.categoryId;
    _dueDate = t.dueDate;
    _reminderTime = t.reminderTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    if (_selectedCategoryId == null) return;
    setState(() => _saving = true);

    try {
      if (_isEditMode) {
        // Edit mode (2.16)
        await TaskRepository.instance.updateTask(
          widget.editTask!,
          title: _titleController.text.trim(),
          categoryId: _selectedCategoryId,
          priority: _priority,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          dueDate: _dueDate,
          reminderTime: _reminderTime,
        );
      } else {
        // Create (2.15)
        final task = await TaskRepository.instance.createTask(
          title: _titleController.text.trim(),
          categoryId: _selectedCategoryId!,
          priority: _priority,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          dueDate: _dueDate,
          reminderTime: _reminderTime,
          parentTaskId: widget.parentTaskId,
        );

        // Create inline subtasks (2.14)
        for (final st in _subtaskTitles) {
          await TaskRepository.instance.createTask(
            title: st,
            categoryId: _selectedCategoryId!,
            priority: _priority,
            parentTaskId: task.uuid,
          );
        }
      }

      HapticFeedback.lightImpact();
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subtaskTitles.add(text);
      _subtaskController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = scheme.primary;
    final textPrimary = scheme.onSurface;
    final bg = scheme.surface;
    final border = scheme.onSurface.withOpacity(0.1);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ────────────────────────────────────────────
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // ── Mode toggle Task | Time Block (2.12) ───────────────────
            if (!_isEditMode && widget.parentTaskId == null)
              _ModeToggle(
                mode: _mode,
                accent: accent,
                onSelect: (m) => setState(() => _mode = m),
              ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title (2.13) ───────────────────────────────────
                    TextField(
                      controller: _titleController,
                      autofocus: true,
                      style: AppTypography.headingSmall.copyWith(
                        color: textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: _mode == _SheetMode.task
                            ? 'Task title'
                            : 'Time block title',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        fillColor: Colors.transparent,
                        filled: false,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      minLines: 1,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Divider(color: border),
                    const SizedBox(height: AppSpacing.sm),

                    // ── Notes ──────────────────────────────────────────
                    TextField(
                      controller: _notesController,
                      style: AppTypography.bodyMedium.copyWith(
                          color: textPrimary.withOpacity(0.7)),
                      decoration: InputDecoration(
                        hintText: 'Notes (optional)',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        fillColor: Colors.transparent,
                        filled: false,
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                    const SizedBox(height: AppSpacing.base),

                    // ── Category ───────────────────────────────────────
                    _FieldLabel(label: 'Category', textPrimary: textPrimary),
                    const SizedBox(height: AppSpacing.xs),
                    _CategorySelector(
                      categories: _categories,
                      selectedId: _selectedCategoryId,
                      onSelect: (id) =>
                          setState(() => _selectedCategoryId = id),
                    ),
                    const SizedBox(height: AppSpacing.base),

                    // ── Priority ───────────────────────────────────────
                    _FieldLabel(label: 'Priority', textPrimary: textPrimary),
                    const SizedBox(height: AppSpacing.xs),
                    _PrioritySelector(
                      selected: _priority,
                      onSelect: (p) => setState(() => _priority = p),
                    ),
                    const SizedBox(height: AppSpacing.base),

                    // ── Due date ───────────────────────────────────────
                    _DateRow(
                      icon: Icons.calendar_today_outlined,
                      label: _dueDate == null
                          ? 'Due date'
                          : _formatDate(_dueDate!),
                      hasValue: _dueDate != null,
                      accent: accent,
                      onTap: () => _pickDate(context),
                      onClear: () => setState(() => _dueDate = null),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // ── Reminder ───────────────────────────────────────
                    _DateRow(
                      icon: Icons.notifications_outlined,
                      label: _reminderTime == null
                          ? 'Add reminder'
                          : 'Reminder: ${_formatDate(_reminderTime!)}',
                      hasValue: _reminderTime != null,
                      accent: accent,
                      onTap: () => _pickReminder(context),
                      onClear: () => setState(() => _reminderTime = null),
                    ),

                    // ── Subtasks (2.14) — only on new root tasks ───────
                    if (!_isEditMode && widget.parentTaskId == null) ...[
                      const SizedBox(height: AppSpacing.base),
                      _FieldLabel(
                          label: 'Subtasks', textPrimary: textPrimary),
                      const SizedBox(height: AppSpacing.xs),
                      // Existing subtasks
                      ..._subtaskTitles.asMap().entries.map((e) =>
                          _SubtaskRow(
                            title: e.value,
                            onRemove: () => setState(
                                    () => _subtaskTitles.removeAt(e.key)),
                            textPrimary: textPrimary,
                          )),
                      // Input row
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _subtaskController,
                              style: AppTypography.bodySmall
                                  .copyWith(color: textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Add subtask…',
                                contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 8),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                fillColor: Colors.transparent,
                                filled: false,
                              ),
                              onSubmitted: (_) => _addSubtask(),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline,
                                color: accent, size: 20),
                            onPressed: _addSubtask,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),

                    // ── Save button ────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _saving
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          _isEditMode ? 'Save Changes' : 'Add Task',
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickReminder(BuildContext context) async {
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
    );
    if (time == null) return;
    setState(() {
      _reminderTime = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month]} ${dt.day}, ${dt.year}';
  }
}

// ── Mode toggle ───────────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.mode,
    required this.accent,
    required this.onSelect,
  });
  final _SheetMode mode;
  final Color accent;
  final ValueChanged<_SheetMode> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _Tab(
              label: 'Task',
              selected: mode == _SheetMode.task,
              accent: accent,
              onTap: () => onSelect(_SheetMode.task),
            ),
            _Tab(
              label: 'Time Block',
              selected: mode == _SheetMode.timeBlock,
              accent: accent,
              onTap: () => onSelect(_SheetMode.timeBlock),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: selected ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: selected
                    ? Colors.white
                    : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Category selector ─────────────────────────────────────────────────────────

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
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
        final selected = cat.uuid == selectedId;
        return GestureDetector(
          onTap: () => onSelect(cat.uuid),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? color.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? color : color.withOpacity(0.3),
              ),
            ),
            child: Text(
              cat.name,
              style: AppTypography.labelMedium.copyWith(color: color),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Priority selector ─────────────────────────────────────────────────────────

class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({
    required this.selected,
    required this.onSelect,
  });

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PriorityOption(
          priority: 'high',
          selected: selected == 'high',
          onTap: () => onSelect('high'),
        ),
        const SizedBox(width: 8),
        _PriorityOption(
          priority: 'medium',
          selected: selected == 'medium',
          onTap: () => onSelect('medium'),
        ),
        const SizedBox(width: 8),
        _PriorityOption(
          priority: 'low',
          selected: selected == 'low',
          onTap: () => onSelect('low'),
        ),
      ],
    );
  }
}

class _PriorityOption extends StatelessWidget {
  const _PriorityOption({
    required this.priority,
    required this.selected,
    required this.onTap,
  });

  final String priority;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      'high' => ('High', AppColors.priorityHigh),
      'low' => ('Low', AppColors.priorityLow),
      _ => ('Medium', AppColors.priorityMedium),
    };
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color : color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Date row ──────────────────────────────────────────────────────────────────

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.icon,
    required this.label,
    required this.hasValue,
    required this.accent,
    required this.onTap,
    required this.onClear,
  });

  final IconData icon;
  final String label;
  final bool hasValue;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final textColor = hasValue
        ? accent
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.4);

    return Row(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(color: textColor),
              ),
            ],
          ),
        ),
        if (hasValue) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close, size: 14, color: textColor),
          ),
        ],
      ],
    );
  }
}

// ── Subtask row ───────────────────────────────────────────────────────────────

class _SubtaskRow extends StatelessWidget {
  const _SubtaskRow({
    required this.title,
    required this.onRemove,
    required this.textPrimary,
  });
  final String title;
  final VoidCallback onRemove;
  final Color textPrimary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.subdirectory_arrow_right_rounded,
              size: 14, color: textPrimary.withOpacity(0.4)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodySmall.copyWith(color: textPrimary),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close,
                size: 14, color: textPrimary.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }
}

// ── Field label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.textPrimary});
  final String label;
  final Color textPrimary;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.labelSmall.copyWith(
        color: textPrimary.withOpacity(0.5),
        letterSpacing: 0.5,
      ),
    );
  }
}