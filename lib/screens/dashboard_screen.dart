import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:itsushita/l10n/app_localizations.dart';
import '../providers/action_provider.dart';
import '../providers/record_provider.dart';
import '../models/action_record.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.watch(actionListProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(title: Text(l10n.dashboardTitle)),
      body: actions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_task, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noActionsYet,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.goManageToAdd,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return _ActionCard(action: action);
              },
            ),
    );
  }
}

class _ActionCard extends ConsumerWidget {
  final dynamic action; // precise typing handled in usage

  const _ActionCard({required this.action});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseColor = Color(action.colorValue);
    final l10n = AppLocalizations.of(context)!;
    final allRecords = ref.watch(recordListProvider);

    // Filter records for this action
    final actionRecords = allRecords
        .where((r) => r.actionId == action.id)
        .toList();

    // Sort records descending
    actionRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    int getStreak() {
      if (actionRecords.isEmpty) return 0;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Calculate positive streak (consecutive days doing it)
      // Check if done today or yesterday to keep streak alive

      // Simplify: Turn timestamps into set of normalization dates
      final doneDates = actionRecords.map((r) {
        final t = r.timestamp;
        return DateTime(t.year, t.month, t.day);
      }).toSet();

      if (doneDates.isEmpty) return 0;

      int streak = 0;
      // Check backwards from today
      DateTime checkDate = today;

      // If not done today, check if done yesterday to start counting
      if (!doneDates.contains(checkDate)) {
        checkDate = checkDate.subtract(const Duration(days: 1));
        if (!doneDates.contains(checkDate)) {
          return 0; // Streak broken if not done today or yesterday
        }
      }

      while (doneDates.contains(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      return streak;
    }

    // Simple calculations for "Not done for X days" if beneficial,
    // but user asked for "Continuous implementation days OR Continuous non-implementation days".

    String getStreakText() {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (actionRecords.isEmpty) {
        // Never done
        return '';
      }

      final lastDone = actionRecords.first.timestamp;
      final lastDoneDate = DateTime(
        lastDone.year,
        lastDone.month,
        lastDone.day,
      );

      final daysSinceLast = today.difference(lastDoneDate).inDays;

      if (daysSinceLast > 1) {
        // Not done for a while
        return '$daysSinceLast日未実施';
      } else {
        // Done recently, show streak
        final streak = getStreak();
        if (streak > 1) {
          return '$streak日連続';
        }
      }
      return '';
    }

    final streakText = getStreakText();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [baseColor.withValues(alpha: 0.8), baseColor],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            // Logic handled here
            final record = ActionRecord(
              id: const Uuid().v4(),
              actionId: action.id,
              timestamp: DateTime.now(),
            );
            ref.read(recordListProvider.notifier).addRecord(record);

            // Show custom feedback
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      l10n.logged(action.name),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                backgroundColor: baseColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.touch_app_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        action.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (action.frequency.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    action.frequency,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (streakText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      streakText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
