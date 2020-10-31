import 'package:flutter/material.dart';
import 'package:generator_record/records_page.dart';
import 'package:generator_record/utils.dart';

class DrawerUtil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("MyLaundry.NG"),
            accountEmail: Text("exinnowhiteconsults@gmail.com"),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
          Container(
            color: Colors.grey,
            child: ListTile(
                title: Text(
                  "Records By Date",
                ),
                trailing: Icon(
                  Icons.date_range_rounded,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ListTile(
              title: Text('Daily'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        RecordsPage(calendarView: CalendarView.Daily)));
              },
            ),
          ),
          Divider(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ListTile(
              title: Text('Monthly'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        RecordsPage(calendarView: CalendarView.Monthly)));
              },
            ),
          ),
          Divider(height: 3),
          Container(
            color: Colors.grey,
            child: ListTile(
              title: Text(
                "Records By Power Source",
              ),
              trailing: Icon(
                Icons.flash_on_outlined,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ListTile(
              title: Text('Small Gen'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => RecordsPage(
                          powerSource: PowerState.Small_Gen,
                        )));
              },
            ),
          ),
          Divider(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ListTile(
              title: Text('Big Gen'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        RecordsPage(powerSource: PowerState.Big_Gen)));
              },
            ),
          ),
          Divider(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ListTile(
              title: Text('Nepa'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => RecordsPage(
                          powerSource: PowerState.Nepa,
                        )));
              },
            ),
          ),
          Divider(height: 3),
          SizedBox(
            height: 25,
          ),
        ],
      ),
    );
  }
}
