import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/marker_color.dart';
import 'dart:convert';
import '../models/unit.dart';

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

    // Create default scenario
    final scenarioId = 'default_scenario';
    await db.insert('scenarios', {
      'id': scenarioId,
      'name': 'Default Scenario',
      'description': 'Initial scenario with Alpha and Beta task groups',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'faction': 'USMC'
    });

    // Create Alpha task group
    final alphaGroupId = 'alpha_group_${DateTime.now().millisecondsSinceEpoch}';
    await db.insert('task_groups', {
      'id': alphaGroupId,
      'scenario_id': scenarioId,
      'name': 'Alpha Group',
      'description': 'First task group',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'faction': 'USMC'
    });

    // Create Beta task group
    final betaGroupId = 'beta_group_${DateTime.now().millisecondsSinceEpoch + 1}';
    await db.insert('task_groups', {
      'id': betaGroupId,
      'scenario_id': scenarioId,
      'name': 'Beta Group',
      'description': 'Second task group',
      'created_at': DateTime.now().millisecondsSinceEpoch + 1,
      'faction': 'USMC'
    });

    // Create units for Alpha group
    final alphaUnit1Id = 'alpha_unit1_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';
    await db.insert('units', {
      'id': alphaUnit1Id,
      'task_group_id': alphaGroupId,
      'name': 'Alpha Unit 1',
      'type': 'infantry',
      'attack': 3,
      'defense': 2,
      'movement': 2,
      'special': 'None'
    });

    final alphaUnit2Id = 'alpha_unit2_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch + 1}';
    await db.insert('units', {
      'id': alphaUnit2Id,
      'task_group_id': alphaGroupId,
      'name': 'Alpha Unit 2',
      'type': 'armor',
      'attack': 4,
      'defense': 3,
      'movement': 3,
      'special': 'None'
    });

    // Create units for Beta group
    final betaUnit1Id = 'beta_unit1_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch + 2}';
    await db.insert('units', {
      'id': betaUnit1Id,
      'task_group_id': betaGroupId,
      'name': 'Beta Unit 1',
      'type': 'infantry',
      'attack': 3,
      'defense': 2,
      'movement': 2,
      'special': 'None'
    });

    final betaUnit2Id = 'beta_unit2_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch + 3}';
    await db.insert('units', {
      'id': betaUnit2Id,
      'task_group_id': betaGroupId,
      'name': 'Beta Unit 2',
      'type': 'armor',
      'attack': 4,
      'defense': 3,
      'movement': 3,
      'special': 'None'
    });
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create scenarios table
      await db.execute('''
        CREATE TABLE scenarios (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          created_at INTEGER NOT NULL,
          faction TEXT NOT NULL CHECK(faction IN ('USMC', 'PLAN'))
        )
      ''');

      // Add new columns to task_groups
      await db.execute('''
        ALTER TABLE task_groups 
        ADD COLUMN scenario_id TEXT NOT NULL DEFAULT 'default_scenario'
      ''');

      await db.execute('''
        ALTER TABLE task_groups 
        ADD COLUMN faction TEXT NOT NULL DEFAULT 'USMC' 
        CHECK(faction IN ('USMC', 'PLAN'))
      ''');

      // Create default scenario
      await db.insert('scenarios', {
        'id': 'default_scenario',
        'name': 'Default Scenario',
        'description': 'Migrated from version 1',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'faction': 'USMC'
      });

      // Update existing task groups to have unique IDs
      final taskGroups = await db.query('task_groups');
      for (final taskGroup in taskGroups) {
        final newTaskGroupId = '${DateTime.now().millisecondsSinceEpoch}_${taskGroup['id']}';
        await db.update(
          'task_groups',
          {'id': newTaskGroupId},
          where: 'id = ?',
          whereArgs: [taskGroup['id']],
        );

        // Update units to have unique IDs and correct task group references
        final units = await db.query(
          'units',
          where: 'task_group_id = ?',
          whereArgs: [taskGroup['id']],
        );
        for (final unit in units) {
          final newUnitId = '${DateTime.now().millisecondsSinceEpoch}_${unit['id']}';
          await db.update(
            'units',
            {
              'id': newUnitId,
              'task_group_id': newTaskGroupId,
            },
            where: 'id = ?',
            whereArgs: [unit['id']],
          );

          // Update markers to reference new unit ID
          await db.update(
            'unit_markers',
            {'unit_id': newUnitId},
            where: 'unit_id = ?',
            whereArgs: [unit['id']],
          );
        }
      }
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

  Future<String> duplicateScenario(String scenarioId) async {
    final db = await instance.database;
    final scenario = await getScenario(scenarioId);
    if (scenario == null) throw Exception('Scenario not found');

    final newScenarioId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Create new scenario
    await db.insert('scenarios', {
      'id': newScenarioId,
      'name': '${scenario['name']} (Copy)',
      'description': scenario['description'],
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'faction': scenario['faction'],
    });

    // Get all task groups for the scenario
    final taskGroups = await db.query(
      'task_groups',
      where: 'scenario_id = ?',
      whereArgs: [scenarioId],
    );

    // Duplicate each task group and its units
    for (final taskGroup in taskGroups) {
      final newTaskGroupId = '${DateTime.now().millisecondsSinceEpoch}_${taskGroup['id']}';
      
      // Create new task group
      await db.insert('task_groups', {
        'id': newTaskGroupId,
        'scenario_id': newScenarioId,
        'name': taskGroup['name'],
        'description': taskGroup['description'],
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'faction': taskGroup['faction'],
      });

      // Get all units for the task group
      final units = await db.query(
        'units',
        where: 'task_group_id = ?',
        whereArgs: [taskGroup['id']],
      );

      // Duplicate each unit and its markers
      for (final unit in units) {
        final newUnitId = '${DateTime.now().millisecondsSinceEpoch}_${unit['id']}';
        
        // Create new unit
        await db.insert('units', {
          'id': newUnitId,
          'task_group_id': newTaskGroupId,
          'name': unit['name'],
          'type': unit['type'],
          'attack': unit['attack'],
          'defense': unit['defense'],
          'movement': unit['movement'],
          'special': unit['special'],
        });

        // Get all markers for the unit
        final markers = await db.query(
          'unit_markers',
          where: 'unit_id = ?',
          whereArgs: [unit['id']],
        );

        // Duplicate each marker
        for (final marker in markers) {
          await db.insert('unit_markers', {
            'unit_id': newUnitId,
            'position': marker['position'],
            'color': marker['color'],
          });
        }
      }
    }

    return newScenarioId;
  }

  Future<String> exportScenario(String scenarioId) async {
    final db = await instance.database;
    final scenario = await getScenario(scenarioId);
    if (scenario == null) throw Exception('Scenario not found');

    final exportData = {
      'scenario': scenario,
      'task_groups': await db.query(
        'task_groups',
        where: 'scenario_id = ?',
        whereArgs: [scenarioId],
      ),
      'units': await db.query(
        'units',
        where: 'task_group_id IN (SELECT id FROM task_groups WHERE scenario_id = ?)',
        whereArgs: [scenarioId],
      ),
      'markers': await db.query(
        'unit_markers',
        where: 'unit_id IN (SELECT id FROM units WHERE task_group_id IN (SELECT id FROM task_groups WHERE scenario_id = ?))',
        whereArgs: [scenarioId],
      ),
    };

    return jsonEncode(exportData);
  }

  Future<void> importScenario(String jsonData) async {
    final db = await instance.database;
    final importData = jsonDecode(jsonData) as Map<String, dynamic>;

    // Create new scenario with original ID
    await db.insert('scenarios', {
      'id': importData['scenario']['id'],
      'name': importData['scenario']['name'],
      'description': importData['scenario']['description'],
      'created_at': importData['scenario']['created_at'],
      'faction': importData['scenario']['faction'],
    });

    // Create task groups with original IDs
    for (final taskGroup in importData['task_groups']) {
      await db.insert('task_groups', {
        'id': taskGroup['id'],
        'scenario_id': importData['scenario']['id'],
        'name': taskGroup['name'],
        'description': taskGroup['description'],
        'created_at': taskGroup['created_at'],
        'faction': taskGroup['faction'],
      });
    }

    // Create units with original IDs
    for (final unit in importData['units']) {
      await db.insert('units', {
        'id': unit['id'],
        'task_group_id': unit['task_group_id'],
        'name': unit['name'],
        'type': unit['type'],
        'attack': unit['attack'],
        'defense': unit['defense'],
        'movement': unit['movement'],
        'special': unit['special'],
      });
    }

    // Create markers with original unit IDs
    for (final marker in importData['markers']) {
      await db.insert('unit_markers', {
        'unit_id': marker['unit_id'],
        'position': marker['position'],
        'color': marker['color'],
      });
    }
  }

  Future<Map<String, dynamic>> getScenarioStats(String scenarioId) async {
    final db = await instance.database;
    
    final taskGroupCount = (await db.query(
      'task_groups',
      where: 'scenario_id = ?',
      whereArgs: [scenarioId],
    )).length;

    final unitCount = (await db.query(
      'units',
      where: 'task_group_id IN (SELECT id FROM task_groups WHERE scenario_id = ?)',
      whereArgs: [scenarioId],
    )).length;

    final markerCount = (await db.query(
      'unit_markers',
      where: 'unit_id IN (SELECT id FROM units WHERE task_group_id IN (SELECT id FROM task_groups WHERE scenario_id = ?))',
      whereArgs: [scenarioId],
    )).length;

    return {
      'taskGroupCount': taskGroupCount,
      'unitCount': unitCount,
      'markerCount': markerCount,
    };
  }

  Future<List<Map<String, dynamic>>> getUnitsForTaskGroup(String taskGroupId) async {
    final db = await instance.database;
    return await db.query(
      'units',
      where: 'task_group_id = ?',
      whereArgs: [taskGroupId],
      orderBy: 'name ASC',
    );
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'littoral_tracker.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  Future<void> createUnit({
    required String taskGroupId,
    required String name,
    required UnitType type,
    required int attack,
    required int defense,
    required int movement,
    String? special,
  }) async {
    final db = await database;
    await db.insert(
      'units',
      {
        'id': '${DateTime.now().millisecondsSinceEpoch}_${taskGroupId}',
        'task_group_id': taskGroupId,
        'name': name,
        'type': type.toString().split('.').last,
        'attack': attack,
        'defense': defense,
        'movement': movement,
        'special': special,
      },
    );
  }

  Future<void> updateUnit({
    required String id,
    required String name,
    required UnitType type,
    required int attack,
    required int defense,
    required int movement,
    String? special,
  }) async {
    final db = await database;
    await db.update(
      'units',
      {
        'name': name,
        'type': type.toString().split('.').last,
        'attack': attack,
        'defense': defense,
        'movement': movement,
        'special': special,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteUnit(String id) async {
    final db = await database;
    await db.delete(
      'units',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 