import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:itsushita/l10n/app_localizations.dart';
import '../models/action_item.dart';
import '../providers/action_provider.dart';
import '../providers/locale_provider.dart';

class ActionsManageScreen extends ConsumerWidget {
  const ActionsManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.watch(actionListProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          l10n.manageActionsTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Locale>(
                value: locale,
                icon: const Icon(Icons.language, color: Colors.black54),
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(value: Locale('ja'), child: Text('日本語')),
                ],
                onChanged: (newLocale) {
                  if (newLocale != null) {
                    ref.read(localeProvider.notifier).setLocale(newLocale);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: actions.isEmpty
          ? Center(
              child: Text(
                l10n.noActionsYet,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(action.colorValue).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        action.type == ActionType.shouldDo
                            ? Icons.check_circle_outline
                            : Icons.block_outlined,
                        color: Color(action.colorValue),
                      ),
                    ),
                    title: Text(
                      action.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${action.type == ActionType.shouldDo ? l10n.positive : l10n.negative} • ${action.frequency.isEmpty ? l10n.noFrequency : action.frequency}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                      onPressed: () {
                        // Confirm deletion
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: Text(l10n.deleteAction),
                            content: Text(l10n.deleteActionConfirmation),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c),
                                child: Text(l10n.cancel),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref
                                      .read(actionListProvider.notifier)
                                      .deleteAction(action.id);
                                  Navigator.pop(c);
                                },
                                child: Text(
                                  l10n.delete,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddActionDialog(context, ref),
        label: Text(l10n.newAction),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddActionDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final frequencyController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    ActionType selectedType = ActionType.shouldDo;
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.newAction),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: l10n.actionName),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: frequencyController,
                      decoration: InputDecoration(labelText: l10n.frequency),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('${l10n.type}: '),
                        DropdownButton<ActionType>(
                          value: selectedType,
                          items: ActionType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(
                                type == ActionType.shouldDo
                                    ? l10n.positive
                                    : l10n.negative,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedType = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: Colors.primaries.map((color) {
                        return GestureDetector(
                          onTap: () => setState(() => selectedColor = color),
                          child: CircleAvatar(
                            backgroundColor: color,
                            radius: 12,
                            child: selectedColor == color
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      final newAction = ActionItem(
                        id: const Uuid().v4(),
                        name: nameController.text,
                        type: selectedType,
                        colorValue: selectedColor.toARGB32(),
                        frequency: frequencyController.text,
                      );
                      ref
                          .read(actionListProvider.notifier)
                          .addAction(newAction);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(l10n.add),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
