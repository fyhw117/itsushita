import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/action_record.dart';
import '../data/database_helper.dart';

final recordListProvider =
    NotifierProvider<RecordListNotifier, List<ActionRecord>>(
      RecordListNotifier.new,
    );

class RecordListNotifier extends Notifier<List<ActionRecord>> {
  @override
  List<ActionRecord> build() {
    _loadRecords();
    return [];
  }

  Future<void> _loadRecords() async {
    final records = await DatabaseHelper().getRecords();
    state = records;
  }

  Future<void> addRecord(ActionRecord record) async {
    await DatabaseHelper().insertRecord(record);
    await _loadRecords();
  }
}
