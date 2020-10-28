import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_slider/flutter_circular_slider.dart';
import 'package:generator_record/db_helper.dart';
import 'package:generator_record/drawer_util.dart';
import 'package:generator_record/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SharedPreferences prefs;
  String genState = "gen_state";
  String powerState = "power_state";
  String firstDate = "firstDate";
  bool isGenOn = false;
  Database database;

  PowerState currentPowerState = PowerState.Unknown;

  Map<PowerState, String> powerStateMap = {
    PowerState.No_Light: "No Light in the Factory",
    PowerState.Nepa: "This is Nepa Light",
    PowerState.Small_Gen: "Small Gen is currently ON",
    PowerState.Big_Gen: "Big Gen is Currently ON"
  };

  Map<PowerState, String> powerSourceMap = {
    PowerState.No_Light: "No Light",
    PowerState.Nepa: "Nepa",
    PowerState.Small_Gen: "Small Gen",
    PowerState.Big_Gen: "Big Gen"
  };

  Map<PowerState, int> sliderStartMap = {
    PowerState.Unknown: 50,
    // The two handlers at 50 helps keeps them at No Light while loading last state
    PowerState.No_Light: 38,
    PowerState.Nepa: 88,
    PowerState.Small_Gen: 13,
    PowerState.Big_Gen: 63
  };

  Map<PowerState, int> sliderEndMap = {
    PowerState.Unknown: 50,
    // The two handlers at 50 helps keeps them at No Light while loading last state
    PowerState.No_Light: 63,
    PowerState.Nepa: 13,
    PowerState.Small_Gen: 38,
    PowerState.Big_Gen: 88,
  };

  String heading = "Loading... Please wait"; // initial value on start up
  ValueKey<PowerState> forceRebuild = ValueKey(PowerState.Unknown);

  _togglePowerState() async {
    bool prevState = prefs.getBool(genState);
    print("Previous gen State: ${prefs.getBool(genState)}");
    prefs.setBool(genState, !prevState);
    print("New gen State: ${prefs.getBool(genState)}");
  }

  @override
  void initState() {
    // TODO: implement initState
    _setUpPersistence();
    super.initState();
  }

  _setUpPersistence() async {
    prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(powerState)) {
      prefs.setBool(genState, false);
      prefs.setString(
          powerState, EnumToString.convertToString(PowerState.No_Light));
    } else {
      isGenOn = prefs.getBool(genState);
      PowerState savedPowerState = EnumToString.fromString<PowerState>(
          PowerState.values, prefs.getString(powerState));
      currentPowerState = savedPowerState;
      forceRebuild = ValueKey(savedPowerState);
      heading = powerStateMap[currentPowerState];
    }

    if (!prefs.containsKey(firstDate)) {
      // if this is the first run of app
      prefs.setString(firstDate, DateTime.now().toIso8601String());
    }

    // open the database
    database = await DbHelper().database;
  }

  void _panHandler(DragUpdateDetails dragDetails) {
    double radius = 150;

    // Pan Location on the wheel
    bool onTop = dragDetails.localPosition.dy <= radius;
    bool onLeftSide = dragDetails.localPosition.dx <= radius;
    bool onRightSide = !onLeftSide;
    bool onBottom = !onTop;

    // Pan movements
    bool panUp = dragDetails.delta.dy <= 0.0;
    bool panLeft = dragDetails.delta.dx <= 0.0;
    bool panRight = !panLeft;
    bool panDown = !panUp;

    // Absolute change on axis
    double yChange = dragDetails.delta.dy.abs();
    double xChange = dragDetails.delta.dx.abs();

    // Directional change on wheel
    double verticalRotation = (onRightSide && panDown) || (onLeftSide && panUp)
        ? yChange
        : (yChange * -1);

    double horizontalRotation =
        (onTop && panRight) || (onBottom && panLeft) ? xChange : (xChange * -1);

    // Total computed change
    double rotationalChange = (verticalRotation + horizontalRotation) *
        (dragDetails.delta.distance * 0.2);

    // Move the page view scroller
    // _pageCtrl.jumpTo(_pageCtrl.offset + rotationalChange);
  }

  showMyDialog(BuildContext context, PowerState newState) {
    String message = powerStateMap[newState];

    if (newState == PowerState.No_Light) {
      if (currentPowerState == PowerState.Nepa) {
        message = "Nepa has taken Light ?";
      } else {
        message = "Switch Off ${powerSourceMap[currentPowerState]} ?";
      }
    } else if (newState == PowerState.Nepa) {
      message = "Nepa Has brought Light?";
    } else {
      message = "Switch On ${powerSourceMap[newState]}";
    }

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    message,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                              child: Text(
                                "No",
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                              child: Text(
                                "Yes",
                                style: TextStyle(color: Colors.green),
                              ),
                              onPressed: () {
                                _setPowerState(newState);
                                Navigator.pop(context);
                              }),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  _setPowerState(PowerState newState) {
    setState(() {
      heading = powerStateMap[newState];
      currentPowerState = newState;
      forceRebuild = ValueKey(newState);
    });
    PowerState prevState =
        EnumToString.fromString(PowerState.values, prefs.getString(powerState));
    print("Previous gen State: ${powerStateMap[prevState]}");
    prefs.setString(powerState, EnumToString.convertToString(newState));
    print("New gen State: ${powerStateMap[newState]}");
  }

  _startGen() async {
    _togglePowerState();
    // Insert some records in a transaction
    await database.transaction((txn) async {
      DateTime currentDateTime = DateTime.now();
      String startDate = formatIntoDateString(currentDateTime);

      String startTime = formatIntoTimeString(currentDateTime);

      prefs.setString(
          "startTime", currentDateTime.toIso8601String().toString());
      int id1 = await txn
          .rawInsert('INSERT INTO ${DbHelper.mainRecordTable} '
          '(${DbHelper.startDateCol}, ${DbHelper.startTimeCol}, ${DbHelper
          .startDateTimeCol}) '
          'VALUES("$startDate", "$startTime", "${currentDateTime
          .toIso8601String()}")')
          .then((value) {
        setState(() {
          isGenOn = true;
        });
        return value;
      });
      print('inserted1: $id1');

      // Get the records
      List<Map> list = await txn.rawQuery(
          "SELECT * FROM ${DbHelper.dailySummaryTable} WHERE ${DbHelper
              .dateCol} = '$startDate' ");

      if (list.isEmpty) {
        DateTime currentDate = DateTime(
            currentDateTime.year, currentDateTime.month, currentDateTime.day);

        txn.rawInsert(
            "INSERT INTO ${DbHelper.dailySummaryTable} ("
                "${DbHelper.dateCol},"
                " ${DbHelper.initialStartCol},"
                " ${DbHelper.dateTimeCol}"
                ") VALUES(?, ?, ?)",
            ['$startDate', '$startTime', '${currentDate.toIso8601String()}']);
      }
    });
  }

  _stopGen() async {
    _togglePowerState();
    // Insert some records in a transaction

    await database.transaction((txn) async {
      DateTime currentDateTime = DateTime.now();
      String endDate = formatIntoDateString(currentDateTime);

      String endTime = formatIntoTimeString(currentDateTime);

      String startTimeStr = prefs.getString("startTime");

      print("StartTime: $startTimeStr");

      DateTime startTime = DateTime.parse(startTimeStr);

      Duration currentDuration = currentDateTime.difference(startTime);

      String startDateStr = formatIntoDateString(startTime);
      List<Map> list = await txn.rawQuery(
          "SELECT ${DbHelper.durationInMinsCol} FROM ${DbHelper
              .dailySummaryTable} WHERE ${DbHelper
              .dateCol} = '$startDateStr' ");
      int oldDurationInMins = 0;
      if (list.length == 1) {
        oldDurationInMins = list.first[DbHelper.durationInMinsCol];
      } else if (list.length == 0) {
        print(
            "ERROR: About to switch-off gen and Daily Record table has no record for present day");
      } else {
        print(
            "ERROR: About to switch-off gen and Daily Record table has more than one record for present day");
      }

      if (currentDateTime.day == startTime.day &&
          currentDateTime.month == startTime.month &&
          currentDateTime.year == startTime.year) {
        // gen was shutdown the same day it was switched on
        await txn.rawUpdate(
            'UPDATE ${DbHelper.dailySummaryTable} SET  ${DbHelper
                .finalShutdownCol} = ?, ${DbHelper
                .durationInMinsCol} = ? WHERE ${DbHelper.dateCol} = ?',
            [
              '$endTime',
              oldDurationInMins + currentDuration.inMinutes,
              endDate
            ] // Since same date, endDate is equal to start date
        );
      } else {
        // Gen may have been switch on over the night.
        // record that gen was on till 12 midnight the previous day
        // then record that gen on from midnight the present day

        //to get the duration for previous day subtract the startTime in Minutes frm 1440
        // where 1440 is the total number of mins in a day (24*60)

        int prevDayDurationInMins =
        (1440 - (startTime.hour * 60) + (startTime.minute));

        int id1 = await txn.rawUpdate(
            'UPDATE ${DbHelper.dailySummaryTable} SET ${DbHelper
                .finalShutdownCol} = ?, ${DbHelper
                .durationInMinsCol} = ? WHERE ${DbHelper.dateCol} = ?',
            [
              '23:59',
              oldDurationInMins + prevDayDurationInMins,
              '$startDateStr'
            ]);

        DateTime newStartDate = startTime.add(Duration(days: 1));

        newStartDate =
            DateTime(newStartDate.year, newStartDate.month, newStartDate.day);

        while (currentDateTime.day - newStartDate.day != 0 &&
            currentDateTime.month == newStartDate.month &&
            currentDateTime.year == newStartDate.year) {
          String newStartDateSTr = formatIntoDateString(newStartDate);

          // check if a row exist for newDate in Daily Records Table
          // A row ideally shouldn't exist but we can never be too careful

          String queryStr =
              "SELECT ${DbHelper.dateCol} FROM ${DbHelper
              .dailySummaryTable} WHERE $DbHelper.DATE_COLUMN ='$newStartDateSTr'";

          var result = await txn.rawQuery(queryStr);

          if (result.isEmpty) {
            txn.rawInsert(
                'INSERT INTO ${DbHelper.dailySummaryTable} ( '
                    ' ${DbHelper.dateCol},'
                    ' ${DbHelper.initialStartCol},'
                    ' ${DbHelper.finalShutdownCol},'
                    ' ${DbHelper.durationInMinsCol}'
                    ' ${DbHelper.dateTimeCol}'
                    ') VALUES(?, ?, ?, ?, ?)',
                [
                  '$newStartDateSTr',
                  '00:00',
                  '23:59',
                  1440,
                  newStartDate.toIso8601String()
                ]);
          }

          /*
          We are not inserting a new row in the main table for each day because it doesn't follow how it was done in reality.
          For example, when the gen is left overnight, it isnt seen as it is switched off by 23:59 today and switched on by 00:00 the next day
          The average person just understands it as the gen was switched on by 10 pm and switched off by 6am the next day
          */

          newStartDate = newStartDate.add(Duration(days: 1));
          newStartDate =
              DateTime(newStartDate.year, newStartDate.month, newStartDate.day);
        }

        // Now record that the gen was on from 12 midnight for present day

        // Current date is midnight the current day
        DateTime currentDate = DateTime(
            currentDateTime.year, currentDateTime.month, currentDateTime.day);
        Duration durationFromMidnight = currentDateTime.difference(currentDate);

        txn.rawInsert(
            'INSERT INTO ${DbHelper.dailySummaryTable} ( '
                '${DbHelper.dateCol},'
                ' ${DbHelper.initialStartCol},'
                ' ${DbHelper.finalShutdownCol},'
                ' ${DbHelper.durationInMinsCol}'
                ' ${DbHelper.dateTimeCol}'
                ') VALUES(?, ?, ?, ?, ?)',
            [
              '$endDate',
              '00:00',
              '$endTime',
              (durationFromMidnight),
              currentDate.toIso8601String()
            ]);
      }

      print("Duration in minutes: ${currentDuration.inMinutes}");
      print("Duration in hours: ${currentDuration.inHours}");

      int id1 = await txn.rawUpdate(
          'UPDATE ${DbHelper.mainRecordTable} SET ${DbHelper
              .endDateCol} = ?, ${DbHelper.endTimeCol} = ?, ${DbHelper
              .endDateTimeCol} = ?, ${DbHelper
              .durationInMinsCol} = ? WHERE ${DbHelper.startDateTimeCol} = ?',
          [
            '$endDate',
            '$endTime',
            "${currentDateTime.toIso8601String()}",
            currentDuration.inMinutes,
            '$startTimeStr'
          ]).then((value) {
        setState(() {
          isGenOn = false;
        });
        return value;
      });

      print('Updated: $id1');
    });
  }

  _buildOldUI(BuildContext context) {
    String txt = isGenOn ? "Gen is Currently On" : "Gen is Currently Off";
    Color txtColor = isGenOn ? Colors.green : Colors.red;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Center(
          child: Text(
            txt,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: txtColor, fontSize: 25),
          ),
        ),
        Center(
            child: RaisedButton(
                padding: EdgeInsets.all(15),
                shape: StadiumBorder(),
                onPressed: !isGenOn ? _startGen : _stopGen,
                color: !isGenOn ? Colors.green : Colors.red,
                disabledTextColor: Colors.green,
                child: Text(
                  !isGenOn ? 'Switch On' : 'Switch Off',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ))),
      ],
    );
  }

  _buildNewUI(BuildContext context) {
    Color txtColor;

    if (currentPowerState == PowerState.Unknown) {
      txtColor = Colors.grey;
    } else {
      txtColor =
      currentPowerState == PowerState.No_Light ? Colors.red : Colors.green;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          heading,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: txtColor, fontSize: 25),
        ),
        Container(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  key: forceRebuild,
                  child: DoubleCircularSlider(
                    100,
                    sliderStartMap[currentPowerState],
                    sliderEndMap[currentPowerState],
                    height: 300,
                    width: 300,
                    baseColor: Colors.grey,
                    selectionColor: txtColor,
                    primarySectors: 4,
                  ),
                ),
                GestureDetector(
                  onPanUpdate: _panHandler,
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.topCenter,
                          margin: const EdgeInsets.only(top: 36),
                          child: InkWell(
                            onTap: currentPowerState == PowerState.Nepa
                                ? () {}
                                : () {
                              showMyDialog(context, PowerState.Nepa);
                            },
                            child: Text("NEPA",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: currentPowerState != PowerState.Nepa
                                        ? Colors.grey
                                        : Colors.green)),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(right: 30),
                          child: InkWell(
                            onTap: currentPowerState == PowerState.Small_Gen
                                ? () {}
                                : () {
                              showMyDialog(context, PowerState.Small_Gen);
                            },
                            child: Text("S Gen",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: currentPowerState !=
                                        PowerState.Small_Gen
                                        ? Colors.grey
                                        : Colors.green)),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(left: 30),
                          child: InkWell(
                            onTap: currentPowerState == PowerState.Big_Gen
                                ? () {}
                                : () {
                              showMyDialog(context, PowerState.Big_Gen);
                            },
                            child: Text("B Gen",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: currentPowerState !=
                                        PowerState.Big_Gen
                                        ? Colors.grey
                                        : Colors.green)),
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          margin: const EdgeInsets.only(bottom: 30),
                          child: InkWell(
                            onTap: currentPowerState == PowerState.No_Light
                                ? () {}
                                : () {
                              showMyDialog(context, PowerState.No_Light);
                            },
                            child: Text("NO LIGHT",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: currentPowerState !=
                                        PowerState.No_Light
                                        ? Colors.grey
                                        : Colors.red)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Big Gen Records"),
      ),
      body: _buildNewUI(context),
      drawer: DrawerUtil(),
    );
  }
}
