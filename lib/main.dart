import 'package:flutter/material.dart';
import 'package:generator_record/days_page.dart';
import 'package:generator_record/db_helper.dart';
import 'package:generator_record/utils.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String firstDate = "firstDate";
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
      setState(() {
        isGenOn = prefs.getBool(genState);
      });
    }

    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, DbHelper.DB_NAME);

// open the database
    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE ${DbHelper.MAIN_RECORD_TABLE} (${DbHelper.ID_COLUMN} INTEGER PRIMARY KEY, ${DbHelper.START_DATE_COLUMN} TEXT NOT NULL, ${DbHelper.START_TIME_COLUMN} TEXT NOT NULL, ${DbHelper.END_TIME_COLUMN} TEXT, ${DbHelper.END_DATE_COLUMN} TEXT,  ${DbHelper.START_DATE_TIME_COLUMN} TEXT UNIQUE NOT NULL, ${DbHelper.END_DATE_TIME_COLUMN} TEXT UNIQUE, ${DbHelper.DURATION_IN_MINS_COLUMN} INTEGER)');
      await db.execute(
          'CREATE TABLE ${DbHelper.DAILY_RECORDS_TABLE} (${DbHelper.ID_COLUMN} INTEGER PRIMARY KEY, ${DbHelper.DATE_COLUMN} TEXT UNIQUE NOT NULL, ${DbHelper.INITIAL_START_COLUMN} TEXT NOT NULL, ${DbHelper.FINAL_SHUTDOWN_COLUMN} TEXT, ${DbHelper.DURATION_IN_MINS_COLUMN} INTEGER DEFAULT 0)');
      prefs.setString(firstDate, DateTime.now().toUtc().toString());
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
      DateTime currentDateTime = DateTime.now();
      String startDate = formatIntoDateString(currentDateTime);

      String startTime = formatIntoTimeString(currentDateTime);

      prefs.setString("startTime", currentDateTime.toUtc().toString());
      int id1 = await txn
          .rawInsert(
              'INSERT INTO ${DbHelper.MAIN_RECORD_TABLE} (${DbHelper.START_DATE_COLUMN}, ${DbHelper.START_TIME_COLUMN}, ${DbHelper.START_DATE_TIME_COLUMN}) VALUES("$startDate", "$startTime", "${currentDateTime.toUtc()}")')
          .then((value) {
        setState(() {
          isGenOn = true;
        });
        return value;
      });
      print('inserted1: $id1');

      // Get the records
      List<Map> list = await txn.rawQuery(
          "SELECT * FROM ${DbHelper.DAILY_RECORDS_TABLE} WHERE ${DbHelper.DATE_COLUMN} = '$startDate' ");

      if (list.isEmpty) {
        txn.rawInsert(
            "INSERT INTO ${DbHelper.DAILY_RECORDS_TABLE} (${DbHelper.DATE_COLUMN}, ${DbHelper.INITIAL_START_COLUMN}) VALUES(?, ?)",
            ['$startDate', '$startTime']);
      }

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
      DateTime currentDateTime = DateTime.now();
      String endDate = formatIntoDateString(currentDateTime);

      String endTime = formatIntoTimeString(currentDateTime);

      String startTimeStr = prefs.getString("startTime");

      print("StartTime: $startTimeStr");

      DateTime startTime = DateTime.parse(startTimeStr);

      Duration currentDuration = currentDateTime.difference(startTime);

      String startDateStr = formatIntoDateString(startTime);
      List<Map> list = await txn.rawQuery(
          "SELECT ${DbHelper.DURATION_IN_MINS_COLUMN} FROM ${DbHelper
              .DAILY_RECORDS_TABLE} WHERE ${DbHelper
              .DATE_COLUMN} = '$startDateStr' ");
      int oldDurationInMins = 0;
      if (list.length == 1) {
        oldDurationInMins = list.first[DbHelper.DURATION_IN_MINS_COLUMN];
      } else if (list.length == 0) {
        print(
            "ERROR: About to switch-off gen and Daily Record table has no record for present day");
      } else {
        print(
            "ERROR: About to switch-off gen and Daily Record table has more than one record for present day");
      }

      if (currentDateTime.day == startTime.day &&
          currentDateTime.month == startTime.month &&
          currentDateTime.year == startTime.year) {
        int id1 = await txn.rawUpdate(
            'UPDATE ${DbHelper.DAILY_RECORDS_TABLE} SET  ${DbHelper
                .FINAL_SHUTDOWN_COLUMN} = ?, ${DbHelper
                .DURATION_IN_MINS_COLUMN} = ? WHERE ${DbHelper
                .DATE_COLUMN} = ?',
            [
              '$endTime',
              oldDurationInMins + currentDuration.inMinutes,
              endDate
            ] // Since same date, endDate is equal to start date
        );
      } else {
        // Gen may have been switch on over the night.
        // record that gen was on till 12 midnight the previous day
        // then record that gen on from midnight the present day

        //to get the duration for previous day subtract the startTime in Minutes frm 1440
        // where 1440 is the total number of mins in a day (24*60)


        int prevDayDurationInMins =
        (1440 - (startTime.hour * 60) + (startTime.minute));

        int id1 = await txn.rawUpdate(
            'UPDATE ${DbHelper.DAILY_RECORDS_TABLE} SET ${DbHelper
                .FINAL_SHUTDOWN_COLUMN} = ?, ${DbHelper
                .DURATION_IN_MINS_COLUMN} = ? WHERE ${DbHelper
                .DATE_COLUMN} = ?',
            [
              '23:59',
              oldDurationInMins + prevDayDurationInMins,
              '$startDateStr'
            ]);

        DateTime newStartDate = startTime.add(Duration(days: 1));

        newStartDate = DateTime(
            newStartDate.year, newStartDate.month, newStartDate.day, 00, 00);

        while (currentDateTime.day - newStartDate.day != 0 &&
            currentDateTime.month == newStartDate.month &&
            currentDateTime.year == newStartDate.year) {
          String newStartDateSTr = formatIntoDateString(newStartDate);


          // check if a row exist for newDate in Daily Records Table
          // A row ideally shouldn't exist but we can never be too careful

          String queryStr = "SELECT ${DbHelper.DATE_COLUMN} FROM ${DbHelper
              .DAILY_RECORDS_TABLE} WHERE $DbHelper.DATE_COLUMN ='$newStartDateSTr'";

          var result = await txn.rawQuery(queryStr);

          if (result.isEmpty) {
            txn.rawInsert(
                'INSERT INTO ${DbHelper.DAILY_RECORDS_TABLE} ( ${DbHelper
                    .DATE_COLUMN}, ${DbHelper.INITIAL_START_COLUMN}, ${DbHelper
                    .FINAL_SHUTDOWN_COLUMN}, ${DbHelper
                    .DURATION_IN_MINS_COLUMN}) VALUES(?, ?, ?, ?)',
                [
                  '$newStartDateSTr',
                  '00:00',
                  '23:59',
                  1440
                ]);
          }


          newStartDate = newStartDate.add(Duration(days: 1));
          newStartDate = DateTime(
              newStartDate.year, newStartDate.month, newStartDate.day, 00, 00);
        }


        // Now record that the gen was on from 12 midnight for present day

        // Interim date is midnight the current day
        DateTime interimDate = DateTime(
            currentDateTime.year, currentDateTime.month, currentDateTime.day,
            00, 00);
        Duration durationFromMidnight = currentDateTime.difference(interimDate);

        txn.rawInsert(
            'INSERT INTO ${DbHelper.DAILY_RECORDS_TABLE} ( ${DbHelper
                .DATE_COLUMN}, ${DbHelper.INITIAL_START_COLUMN}, ${DbHelper
                .FINAL_SHUTDOWN_COLUMN}, ${DbHelper
                .DURATION_IN_MINS_COLUMN}) VALUES(?, ?, ?, ?)',
            [
              '$endDate',
              '00:00',
              '$endTime',
              (durationFromMidnight)
            ]);
      }

      print("Duration in minutes: ${currentDuration.inMinutes}");
      print("Duration in hours: ${currentDuration.inHours}");

      int id1 = await txn.rawUpdate(
          'UPDATE ${DbHelper.MAIN_RECORD_TABLE} SET ${DbHelper
              .END_DATE_COLUMN} = ?, ${DbHelper.END_TIME_COLUMN} = ?, ${DbHelper
              .END_DATE_TIME_COLUMN} = ?, ${DbHelper
              .DURATION_IN_MINS_COLUMN} = ? WHERE ${DbHelper
              .START_DATE_TIME_COLUMN} = ?',
          [
            '$endDate',
            '$endTime',
            "${currentDateTime.toUtc()}",
            currentDuration.inMinutes,
            '$startTimeStr'
          ]).then((value) {
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
        actions: [
          IconButton(
              icon: Icon(Icons.refresh),
              color: isGenOn ? Colors.green : Colors.red,
              onPressed: () {
                prefs.setBool(genState, false);
                setState(() {
                  isGenOn = false;
                });
              }),
          IconButton(
              icon: Icon(Icons.remove_red_eye),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => DaysPage()));
              })
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: Text("Gen is Currently On"),
          ),
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
                  onPressed: isGenOn ? _stopGen : null,
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
