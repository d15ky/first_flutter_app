
import 'package:moor/moor.dart';

class DurationConverter extends TypeConverter<Duration, int> {
  const DurationConverter();
  @override
  Duration? mapToDart(int? fromDb) {
    if (fromDb == null) {
      return null;
    }
    return Duration(seconds: fromDb);
  }
