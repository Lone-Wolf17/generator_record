// TODO :: Gen was on over a couple of days

// TODO :: Ability to edit or delete record

// TODO :: Ability to manually add time

import 'package:intl/intl.dart';

String formatIntoDateString(DateTime dateTime) {
  return DateFormat('dd-MMM-yy').format(dateTime);
}

String formatIntoTimeString(DateTime dateTime) {
  return DateFormat('kk:mm').format(dateTime);
}
