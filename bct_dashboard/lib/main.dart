import 'package:flutter/material.dart';
import './UI/MetricsAtLocations_UI.dart';
import './ServiceLocator/service_locator.dart';
import 'RouterSettings/router.dart' as router;
import 'RouterSettings/routerConstants.dart';

void main() {
  setupServiceLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: HomeViewRoute,
      onGenerateRoute: router.generateRoute,
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              //FIXME: Implement routing with a proper routing module set-up
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MetricsAtLocationsUI()));
              },
              child: Text("Metrics At Locations Tab"),
            )
          ],
        ),
      ),
    );
  }
}
