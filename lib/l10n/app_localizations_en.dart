// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboardTitle => 'My Routine';

  @override
  String get tabDashboard => 'Home';

  @override
  String get tabHistory => 'History';

  @override
  String get tabManage => 'Manage';

  @override
  String get manageActionsTitle => 'Manage Actions';

  @override
  String get historyTitle => 'History';

  @override
  String get noActionsYet => 'No actions yet.';

  @override
  String get goManageToAdd => 'Go to the Manage tab to add one!';

  @override
  String get newAction => 'New Action';

  @override
  String get actionName => 'Action Name';

  @override
  String get frequency => 'Frequency (e.g. Daily)';

  @override
  String get type => 'Type';

  @override
  String get positive => 'Positive';

  @override
  String get negative => 'Negative';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get deleteAction => 'Delete Action?';

  @override
  String get deleteActionConfirmation =>
      'This will remove the action but keep past records.';

  @override
  String get delete => 'Delete';

  @override
  String logged(Object actionName) {
    return 'Logged: $actionName';
  }

  @override
  String get selectDay => 'Select a day';

  @override
  String get noActionsRecorded => 'No actions recorded on this day.';

  @override
  String get unknownAction => 'Unknown Action';

  @override
  String get shouldDo => 'Should Do';

  @override
  String get shouldNotDo => 'Should Not Do';

  @override
  String get noFrequency => 'No frequency';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get editAction => 'Edit Action';

  @override
  String get update => 'Update';

  @override
  String get editRecord => 'Edit Record';

  @override
  String get changeDate => 'Change Date';

  @override
  String get changeTime => 'Change Time';

  @override
  String get confirmDelete => 'Are you sure you want to delete?';
}
