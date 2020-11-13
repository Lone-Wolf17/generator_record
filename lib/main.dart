import 'package:flutter/material.dart';
import 'package:generator_record/views/home_page.dart';
import 'package:provider/provider.dart';

import 'models/records_filter.dart';

void main() {
  runApp(ChangeNotifierProvider<RecordsFilter>(
      create: (context) => RecordsFilter(), child: MyApp()));
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
