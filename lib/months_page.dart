import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:generator_record/days_page.dart';
import 'package:generator_record/utils.dart';
import 'package:sqflite/sqflite.dart';

import 'db_helper.dart';

class MonthsPage extends StatelessWidget {
  Future<List<Map>> _readDB() async {
    // open the database
    Database database = await DbHelper().database;

    // Get the records
    List<Map> daysList = await database.rawQuery(
        "SELECT * FROM ${DbHelper.dailySummaryTable} ORDER BY ${DbHelper.dateTimeCol} DESC");

    return daysList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Months Page'),
      ),
      body: FutureBuilder<List<Map>>(
        future: _readDB(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isEmpty) {
              return Center(
                child: Text("No Record Found in Database!!!"),
              );
            }

            LinkedHashMap<String, int> map = LinkedHashMap<String, int>();

            snapshot.data.forEach((element) {
              String date = element[DbHelper.dateCol];
              List dateSplit = date.split("-");
              String monthYear = dateSplit[1] + "-20" + dateSplit[2];

              if (!map.containsKey(monthYear)) {
                map[monthYear] = element[DbHelper.durationInMinsCol];
              } else {
                int previousDuration = map[monthYear];
                map[monthYear] =
                    previousDuration + element[DbHelper.durationInMinsCol];
              }
            });

            List<Widget> list = List();

            map.forEach((monthYear, value) {
              Duration duration = Duration(minutes: value);

              list.add(InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          DaysPage(whereParams: monthYear,)));
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(monthYear,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.primaries[Random()
                                        .nextInt(Colors.primaries.length)]))),
                        Expanded(
                            child: Text(
                              durationInHoursAndMins(duration),
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ))
                      ],
                    ),
                  ),
                ),
              ));
            });

            return ListView(
              children: list,
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
