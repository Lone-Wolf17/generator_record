import 'package:flutter/material.dart';
import 'package:generator_record/constants/enums.dart';
import 'package:generator_record/models/records_filter.dart';
import 'package:generator_record/views/records_page.dart';
import 'package:provider/provider.dart';

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
                Provider.of<RecordsFilter>(context, listen: false)
                    .changeCalenderTypeFilter(CalendarView.Daily);

                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => RecordsPage()));
              },
            ),
          ),
          Divider(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ListTile(
              title: Text('Monthly'),
              onTap: () {
                Provider.of<RecordsFilter>(context, listen: false)
                    .changeCalenderTypeFilter(CalendarView.Monthly);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => RecordsPage()));
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
                Provider.of<RecordsFilter>(context, listen: false)
                    .changePowerSourceFilter(PowerState.Small_Gen);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => RecordsPage()));
              },
            ),
          ),
          Divider(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ListTile(
              title: Text('Big Gen'),
              onTap: () {
                Provider.of<RecordsFilter>(context, listen: false)
                    .changePowerSourceFilter(PowerState.Big_Gen);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => RecordsPage()));
              },
            ),
          ),
          Divider(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ListTile(
              title: Text('Nepa'),
              onTap: () {
                Provider.of<RecordsFilter>(context, listen: false)
                    .changePowerSourceFilter(PowerState.Nepa);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => RecordsPage()));
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
