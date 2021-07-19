import 'dart:io';

import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'tasks.g.dart';

const MaxTaskNameLength = 64;
const MaxTaskDescLength = 8192;

@UseMoor(
  include: {'tables.moor'},
)

//   @override
//   int? mapToSql(Duration? value) {
//     if (value == null) {
//       return null;
//     }

//     return value.inSeconds;
//   }
// }

// class Tasks extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get name => text().withLength(min: 1, max: MaxTaskNameLength)();
//   TextColumn get description => text().withLength(max: MaxTaskDescLength)();
//   IntColumn get estimate => integer().map(const DurationConverter())();
//   DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
//   DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
// }

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final fullPath = p.join(dbFolder.path, 'db.sqlite');
    final file = File(fullPath);
    print(fullPath);
    return VmDatabase(file, logStatements: true);
  });
}

@UseMoor(tables: [Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}
