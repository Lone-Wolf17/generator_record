import 'dart:math';

import 'package:flutter/material.dart';
import 'package:generator_record/db_helper.dart';
import 'package:generator_record/utils.dart';
import 'package:sqflite/sqflite.dart';

class DaysPage extends StatelessWidget {
  Future<List<Map>> _readDB() async {
    // open the database
    Database database = await DbHelper().database;

    // Get the records
    List<Map> daysList = await database.rawQuery(
        'SELECT * FROM ${DbHelper.dailySummaryTable} ORDER BY "${DbHelper.dateCol}" DESC');

    return daysList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Days Record"),
      ),
      body: FutureBuilder<List<Map>>(
        future: _readDB(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isEmpty) {
              return Center(child: Text("No Record Found in Database!!!"),);
            }

            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, i) {
                  Duration duration = Duration(
                      minutes: snapshot.data[i]
                      [DbHelper.durationInMinsCol]);

                  String durationStr = durationInHoursAndMins(duration);

                  String dateStr = snapshot.data[i][DbHelper.dateCol];

                  // So in case there is no value in final shut down column
                  // happens when its the first time the gen is put on for the day
                  // cant think of another placeholder for this scenario right now.
                  // But i don't want it to display null

                  String finalShutdown = snapshot.data[i][DbHelper
                      .finalShutdownCol] == null ? "-- : --" : snapshot
                      .data[i][DbHelper.finalShutdownCol];

                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              SingleDayRecordPage(dateStr: dateStr)));
                    },
                    child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: Text(dateStr,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.primaries[Random()
                                                  .nextInt(
                                                  Colors.primaries.length)]))),
                                  Expanded(
                                      child: Text(
                                        durationStr,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                        "Initial Start: ${snapshot
                                            .data[i][DbHelper
                                            .initialStartCol]}"),
                                  ),
                                  Expanded(
                                    child: Text(
                                        "Final Shutdown: $finalShutdown"),
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
    // open the database
    Database database = await DbHelper().database;

    // Get the records
    List<Map> dateRecords = await database.rawQuery(
        "SELECT * FROM ${DbHelper.mainRecordTable} WHERE ${DbHelper
            .startDateCol} = '$dateStr' ORDER BY '${DbHelper
            .startTimeCol}' ASC");

    return dateRecords;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Date: $dateStr"),
        actions: [
          IconButton(
              icon: Icon(Icons.home_outlined),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              })
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.only(left: 4, top: 0, right: 4, bottom: 4),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Start Time",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "End Time",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Shutdown Date",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Duration",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 4, top: 0, right: 4, bottom: 4),
            child: FutureBuilder(
                future: _readDateRecordsFromDB(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    print(snapshot.data);

                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          String durationStr = "";

                          /* If End Time || End Date || duration Colloum is null
                            It most likely means that gen is still On for that record,
                            Hence no End Time, Date and Duration yet,
                            We therefore we provide a placeholder value, so
                            that null value is not used
                          */

                          if (snapshot.data[index]
                          [DbHelper.durationInMinsCol] ==
                              null) {
                            durationStr = "Still ON";
                          } else {
                            Duration duration = Duration(
                                minutes: snapshot.data[index]
                                [DbHelper.durationInMinsCol]);

                            durationStr = durationInHoursAndMins(duration);
                          }

                          String shutdownDate = "";

                          if (snapshot.data[index][DbHelper.endDateCol] ==
                              null) {
                            shutdownDate = "Still ON";
                          } else if (snapshot.data[index]
                          [DbHelper.startDateCol] ==
                              snapshot.data[index][DbHelper.endDateCol]) {
                            shutdownDate = "Same Day";
                          } else {
                            shutdownDate =
                            snapshot.data[index][DbHelper.endDateCol];
                          }

                          String endTimeStr = snapshot.data[index]
                          [DbHelper.endTimeCol] ==
                              null
                              ? "Still On"
                              : snapshot.data[index][DbHelper.endTimeCol];

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(snapshot.data[index]
                                    [DbHelper.startTimeCol])),
                                Expanded(child: Text(endTimeStr)),
                                Expanded(child: Text(shutdownDate)),
                                Expanded(child: Text(durationStr)),
                              ],
                            ),
                          );
                        });
                  }

                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

