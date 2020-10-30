// TODO :: Gen was on over a couple of days

// TODO :: Ability to edit or delete record

// TODO :: Ability to manually add time

// TODO :: Handle when currentDate is Before Start Date
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum PowerState { No_Light, Nepa, Small_Gen, Big_Gen, Unknown }

enum CalendarView { Monthly, Daily }

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

  if (duration.inMinutes != 0) {
    durationStr += "${duration.inMinutes} Mins";
  }

  if (durationStr.isEmpty) {
    durationStr = "No Data";
  }

  return durationStr;
}

popUntilHomePage(BuildContext context) {
  Navigator.of(context).popUntil(
      ModalRoute.withName(Navigator.defaultRouteName));
}

Widget buildHomeButton(BuildContext context) {
  return IconButton(
      icon: Icon(Icons.home_outlined),
      onPressed: () {
        popUntilHomePage(context);
      });
}
