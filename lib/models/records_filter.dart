import 'dart:collection';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:generator_record/constants/enums.dart';

import '../db_helper.dart';

class RecordsFilter extends ChangeNotifier {
  CalendarView _calendarTypeFilter = CalendarView.Daily;
  PowerState _powerSourceFilter = PowerState.Unknown;

  CalendarView get calendarTypeFilter => _calendarTypeFilter;

  PowerState get powerSourceFilter => _powerSourceFilter;

  void changeCalenderTypeFilter(CalendarView calendarView) {
    _calendarTypeFilter = calendarView;

    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void changePowerSourceFilter(PowerState powerSource) {
    _powerSourceFilter = powerSource;

    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  LinkedHashMap<String, Map<PowerState, int>> filterDBResults(
      List<Map> dbResults) {
    LinkedHashMap<String, Map<PowerState, int>> _buildForDays(
        List<Map> snapshot) {
      LinkedHashMap<String, Map<PowerState, int>> map =
          LinkedHashMap<String, LinkedHashMap<PowerState, int>>();

      dbResults.forEach((element) {
        String date = element[DbHelper.startDateCol];
        PowerState powerState = EnumToString.fromString(
            PowerState.values, element[DbHelper.powerSourceCol]);

        if (!map.containsKey(date)) {
          map[date] = {
            PowerState.Nepa: 0,
            PowerState.Big_Gen: 0,
            PowerState.Small_Gen: 0,
          };
        }

        map[date][powerState] = element[DbHelper.durationInMinsCol];
      });

      return map;
    }

    LinkedHashMap<String, Map<PowerState, int>> _buildForMonths(
        List<Map> snapshot) {
      LinkedHashMap<String, Map<PowerState, int>> map =
          LinkedHashMap<String, LinkedHashMap<PowerState, int>>();

      dbResults.forEach((element) {
        String date = element[DbHelper.startDateCol];
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

    LinkedHashMap<String, Map<PowerState, int>> map;

    if (_calendarTypeFilter == CalendarView.Monthly) {
      map = _buildForMonths(dbResults);
    } else if (_calendarTypeFilter == CalendarView.Daily) {
      map = _buildForDays(dbResults);
    }

    return map;
  }
}
