import 'package:flutter/material.dart';
import 'package:generator_record/db_helper.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DaysPage extends StatefulWidget {
  @override
  _DaysPageState createState() => _DaysPageState();
}

class _DaysPageState extends State<DaysPage> {

  _readDB() async {


    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, DbHelper.DB_NAME);

// open the database
    Database database = await openDatabase(path);

    // Get the records
    List<Map> list =
        await database.rawQuery('SELECT * FROM ${DbHelper.MAIN_RECORD_TABLE}');
  }



  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
