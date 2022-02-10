import 'package:flutter/material.dart';
import 'package:ipm1920_p2/views/MasterDetail.dart';

void main() => runApp(Main());

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ipm-p2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        backgroundColor: Colors.black,
      ),
      home:  MasterDetailContainer(),
    );
  }
}
