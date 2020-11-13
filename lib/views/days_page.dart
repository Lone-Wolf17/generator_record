import 'dart:math';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:generator_record/constants/enums.dart';
import 'package:generator_record/db_helper.dart';
import 'package:generator_record/models/records_filter.dart';
import 'package:generator_record/utils.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class SingleDayRecordPage extends StatelessWidget {
  final String dateStr;

  SingleDayRecordPage({@required this.dateStr});

  Future<List<Map>> _readDateRecordsFromDB(BuildContext context) async {
    // open the database
    Database database = await DbHelper().database;

    print("DateStr: $dateStr");

    String powerSourceWhere = "";

    PowerState powerSource =
        Provider.of<RecordsFilter>(context, listen: false).powerSourceFilter;

    if (powerSource != PowerState.Unknown) {
      String stateStr = EnumToString.convertToString(powerSource);
      powerSourceWhere = " AND ${DbHelper.powerSourceCol} = '$stateStr' ";
    }

    String queryStr =
        "SELECT ${DbHelper.powerSourceCol}, ${DbHelper.durationInMinsCol},"
        " ${DbHelper.startTimeCol}, ${DbHelper.endTimeCol}"
        " FROM ${DbHelper.mainRecordTable} WHERE ${DbHelper.startDateCol} = '$dateStr' $powerSourceWhere ORDER BY ${DbHelper.startDateTimeCol} DESC";

    // Get the records
    List<Map> results = await database.rawQuery(queryStr);

    return results;
  }

  _buildRecordCard(Map powerRecord) {
    String durationStr = "";

    /* If End Time || End Date || duration Cols is null
        It most likely means that gen is still On for that record,
        Hence no End Time, Date and Duration yet,
        We therefore we provide a placeholder value, so
        that null value is not used
    */

    String endTimeStr = "";

    if (powerRecord[DbHelper.endTimeCol] == null) {
      endTimeStr = "Still On";
      durationStr = "Still ON";
    } else {
      endTimeStr = powerRecord[DbHelper.endTimeCol];

      Duration duration =
          Duration(minutes: powerRecord[DbHelper.durationInMinsCol]);

      durationStr = durationInHoursAndMins(duration);
    }

    String source = powerRecord[DbHelper.powerSourceCol];

    PowerState rowPowerSource =
        EnumToString.fromString(PowerState.values, source);

    String startTime = powerRecord[DbHelper.startTimeCol];

    return Consumer<RecordsFilter>(builder:
        (BuildContext context, RecordsFilter recordsFilter, Widget child) {
      return Visibility(
        visible: rowPowerSource == recordsFilter.powerSourceFilter ||
            recordsFilter.powerSourceFilter == PowerState.Unknown,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text("Source: $source",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.primaries[Random()
                                    .nextInt(Colors.primaries.length)]))),
                    Expanded(
                        child: Text(
                      durationStr,
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      "Start Time: $startTime",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    )),
                    Expanded(
                        child: Text(
                      "End Time: $endTimeStr",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Date: $dateStr"),
        actions: [buildHomeButton(context)],
      ),
      body: Column(
        children: [
          buildPowerSourceFilterChips(),
          Expanded(
            child: Container(
              margin:
                  const EdgeInsets.only(left: 4, top: 0, right: 4, bottom: 4),
              child: Consumer<RecordsFilter>(
                builder: (BuildContext context, RecordsFilter recordsFilter,
                    Widget child) {
                  return FutureBuilder<List<Map>>(
                      future: _readDateRecordsFromDB(context),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Set<PowerState> availableState = Set<PowerState>();

                          snapshot.data.forEach((element) {
                            PowerState rowPowerSource = EnumToString.fromString(
                                PowerState.values,
                                element[DbHelper.powerSourceCol]);
                            availableState.add(rowPowerSource);
                          });

                          if (!availableState
                                  .contains(recordsFilter.powerSourceFilter) &&
                              recordsFilter.powerSourceFilter !=
                                  PowerState.Unknown) {
                            return Center(
                              child: Text(
                                  "No Records found in Database for this Power Source !!"),
                            );
                          }

                          return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                Map powerRecord = snapshot.data[index];

                                return _buildRecordCard(powerRecord);
                              });
                        }

                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
