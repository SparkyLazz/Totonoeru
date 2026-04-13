// lib/features/settings/category_sheet.dart
//
// Task 3.08 — Add/Edit category bottom sheet
// Fields: name, JP label, color (6 swatches + custom hex), icon (grid picker)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/category.dart';
import '../../data/repositories/category_repository.dart';
import '../../shared/widgets/app_toast.dart';

// ── Color swatches ────────────────────────────────────────────────────────────

const _swatches = [
  '#4A90D9', // Blue (Work)
  '#7F77DD', // Purple (Personal)
  '#1D9E75', // Green (Study)
  '#EF9F27', // Amber (Health)
  '#D44C3A', // Coral (Break)
  '#3CBFAE', // Teal
  '#E24B4A', // Red
  '#5A5A5A', // Mono
  '#F59E0B', // Warm amber
  '#8B5CF6', // Violet
  '#EC4899', // Pink
  '#10B981', // Emerald
];

// ── Icon options ──────────────────────────────────────────────────────────────

const _icons = <String, IconData>{
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

// ── CategorySheet ─────────────────────────────────────────────────────────────

class CategorySheet extends StatefulWidget {
  const CategorySheet({super.key, this.editCategory});

  /// Pass null to create, pass a Category to edit.
  final Category? editCategory;

  @override
  State<CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<CategorySheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _nameJpCtrl;
  late final TextEditingController _hexCtrl;

  late String _selectedColor;
  late String _selectedIcon;
  bool _saving = false;

  bool get _isEditing => widget.editCategory != null;

  @override
  void initState() {
    super.initState();
    final cat = widget.editCategory;
    _selectedColor = cat?.colorHex ?? _swatches.first;
    _selectedIcon = cat?.iconIdentifier ?? _icons.keys.first;
    _nameCtrl = TextEditingController(text: cat?.name ?? '');
    _nameJpCtrl = TextEditingController(text: cat?.nameJp ?? '');
    _hexCtrl = TextEditingController(text: _selectedColor);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameJpCtrl.dispose();
    _hexCtrl.dispose();
    super.dispose();
  }

  bool _isValidHex(String hex) =>
      RegExp(r'^#([0-9A-Fa-f]{6})$').hasMatch(hex);

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      AppToast.show(context, 'Name is required');
      return;
    }
    if (!_isValidHex(_selectedColor)) {
      AppToast.show(context, 'Invalid hex color');
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = CategoryRepository.instance;
      if (_isEditing) {
        await repo.updateCategory(
          widget.editCategory!,
          name: name,
          nameJp: _nameJpCtrl.text.trim(),
          colorHex: _selectedColor,
          iconIdentifier: _selectedIcon,
        );
      } else {
        await repo.createCategory(
          name: name,
          nameJp: _nameJpCtrl.text.trim(),
          colorHex: _selectedColor,
          iconIdentifier: _selectedIcon,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) AppToast.show(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = scheme.primary;
    final textPrimary = scheme.onSurface;
    final textSecondary = scheme.onSurface.withOpacity(0.5);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
                _isEditing ? 'Edit Category' : 'New Category',
                style: AppTypography.headingMedium.copyWith(color: textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                _isEditing ? 'カテゴリを編集' : 'カテゴリを追加',
                style: AppTypography.jpLight.copyWith(color: textSecondary),
              ),
              const SizedBox(height: 24),

              // ── Preview row ──
              _PreviewRow(
                name: _nameCtrl.text.isEmpty ? 'Category' : _nameCtrl.text,
                colorHex: _selectedColor,
                iconIdentifier: _selectedIcon,
              ),
              const SizedBox(height: 24),

              // ── Name field ──
              _Label('Name', textSecondary),
              const SizedBox(height: 8),
              _TextField(
                controller: _nameCtrl,
                hint: 'e.g. Work',
                maxLength: 30,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // ── JP name field ──
              _Label('Japanese label (optional)', textSecondary),
              const SizedBox(height: 8),
              _TextField(
                controller: _nameJpCtrl,
                hint: 'e.g. 仕事',
                maxLength: 20,
              ),
              const SizedBox(height: 20),

              // ── Color swatches ──
              _Label('Color', textSecondary),
              const SizedBox(height: 12),
              _ColorGrid(
                swatches: _swatches,
                selected: _selectedColor,
                onSelect: (hex) => setState(() {
                  _selectedColor = hex;
                  _hexCtrl.text = hex;
                }),
              ),
              const SizedBox(height: 10),
              // Hex input
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _isValidHex(_selectedColor)
                          ? AppColors.accentFromHex(_selectedColor)
                          : scheme.onSurface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _hexCtrl,
                      style: AppTypography.bodyMedium.copyWith(
                        color: textPrimary,
                        fontFamily: 'monospace',
                      ),
                      decoration: InputDecoration(
                        hintText: '#3CBFAE',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: textSecondary,
                        ),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: scheme.onSurface.withOpacity(0.15),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                      inputFormatters: [
                        _HexInputFormatter(),
                      ],
                      onChanged: (v) {
                        if (_isValidHex(v)) {
                          setState(() => _selectedColor = v);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Icon picker ──
              _Label('Icon', textSecondary),
              const SizedBox(height: 12),
              _IconGrid(
                icons: _icons,
                selected: _selectedIcon,
                selectedColor: _isValidHex(_selectedColor)
                    ? AppColors.accentFromHex(_selectedColor)
                    : accent,
                onSelect: (id) => setState(() => _selectedIcon = id),
              ),
              const SizedBox(height: 28),

              // ── Save button ──
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    _isEditing ? 'Save Changes' : 'Add Category',
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
}

// ── Preview row ───────────────────────────────────────────────────────────────

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.name,
    required this.colorHex,
    required this.iconIdentifier,
  });
  final String name;
  final String colorHex;
  final String iconIdentifier;

  @override
  Widget build(BuildContext context) {
    final isValid = RegExp(r'^#([0-9A-Fa-f]{6})$').hasMatch(colorHex);
    final color = isValid
        ? AppColors.accentFromHex(colorHex)
        : Theme.of(context).colorScheme.primary;
    final icon = _icons[iconIdentifier] ?? Icons.category_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Color grid ────────────────────────────────────────────────────────────────

class _ColorGrid extends StatelessWidget {
  const _ColorGrid({
    required this.swatches,
    required this.selected,
    required this.onSelect,
  });
  final List<String> swatches;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: swatches.map((hex) {
        final color = AppColors.accentFromHex(hex);
        final isSelected = selected.toLowerCase() == hex.toLowerCase();
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onSelect(hex);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

// ── Icon grid ─────────────────────────────────────────────────────────────────

class _IconGrid extends StatelessWidget {
  const _IconGrid({
    required this.icons,
    required this.selected,
    required this.selectedColor,
    required this.onSelect,
  });
  final Map<String, IconData> icons;
  final String selected;
  final Color selectedColor;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: icons.entries.map((e) {
        final isSelected = selected == e.key;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onSelect(e.key);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? selectedColor.withOpacity(0.15)
                  : scheme.onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? selectedColor
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Icon(
              e.value,
              size: 20,
              color: isSelected
                  ? selectedColor
                  : scheme.onSurface.withOpacity(0.4),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text, this.color);
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

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    this.maxLength,
    this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      maxLength: maxLength,
      onChanged: onChanged,
      style: AppTypography.bodyMedium.copyWith(color: scheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: scheme.onSurface.withOpacity(0.35),
        ),
        counterText: '',
        filled: true,
        fillColor: scheme.onSurface.withOpacity(0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.onSurface.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.onSurface.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

// ── Hex input formatter ───────────────────────────────────────────────────────

class _HexInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var text = newValue.text;
    if (!text.startsWith('#')) text = '#$text';
    if (text.length > 7) text = text.substring(0, 7);
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}