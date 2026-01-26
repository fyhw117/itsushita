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
        title: Text(l10n.manageActionsTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Locale>(
                value: locale,
                icon: const Icon(
                  Icons.language,
                  color: Colors.white,
                ), // Explicit white to ensure visibility
                dropdownColor: Colors.white, // Ensure dropdown bg is white
                style: const TextStyle(
                  color: Colors.black87,
                ), // Default text style for items
                selectedItemBuilder: (BuildContext context) {
                  return const [
                    // Displayed in the App Bar (White text)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'English',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('日本語', style: TextStyle(color: Colors.white)),
                    ),
                  ];
                },
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
                    visualDensity: const VisualDensity(
                      horizontal: 0,
                      vertical: -4,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    dense: true,
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Color(action.colorValue).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        action.type == ActionType.shouldDo
                            ? Icons.check_circle_outline
                            : Icons.block_outlined,
                        color: Color(action.colorValue),
                        size: 18,
                      ),
                    ),
                    title: Text(
                      action.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      '${action.type == ActionType.shouldDo ? l10n.positive : l10n.negative} • ${action.frequency.isEmpty ? l10n.noFrequency : action.frequency}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue[300], size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _showActionDialog(context, ref, actionToEdit: action);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActionDialog(context, ref),
        label: Text(l10n.newAction),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showActionDialog(
    BuildContext context,
    WidgetRef ref, {
    ActionItem? actionToEdit,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: actionToEdit?.name);
    final frequencyController = TextEditingController(
      text: actionToEdit?.frequency,
    );

    ActionType selectedType = actionToEdit?.type ?? ActionType.shouldDo;
    Color selectedColor = actionToEdit != null
        ? Color(actionToEdit.colorValue)
        : Colors.blue;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                actionToEdit == null ? l10n.newAction : l10n.editAction,
              ),
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
                if (actionToEdit != null)
                  TextButton(
                    onPressed: () {
                      // Confirm deletion within edit dialog
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
                                    .deleteAction(actionToEdit.id);
                                Navigator.pop(c); // Close confirm
                                Navigator.pop(context); // Close edit
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
                    if (nameController.text.isNotEmpty) {
                      final newAction = ActionItem(
                        // Use existing ID if editing, else generate new
                        id: actionToEdit?.id ?? const Uuid().v4(),
                        name: nameController.text,
                        type: selectedType,
                        colorValue: selectedColor.toARGB32(),
                        frequency: frequencyController.text,
                      );
                      ref
                          .read(actionListProvider.notifier)
                          .addAction(
                            newAction,
                          ); // addAction handles insert/replace
                      Navigator.pop(context);
                    }
                  },
                  child: Text(actionToEdit == null ? l10n.add : l10n.update),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
