import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/action_item.dart';
import '../data/database_helper.dart';

final actionListProvider =
    NotifierProvider<ActionListNotifier, List<ActionItem>>(
      ActionListNotifier.new,
    );

class ActionListNotifier extends Notifier<List<ActionItem>> {
  @override
  List<ActionItem> build() {
    _loadActions();
    return [];
  }

  Future<void> _loadActions() async {
    final actions = await DatabaseHelper().getActions();
    state = actions;
  }

  Future<void> addAction(ActionItem action) async {
    await DatabaseHelper().insertAction(action);
    await _loadActions();
  }

  Future<void> deleteAction(String id) async {
    await DatabaseHelper().deleteAction(id);
    await _loadActions();
  }
}
