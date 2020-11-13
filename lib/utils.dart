// TODO :: Gen was on over a couple of days

// TODO :: Ability to edit or delete record

// TODO :: Ability to manually add time

// TODO :: Handle when currentDate is Before Start Date
import 'package:flutter/material.dart';
import 'package:generator_record/constants/enums.dart';
import 'package:generator_record/models/records_filter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Map<PowerState, String> powerSourceMap = {
  PowerState.No_Light: "No Light",
  PowerState.Nepa: "Nepa",
  PowerState.Small_Gen: "Small Gen",
  PowerState.Big_Gen: "Big Gen"
};

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}

String formatIntoDateString(DateTime dateTime) {
  return DateFormat('dd-MMM-yy').format(dateTime);
}

String formatIntoTimeString(DateTime dateTime) {
  return DateFormat('kk:mm').format(dateTime);
}

String durationInHoursAndMins(Duration duration) {
  String durationStr = "";

  if (duration.inHours != 0) {
    int remainingMins = duration.inMinutes - (duration.inHours * 60);
    durationStr += "${duration.inHours}"
        " Hrs ";
    duration = Duration(minutes: remainingMins);
  }

  if (duration.inMinutes == 0 && durationStr.isNotEmpty) {
    // Add nothing
  } else if (duration.inMinutes == 0) {
    if (durationStr.isEmpty) {
      durationStr += "${duration.inMinutes} Mins";
    }
  } else {
    durationStr += "${duration.inMinutes} Mins";
  }

  return durationStr;
}

popUntilHomePage(BuildContext context) {
  Navigator.of(context)
      .popUntil(ModalRoute.withName(Navigator.defaultRouteName));
}

Widget buildHomeButton(BuildContext context) {
  return IconButton(
      icon: Icon(Icons.home_outlined),
      onPressed: () {
        popUntilHomePage(context);
      });
}

Widget buildPowerSourceFilterChips() {
  return Card(
    margin: const EdgeInsets.all(6),
    child: Padding(
      padding: const EdgeInsets.all(6),
      child: Consumer<RecordsFilter>(
        builder:
            (BuildContext context, RecordsFilter recordsFilter, Widget child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  recordsFilter.changePowerSourceFilter(PowerState.Unknown);
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: recordsFilter.powerSourceFilter ==
                                PowerState.Unknown
                            ? Colors.green
                            : Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text("All"),
                    )),
              ),
              InkWell(
                onTap: () {
                  recordsFilter.changePowerSourceFilter(PowerState.Nepa);
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: recordsFilter.powerSourceFilter == PowerState.Nepa
                          ? Colors.green
                          : Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text("Nepa"),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  recordsFilter.changePowerSourceFilter(PowerState.Big_Gen);
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: recordsFilter.powerSourceFilter ==
                                PowerState.Big_Gen
                            ? Colors.green
                            : Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text("Big Gen"),
                    )),
              ),
              InkWell(
                onTap: () {
                  recordsFilter.changePowerSourceFilter(PowerState.Small_Gen);
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: recordsFilter.powerSourceFilter ==
                              PowerState.Small_Gen
                          ? Colors.green
                          : Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text("Small Gen"),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
