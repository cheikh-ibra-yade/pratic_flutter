import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  User.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        name = map[nameColumn] as String,
        email = map[emailColumn] as String;
}

class Note {
  final int id;
  final int userId;
  final String text;
  final bool isSynced;

  Note(
      {required this.id,
      required this.userId,
      required this.text,
      required this.isSynced});

  Note.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSynced = (map[isSyncedColumn] as int) == 1 ? true : false;
}

class NoteService {
  Database? _db;

  List<Note> _notes = [];

  // Singleton principe
  static final NoteService _shared = NoteService._sharedInstance();
  NoteService._sharedInstance();
  factory NoteService() => _shared;

  final _sreamNoteController = StreamController<List<Note>>.broadcast();

  Stream<List<Note>> get allNotes => _sreamNoteController.stream;

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpened {}
  }

  Future<void> catcheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _sreamNoteController.add(_notes);
  }

  Future<void> open() async {
    if (_db != null) throw new DatabaseAlreadyOpened();

    try {
      final myDocApllPath = await getApplicationDocumentsDirectory();
      final dbPath = join(myDocApllPath.path, dbFile);
      _db = await openDatabase(dbPath);
      await _db?.execute(scriptCreateTableUSer);
      await _db?.execute(scriptCreateTableNote);

      await catcheNotes();
    } catch (e) {}
  }

  Future<void> close() async {
    if (_db == null) {
      throw DatabaseIsNotOpened();
    } else {
      _db?.close();
    }
  }

  Database getDatabaseOrThrow() {
    final db = _db!;
    if (_db == null) {
      throw DatabaseIsNotOpened();
    } else {
      return db;
    }
  }

  Future<User> getOrCreateUser({required String email}) {
    try {
      final user = getUserByEmail(email: email);
      return user;
    } on UserCountNotFound {
      final newUser = saveUser(email: email, name: "Yade");
      return newUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = getDatabaseOrThrow();
    final deleteCount =
        db.delete(userTable, where: 'email = ?', whereArgs: [email.toString()]);
    if (deleteCount == 0) {
      throw Exception();
    } else {}
  }

  Future<User> saveUser({required String email, required String name}) async {
    await _ensureDbIsOpen();
    final db = getDatabaseOrThrow();

    //Check if the user already exists
    final result = await db
        .query(userTable, limit: 1, where: 'email = ?', whereArgs: [email]);

    if (result.isNotEmpty) throw new Exception();
    final userId =
        await db.insert(userTable, {nameColumn: name, emailColumn: email});

    if (userId != 1) throw Exception();

    return User(id: userId, email: email, name: name);
  }

  Future<User> getUserByEmail({required String email}) async {
    await _ensureDbIsOpen();
    final db = getDatabaseOrThrow();

    final results = await db.query(userTable,
        limit: 1, where: 'email=?', whereArgs: [email.toLowerCase()]);
    if (results.isEmpty) {
      throw UserCountNotFound();
    }

    return User.fromRow(results.first);
  }

  Future<Note> saveNote({required String text, required User owner}) async {
    await _ensureDbIsOpen();
    final db = getDatabaseOrThrow();
    // chex if owner exists
    final user = await getUserByEmail(email: owner.email);
    if (user.id != owner.id) throw new Exception();

    final idNote = await db.insert(noteTable,
        {userIdColumn: owner.id, textColumn: text, isSyncedColumn: 1});

    if (idNote == 0) {
      throw Exception();
    }

    // TODO: ISync ID TRUE
    final note = Note(id: idNote, userId: owner.id, text: text, isSynced: true);
    _notes.add(note);
    _sreamNoteController.add(_notes);
    return note;
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = getDatabaseOrThrow();
    final numberOfDeletion = db.delete(noteTable);
    if (numberOfDeletion == 0) {
      throw Exception();
    }
    _notes = [];
    _sreamNoteController.add(_notes);
    return numberOfDeletion;
  }

  Future<int> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = getDatabaseOrThrow();
    final deletedCount = db.delete(noteTable, where: 'id = ?', whereArgs: [id]);
    if (deletedCount == 0) {
      throw Exception();
    }

    _notes.removeWhere((note) => note.id == id);
    _sreamNoteController.add(_notes);
    return deletedCount;
  }

  Future<Note> getNoteById({required int id}) async {
    await _ensureDbIsOpen();
    final db = getDatabaseOrThrow();
    final result = await db.query(noteTable, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) throw Exception();
    final note = Note.fromRow(result.first);
    _notes.removeWhere((note) => note.id == id);
    _notes.add(note);
    _sreamNoteController.add(_notes);
    return note;
  }

  Future<Iterable<Note>> getAllNotes() async {
    final db = await getDatabaseOrThrow();
    final notes = await db.query(noteTable);

    if (notes.isEmpty) throw Exception();
    return notes.map((noteRow) => Note.fromRow(noteRow));
  }

  Future<Note> updateNote({required Note note, required String text}) async {
    await _ensureDbIsOpen();
    final db = getDatabaseOrThrow();

// exist or throw exception
    await db.query(noteTable, where: 'id = ?', whereArgs: [note.id]);

    final count = db.update(
        noteTable, {textColumn: text, isSyncedColumn: note.isSynced},
        where: 'id = ?', whereArgs: [note.id]);

    if (count == 0) {
      throw Exception();
    } else {
      final updatedNote = await getNoteById(id: note.id);
      _notes.removeWhere((noteItem) => noteItem.id == updatedNote.id);
      _sreamNoteController.add(_notes);
      return updatedNote;
    }
  }
}

const scriptCreateTableUSer = '''CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL,
	"name"	TEXT NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
)''';

const scriptCreateTableNote = '''CREATE TABLE IF NOT EXISTS "note" (
	"id"	INTEGER NOT NULL,
	"text"	TEXT NOT NULL,
	"user_id"	INTEGER,
	"is_synced"	INTEGER DEFAULT 0 COLLATE UTF16,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
)''';

const userTable = "user";
const noteTable = "note";
const dbFile = "note.db";
const idColumn = "id";
const userIdColumn = "user_id";
const nameColumn = "name";
const emailColumn = "email";
const textColumn = "text";
const isSyncedColumn = "is_ynced";

class DatabaseAlreadyOpened implements Exception {}

class DatabaseIsNotOpened implements Exception {}

class UserCountNotFound implements Exception {}
