import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static Database _database;
  static DbHelper _dbHelper; // Singleton Helper

  DbHelper._createInstance(); // Named CONST To Create Instance of the DbHelper

  static final String DB_NAME = "gen_records.db";

  static final String MAIN_RECORD_TABLE = "main_gen_record";
  static final String ID_COLUMN = "id";
  static final String START_DATE_COLUMN = "startDate";
  static final String START_TIME_COLUMN = "startTime";
  static final String END_DATE_COLUMN = "endDate";
  static final String END_TIME_COLUMN = "endTime";
  static final String START_DATE_TIME_COLUMN = "startDateTime";
  static final String END_DATE_TIME_COLUMN = "endDateTime";
  static final String DURATION_IN_MINS_COLUMN = "duration_in_mins";

  static final String DAILY_RECORDS_TABLE = "daily_record";
  static final String DATE_COLUMN = "date";
  static final String INITIAL_START_COLUMN = "initialStart";
  static final String FINAL_SHUTDOWN_COLUMN = "finalShutDown";

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
    String path = join(databasesPath, DbHelper.DB_NAME);

    // OPEN / CREATE THE DB AT GIVEN PATH

    var db = await openDatabase(path, version: 1, onCreate: _createDB);

    return db;
  }

  void _createDB(Database db, int newVersion) async {
    // When creating the db, create the tables
    await db.execute(
        'CREATE TABLE $MAIN_RECORD_TABLE ($ID_COLUMN INTEGER PRIMARY KEY, $START_DATE_COLUMN TEXT NOT NULL, $START_TIME_COLUMN TEXT NOT NULL, $END_TIME_COLUMN TEXT, $END_DATE_COLUMN TEXT,  $START_DATE_TIME_COLUMN TEXT UNIQUE NOT NULL, ${DbHelper.END_DATE_TIME_COLUMN} TEXT UNIQUE, $DURATION_IN_MINS_COLUMN INTEGER)');
    await db.execute(
        'CREATE TABLE $DAILY_RECORDS_TABLE ($ID_COLUMN INTEGER PRIMARY KEY, $DATE_COLUMN TEXT UNIQUE NOT NULL, $INITIAL_START_COLUMN TEXT NOT NULL, $FINAL_SHUTDOWN_COLUMN TEXT, $DURATION_IN_MINS_COLUMN INTEGER DEFAULT 0)');
  }
}
