import 'dart:collection';
import 'dart:math';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:generator_record/db_helper.dart';
import 'package:generator_record/utils.dart';
import 'package:sqflite/sqflite.dart';

import 'days_page.dart';

class RecordsPage extends StatefulWidget {
  final CalendarView calendarView;

  RecordsPage({@required this.calendarView});

  @override
  _RecordsPageState createState() =>
      _RecordsPageState(calendarView: calendarView);
}

class _RecordsPageState extends State<RecordsPage> {
  Future<List<Map>> _readDB() async {
    // open the database
    Database database = await DbHelper().database;

    // Get the records
    List<Map> daysList = await database.rawQuery(
        "SELECT * FROM ${DbHelper.dailySummaryTable} ORDER BY ${DbHelper.dateTimeCol} DESC");

    return daysList;
  }

  _RecordsPageState({@required this.calendarView});

  PowerState _powerSource;
  CalendarView calendarView;

  LinkedHashMap<String, Map<PowerState, int>> _buildForDays(
      AsyncSnapshot<List<Map>> snapshot) {
    LinkedHashMap<String, Map<PowerState, int>> map =
        LinkedHashMap<String, LinkedHashMap<PowerState, int>>();

    snapshot.data.forEach((element) {
      String date = element[DbHelper.dateCol];
      PowerState powerState = EnumToString.fromString(
          PowerState.values, element[DbHelper.powerSourceCol]);

      if (!map.containsKey(date)) {
        map[date] = {
          PowerState.Nepa: 0,
          PowerState.Big_Gen: 0,
          PowerState.Small_Gen: 0,
        };
      }

      // String powerSource = powerSourceMap[powerState];

      map[date][powerState] = element[DbHelper.durationInMinsCol];
    });

    return map;
  }

  LinkedHashMap<String, Map<PowerState, int>> _buildForMonths(
      AsyncSnapshot<List<Map>> snapshot) {
    LinkedHashMap<String, Map<PowerState, int>> map =
        LinkedHashMap<String, LinkedHashMap<PowerState, int>>();

    snapshot.data.forEach((element) {
      String date = element[DbHelper.dateCol];
      List dateSplit = date.split("-");
      String monthYear = dateSplit[1] + "-20" + dateSplit[2];
      PowerState powerState = EnumToString.fromString(
          PowerState.values, element[DbHelper.powerSourceCol]);

      if (!map.containsKey(monthYear)) {
        map[monthYear] = {
          PowerState.Nepa: 0,
          PowerState.Big_Gen: 0,
          PowerState.Small_Gen: 0,
        };
      }
      int previousDuration = map[monthYear][powerState];

      map[monthYear][powerState] =
          previousDuration + element[DbHelper.durationInMinsCol];
    });

    return map;
  }

  _buildSummaryCard(String dateOrMonth, Map<PowerState, int> durationMap) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DaysPage(
                  whereParams: dateOrMonth,
                )));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateOrMonth,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.primaries[
                          Random().nextInt(Colors.primaries.length)])),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "${powerSourceMap[PowerState.Nepa]}: ",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "${durationInHoursAndMins(Duration(minutes: durationMap[PowerState.Nepa]))}",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "${powerSourceMap[PowerState.Small_Gen]}: ",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "${durationInHoursAndMins(Duration(minutes: durationMap[PowerState.Small_Gen]))}",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "${powerSourceMap[PowerState.Big_Gen]}: ",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "${durationInHoursAndMins(Duration(minutes: durationMap[PowerState.Big_Gen]))}",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Records Page'),
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

            LinkedHashMap<String, Map<PowerState, int>> map;

            if (calendarView == CalendarView.Monthly) {
              map = _buildForMonths(snapshot);
            } else if (calendarView == CalendarView.Daily) {
              map = _buildForDays(snapshot);
            }

            List<Widget> list = List();

            map.forEach((dateOrMonth, durationMap) {
              // Duration duration = Duration(minutes: value);

              list.add(_buildSummaryCard(dateOrMonth, durationMap));
            });

            return Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(6),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              calendarView = CalendarView.Daily;
                            });
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: calendarView == CalendarView.Daily
                                      ? Colors.green
                                      : Colors.grey,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text("Daily"),
                              )),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              calendarView = CalendarView.Monthly;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: calendarView == CalendarView.Monthly
                                    ? Colors.green
                                    : Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text("Monthly"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: list,
                  ),
                ),
              ],
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
