import 'package:bct_dashboard/GraphQLClient/graphQlClient.dart';
import 'package:bct_dashboard/Queries/NPSDetails_Queries.dart';
import 'package:bct_dashboard/UI/Low/Logger.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';

class NPSDetailsViewModel extends ChangeNotifier {
  GraphQLClient _client = ConfigTest.initailizeClient();
  QueryResult result, filteredResults, pieResults;
  String distinctDayNPS,
      npsMetrics,
      npsMetricsDay,
      npsDistinctScores,
      preloadLabel,
      npsGetPieChartData;

  int preloadDay;
  int npsDayData;
  List<int> initDayData;
  List<DropdownMenuItem> distinctLabel;
  List<FlSpot> hourlyData, hourlyLabelData;
  List<String> pieTitles;
  List<double> pieData;
  List<DropdownMenuItem> days;
  String initNpsMetricsDay, initNpsMetrics, initDistinctLabels;

  Logger log = ReturnLogger.returnLogger();

  void getData() async {
    initDayData = [];
    distinctLabel = [];
    days = [];
    hourlyData = [];
    pieTitles = [];
    pieData = [];

    result = await _client.query(QueryOptions(
        documentNode: gql(NPSDetailsQueries.distinctDayNPS), variables: {}));

    cleanInitData(result.data['distinctDayNPS']);
    addDays(initDayData);

    preloadDay = initDayData.last;

    initNpsMetricsDay = NPSDetailsQueries.returnNpsMetricsDay(preloadDay);

    result = await _client.query(QueryOptions(
        documentNode: gql(initNpsMetricsDay), variables: {'day': preloadDay}));
    cleanData(result.data['npsMetricsDay']);

    initNpsMetrics = NPSDetailsQueries.returnNpsMetrics(preloadDay);

    result = await _client.query(QueryOptions(
        documentNode: gql(initNpsMetrics), variables: {'day': preloadDay}));

    addToHourlyData(result.data['npsMetrics']);

    initDistinctLabels = NPSDetailsQueries.returnNpsDistinctLabelName();

    result = await _client.query(
        QueryOptions(documentNode: gql(initDistinctLabels), variables: {}));

    addToDistinctLabels(result.data['npsDistinctLabelName']);

    preloadLabel = result.data['npsDistinctLabelName'][0]['distinctLabel'];
    npsDistinctScores =
        NPSDetailsQueries.returnNpsDistinctScores(preloadDay, preloadLabel);

    result = await _client.query(QueryOptions(
        documentNode: gql(npsDistinctScores),
        variables: {'day': preloadDay, 'label': preloadLabel}));

    addToDistinctScores(result.data['npsDistinctScores']);

    npsGetPieChartData = NPSDetailsQueries.returnNpsGetPieChartData(preloadDay);
    result = await _client.query(QueryOptions(
        documentNode: gql(npsGetPieChartData), variables: {'day': preloadDay}));

    addToPieChart(result.data['npsGetPieChartData']);

    notifyListeners();
  }

  void cleanInitData(List data) {
    if ('distinctDay' == data[0].keys.toList()[0] && initDayData.length == 0) {
      data.forEach((element) {
        initDayData.add(element['distinctDay']);
      });
    }
  }

  void addDays(List initData) {
    initData.forEach((element) {
      days.add(DropdownMenuItem(
          child: Text(element.toString()), value: element.toString()));
    });
  }

  void cleanData(List data) {
    npsDayData = result.data['npsMetricsDay'][0]['avgScoreDay'];
  }

  void addToHourlyData(List data) {
    hourlyData = [];
    data.forEach((element) {
      hourlyData.add(FlSpot(element['hour'] * 1.0,
          num.parse(element['avgScore'].toStringAsFixed(2))));
    });
  }

  void getNPSMetricsDay(String day) async {
    String filteredQuery =
        NPSDetailsQueries.returnNpsMetricsDay(int.parse(day));
    result = await _client.query(QueryOptions(
        documentNode: gql(filteredQuery), variables: {'day': day}));

    cleanData(result.data['npsMetricsDay']);

    notifyListeners();
  }

  void getNPSMetrics(String day) async {
    String filteredQuery = NPSDetailsQueries.returnNpsMetrics(int.parse(day));
    result = await _client.query(QueryOptions(
        documentNode: gql(filteredQuery), variables: {'day': day}));

    addToHourlyData(result.data['npsMetrics']);

    notifyListeners();
  }

  void getDistinctScores(String day, String label) async {
    if (day == '' || day == null) {
      day = preloadDay.toString();
    }
    String filteredQuery =
        NPSDetailsQueries.returnNpsDistinctScores(int.parse(day), label);
    result = await _client.query(QueryOptions(
        documentNode: gql(filteredQuery),
        variables: {'day': day, 'label': label}));

    addToDistinctScores(result.data['npsDistinctScores']);
    notifyListeners();
  }

  void addToDistinctLabels(List data) {
    data.forEach((element) {
      distinctLabel.add(DropdownMenuItem<String>(
        child: Text(element['distinctLabel']),
        value: element['distinctLabel'],
      ));
    });
  }

  void addToDistinctScores(List data) {
    hourlyLabelData = [];
    data.forEach((element) {
      hourlyLabelData.add(FlSpot(
          element['hour'] * 1.0, element['distinctContributorsCount'] * 1.0));
    });
  }

  void getPieChartData(String day) async {
    npsGetPieChartData =
        NPSDetailsQueries.returnNpsGetPieChartData(int.parse(day));

    result = await _client.query(QueryOptions(
        documentNode: gql(npsGetPieChartData),
        variables: {'day': int.parse(day)}));

    addToPieChart(result.data['npsGetPieChartData']);

    notifyListeners();
  }

  void addToPieChart(List data) {
    pieTitles = [];
    pieData = [];

    data.forEach((element) {
      pieTitles.add(element['labelName']);
      pieData.add(element['labelPercent'] * 1.0);
    });
  }
}
