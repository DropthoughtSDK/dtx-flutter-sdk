import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../GraphQLClient/graphQlClient.dart';
import 'package:graphql/client.dart';
import '../Queries/MetricsAtLocations_Queries.dart';
import '../UI/Low/Logger.dart';
import 'package:logger/logger.dart';

class MetricsAtLocationsViewModel extends ChangeNotifier {
  MetricsAtLocationsViewModel();
  static int id = 4012555;
  List<String> initLabelData = [];
  List<String> initNameData = [];
  List<int> initDayData = [];
  String preloadLabel;
  String preloadName;
  int preloadDay;
  List<DropdownMenuItem> names = [];
  List<DropdownMenuItem> labels = [];
  List<DropdownMenuItem> days = [];
  List<FlSpot> hourlyData = [];
  List<double> pieData = [];
  List<String> pieDataTitles = [];
  List<Color> gradientColors = [
    Colors.red,
    Colors.orange,
  ];

  GraphQLClient _client = ConfigTest.initailizeClient();
  QueryResult result, filteredResults, pieResults;
  String mainQuery;
  String pieChartQuery;
  QueryResult get returnData => result;
  Logger log = ReturnLogger.returnLogger();

  void getData() async {
    initDayData = [];
    initLabelData = [];
    initNameData = [];
    names = [];
    labels = [];
    days = [];
    pieData = [];
    pieDataTitles = [];

    result = await _client.query(QueryOptions(
        documentNode: gql(MetricsAtLocationsQueries.initLabelQuery),
        variables: {}));

    cleanInitData(result.data['distinctLabelsQuery']);
    addLabels(initLabelData);

    preloadLabel = initLabelData.last;

    result = await _client.query(QueryOptions(
        documentNode: gql(MetricsAtLocationsQueries.initNameQuery),
        variables: {}));

    cleanInitData(result.data['distinctNamesQuery']);

    addNames(initNameData);
    preloadName = initNameData.last;

    result = await _client.query(QueryOptions(
        documentNode: gql(MetricsAtLocationsQueries.initDayQuery),
        variables: {}));

    cleanInitData(result.data['distinctDaysQuery']);

    addDays(initDayData);
    preloadDay = initDayData.last;

    mainQuery = MetricsAtLocationsQueries.returnMainQuery(
        preloadDay, preloadName, preloadLabel);

    result = await _client.query(QueryOptions(
        documentNode: gql(mainQuery),
        variables: {
          'day': preloadDay,
          'name': preloadName,
          'label': preloadLabel
        }));

    cleanData(result.data['metrics']);

    pieChartQuery = MetricsAtLocationsQueries.returnPieChartQuery(
        preloadDay, preloadName, preloadLabel);

    result = await _client.query(QueryOptions(
        documentNode: gql(pieChartQuery),
        variables: {
          'day': preloadDay,
          'name': preloadName,
          'label': preloadLabel
        }));

    cleanPieChartData(result.data['getPieChartData']);
    log.i(
        "Initial Data for linechart and piechart is fetched, cleaned and passed to the UI");
    notifyListeners();
  }

  void cleanInitData(List data) {
    if ('distinctLabel' == data[0].keys.toList()[0] &&
        initLabelData.length == 0) {
      data.forEach((element) {
        initLabelData.add(element['distinctLabel']);
      });
    } else if ('distinctDay' == data[0].keys.toList()[0] &&
        initDayData.length == 0) {
      data.forEach((element) {
        initDayData.add(element['distinctDay']);
      });
    } else if ('distinctName' == data[0].keys.toList()[0] &&
        initNameData.length == 0) {
      data.forEach((element) {
        initNameData.add(element['distinctName']);
      });
    }
  }

  void addNames(List initData) {
    initData.forEach((element) {
      names.add(DropdownMenuItem(child: Text(element), value: element));
    });
  }

  void addLabels(List initData) {
    initData.forEach((element) {
      labels.add(DropdownMenuItem(child: Text(element), value: element));
    });
  }

  void addDays(List initData) {
    initData.forEach((element) {
      days.add(DropdownMenuItem(
          child: Text(element.toString()), value: element.toString()));
    });
  }

  void cleanData(List data) {
    hourlyData = [];
    data.forEach((element) {
      hourlyData.add(FlSpot(element['hour'] * 1.0,
          num.parse(element['avgScore'].toStringAsFixed(2))));
    });
  }

  void cleanPieChartData(List data) {
    pieDataTitles = [];
    pieData = [];

    data.forEach((element) {
      pieDataTitles.add(element['labelName']);
      pieData.add(element['labelPercent'] * 1.0);
    });
  }

  void getFilteredData(String day, String name, String label) async {
    String filteredDataQuery =
        MetricsAtLocationsQueries.returnMainQuery(int.parse(day), name, label);
    filteredResults = await _client.query(QueryOptions(
        documentNode: gql(filteredDataQuery),
        variables: {'day': day, 'name': name, 'label': label}));

    cleanData(filteredResults.data['metrics']);

    log.i(
        "OnSubmit data has been fetched, cleaned and sent back to repopulate the LineChart View in UI");
    notifyListeners();
  }

  void getFilteredPieData(String day, String name, String label) async {
    String filteredPieDataQuery = MetricsAtLocationsQueries.returnPieChartQuery(
        int.parse(day), name, label);

    pieResults = await _client.query(QueryOptions(
        documentNode: gql(filteredPieDataQuery),
        variables: {'day': day, 'name': name, 'label': label}));

    cleanPieChartData(pieResults.data['getPieChartData']);

    log.i(
        "OnSubmit data has been fetched, cleaned and sent back to repopulate the PieChart View in UI");
    notifyListeners();
  }
}