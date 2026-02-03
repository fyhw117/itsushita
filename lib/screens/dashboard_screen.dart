import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:itsushita/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../providers/action_provider.dart';
import '../providers/record_provider.dart';
import '../models/action_record.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final actions = ref.watch(actionListProvider);
    final l10n = AppLocalizations.of(context)!;
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(title: Text(l10n.dashboardTitle)),
      body: Column(
        children: [
          // Date selection header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(
                        const Duration(days: 1),
                      );
                    });
                  },
                ),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        // Keep current time, update date components
                        final now = DateTime.now();
                        _selectedDate = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          now.hour,
                          now.minute,
                          now.second,
                        );
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat.yMMMd(
                            Localizations.localeOf(context).toString(),
                          ).format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 4),
                          const Text(
                            "(Today)",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: isToday
                      ? null
                      : () {
                          setState(() {
                            final nextDay = _selectedDate.add(
                              const Duration(days: 1),
                            );
                            if (nextDay.isBefore(
                              DateTime.now().add(const Duration(seconds: 1)),
                            )) {
                              _selectedDate = nextDay;
                            }
                          });
                        },
                ),
              ],
            ),
          ),
          Expanded(
            child: actions.isEmpty
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.4,
                        ),
                    itemCount: actions.length,
                    itemBuilder: (context, index) {
                      final action = actions[index];
                      return _ActionCard(
                        action: action,
                        selectedDate: _selectedDate,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends ConsumerWidget {
  final dynamic action; // precise typing handled in usage
  final DateTime selectedDate;

  const _ActionCard({required this.action, required this.selectedDate});

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
        return l10n.notDoneDays(daysSinceLast);
      } else {
        // Done recently, show streak
        final streak = getStreak();
        if (streak > 0) {
          return l10n.streakDays(streak);
        }
      }
      return '';
    }

    final streakText = action.showConsecutiveDays ? getStreakText() : '';

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
            // Ensure we use the selected date but keep "now" time if it's today,
            // or just use the whole selectedDate which might have preserved time or be midnight.
            // If selectedDate is just a date with time 00:00:00 (from date picker usually),
            // and we want to "log at this moment but on that day", we might want to mix.
            // BUT, the _DashboardScreenState logic preserved time when picking.
            // So we can just use selectedDate directly.

            // However, if the user didn't pick, _selectedDate is initialized to 'now' at build time...
            // wait, initialized in State.
            // So if I sit on the screen for 1 hour, _selectedDate is 1 hour old.
            // Let's re-sync time current time to the selected date.
            final now = DateTime.now();
            final timestamp = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              now.hour,
              now.minute,
              now.second,
            );

            final record = ActionRecord(
              id: const Uuid().v4(),
              actionId: action.id,
              timestamp: timestamp,
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
              vertical: 8.0,
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
