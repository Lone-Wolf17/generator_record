import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static Database _database;
  static DbHelper _dbHelper; // Singleton Helper

  DbHelper._createInstance(); // Named CONST To Create Instance of the DbHelper

  static final String dbName = "power_records.db";

  static final String mainRecordTable = "main_record";
  static final String idCol = "id";
  static final String startDateCol = "startDate";
  static final String startTimeCol = "startTime";
  static final String endDateCol = "endDate";
  static final String endTimeCol = "endTime";
  static final String startDateTimeCol = "startDateTime";
  static final String powerSourceCol = "powerSource";
  static final String endDateTimeCol = "endDateTime";
  static final String durationInMinsCol = "duration_in_mins";

  static final String dailySummaryTable = "daily_summary";
  static final String dateCol = "date";
  static final String dateTimeCol = "dateTime";
  static final String initialStartCol = "initialStart";
  static final String finalShutdownCol = "finalShutDown";

  factory DbHelper() {
    if (_dbHelper == null) {
      _dbHelper = DbHelper._createInstance(); // EXEC ONLY ONCE (SINGLETON OBJ)
    }

    return _dbHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDB();
    }

    return _database;
  }

  Future<Database> initializeDB() async {
    //GET THE PATH TO THE DIRECTORY FOR IOS AND ANDROID TO STORE DB
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, DbHelper.dbName);

    // OPEN / CREATE THE DB AT GIVEN PATH

    var db = await openDatabase(path, version: 1, onCreate: _createDB);

    return db;
  }

  void _createDB(Database db, int newVersion) async {
    // When creating the db, create the tables
    await db.execute('CREATE TABLE $mainRecordTable ('
        ' $idCol INTEGER PRIMARY KEY,'
        ' $powerSourceCol TEXT NOT NULL,'
        ' $startDateCol TEXT NOT NULL,'
        ' $startTimeCol TEXT NOT NULL,'
        ' $endTimeCol TEXT,'
        ' $endDateCol TEXT,'
        ' $startDateTimeCol TEXT UNIQUE NOT NULL,'
        ' $endDateTimeCol TEXT UNIQUE,'
        ' $durationInMinsCol INTEGER DEFAULT 0)');

  }
}
