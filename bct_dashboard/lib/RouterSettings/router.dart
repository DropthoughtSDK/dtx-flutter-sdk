import 'package:flutter/material.dart';
import '../main.dart';
import '../UI/MetricsAtLocations_UI.dart';

import './routerConstants.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case HomeViewRoute:
      return MaterialPageRoute(builder: (context) => MyHomePage());

    case MetricsAtLocationsViewRouter:
      return MaterialPageRoute(builder: (context) => MetricsAtLocationsUI());

    default:
  }
}
