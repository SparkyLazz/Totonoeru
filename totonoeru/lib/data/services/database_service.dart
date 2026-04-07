import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/time_block.dart';
import '../models/category.dart';
import '../models/focus_session.dart';
import '../models/productivity_stats.dart';

/// Singleton that owns the Isar instance.
/// Call [DatabaseService.init] once in main() before runApp.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  late Isar _isar;
  Isar get isar => _isar;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  // ── Init (task 1.22) ──────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [
        TaskSchema,
        TimeBlockSchema,
        CategorySchema,
        FocusSessionSchema,
        ProductivityStatsSchema,
      ],
      directory: dir.path,
      name: 'totonoeru',
    );

    _initialized = true;

    await _seedDefaultCategories();
  }

  // ── Seed 5 default categories (task 1.23) ─────────────────────────────────

  Future<void> _seedDefaultCategories() async {
    final existing = await _isar.categorys.count();
    if (existing > 0) return; // already seeded

    const uuid = Uuid();

    final defaults = [
      Category.create(
        uuid: uuid.v4(),
        name: 'Work',
        nameJp: '仕事',
        colorHex: '#4A90D9',
        iconIdentifier: 'briefcase',
        isSystem: true,
        sortOrder: 0,
      ),
      Category.create(
        uuid: uuid.v4(),
        name: 'Personal',
        nameJp: '個人',
        colorHex: '#7F77DD',
        iconIdentifier: 'person',
        isSystem: true,
        sortOrder: 1,
      ),
      Category.create(
        uuid: uuid.v4(),
        name: 'Study',
        nameJp: '勉強',
        colorHex: '#1D9E75',
        iconIdentifier: 'book',
        isSystem: true,
        sortOrder: 2,
      ),
      Category.create(
        uuid: uuid.v4(),
        name: 'Health',
        nameJp: '健康',
        colorHex: '#EF9F27',
        iconIdentifier: 'heart',
        isSystem: true,
        sortOrder: 3,
      ),
      Category.create(
        uuid: uuid.v4(),
        name: 'Break',
        nameJp: '休憩',
        colorHex: '#D44C3A',
        iconIdentifier: 'coffee',
        isSystem: true,
        sortOrder: 4,
      ),
    ];

    await _isar.writeTxn(() async {
      await _isar.categorys.putAll(defaults);
    });
  }

  // ── Close (for testing) ───────────────────────────────────────────────────

  Future<void> close() async {
    if (_initialized) {
      await _isar.close();
      _initialized = false;
    }
  }
}
