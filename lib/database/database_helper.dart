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
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE task_groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        created_at INTEGER NOT NULL
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
        FOREIGN KEY (task_group_id) REFERENCES task_groups (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE unit_markers (
        unit_id TEXT NOT NULL,
        position INTEGER NOT NULL,
        color TEXT NOT NULL,
        FOREIGN KEY (unit_id) REFERENCES units (id)
      )
    ''');
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
} 