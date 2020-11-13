import 'dart:collection';
import 'dart:math';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:generator_record/constants/enums.dart';
import 'package:generator_record/db_helper.dart';
import 'package:generator_record/models/records_filter.dart';
import 'package:generator_record/utils.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'days_page.dart';

class RecordsPage extends StatelessWidget {
  final String whereParams; // This is optional

  RecordsPage({this.whereParams});

  Future<List<Map>> _readDB(BuildContext context) async {
    // open the database
    Database database = await DbHelper().database;

    String whereClause = "";

    print("DB Called!!!!!");

    PowerState powerSourceFilter =
        Provider.of<RecordsFilter>(context, listen: false).powerSourceFilter;

    if (powerSourceFilter != PowerState.Unknown || whereParams != null) {
      whereClause = "WHERE ";

      if (powerSourceFilter != PowerState.Unknown) {
        String stateStr = EnumToString.convertToString(powerSourceFilter);
        whereClause += " ${DbHelper.powerSourceCol} = '$stateStr' ";
      }

      if (powerSourceFilter != PowerState.Unknown && whereParams != null) {
        whereClause += " AND ";
      }

      // add where clause only if where Params is available
      if (whereParams != null) {
        List split = whereParams.split('-20');
        String querableStr = split[0] + "-" + split[1];
        whereClause += " ${DbHelper.startDateCol} LIKE '%$querableStr'";
      }
    }

    String queryStr =
        "SELECT ${DbHelper.startDateCol}, ${DbHelper.powerSourceCol},"
        " SUM(${DbHelper.durationInMinsCol}) ${DbHelper.durationInMinsCol} "
        " FROM ${DbHelper.mainRecordTable}"
        " $whereClause"
        " GROUP BY ${DbHelper.startDateCol}, ${DbHelper.powerSourceCol}"
        " ORDER BY ${DbHelper.startDateTimeCol} DESC";

    // Get the records
    List<Map> results = await database.rawQuery(queryStr);

    return results;
  }

  _buildSummaryCard(String dateOrMonth, Map<PowerState, int> durationMap) {
    return Consumer<RecordsFilter>(
      builder:
          (BuildContext context, RecordsFilter recordsFilter, Widget child) {
        return InkWell(
          onTap: () {
            if (recordsFilter.calendarTypeFilter == CalendarView.Monthly) {
              print("Power Source: ${recordsFilter.powerSourceFilter}");
              print("dateOrMonth: $dateOrMonth");

              Provider.of<RecordsFilter>(context, listen: false)
                  .changeCalenderTypeFilter(CalendarView.Daily);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RecordsPage(
                        whereParams: dateOrMonth,
                      )));
            } else if (recordsFilter.calendarTypeFilter == CalendarView.Daily) {
              if (whereParams != null) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => SingleDayRecordPage(
                          dateStr: dateOrMonth,
                        )));
              } else {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => SingleDayRecordPage(
                          dateStr: dateOrMonth,
                        )));
              }
            }
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
                  Visibility(
                    visible: recordsFilter.powerSourceFilter ==
                            PowerState.Nepa ||
                        recordsFilter.powerSourceFilter == PowerState.Unknown,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${powerSourceMap[PowerState.Nepa]}: ",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "${durationInHoursAndMins(Duration(minutes: durationMap[PowerState.Nepa]))}",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: recordsFilter.powerSourceFilter ==
                            PowerState.Small_Gen ||
                        recordsFilter.powerSourceFilter == PowerState.Unknown,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${powerSourceMap[PowerState.Small_Gen]}: ",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "${durationInHoursAndMins(Duration(minutes: durationMap[PowerState.Small_Gen]))}",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: recordsFilter.powerSourceFilter ==
                            PowerState.Big_Gen ||
                        recordsFilter.powerSourceFilter == PowerState.Unknown,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${powerSourceMap[PowerState.Big_Gen]}: ",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "${durationInHoursAndMins(Duration(minutes: durationMap[PowerState.Big_Gen]))}",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Records Page'),
        actions: [buildHomeButton(context)],
      ),
      body: Column(
        children: [
          // Card for Power Source Selection
          buildPowerSourceFilterChips(),

          // Card for Calendar View Selection
          Consumer<RecordsFilter>(
            builder: (BuildContext context, RecordsFilter calenderType,
                Widget child) {
              return Visibility(
                visible: whereParams == null,
                child: Card(
                  margin: const EdgeInsets.all(6),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            calenderType
                                .changeCalenderTypeFilter(CalendarView.Daily);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: calenderType.calendarTypeFilter ==
                                          CalendarView.Daily
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
                            calenderType
                                .changeCalenderTypeFilter(CalendarView.Monthly);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: calenderType.calendarTypeFilter ==
                                        CalendarView.Monthly
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
              );
            },
          ),

          Expanded(
            child: Consumer<RecordsFilter>(
              builder: (BuildContext context, RecordsFilter recordsFilter,
                  Widget child) {
                return FutureBuilder<List<Map>>(
                  future: _readDB(context),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.isEmpty) {
                        return Center(
                          child: Text(
                              "No Records found in Database for this Power Source !!"),
                        );
                      }

                      LinkedHashMap<String, Map<PowerState, int>> filteredData =
                          recordsFilter.filterDBResults(snapshot.data);

                      List<Widget> widgetsList = List();

                      filteredData.forEach((dateOrMonth, durationMap) {
                        widgetsList
                            .add(_buildSummaryCard(dateOrMonth, durationMap));
                      });

                      return ListView(
                        children: widgetsList,
                      );
                    }

                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
