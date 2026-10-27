import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/group_model.dart';
import '../models/member_model.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();

    _database = await openDatabase(
      join(dbPath, 'splitmate.db'),
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE groups (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE members (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            group_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            is_me INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (group_id)
              REFERENCES groups(id)
              ON DELETE CASCADE
          )
        ''');
      },
    );

    return _database!;
  }

  Future<int> createGroup(
      String name,
      List<String> members,
      ) async {
    final db = await database;

    return db.transaction((txn) async {
      final groupId = await txn.insert(
        'groups',
        {
          'name': name.trim(),
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
      );

      for (final member in members) {
        await txn.insert('members', {
          'group_id': groupId,
          'name': member.trim(),
          'is_me': 0,
        });
      }

      return groupId;
    });
  }

  Future<List<GroupModel>> getGroups() async {
    final db = await database;

    final rows = await db.query(
      'groups',
      orderBy: 'created_at DESC, id DESC',
    );

    return rows.map(GroupModel.fromMap).toList();
  }

  Future<GroupModel?> getGroup(int groupId) async {
    final db = await database;

    final rows = await db.query(
      'groups',
      where: 'id = ?',
      whereArgs: [groupId],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return GroupModel.fromMap(rows.first);
  }

  Future<List<MemberModel>> getMembers(int groupId) async {
    final db = await database;

    final rows = await db.query(
      'members',
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'id ASC',
    );

    return rows.map(MemberModel.fromMap).toList();
  }

  Future<int> addMember(int groupId, String name) async {
    final db = await database;

    return db.insert('members', {
      'group_id': groupId,
      'name': name.trim(),
      'is_me': 0,
    });
  }

  Future<int> deleteMember(int memberId) async {
    final db = await database;

    return db.delete(
      'members',
      where: 'id = ?',
      whereArgs: [memberId],
    );
  }

  Future<int> renameGroup(int groupId, String name) async {
    final db = await database;

    return db.update(
      'groups',
      {'name': name.trim()},
      where: 'id = ?',
      whereArgs: [groupId],
    );
  }

  Future<int> deleteGroup(int groupId) async {
    final db = await database;

    return db.delete(
      'groups',
      where: 'id = ?',
      whereArgs: [groupId],
    );
  }
}