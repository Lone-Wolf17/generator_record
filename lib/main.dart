import 'package:flutter/material.dart';
import 'package:generator_record/utils.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SharedPreferences prefs;
  String genState = "gen_state";
  bool isGenOn = false;
  Database database;

  _toggleGenState() async {
    bool prevState = prefs.getBool(genState);
    print("Previous gen State: ${prefs.getBool(genState)}");
    prefs.setBool(genState, !prevState);
    print("New gen State: ${prefs.getBool(genState)}");
  }

  _setUpPersistence() async {
    prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(genState)) {
      prefs.setBool(genState, false);
    } else {
      isGenOn = prefs.getBool(genState);
    }

    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo3.db');

// open the database
    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE $mainTableName (id INTEGER PRIMARY KEY, startDate TEXT, startTime TEXT, endTime TEXT, endDate TEXT, startDateTime TEXT UNIQUE, endDateTime TEXT UNIQUE, duration INTEGER)');
      prefs.setString("firstDate", DateTime.now().toUtc().toString());
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _setUpPersistence();
    super.initState();
  }

  _startGen() async {
    _toggleGenState();
    // Insert some records in a transaction
    await database.transaction((txn) async {
      DateTime.now();
      DateTime dt = DateTime.now();
      String startDate = DateFormat('dd-MMM-yy').format(dt);

      String startTime = DateFormat('kk:mm').format(dt);
      prefs.setString("startTime", dt.toUtc().toString());
      int id1 = await txn.rawInsert(
          'INSERT INTO $mainTableName (startDate, startTime, startDateTime) VALUES("$startDate", "$startTime", "${dt.toUtc()}")')
      .then((value) {
        setState(() {
          isGenOn = true;
        });
        return value;
      });
      print('inserted1: $id1');
      // int id2 = await txn.rawInsert(
      //     'INSERT INTO Test(name, value, num) VALUES(?, ?, ?)',
      //     ['another name', 12345678, 3.1416]);
      // print('inserted2: $id2');
    });


  }

  _stopGen() async {
    _toggleGenState();
    // Insert some records in a transaction
    await database.transaction((txn) async {
      DateTime dt = DateTime.now();
      String endDate = DateFormat('dd-MMM-yy').format(dt);

      String endTime = DateFormat('kk:mm').format(dt);

      String startTimeStr = prefs.getString("startTime");

      DateTime startTime = DateTime.parse(startTimeStr);

      Duration duration = dt.difference(startTime);

      print("Duration in minutes: ${duration.inMinutes}");
      print("Duration in hours: ${duration.inHours}");

      int id1 = await txn.rawUpdate(
          'UPDATE $mainTableName SET endDate = ?, endTime = ?, endDateTime = ?, duration = ? WHERE startDateTime = ?',
          ['$endDate', '$endTime', "${dt.toUtc()}", '$startTimeStr', duration.inMinutes]).then((value) {
        setState(() {
          isGenOn = false;
        });
        return value;
      });

      print('Updated: $id1');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Big Gen Records"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
              child: RaisedButton(
                  padding: EdgeInsets.all(15),
                  shape: StadiumBorder(),
                  onPressed: !isGenOn ? _startGen : null,
                  color: Colors.green,
                  disabledTextColor: Colors.green,
                  child: Text(
                    'Switch On',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ))),
          Center(
              child: RaisedButton(
                  padding: EdgeInsets.all(15),
                  shape: StadiumBorder(),
                  onPressed: isGenOn
                      ? _stopGen
                      : null,
                  color: Colors.red,
                  disabledTextColor: Colors.red,
                  child: Text(
                    'Switch Off',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  )))
        ],
      ),
    );
  }
}
