import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/action_item.dart';
import '../models/action_record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'itsushita.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE actions(
        id TEXT PRIMARY KEY,
        name TEXT,
        type INTEGER,
        colorValue INTEGER,
        frequency TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE records(
        id TEXT PRIMARY KEY,
        actionId TEXT,
        timestamp TEXT,
        FOREIGN KEY(actionId) REFERENCES actions(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE actions ADD COLUMN frequency TEXT DEFAULT ""',
      );
    }
  }

  // Actions
  Future<List<ActionItem>> getActions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('actions');
    return List.generate(maps.length, (i) {
      return ActionItem.fromMap(maps[i]);
    });
  }

  Future<void> insertAction(ActionItem action) async {
    final db = await database;
    await db.insert(
      'actions',
      action.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteAction(String id) async {
    final db = await database;
    await db.delete('actions', where: 'id = ?', whereArgs: [id]);
  }

  // Records
  Future<List<ActionRecord>> getRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('records');
    return List.generate(maps.length, (i) {
      return ActionRecord.fromMap(maps[i]);
    });
  }

  Future<void> insertRecord(ActionRecord record) async {
    final db = await database;
    await db.insert(
      'records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ActionRecord>> getRecordsForAction(String actionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'records',
      where: 'actionId = ?',
      whereArgs: [actionId],
    );
    return List.generate(maps.length, (i) {
      return ActionRecord.fromMap(maps[i]);
    });
  }

  Future<void> deleteRecord(String id) async {
    final db = await database;
    await db.delete('records', where: 'id = ?', whereArgs: [id]);
  }
}
