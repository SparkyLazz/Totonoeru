// lib/core/providers/focus_provider.dart
// Task 5.08 — Focus timer state machine
//
// FIX (lines 133, 145): prefsProvider doesn't exist by that name.
// We resolve SharedPreferences directly via an async provider instead.

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../data/models/focus_session.dart';
import '../../data/models/task.dart';
import '../../data/repositories/focus_repository.dart';

// ── SharedPreferences singleton provider ─────────────────────────
// If your codebase already has a prefsProvider / sharedPrefsProvider,
// replace this with an import of that provider and use ref.read() on it.
final _sharedPrefsProvider = FutureProvider<SharedPreferences>(
      (_) => SharedPreferences.getInstance(),
);

// ── Enums ────────────────────────────────────────────────────────
enum FocusPhase { work, shortBreak }

enum TimerStatus { idle, running, paused, breakRunning, breakPaused, complete }

enum FocusMode { pomodoro, shortFocus, deepWork }

// ── State ────────────────────────────────────────────────────────
class FocusState {
  const FocusState({
    this.status = TimerStatus.idle,
    this.phase = FocusPhase.work,
    this.mode = FocusMode.pomodoro,
    this.remainingSeconds = 25 * 60,
    this.totalSeconds = 25 * 60,
    this.sessionsCompleted = 0,
    this.sessionsTarget = 4,
    this.linkedTask,
    this.currentSessionStarted,
    this.elapsedSeconds = 0,
  });

  final TimerStatus status;
  final FocusPhase phase;
  final FocusMode mode;
  final int remainingSeconds;
  final int totalSeconds;
  final int sessionsCompleted;
  final int sessionsTarget;
  final Task? linkedTask;
  final DateTime? currentSessionStarted;
  final int elapsedSeconds;

  bool get isActive =>
      status == TimerStatus.running || status == TimerStatus.breakRunning;
  bool get isPaused =>
      status == TimerStatus.paused || status == TimerStatus.breakPaused;
  bool get isIdle => status == TimerStatus.idle;
  bool get isBreak =>
      phase == FocusPhase.shortBreak &&
          (status == TimerStatus.breakRunning ||
              status == TimerStatus.breakPaused);

  double get progress =>
      totalSeconds > 0 ? remainingSeconds / totalSeconds : 1.0;

  String get formattedTime {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get phaseLabel {
    switch (mode) {
      case FocusMode.pomodoro:
        return phase == FocusPhase.work ? 'FOCUS' : 'BREAK';
      case FocusMode.shortFocus:
        return 'SHORT';
      case FocusMode.deepWork:
        return 'DEEP';
    }
  }

  String get sessionLabel {
    switch (mode) {
      case FocusMode.pomodoro:
        return 'Session ${sessionsCompleted + 1} of $sessionsTarget';
      case FocusMode.shortFocus:
        return '15 min session';
      case FocusMode.deepWork:
        return 'Deep work · 50 min';
    }
  }

  FocusState copyWith({
    TimerStatus? status,
    FocusPhase? phase,
    FocusMode? mode,
    int? remainingSeconds,
    int? totalSeconds,
    int? sessionsCompleted,
    int? sessionsTarget,
    Task? linkedTask,
    bool clearLinkedTask = false,
    DateTime? currentSessionStarted,
    bool clearStarted = false,
    int? elapsedSeconds,
  }) {
    return FocusState(
      status: status ?? this.status,
      phase: phase ?? this.phase,
      mode: mode ?? this.mode,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      sessionsTarget: sessionsTarget ?? this.sessionsTarget,
      linkedTask: clearLinkedTask ? null : (linkedTask ?? this.linkedTask),
      currentSessionStarted: clearStarted
          ? null
          : (currentSessionStarted ?? this.currentSessionStarted),
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────
class FocusNotifier extends StateNotifier<FocusState> {
  FocusNotifier(this._ref) : super(const FocusState()) {
    _applyMode(FocusMode.pomodoro);
  }

  final Ref _ref;
  Timer? _ticker;
  static const _uuid = Uuid();

  // -- Read work/break durations from SharedPreferences -----------
  // Falls back to sensible defaults if prefs not yet loaded.
  Future<SharedPreferences> get _prefs async =>
      _ref.read(_sharedPrefsProvider.future);

  Future<int> get _workSecs async {
    final prefs = await _prefs;
    switch (state.mode) {
      case FocusMode.pomodoro:
        return (prefs.getInt('focus_work_minutes') ?? 25) * 60;
      case FocusMode.shortFocus:
        return 15 * 60;
      case FocusMode.deepWork:
        return 50 * 60;
    }
  }

  Future<int> get _breakSecs async {
    final prefs = await _prefs;
    return (prefs.getInt('focus_break_minutes') ?? 5) * 60;
  }

  // ── Mode selection ────────────────────────────────────────────
  void setMode(FocusMode mode) {
    _stopTimer();
    _applyMode(mode);
  }

  void _applyMode(FocusMode mode) {
    // Use synchronous defaults for immediate UI response;
    // the async read from prefs is only needed when timer starts.
    final secs = mode == FocusMode.pomodoro
        ? 25 * 60
        : mode == FocusMode.shortFocus
        ? 15 * 60
        : 50 * 60;
    state = FocusState(
      mode: mode,
      remainingSeconds: secs,
      totalSeconds: secs,
      linkedTask: state.linkedTask,
    );
  }

  // ── Play / Pause ──────────────────────────────────────────────
  void startOrPause() {
    if (state.isActive) {
      _pause();
    } else {
      _startAsync();
    }
  }

  Future<void> _startAsync() async {
    HapticFeedback.mediumImpact();
    // If idle (first start), reload durations from prefs
    if (state.status == TimerStatus.idle) {
      final secs = await _workSecs;
      state = state.copyWith(
        remainingSeconds: secs,
        totalSeconds: secs,
      );
    }
    final isBreakPhase = state.phase == FocusPhase.shortBreak;
    state = state.copyWith(
      status: isBreakPhase ? TimerStatus.breakRunning : TimerStatus.running,
      currentSessionStarted: state.currentSessionStarted ?? DateTime.now(),
    );
    WakelockPlus.enable();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _pause() {
    HapticFeedback.mediumImpact();
    _stopTimer();
    final isBreakPhase = state.phase == FocusPhase.shortBreak;
    state = state.copyWith(
      status: isBreakPhase ? TimerStatus.breakPaused : TimerStatus.paused,
    );
    WakelockPlus.disable();
  }

  void _tick() {
    if (state.remainingSeconds <= 0) {
      _onPhaseComplete();
      return;
    }
    state = state.copyWith(
      remainingSeconds: state.remainingSeconds - 1,
      elapsedSeconds: state.elapsedSeconds + 1,
    );
  }

  // ── Phase completion ──────────────────────────────────────────
  void _onPhaseComplete() {
    _stopTimer();
    WakelockPlus.disable();

    if (state.phase == FocusPhase.work) {
      _saveWorkSession(); // fire-and-forget
      final newCompleted = state.sessionsCompleted + 1;
      HapticFeedback.heavyImpact();

      if (newCompleted >= state.sessionsTarget &&
          state.mode == FocusMode.pomodoro) {
        state = state.copyWith(
          status: TimerStatus.complete,
          sessionsCompleted: newCompleted,
          clearStarted: true,
          elapsedSeconds: 0,
        );
      } else {
        // Transition to break — use default 5 min synchronously;
        // async reload happens on next _startAsync().
        const breakSecs = 5 * 60;
        state = state.copyWith(
          status: TimerStatus.breakRunning,
          phase: FocusPhase.shortBreak,
          remainingSeconds: breakSecs,
          totalSeconds: breakSecs,
          sessionsCompleted: newCompleted,
          clearStarted: true,
          elapsedSeconds: 0,
        );
        WakelockPlus.enable();
        _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      }
    } else {
      // Break done → back to work
      const workSecs = 25 * 60;
      state = state.copyWith(
        status: TimerStatus.idle,
        phase: FocusPhase.work,
        remainingSeconds: workSecs,
        totalSeconds: workSecs,
        elapsedSeconds: 0,
      );
    }
  }

  Future<void> _saveWorkSession() async {
    final session = FocusSession()
      ..uuid = _uuid.v4()
      ..taskId = state.linkedTask?.uuid
      ..durationSeconds = state.totalSeconds
      ..elapsedSeconds = state.totalSeconds
      ..completed = true
      ..startedAt = state.currentSessionStarted ?? DateTime.now()
      ..endedAt = DateTime.now();

    await FocusRepository.instance.createSession(session);
    await FocusRepository.instance
        .recordCompletedSession(state.totalSeconds);
  }

  // ── Reset ─────────────────────────────────────────────────────
  void reset() {
    _stopTimer();
    WakelockPlus.disable();
    _applyMode(state.mode);
  }

  // ── Skip ──────────────────────────────────────────────────────
  void skip() {
    _stopTimer();
    WakelockPlus.disable();
    if (state.phase == FocusPhase.work) {
      _onPhaseComplete();
    } else {
      const workSecs = 25 * 60;
      state = state.copyWith(
        status: TimerStatus.idle,
        phase: FocusPhase.work,
        remainingSeconds: workSecs,
        totalSeconds: workSecs,
        elapsedSeconds: 0,
      );
    }
  }

  // ── Task picker ───────────────────────────────────────────────
  void linkTask(Task task) => state = state.copyWith(linkedTask: task);
  void unlinkTask() => state = state.copyWith(clearLinkedTask: true);

  // ── Helpers ───────────────────────────────────────────────────
  void _stopTimer() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTimer();
    WakelockPlus.disable();
    super.dispose();
  }
}

// ── Providers ─────────────────────────────────────────────────────
final focusProvider =
StateNotifierProvider<FocusNotifier, FocusState>((ref) {
  return FocusNotifier(ref);
});

/// Today's sessions stream for the log list (5.13)
final todaySessionsProvider = StreamProvider<List<FocusSession>>((ref) {
  return FocusRepository.instance.watchTodaySessions();
});