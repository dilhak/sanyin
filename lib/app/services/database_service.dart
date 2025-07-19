import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modules/client/models/client_model.dart';
import '../modules/care_log/models/care_log_model.dart';
import '../models/reminder_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sanyin.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create clients table
    await db.execute('''
      CREATE TABLE clients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phoneNumber TEXT,
        address TEXT,
        emergencyContact TEXT,
        medicalNotes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create care_logs table
    await db.execute('''
      CREATE TABLE care_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientId INTEGER NOT NULL,
        activityType TEXT NOT NULL,
        action TEXT,
        subAction TEXT,
        details TEXT,
        photoPath TEXT,
        timestamp TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (clientId) REFERENCES clients (id)
      )
    ''');

    // Create reminders table
    await db.execute('''
      CREATE TABLE reminders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        scheduledTime INTEGER NOT NULL,
        isActive INTEGER NOT NULL,
        frequency TEXT,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (clientId) REFERENCES clients (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add reminders table for version 2
      await db.execute('''
        CREATE TABLE reminders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          clientId INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          scheduledTime INTEGER NOT NULL,
          isActive INTEGER NOT NULL,
          frequency TEXT,
          createdAt INTEGER NOT NULL,
          FOREIGN KEY (clientId) REFERENCES clients (id)
        )
      ''');
    }
  }

  // Client operations
  Future<int> insertClient(Client client) async {
    final db = await database;
    return await db.insert('clients', client.toMap());
  }

  Future<List<Client>> getClients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clients', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => Client.fromMap(maps[i]));
  }

  Future<Client?> getClient(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Client.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateClient(Client client) async {
    final db = await database;
    return await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(int id) async {
    final db = await database;
    // First delete related care logs
    await db.delete(
      'care_logs',
      where: 'clientId = ?',
      whereArgs: [id],
    );
    // Then delete the client
    return await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Care log operations
  Future<int> insertCareLog(CareLog careLog) async {
    final db = await database;
    return await db.insert('care_logs', careLog.toMap());
  }

  Future<List<CareLog>> getCareLogsForClient(int clientId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'care_logs',
      where: 'clientId = ?',
      whereArgs: [clientId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => CareLog.fromMap(maps[i]));
  }

  Future<List<CareLog>> getAllCareLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'care_logs',
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => CareLog.fromMap(maps[i]));
  }

  Future<int> deleteCareLog(int id) async {
    final db = await database;
    return await db.delete(
      'care_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Reminder operations
  Future<int> insertReminder(Reminder reminder) async {
    final db = await database;
    return await db.insert('reminders', reminder.toMap());
  }

  Future<List<Reminder>> getRemindersForClient(int clientId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reminders',
      where: 'clientId = ?',
      whereArgs: [clientId],
      orderBy: 'scheduledTime ASC',
    );
    return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
  }

  Future<List<Reminder>> getAllReminders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reminders',
      orderBy: 'scheduledTime ASC',
    );
    return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
  }

  Future<int> updateReminder(Reminder reminder) async {
    final db = await database;
    return await db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    return await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Database utilities
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    await close();
    String path = join(await getDatabasesPath(), 'sanyin.db');
    await databaseFactory.deleteDatabase(path);
  }
} 