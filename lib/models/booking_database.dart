import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'booking.dart';

class BookingDatabase {
  static final BookingDatabase instance = BookingDatabase._init();
  static Database? _database;

  BookingDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bookings.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE bookings (
  reference_no TEXT PRIMARY KEY,
  airport_name TEXT NOT NULL,
  departure_date TEXT NOT NULL,
  return_date TEXT NOT NULL,
  total_amount REAL NOT NULL,
  number_of_days INTEGER NOT NULL,
  company_name TEXT NOT NULL,
  company_logo TEXT NOT NULL,
  created_at TEXT NOT NULL
)
''');
  }

  Future<void> insertBooking(Booking booking) async {
    final db = await instance.database;
    await db.insert('bookings', booking.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Booking>> getBookings() async {
    final db = await instance.database;
    final result = await db.query('bookings');
    return result.map((json) => Booking.fromJson(json)).toList();
  }
}
