// lib/features/schedule/add_time_block_sheet.dart
//
// Tasks 3.18–3.21 — Add/Edit Time Block sheet
// 3.18  Sheet scaffold: title field, start/end time pickers
// 3.19  Fields: category chips, priority chips, notes, optional task link
// 3.20  Save → Isar → timeline live-updates via dayBlocksProvider
// 3.21  Edit mode — pre-fill all fields from existing block

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/categories_provider.dart';
import '../../core/providers/time_blocks_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/category.dart';
import '../../data/models/time_block.dart';
import '../../data/repositories/time_block_repository.dart';
import '../../shared/widgets/app_toast.dart';

class AddTimeBlockSheet extends ConsumerStatefulWidget {
  const AddTimeBlockSheet({
    super.key,
    this.editBlock,
    this.initialDate,
    this.initialTime,
  });

  final TimeBlock? editBlock;
  final DateTime? initialDate;
  final DateTime? initialTime;

  @override
  ConsumerState<AddTimeBlockSheet> createState() => _AddTimeBlockSheetState();
}

class _AddTimeBlockSheetState extends ConsumerState<AddTimeBlockSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _notesCtrl;

  late DateTime _startTime;
  late DateTime _endTime;
  String? _categoryId;
  String _priority = 'medium';
  bool _saving = false;

  bool get _isEditing => widget.editBlock != null;

  @override
  void initState() {
    super.initState();
    final block = widget.editBlock;

    _titleCtrl = TextEditingController(text: block?.title ?? '');
    _notesCtrl = TextEditingController(text: block?.notes ?? '');
    _priority = block?.priority ?? 'medium';
    _categoryId = block?.categoryId;

    // Default start time: initialTime or next round hour
    final base = block?.startTime ??
        widget.initialTime ??
        _nextRoundHour(widget.initialDate ?? DateTime.now());
    _startTime = base;
    _endTime = block?.endTime ?? base.add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  /// Round up to the next whole hour.
  DateTime _nextRoundHour(DateTime dt) {
    if (dt.minute == 0 && dt.second == 0) return dt;
    return DateTime(dt.year, dt.month, dt.day, dt.hour + 1);
  }

  // ── Time picker helpers ───────────────────────────────────────────────────

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    final base = isStart ? _startTime : _endTime;
    final updated = DateTime(
        base.year, base.month, base.day, picked.hour, picked.minute);
    setState(() {
      if (isStart) {
        _startTime = updated;
        // Keep duration if possible; else snap end to start+1h
        if (!_endTime.isAfter(_startTime)) {
          _endTime = _startTime.add(const Duration(hours: 1));
        }
      } else {
        if (updated.isAfter(_startTime)) {
          _endTime = updated;
        } else {
          AppToast.show(context, 'End time must be after start time');
        }
      }
    });
  }

  // ── Save ──────────────────────────────────────────────────────────────────

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
    if (!_endTime.isAfter(_startTime)) {
      AppToast.show(context, 'End time must be after start time');
      return;
    }

    // Overlap check — warn but don't block
    final overlaps = await TimeBlockRepository.instance.getOverlapping(
      start: _startTime,
      end: _endTime,
      excludeUuid: widget.editBlock?.uuid,
    );
    if (overlaps.isNotEmpty && mounted) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Overlap detected',
              style: TextStyle(fontFamily: 'DMSans')),
          content: Text(
            'This block overlaps with "${overlaps.first.title}". Save anyway?',
            style: const TextStyle(fontFamily: 'DMSans'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save anyway')),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() => _saving = true);
    try {
      final repo = TimeBlockRepository.instance;
      if (_isEditing) {
        // Task 3.21 — edit mode
        await repo.updateTimeBlock(
          widget.editBlock!,
          title: title,
          startTime: _startTime,
          endTime: _endTime,
          categoryId: _categoryId!,
          priority: _priority,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
      } else {
        // Task 3.20 — create
        await repo.createTimeBlock(
          title: title,
          startTime: _startTime,
          endTime: _endTime,
          categoryId: _categoryId!,
          priority: _priority,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
      }
      // Invalidate provider → HourlyTimeline auto-rebuilds (3.20)
      ref.invalidate(dayBlocksProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) AppToast.show(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = scheme.primary;
    final textPrimary = scheme.onSurface;
    final textSecondary = scheme.onSurface.withOpacity(0.5);
    final catsAsync = ref.watch(categoriesProvider);

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
              // ── Handle ──
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

              // ── Title ──
              Text(
                _isEditing ? 'Edit Block' : 'New Time Block',
                style:
                AppTypography.headingMedium.copyWith(color: textPrimary),
              ),
              Text(
                _isEditing ? 'ブロックを編集' : '時間ブロックを追加',
                style: AppTypography.jpLight.copyWith(color: textSecondary),
              ),
              const SizedBox(height: 20),

              // ── Title field (3.18) ──
              _SectionLabel('Title', textSecondary),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                autofocus: !_isEditing,
                maxLength: 80,
                style: AppTypography.bodyMedium
                    .copyWith(color: textPrimary),
                decoration: _inputDec(
                    scheme, hint: 'e.g. Deep work session'),
              ),
              const SizedBox(height: 16),

              // ── Time pickers (3.18) ──
              _SectionLabel('Time', textSecondary),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _TimeTile(
                      label: 'Start',
                      time: _startTime,
                      accent: accent,
                      scheme: scheme,
                      onTap: () => _pickTime(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded,
                      size: 16,
                      color: scheme.onSurface.withOpacity(0.3)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TimeTile(
                      label: 'End',
                      time: _endTime,
                      accent: accent,
                      scheme: scheme,
                      onTap: () => _pickTime(isStart: false),
                    ),
                  ),
                ],
              ),
              // Duration hint
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _durationLabel(),
                  style: AppTypography.labelSmall.copyWith(
                      color: scheme.onSurface.withOpacity(0.4)),
                ),
              ),
              const SizedBox(height: 18),

              // ── Category chips (3.19) ──
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

              // ── Priority chips (3.19) ──
              _SectionLabel('Priority', textSecondary),
              const SizedBox(height: 8),
              _PriorityChips(
                selected: _priority,
                onSelect: (p) => setState(() => _priority = p),
              ),
              const SizedBox(height: 18),

              // ── Notes (3.19) ──
              _SectionLabel('Notes (optional)', textSecondary),
              const SizedBox(height: 8),
              TextField(
                controller: _notesCtrl,
                maxLines: 3,
                maxLength: 300,
                style: AppTypography.bodyMedium
                    .copyWith(color: textPrimary),
                decoration: _inputDec(scheme,
                    hint: 'Add notes…', counterStyle: true),
              ),
              const SizedBox(height: 24),

              // ── Save button ──
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
                    _isEditing ? 'Save Changes' : 'Add Block',
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

  String _durationLabel() {
    final mins = _endTime.difference(_startTime).inMinutes;
    if (mins <= 0) return 'Invalid range';
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  InputDecoration _inputDec(
      ColorScheme scheme, {
        required String hint,
        bool counterStyle = false,
      }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyMedium
            .copyWith(color: scheme.onSurface.withOpacity(0.3)),
        counterText: '',
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
}

// ── Time tile ─────────────────────────────────────────────────────────────────

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.time,
    required this.accent,
    required this.scheme,
    required this.onTap,
  });
  final String label;
  final DateTime time;
  final Color accent;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTypography.labelSmall.copyWith(
                color: scheme.onSurface.withOpacity(0.4),
                fontSize: 10,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: AppTypography.headingSmall.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category chips ────────────────────────────────────────────────────────────

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
              color: isSelected
                  ? color
                  : color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? color
                    : color.withOpacity(0.25),
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

// ── Priority chips ────────────────────────────────────────────────────────────

class _PriorityChips extends StatelessWidget {
  const _PriorityChips({
    required this.selected,
    required this.onSelect,
  });
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
                  Icon(
                    Icons.flag_rounded,
                    size: 12,
                    color: isSelected ? Colors.white : color,
                  ),
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

// ── Section label ─────────────────────────────────────────────────────────────

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