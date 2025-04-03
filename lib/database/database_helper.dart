import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/marker_color.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('littoral_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scenarios (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        created_at INTEGER NOT NULL,
        faction TEXT NOT NULL CHECK(faction IN ('USMC', 'PLAN'))
      )
    ''');

    await db.execute('''
      CREATE TABLE task_groups (
        id TEXT PRIMARY KEY,
        scenario_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        created_at INTEGER NOT NULL,
        faction TEXT NOT NULL CHECK(faction IN ('USMC', 'PLAN')),
        FOREIGN KEY (scenario_id) REFERENCES scenarios (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE units (
        id TEXT PRIMARY KEY,
        task_group_id TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        attack INTEGER NOT NULL,
        defense INTEGER NOT NULL,
        movement INTEGER NOT NULL,
        special TEXT,
        FOREIGN KEY (task_group_id) REFERENCES task_groups (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE unit_markers (
        unit_id TEXT NOT NULL,
        position INTEGER NOT NULL,
        color TEXT NOT NULL,
        FOREIGN KEY (unit_id) REFERENCES units (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE scenarios (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          created_at INTEGER NOT NULL,
          faction TEXT NOT NULL CHECK(faction IN ('USMC', 'PLAN'))
        )
      ''');

      await db.execute('''
        ALTER TABLE task_groups 
        ADD COLUMN scenario_id TEXT NOT NULL DEFAULT 'default_scenario'
      ''');

      await db.execute('''
        ALTER TABLE task_groups 
        ADD COLUMN faction TEXT NOT NULL DEFAULT 'USMC' 
        CHECK(faction IN ('USMC', 'PLAN'))
      ''');

      await db.insert('scenarios', {
        'id': 'default_scenario',
        'name': 'Default Scenario',
        'description': 'Migrated from version 1',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'faction': 'USMC'
      });
    }
  }

  Future<String> createScenario({
    required String name,
    required String faction,
    String? description,
  }) async {
    final db = await instance.database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    await db.insert('scenarios', {
      'id': id,
      'name': name,
      'description': description,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'faction': faction,
    });
    
    return id;
  }

  Future<List<Map<String, dynamic>>> getAllScenarios() async {
    final db = await instance.database;
    return await db.query('scenarios', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getScenario(String id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      'scenarios',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updateScenario({
    required String id,
    required String name,
    required String faction,
    String? description,
  }) async {
    final db = await instance.database;
    await db.update(
      'scenarios',
      {
        'name': name,
        'description': description,
        'faction': faction,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteScenario(String id) async {
    final db = await instance.database;
    await db.delete(
      'scenarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String> createTaskGroup({
    required String scenarioId,
    required String name,
    required String faction,
    String? description,
  }) async {
    final db = await instance.database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    await db.insert('task_groups', {
      'id': id,
      'scenario_id': scenarioId,
      'name': name,
      'description': description,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'faction': faction,
    });
    
    return id;
  }

  Future<List<Map<String, dynamic>>> getTaskGroupsForScenario(String scenarioId) async {
    final db = await instance.database;
    return await db.query(
      'task_groups',
      where: 'scenario_id = ?',
      whereArgs: [scenarioId],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> saveMarkers(String unitId, Map<int, List<MarkerColor>> markers) async {
    final db = await instance.database;
    await db.delete('unit_markers', where: 'unit_id = ?', whereArgs: [unitId]);
    
    for (final entry in markers.entries) {
      for (final color in entry.value) {
        await db.insert('unit_markers', {
          'unit_id': unitId,
          'position': entry.key,
          'color': color.toString(),
        });
      }
    }
  }

  Future<Map<int, List<MarkerColor>>> getMarkersForUnit(String unitId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'unit_markers',
      where: 'unit_id = ?',
      whereArgs: [unitId],
    );

    final markers = <int, List<MarkerColor>>{};
    for (final map in maps) {
      final position = map['position'];
      final color = MarkerColor.values.firstWhere(
        (e) => e.toString() == map['color'],
      );
      
      if (!markers.containsKey(position)) {
        markers[position] = [];
      }
      markers[position]!.add(color);
    }
    return markers;
  }

  Future<void> deleteTaskGroup(String id) async {
    final db = await instance.database;
    await db.delete(
      'task_groups',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 