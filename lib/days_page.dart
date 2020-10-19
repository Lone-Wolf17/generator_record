import 'package:flutter/material.dart';
import 'package:generator_record/db_helper.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DaysPage extends StatefulWidget {
  @override
  _DaysPageState createState() => _DaysPageState();
}

class _DaysPageState extends State<DaysPage> {
  Future<List<Map>> _readDB() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, DbHelper.DB_NAME);

// open the database
    Database database = await openDatabase(path);

    // Get the records
    List<Map> daysList = await database
        .rawQuery('SELECT * FROM ${DbHelper.DAILY_RECORDS_TABLE}');

    setState(() {});
    return daysList;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Days Record"),
      ),
      body: FutureBuilder(
        future: _readDB(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, i) {
                  String durationStr = "Total Duration: ";
                  Duration duration = Duration(
                      minutes: snapshot.data[i]
                          [DbHelper.DURATION_IN_MINS_COLUMN]);
                  if (duration.inHours != 0) {
                    int remainingMins =
                        duration.inMinutes - (duration.inHours * 60);
                    durationStr +=
                        "${duration.inHours} Hrs $remainingMins Mins";
                  } else {
                    durationStr += "${duration.inMinutes} Mins";
                  }
                  return Card(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                                    snapshot.data[i][DbHelper.DATE_COLUMN])),
                            Expanded(child: Text(durationStr)),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                  "Initial Start: ${snapshot.data[i][DbHelper.INITIAL_START_COLUMN]}"),
                            ),
                            Expanded(
                              child: Text(
                                  "Final Shutdown: ${snapshot.data[i][DbHelper.FINAL_SHUTDOWN_COLUMN]}"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
                });
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
