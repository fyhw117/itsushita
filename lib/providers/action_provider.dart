import 'package:flutter/foundation.dart';
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
    try {
      final actions = await DatabaseHelper().getActions();
      debugPrint('ActionListNotifier: Loaded ${actions.length} actions');
      state = actions;
    } catch (e) {
      debugPrint('ActionListNotifier: Error loading actions: $e');
    }
  }

  Future<void> addAction(ActionItem action) async {
    try {
      debugPrint('ActionListNotifier: Adding action ${action.name}');
      await DatabaseHelper().insertAction(action);
      await _loadActions();
    } catch (e) {
      debugPrint('ActionListNotifier: Error adding action: $e');
    }
  }

  Future<void> deleteAction(String id) async {
    await DatabaseHelper().deleteAction(id);
    await _loadActions();
  }
}
