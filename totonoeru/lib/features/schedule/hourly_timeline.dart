// lib/features/schedule/hourly_timeline.dart
//
// Tasks 3.14 + 3.15 + 3.17 + 4.23
// 3.14 — HourlyTimeline: scrollable 24hr vertical axis, 60px/hr (now 64px)
// 3.15 — TimeBlockWidget: color-coded, overlap layout engine
// 3.17 — Auto-scroll to current time on open
// 4.23 — Drag-to-reschedule with 15-minute snap

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
import 'time_block_detail_sheet.dart';
import 'schedule_empty_state.dart';

// ── Layout constants ──────────────────────────────────────────────────────────

const double _hourHeight = 64.0;
const double _labelWidth = 52.0;
const double _topPad = 8.0;
const int _hours = 24;
const int _snapMinutes = 15; // 4.23: 15-min snap

// ── HourlyTimeline ─────────────────────────────────────────────────────────────

class HourlyTimeline extends ConsumerStatefulWidget {
  const HourlyTimeline({super.key, this.onTapEmpty});
  final ValueChanged<DateTime>? onTapEmpty;

  @override
  ConsumerState<HourlyTimeline> createState() => _HourlyTimelineState();
}

class _HourlyTimelineState extends ConsumerState<HourlyTimeline> {
  final ScrollController _scroll = ScrollController();
  bool _didAutoScroll = false;

  // ── 4.23 drag state ────────────────────────────────────────────────────
  TimeBlock? _draggingBlock;
  double _dragOffsetY = 0; // px from block top where user grabbed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNow());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToNow() {
    if (_didAutoScroll) return;
    _didAutoScroll = true;
    final now = DateTime.now();
    final offsetPx = _topPad +
        (now.hour * _hourHeight) +
        (now.minute / 60 * _hourHeight) -
        120;
    final target =
    offsetPx.clamp(0.0, _scroll.position.maxScrollExtent);
    _scroll.animateTo(target,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut);
  }

  // ── 4.23: Snap to 15-min grid ─────────────────────────────────────────

  DateTime _snapToGrid(DateTime dt) {
    final minutes = dt.minute;
    final snapped = (minutes / _snapMinutes).round() * _snapMinutes;
    return DateTime(dt.year, dt.month, dt.day, dt.hour).add(
      Duration(minutes: snapped.clamp(0, 59)),
    );
  }

  DateTime _yToDateTime(double y, DateTime selectedDay) {
    final totalMinutes = ((y - _topPad) / _hourHeight * 60)
        .clamp(0, _hours * 60 - 1)
        .toInt();
    return DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      totalMinutes ~/ 60,
      totalMinutes % 60,
    );
  }

  double _dateTimeToY(DateTime dt) {
    return _topPad + (dt.hour * 60 + dt.minute) / 60 * _hourHeight;
  }

  // ── 4.23: Handle drop ─────────────────────────────────────────────────

  Future<void> _onDrop(double globalY, TimeBlock block) async {
    // Convert global Y → local Y within the scrollable canvas
    final RenderBox? box =
    context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localY = box.globalToLocal(Offset(0, globalY)).dy +
        _scroll.offset -
        _dragOffsetY;

    final selected = ref.read(selectedDateProvider);
    final rawStart = _yToDateTime(localY, selected);
    final snappedStart = _snapToGrid(rawStart);
    final duration = block.endTime.difference(block.startTime);
    final snappedEnd = snappedStart.add(duration);

    // Don't update if nothing changed
    if (snappedStart == block.startTime) {
      setState(() => _draggingBlock = null);
      return;
    }

    try {
      await TimeBlockRepository.instance.updateTimeBlock(
        block,
        startTime: snappedStart,
        endTime: snappedEnd,
      );
      ref.invalidate(dayBlocksProvider);
      if (mounted) {
        HapticFeedback.mediumImpact();
        AppToast.show(
          context,
          'Moved to ${_fmt(snappedStart)}',
        );
      }
    } catch (e) {
      if (mounted) AppToast.show(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _draggingBlock = null);
    }
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final blocksAsync = ref.watch(dayBlocksProvider);
    final catsAsync = ref.watch(categoriesProvider);
    final selected = ref.watch(selectedDateProvider);

    final catMap = <String, Category>{
      for (final c in catsAsync.valueOrNull ?? []) c.uuid: c,
    };

    return blocksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (blocks) => blocks.isEmpty
          ? ScheduleEmptyState(
          onAddBlock: widget.onTapEmpty != null
              ? () => widget.onTapEmpty!(DateTime.now())
              : null)
          : _buildTimeline(context, blocks, catMap, selected),
    );
  }

  Widget _buildTimeline(
      BuildContext context,
      List<TimeBlock> blocks,
      Map<String, Category> catMap,
      DateTime selectedDay,
      ) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isToday = selectedDay.year == now.year &&
        selectedDay.month == now.month &&
        selectedDay.day == now.day;

    final totalHeight = _topPad + _hours * _hourHeight + _topPad;
    final layoutBlocks = _computeLayout(blocks);

    return SingleChildScrollView(
      controller: _scroll,
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          children: [
            // Hour grid lines + labels
            ...List.generate(_hours, (h) {
              final top = _topPad + h * _hourHeight;
              return Positioned(
                top: top,
                left: 0,
                right: 0,
                child: _HourRow(
                  hour: h,
                  labelWidth: _labelWidth,
                  scheme: scheme,
                  onTap: () {
                    final dt = DateTime(
                      selectedDay.year,
                      selectedDay.month,
                      selectedDay.day,
                      h,
                    );
                    widget.onTapEmpty?.call(dt);
                  },
                ),
              );
            }),

            // Snap grid indicator while dragging
            if (_draggingBlock != null)
              ..._buildSnapLines(scheme),

            // Current time indicator
            if (isToday)
              _CurrentTimeIndicator(now: now, scheme: scheme),

            // Time block widgets (with drag support 4.23)
            ...layoutBlocks.map((lb) => _DraggableBlock(
              key: ValueKey(lb.block.uuid),
              layoutBlock: lb,
              catMap: catMap,
              scheme: scheme,
              isDragging: _draggingBlock?.uuid == lb.block.uuid,
              onTap: () => _openDetail(context, lb.block),
              onDragStarted: (offsetY) {
                HapticFeedback.heavyImpact();
                setState(() {
                  _draggingBlock = lb.block;
                  _dragOffsetY = offsetY;
                });
              },
              onDragEnd: (globalY) => _onDrop(globalY, lb.block),
              onDragCanceled: () =>
                  setState(() => _draggingBlock = null),
            )),
          ],
        ),
      ),
    );
  }

  // 15-min snap lines shown while dragging
  List<Widget> _buildSnapLines(ColorScheme scheme) {
    return List.generate(_hours * 4, (i) {
      final top = _topPad + i * (_hourHeight / 4);
      return Positioned(
        top: top,
        left: _labelWidth,
        right: 0,
        child: Container(
          height: 0.5,
          color: scheme.primary.withOpacity(0.08),
        ),
      );
    });
  }

  void _openDetail(BuildContext context, TimeBlock block) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TimeBlockDetailSheet(block: block),
    );
  }
}

// ── Hour row ──────────────────────────────────────────────────────────────────

class _HourRow extends StatelessWidget {
  const _HourRow({
    required this.hour,
    required this.labelWidth,
    required this.scheme,
    required this.onTap,
  });
  final int hour;
  final double labelWidth;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = '${hour.toString().padLeft(2, '0')}:00';
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: _hourHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: labelWidth,
              child: Padding(
                padding: const EdgeInsets.only(top: 2, left: 12),
                child: Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    color: scheme.onSurface.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 0.5,
                margin: const EdgeInsets.only(top: 8),
                color: scheme.onSurface.withOpacity(0.07),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

// ── Current time indicator ────────────────────────────────────────────────────

class _CurrentTimeIndicator extends StatelessWidget {
  const _CurrentTimeIndicator({required this.now, required this.scheme});
  final DateTime now;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final top = _topPad +
        now.hour * _hourHeight +
        now.minute / 60 * _hourHeight;
    return Positioned(
      top: top,
      left: _labelWidth - 5,
      right: 8,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.priorityHigh,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              color: AppColors.priorityHigh,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overlap layout engine ─────────────────────────────────────────────────────

class _LayoutBlock {
  _LayoutBlock({
    required this.block,
    required this.column,
    required this.totalColumns,
  });
  final TimeBlock block;
  final int column;
  final int totalColumns;
}

List<_LayoutBlock> _computeLayout(List<TimeBlock> blocks) {
  if (blocks.isEmpty) return [];
  final sorted = [...blocks]
    ..sort((a, b) => a.startTime.compareTo(b.startTime));

  final result = <_LayoutBlock>[];
  int i = 0;
  while (i < sorted.length) {
    final group = <TimeBlock>[sorted[i]];
    var groupEnd = sorted[i].endTime;
    int j = i + 1;
    while (j < sorted.length &&
        sorted[j].startTime.isBefore(groupEnd)) {
      group.add(sorted[j]);
      if (sorted[j].endTime.isAfter(groupEnd)) groupEnd = sorted[j].endTime;
      j++;
    }

    final cols = <int, DateTime>{};
    for (final b in group) {
      int col = 0;
      while (cols.containsKey(col) && cols[col]!.isAfter(b.startTime)) {
        col++;
      }
      cols[col] = b.endTime;
      result.add(_LayoutBlock(block: b, column: col, totalColumns: 0));
    }

    final maxCol = cols.keys.fold(0, (m, c) => c > m ? c : m) + 1;
    for (var k = result.length - group.length; k < result.length; k++) {
      result[k] = _LayoutBlock(
        block: result[k].block,
        column: result[k].column,
        totalColumns: maxCol,
      );
    }
    i = j;
  }
  return result;
}

// ── Draggable block (4.23) ────────────────────────────────────────────────────

class _DraggableBlock extends StatelessWidget {
  const _DraggableBlock({
    super.key,
    required this.layoutBlock,
    required this.catMap,
    required this.scheme,
    required this.isDragging,
    required this.onTap,
    required this.onDragStarted,
    required this.onDragEnd,
    required this.onDragCanceled,
  });

  final _LayoutBlock layoutBlock;
  final Map<String, Category> catMap;
  final ColorScheme scheme;
  final bool isDragging;
  final VoidCallback onTap;
  final ValueChanged<double> onDragStarted; // offsetY within block
  final ValueChanged<double> onDragEnd;     // globalY of pointer
  final VoidCallback onDragCanceled;

  @override
  Widget build(BuildContext context) {
    final block = layoutBlock.block;
    final startMinutes = block.startTime.hour * 60 + block.startTime.minute;
    final endMinutes = block.endTime.hour * 60 + block.endTime.minute;
    final durationMinutes = (endMinutes - startMinutes).clamp(15, 24 * 60);

    final top = _topPad + startMinutes / 60 * _hourHeight;
    final height = (durationMinutes / 60 * _hourHeight).clamp(20.0, double.infinity);

    final availableWidth =
        MediaQuery.of(context).size.width - _labelWidth - 16;
    final colWidth = availableWidth / layoutBlock.totalColumns;
    final left = _labelWidth + layoutBlock.column * colWidth;
    final width = colWidth - 4;

    final category = catMap[block.categoryId];
    final blockColor = block.colorOverride != null
        ? AppColors.accentFromHex(block.colorOverride!)
        : category != null
        ? AppColors.accentFromHex(category.colorHex)
        : scheme.primary;

    return Positioned(
      top: top,
      left: left,
      width: width,
      height: height,
      child: Opacity(
        opacity: isDragging ? 0.35 : 1.0,
        child: LongPressDraggable<String>(
          data: block.uuid,
          delay: const Duration(milliseconds: 350),
          onDragStarted: () {
            // We'll estimate offset as half block height
            onDragStarted(height / 2);
          },
          onDragEnd: (details) {
            onDragEnd(details.offset.dy + height / 2);
          },
          onDraggableCanceled: (_, __) => onDragCanceled(),
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: width,
              height: height,
              child: _FeedbackBlock(
                block: block,
                color: blockColor,
                category: category,
              ),
            ),
          ),
          childWhenDragging: const SizedBox.shrink(),
          child: TimeBlockWidget(
            block: block,
            color: blockColor,
            category: category,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

// ── Drag feedback block ───────────────────────────────────────────────────────

class _FeedbackBlock extends StatelessWidget {
  const _FeedbackBlock({
    required this.block,
    required this.color,
    required this.category,
  });
  final TimeBlock block;
  final Color color;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.03,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: color, width: 3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(8, 4, 6, 4),
        child: Text(
          block.title,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ── TimeBlockWidget (public — used by weekly_overview too) ────────────────────

class TimeBlockWidget extends StatelessWidget {
  const TimeBlockWidget({
    super.key,
    required this.block,
    required this.color,
    required this.onTap,
    this.category,
  });

  final TimeBlock block;
  final Color color;
  final Category? category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final durationMin = block.endTime.difference(block.startTime).inMinutes;
    final isShort = durationMin < 30;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 2, bottom: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.25 : 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: color, width: 3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 6, 4),
          child: isShort
              ? Row(
            children: [
              Expanded(
                child: Text(
                  block.title,
                  style: AppTypography.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatTime(block.startTime),
                style: AppTypography.labelSmall.copyWith(
                  color: color.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                block.title,
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${_formatTime(block.startTime)} – ${_formatTime(block.endTime)}',
                style: AppTypography.labelSmall.copyWith(
                  color: color.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
              if (category != null && durationMin >= 45) ...[
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category!.name,
                    style: AppTypography.labelSmall.copyWith(
                      color: color,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}