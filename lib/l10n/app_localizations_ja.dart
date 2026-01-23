// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get dashboardTitle => 'アクション記録';

  @override
  String get tabDashboard => '記録';

  @override
  String get tabHistory => '履歴';

  @override
  String get tabManage => 'アクション';

  @override
  String get manageActionsTitle => 'アクション管理';

  @override
  String get historyTitle => '履歴';

  @override
  String get noActionsYet => 'アクションがまだありません。';

  @override
  String get goManageToAdd => '管理タブから追加しましょう！';

  @override
  String get newAction => 'アクション追加';

  @override
  String get actionName => 'アクション名';

  @override
  String get frequency => '頻度（例：毎日）';

  @override
  String get type => '種類';

  @override
  String get positive => 'ポジティブ（すべき）';

  @override
  String get negative => 'ネガティブ（すべきでない）';

  @override
  String get cancel => 'キャンセル';

  @override
  String get add => '追加';

  @override
  String get deleteAction => 'アクションを削除しますか？';

  @override
  String get deleteActionConfirmation => 'アクションを削除しますが、過去の記録は残ります。';

  @override
  String get delete => '削除';

  @override
  String logged(Object actionName) {
    return '記録しました: $actionName';
  }

  @override
  String get selectDay => '日付を選択してください';

  @override
  String get noActionsRecorded => 'この日の記録はありません。';

  @override
  String get unknownAction => '不明なアクション';

  @override
  String get shouldDo => '推奨';

  @override
  String get shouldNotDo => '非推奨';

  @override
  String get noFrequency => '頻度なし';

  @override
  String get settingsTitle => '設定';

  @override
  String get language => '言語';

  @override
  String get editAction => 'アクション編集';

  @override
  String get update => '更新';
}
