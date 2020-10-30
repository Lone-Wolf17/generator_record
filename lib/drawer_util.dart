import 'package:flutter/material.dart';
import 'package:generator_record/months_page.dart';
import 'package:generator_record/records_page.dart';
import 'package:generator_record/utils.dart';

import 'days_page.dart';

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
          ListTile(
            title: Text('By Day'),
            trailing: Icon(
              Icons.date_range,
              color: Theme.of(context).primaryColor,
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      RecordsPage(calendarView: CalendarView.Daily)));
            },
          ),
          Divider(height: 3),
          ListTile(
            title: Text('By Month'),
            trailing: Icon(
              Icons.show_chart,
              color: Theme.of(context).primaryColor,
            ),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) =>
                  RecordsPage(calendarView: CalendarView.Monthly)));
            },
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
