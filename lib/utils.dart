// TODO :: Gen was on over a couple of days

// TODO :: Ability to edit or delete record

// TODO :: Ability to manually add time

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    durationStr += "${duration.inHours} Hrs $remainingMins Mins";
  } else {
    durationStr += "${duration.inMinutes} Mins";
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
