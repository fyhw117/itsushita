import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:itsushita/l10n/app_localizations.dart';
import '../providers/record_provider.dart';
import '../providers/action_provider.dart';
import '../models/action_record.dart';
import '../models/action_item.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(recordListProvider);
    final actions = ref.watch(actionListProvider);
    final l10n = AppLocalizations.of(context)!;

    // Optimization: Create a map for quick lookup
    final Map<String, ActionItem> actionMap = {
      for (var action in actions) action.id: action,
    };

    List<ActionRecord> getEventsForDay(DateTime day) {
      return records.where((record) {
        return isSameDay(record.timestamp, day);
      }).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          l10n.historyTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: getEventsForDay,
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.tealAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                markerSize: 8,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;
                  final eventRecords = events.cast<ActionRecord>();

                  // Take up to 4 unique action colors to show
                  final uniqueActionIds = eventRecords
                      .map((e) => e.actionId)
                      .toSet()
                      .take(4);

                  return Positioned(
                    bottom: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: uniqueActionIds.map((id) {
                        final colorValue =
                            actionMap[id]?.colorValue ?? Colors.grey.toARGB32();
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Color(colorValue),
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedDay == null
                ? Center(child: Text(l10n.selectDay))
                : _buildEventList(
                    getEventsForDay(_selectedDay!),
                    actionMap,
                    l10n,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(
    List<ActionRecord> dayRecords,
    Map<String, ActionItem> actionMap,
    AppLocalizations l10n,
  ) {
    if (dayRecords.isEmpty) {
      return Center(
        child: Text(
          l10n.noActionsRecorded,
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    // Sort by timestamp if needed, currently just list
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: dayRecords.length,
      itemBuilder: (context, index) {
        final record = dayRecords[index];
        final action = actionMap[record.actionId];
        final color = action != null ? Color(action.colorValue) : Colors.grey;
        final name = action?.name ?? l10n.unknownAction;

        return Dismissible(
          key: Key(record.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.red[400],
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            ref.read(recordListProvider.notifier).deleteRecord(record.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.delete}: $name'),
                action: SnackBarAction(
                  label: l10n.cancel,
                  onPressed: () {
                    ref.read(recordListProvider.notifier).addRecord(record);
                  },
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ListTile(
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
              dense: true,
              onTap: () => _showEditRecordDialog(context, record, name, l10n),
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: color, size: 16),
              ),
              title: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                DateFormat('h:mm a').format(record.timestamp),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              trailing: action?.type == ActionType.shouldDo
                  ? Icon(
                      Icons.thumb_up_alt_rounded,
                      color: Colors.green[300],
                      size: 16,
                    )
                  : Icon(
                      Icons.thumb_down_alt_rounded,
                      color: Colors.orange[300],
                      size: 16,
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditRecordDialog(
    BuildContext context,
    ActionRecord record,
    String actionName,
    AppLocalizations l10n,
  ) async {
    DateTime selectedDate = record.timestamp;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(record.timestamp);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final dateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );

            return AlertDialog(
              title: Text(l10n.editRecord),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(l10n.changeDate),
                    subtitle: Text(DateFormat.yMMMd().format(dateTime)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text(l10n.changeTime),
                    subtitle: Text(DateFormat.Hm().format(dateTime)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.delete),
                        content: Text(l10n.confirmDelete),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              l10n.delete,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete == true) {
                      if (context.mounted) {
                        ref
                            .read(recordListProvider.notifier)
                            .deleteRecord(record.id);
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text(
                    l10n.delete,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () {
                    final newDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    if (newDateTime != record.timestamp) {
                      final newRecord = ActionRecord(
                        id: record.id,
                        actionId: record.actionId,
                        timestamp: newDateTime,
                      );
                      ref
                          .read(recordListProvider.notifier)
                          .updateRecord(newRecord);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(l10n.update),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
