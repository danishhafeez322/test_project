import 'package:drift/drift.dart';

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get deleted =>
      boolean().withDefault(const Constant(false))(); // Add deleted column

  @override
  Set<Column> get primaryKey => {id};
}
