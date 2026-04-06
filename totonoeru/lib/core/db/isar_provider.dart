import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'collections.dart';
import 'category_repository.dart';

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError(
    'isarProvider was not initialized. '
        'Override it in ProviderScope inside main.dart.',
  );
});

Future<Isar> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();

  late Isar isar;

  if (Isar.instanceNames.isEmpty) {
    isar = await Isar.open(
      [
        TaskSchema,
        TimeBlockSchema,
        CategorySchema,
        FocusSessionSchema,
        DailyStatSchema,
      ],
      directory: dir.path,
      inspector: true,
    );
  } else {
    isar = Isar.getInstance()!;
  }

  // Seed default categories on first ever launch
  final categoryRepo = CategoryRepository(isar);
  await categoryRepo.seedDefaultsIfNeeded();

  return isar;
}