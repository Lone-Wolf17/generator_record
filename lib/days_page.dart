import 'dart:math';

import 'package:flutter/material.dart';
import 'package:generator_record/db_helper.dart';
import 'package:generator_record/utils.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DaysPage extends StatelessWidget {
  Future<List<Map>> _readDB() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, DbHelper.DB_NAME);

    // open the database
    Database database = await openDatabase(path);

    // Get the records
    List<Map> daysList = await database.rawQuery(
        'SELECT * FROM ${DbHelper.DAILY_RECORDS_TABLE} ORDER BY "${DbHelper.DATE_COLUMN}" DESC');

    return daysList;
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
                  Duration duration = Duration(
                      minutes: snapshot.data[i]
                      [DbHelper.DURATION_IN_MINS_COLUMN]);

                  String durationStr = durationInHoursAndMins(duration);

                  String dateStr = snapshot.data[i][DbHelper.DATE_COLUMN];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) =>
                              SingleDayRecordPage(dateStr: dateStr))
                      );
                    },
                    child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                          dateStr,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.primaries[Random()
                                                  .nextInt(
                                                  Colors.primaries.length)]))),
                                  Expanded(child: Text(durationStr,
                                    style: TextStyle(fontSize: 15,
                                        fontWeight: FontWeight.bold),)),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                        "Initial Start: ${snapshot
                                            .data[i][DbHelper
                                            .INITIAL_START_COLUMN]}"),
                                  ),
                                  Expanded(
                                    child: Text(
                                        "Final Shutdown: ${snapshot
                                            .data[i][DbHelper
                                            .FINAL_SHUTDOWN_COLUMN]}"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                  );
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

class SingleDayRecordPage extends StatelessWidget {

  final String dateStr;

  SingleDayRecordPage({@required this.dateStr});

  Future<List<Map>> _readDateRecordsFromDB() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, DbHelper.DB_NAME);

    // open the database
    Database database = await openDatabase(path);

    // Get the records
    List<Map> dateRecords = await database
        .rawQuery("SELECT * FROM ${DbHelper.MAIN_RECORD_TABLE} WHERE ${DbHelper
        .START_DATE_COLUMN} = '$dateStr' ORDER BY '${DbHelper
        .START_TIME_COLUMN}' ASC");

    return dateRecords;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Date: $dateStr"),),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.only(left: 4, top: 0, right: 4, bottom: 4),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                Expanded(child: Text("Start Time",
                  style: TextStyle(fontWeight: FontWeight.bold),),),
                Expanded(child: Text(
                  "End Time", style: TextStyle(fontWeight: FontWeight.bold),),),
                Expanded(child: Text("Shutdown Date",
                  style: TextStyle(fontWeight: FontWeight.bold),),),
                Expanded(child: Text(
                  "Duration", style: TextStyle(fontWeight: FontWeight.bold),),),
              ],),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 4, top: 0, right: 4, bottom: 4),
            child: FutureBuilder(
                future: _readDateRecordsFromDB(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          Duration duration = Duration(
                              minutes: snapshot.data[index]
                              [DbHelper.DURATION_IN_MINS_COLUMN]);

                          String durationStr = durationInHoursAndMins(duration);

                          String shutdownDate = "";
                          if (snapshot.data[index][DbHelper
                              .START_DATE_COLUMN] ==
                              snapshot.data[index][DbHelper.END_DATE_COLUMN]) {
                            shutdownDate = "Same Day";
                          } else {
                            shutdownDate =
                            snapshot.data[index][DbHelper.END_DATE_COLUMN];
                          }

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(children: [
                              Expanded(child: Text(snapshot.data[index][DbHelper
                                  .START_TIME_COLUMN])),
                              Expanded(child: Text(snapshot.data[index][DbHelper
                                  .END_TIME_COLUMN])),
                              Expanded(child: Text(shutdownDate)),
                              Expanded(child: Text(durationStr)),
                            ],),
                          );
                        });
                  }

                  return Center(child: CircularProgressIndicator(),);
                }),
          ),
        ],
      ),
    );
  }
}

