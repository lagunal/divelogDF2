import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logging/logging.dart';
import 'dart:convert';

class DatabaseHelper {
  static final Logger _log = Logger('DatabaseHelper');
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbDir = await getDatabasesPath();
      final path = join(dbDir, 'divelogtest.db');

      return openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      _log.severe('Error initializing database', e);
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      // Dive Sessions Table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS dive_sessions (
          id TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          cliente TEXT NOT NULL,
          operadoraBuceo TEXT NOT NULL,
          direccionOperadora TEXT NOT NULL,
          lugarBuceo TEXT NOT NULL,
          tipoBuceo TEXT NOT NULL,
          nombreBuzos TEXT NOT NULL,
          supervisorBuceo TEXT NOT NULL,
          estadoMar INTEGER NOT NULL,
          visibilidad REAL NOT NULL,
          temperaturaSuperior REAL NOT NULL,
          temperaturaAgua REAL NOT NULL,
          corrienteAgua TEXT NOT NULL,
          tipoAgua TEXT NOT NULL,
          horaEntrada TEXT NOT NULL,
          maximaProfundidad REAL NOT NULL,
          tiempoIntervaloSuperficie REAL NOT NULL,
          tiempoFondo REAL NOT NULL,
          inicioDescompresion TEXT,
          descompresionCompleta TEXT,
          tiempoTotalInmersion REAL NOT NULL,
          horaSalida TEXT NOT NULL,
          descripcionTrabajo TEXT NOT NULL,
          descompresionUtilizada TEXT NOT NULL,
          enfermedadLesion TEXT,
          tiempoSupervisionAcumulado REAL NOT NULL,
          tiempoBuceoAcumulado REAL NOT NULL,
          isSynced INTEGER DEFAULT 0,
          lastSyncedAt TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');

      // User Profile Table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_profiles (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT NOT NULL,
          certificationLevel TEXT,
          certificationNumber TEXT,
          certificationDate TEXT,
          totalDives INTEGER NOT NULL,
          totalBottomTime REAL NOT NULL,
          deepestDive REAL NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');

      _log.info('Database tables created successfully');
    } catch (e) {
      _log.severe('Error creating database tables', e);
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _log.info('Upgrading database from $oldVersion to $newVersion');
    if (oldVersion < 2) {
      try {
        await db.execute(
            'ALTER TABLE dive_sessions ADD COLUMN isSynced INTEGER DEFAULT 0');
        await db
            .execute('ALTER TABLE dive_sessions ADD COLUMN lastSyncedAt TEXT');
      } catch (e) {
        _log.warning(
            'Error upgrading database to v2 (columns may already exist)', e);
      }
    }
  }

  Map<String, dynamic> _prepareDataForInsert(Map<String, dynamic> data) {
    final Map<String, dynamic> preparedData = Map<String, dynamic>.from(data);
    preparedData.forEach((key, value) {
      if (value is List) {
        // Serialize List to JSON String for TEXT columns (e.g. nombreBuzos)
        preparedData[key] = jsonEncode(value);
      }
    });
    return preparedData;
  }

  // Dive Sessions CRUD
  Future<int> insertDiveSession(Map<String, dynamic> session) async {
    try {
      final db = await database;
      final sessionToInsert = _prepareDataForInsert(session);
      return db.insert(
        'dive_sessions',
        sessionToInsert,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      _log.severe('Error inserting dive session', e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllDiveSessions() async {
    try {
      final db = await database;
      return db.query('dive_sessions', orderBy: 'createdAt DESC');
    } catch (e) {
      _log.severe('Error retrieving dive sessions', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getDiveSessionById(String id) async {
    try {
      final db = await database;
      final result = await db.query(
        'dive_sessions',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      _log.severe('Error retrieving dive session', e);
      rethrow;
    }
  }

  Future<int> updateDiveSession(Map<String, dynamic> session) async {
    try {
      final db = await database;
      final sessionToUpdate = _prepareDataForInsert(session);
      return db.update(
        'dive_sessions',
        sessionToUpdate,
        where: 'id = ?',
        whereArgs: [sessionToUpdate['id']],
      );
    } catch (e) {
      _log.severe('Error updating dive session', e);
      rethrow;
    }
  }

  Future<int> deleteDiveSession(String id) async {
    try {
      final db = await database;
      return db.delete(
        'dive_sessions',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      _log.severe('Error deleting dive session', e);
      rethrow;
    }
  }

  // User Profile CRUD
  Future<int> saveUserProfile(Map<String, dynamic> profile) async {
    try {
      final db = await database;
      final profileToInsert = _prepareDataForInsert(profile);
      return db.insert(
        'user_profiles',
        profileToInsert,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      _log.severe('Error saving user profile', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final db = await database;
      final result = await db.query(
        'user_profiles',
        where: 'id = ?',
        whereArgs: [userId],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      _log.severe('Error retrieving user profile', e);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      final db = await database;
      await db.delete('dive_sessions');
      await db.delete('user_profiles');
      _log.info('All local data cleared');
    } catch (e) {
      _log.severe('Error clearing database', e);
      rethrow;
    }
  }
}
