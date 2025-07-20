import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modules/client/models/client_model.dart';
import '../modules/care_log/models/care_log_model.dart';
import '../modules/facility_logs/models/facility_log_model.dart';
import '../modules/tasks/models/task_model.dart';
import '../models/reminder_model.dart';
import '../core/error_handler.dart';
import '../core/retry_mechanism.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  final RetryMechanism _retryMechanism = RetryMechanism();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'sanyin.db');
      return await openDatabase(
        path,
        version: 5, // Increment version to trigger migration
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw AppError(
        message: 'Failed to initialize database',
        type: ErrorType.database,
        originalError: e,
      );
    }
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

    // Create facility_logs table
    await db.execute('''
      CREATE TABLE facility_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        homeId INTEGER NOT NULL DEFAULT 0,
        action TEXT NOT NULL,
        description TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        type TEXT NOT NULL,
        priority TEXT NOT NULL,
        staffMember TEXT,
        location TEXT,
        additionalData TEXT,
        photoPath TEXT,
        isResolved INTEGER NOT NULL DEFAULT 0,
        resolvedAt TEXT,
        resolvedBy TEXT
      )
    ''');

    // Create tasks table
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        dueDate TEXT,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        assignedTo TEXT,
        category TEXT,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        recurrencePattern TEXT,
        completedAt TEXT,
        completedBy TEXT,
        notes TEXT
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
    
    if (oldVersion < 3) {
      // Add facility_logs table for version 3
      await db.execute('''
        CREATE TABLE facility_logs(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          action TEXT NOT NULL,
          description TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          type TEXT NOT NULL,
          priority TEXT NOT NULL,
          staffMember TEXT,
          location TEXT,
          additionalData TEXT,
          photoPath TEXT,
          isResolved INTEGER NOT NULL DEFAULT 0,
          resolvedAt TEXT,
          resolvedBy TEXT
        )
      ''');
    }
    
    if (oldVersion < 4) {
      // Add homeId column to existing facility_logs table
      try {
        await db.execute('ALTER TABLE facility_logs ADD COLUMN homeId INTEGER NOT NULL DEFAULT 0');
      } catch (e) {
        // Column might already exist, ignore error
        print('homeId column might already exist: $e');
      }
    }
    
    if (oldVersion < 5) {
      // Add tasks table for version 5
      await db.execute('''
        CREATE TABLE tasks(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          createdAt TEXT NOT NULL,
          dueDate TEXT,
          priority TEXT NOT NULL,
          status TEXT NOT NULL,
          assignedTo TEXT,
          category TEXT,
          isRecurring INTEGER NOT NULL DEFAULT 0,
          recurrencePattern TEXT,
          completedAt TEXT,
          completedBy TEXT,
          notes TEXT
        )
      ''');
    }
  }

  // Client operations
  Future<int> insertClient(Client client) async {
    return await _retryMechanism.retryDatabaseOperation(
      () async {
        try {
          final db = await database;
          return await db.insert('clients', client.toMap());
        } catch (e) {
          throw AppError(
            message: 'Failed to add client',
            type: ErrorType.database,
            originalError: e,
          );
        }
      },
      operationName: 'Add client',
    );
  }

  Future<List<Client>> getClients() async {
    return await _retryMechanism.retryDatabaseOperation(
      () async {
        try {
          final db = await database;
          final List<Map<String, dynamic>> maps = await db.query('clients', orderBy: 'name ASC');
          return List.generate(maps.length, (i) => Client.fromMap(maps[i]));
        } catch (e) {
          throw AppError(
            message: 'Failed to load clients',
            type: ErrorType.database,
            originalError: e,
          );
        }
      },
      operationName: 'Load clients',
    );
  }

  Future<Client?> getClient(int id) async {
    try {
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
    } catch (e) {
      throw AppError(
        message: 'Failed to load client details',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  Future<int> updateClient(Client client) async {
    try {
      final db = await database;
      return await db.update(
        'clients',
        client.toMap(),
        where: 'id = ?',
        whereArgs: [client.id],
      );
    } catch (e) {
      throw AppError(
        message: 'Failed to update client',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  Future<int> deleteClient(int id) async {
    try {
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
    } catch (e) {
      throw AppError(
        message: 'Failed to delete client',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  // Care log operations
  Future<int> insertCareLog(CareLog careLog) async {
    return await _retryMechanism.retryDatabaseOperation(
      () async {
        try {
          final db = await database;
          return await db.insert('care_logs', careLog.toMap());
        } catch (e) {
          throw AppError(
            message: 'Failed to save care log',
            type: ErrorType.database,
            originalError: e,
          );
        }
      },
      operationName: 'Save care log',
    );
  }

  Future<List<CareLog>> getCareLogsForClient(int clientId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'care_logs',
        where: 'clientId = ?',
        whereArgs: [clientId],
        orderBy: 'timestamp DESC',
      );
      return List.generate(maps.length, (i) => CareLog.fromMap(maps[i]));
    } catch (e) {
      throw AppError(
        message: 'Failed to load care logs',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  Future<List<CareLog>> getAllCareLogs() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'care_logs',
        orderBy: 'timestamp DESC',
      );
      return List.generate(maps.length, (i) => CareLog.fromMap(maps[i]));
    } catch (e) {
      throw AppError(
        message: 'Failed to load care logs',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  Future<int> deleteCareLog(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'care_logs',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppError(
        message: 'Failed to delete care log',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  // Reminder operations
  Future<int> insertReminder(Reminder reminder) async {
    try {
      final db = await database;
      return await db.insert('reminders', reminder.toMap());
    } catch (e) {
      throw AppError(
        message: 'Failed to add reminder',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  Future<List<Reminder>> getRemindersForClient(int clientId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'reminders',
        where: 'clientId = ?',
        whereArgs: [clientId],
        orderBy: 'scheduledTime ASC',
      );
      return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
    } catch (e) {
      throw AppError(
        message: 'Failed to load reminders',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  Future<List<Reminder>> getAllReminders() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'reminders',
        orderBy: 'scheduledTime ASC',
      );
      return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
    } catch (e) {
      throw AppError(
        message: 'Failed to load reminders',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  Future<int> updateReminder(Reminder reminder) async {
    try {
      final db = await database;
      return await db.update(
        'reminders',
        reminder.toMap(),
        where: 'id = ?',
        whereArgs: [reminder.id],
      );
    } catch (e) {
      throw AppError(
        message: 'Failed to update reminder',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  Future<int> deleteReminder(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'reminders',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppError(
        message: 'Failed to delete reminder',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  // Facility log operations
  Future<int> insertFacilityLog(FacilityLog facilityLog) async {
    return await _retryMechanism.retryDatabaseOperation(
      () async {
        try {
          final db = await database;
          return await db.insert('facility_logs', facilityLog.toMap());
        } catch (e) {
          throw AppError(
            message: 'Failed to save facility log',
            type: ErrorType.database,
            originalError: e,
          );
        }
      },
      operationName: 'Save facility log',
    );
  }

  Future<List<FacilityLog>> getFacilityLogsForHome(int homeId) async {
    try {
      final db = await database;
      // Get logs for specific home AND legacy logs (homeId = 0)
      final List<Map<String, dynamic>> maps = await db.query(
        'facility_logs',
        where: 'homeId = ? OR homeId = 0',
        whereArgs: [homeId],
        orderBy: 'timestamp DESC',
      );
      return List.generate(maps.length, (i) => FacilityLog.fromMap(maps[i]));
    } catch (e) {
      throw AppError(
        message: 'Failed to load facility logs',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  Future<List<FacilityLog>> getAllFacilityLogs() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'facility_logs',
        orderBy: 'timestamp DESC',
      );
      return List.generate(maps.length, (i) => FacilityLog.fromMap(maps[i]));
    } catch (e) {
      throw AppError(
        message: 'Failed to load facility logs',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  Future<FacilityLog?> getFacilityLog(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'facility_logs',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return FacilityLog.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw AppError(
        message: 'Failed to load facility log details',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  Future<int> updateFacilityLog(FacilityLog facilityLog) async {
    try {
      final db = await database;
      return await db.update(
        'facility_logs',
        facilityLog.toMap(),
        where: 'id = ?',
        whereArgs: [facilityLog.id],
      );
    } catch (e) {
      throw AppError(
        message: 'Failed to update facility log',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  Future<int> deleteFacilityLog(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'facility_logs',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppError(
        message: 'Failed to delete facility log',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  // Task operations
  Future<int> insertTask(Task task) async {
    return await _retryMechanism.retryDatabaseOperation(
      () async {
        try {
          final db = await database;
          return await db.insert('tasks', task.toMap());
        } catch (e) {
          throw AppError(
            message: 'Failed to save task',
            type: ErrorType.database,
            originalError: e,
          );
        }
      },
      operationName: 'Save task',
    );
  }

  Future<List<Task>> getAllTasks() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        orderBy: 'createdAt DESC',
        limit: 1000, // Limit to prevent memory issues
      );
      return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
    } catch (e) {
      throw AppError(
        message: 'Failed to load tasks',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  Future<Task?> getTask(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Task.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw AppError(
        message: 'Failed to load task details',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  Future<int> updateTask(Task task) async {
    try {
      final db = await database;
      return await db.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      throw AppError(
        message: 'Failed to update task',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  Future<int> deleteTask(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppError(
        message: 'Failed to delete task',
        type: ErrorType.database,
        originalError: e,
      );
    }
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