import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NotificationDatabase {
  static final NotificationDatabase instance = NotificationDatabase._init();

  static Database? _database;

  NotificationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('notifications.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const dateType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE notifications ( 
  id $idType, 
  message $textType,
  receivedAt $dateType
  )
''');
  }

  Future<void> create(NotificationMessage notification) async {
    final db = await instance.database;

    await db.insert('notifications', notification.toJson());
  }

  Future<List<NotificationMessage>> readAllNotifications() async {
    final db = await instance.database;

    final result = await db.query('notifications', orderBy: 'receivedAt DESC');

    return result.map((json) => NotificationMessage.fromJson(json)).toList();
  }

  Future<void> clearNotifications() async {
    final db = await instance.database;

    await db.delete('notifications');
  }
}

class NotificationMessage {
  final String id;
  final String message;
  final DateTime receivedAt;

  NotificationMessage({
    required this.id,
    required this.message,
    required this.receivedAt,
  });

  factory NotificationMessage.fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      id: json['id'],
      message: json['message'],
      receivedAt: DateTime.parse(json['receivedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'receivedAt': receivedAt.toIso8601String(),
    };
  }
}
