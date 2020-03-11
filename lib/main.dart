import 'package:flutter/material.dart';
import 'package:weather_demo/HourlyForecast.dart';
import 'package:weather_demo/widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final List<HourlyForecast> list = [
    HourlyForecast(tmp:9,isDay: true, time:"2016-12-30 10:00"),
    HourlyForecast(tmp:11,isDay: true, time:"2016-12-30 13:00"),
    HourlyForecast(tmp:7,isDay: true, time:"2016-12-30 16:00"),
    HourlyForecast(tmp:5,isDay: false, time:"2016-12-30 19:00"),
    HourlyForecast(tmp:3,isDay: false, time:"2016-12-30 22:00"),
    HourlyForecast(tmp:1,isDay: false, time:"2016-12-30 1:00")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Weather(
          padding: EdgeInsets.all(5.0),
          size: Size(400.0, 200.0),
          onTapUp: (a){print(a);},
          imagePath: '',
          hourlyList: list,
        ),
      )
    );
  }
}
