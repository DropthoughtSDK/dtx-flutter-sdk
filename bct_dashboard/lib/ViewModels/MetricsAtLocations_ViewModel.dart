import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../GraphQLClient/graphQlClient.dart';
import 'package:graphql/client.dart';
import '../Queries/MetricsAtLocations_Queries.dart';
import '../UI/Low/Logger.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Logger log = ReturnLogger.returnLogger();
  List<Future> futures = [];
  List<Future> getFutures = [];
  List resultData = [];

  List<Future> initFutures() {
    futures.add(_client.query(QueryOptions(
        documentNode: gql(MetricsAtLocationsQueries.initLabelQuery),
        variables: {})));

    futures.add(_client.query(QueryOptions(
        documentNode: gql(MetricsAtLocationsQueries.initNameQuery),
        variables: {})));

    futures.add(_client.query(QueryOptions(
        documentNode: gql(MetricsAtLocationsQueries.initDayQuery),
        variables: {})));

    return futures;
  }

  List<Future> getInitFutures() {
    mainQuery = MetricsAtLocationsQueries.returnMainQuery(
        preloadDay, preloadName, preloadLabel);

    getFutures.add(_client.query(QueryOptions(
        documentNode: gql(mainQuery),
        variables: {
          'day': preloadDay,
          'name': preloadName,
          'label': preloadLabel
        })));

    pieChartQuery = MetricsAtLocationsQueries.returnPieChartQuery(
        preloadDay, preloadName, preloadLabel);

    getFutures.add(_client.query(QueryOptions(
        documentNode: gql(pieChartQuery),
        variables: {
          'day': preloadDay,
          'name': preloadName,
          'label': preloadLabel
        })));

    return getFutures;
  }

  void getData() async {
    Stopwatch stopwatchx = new Stopwatch()..start();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Duration diff;

    if (prefs.getString('dateTime') != null) {
      DateTime timeToLive = DateTime.parse(prefs.getString('dateTime'));
      DateTime now = DateTime.now();
      diff = timeToLive.difference(now);

      if (diff.inMinutes <= 0) {
        resultData = [];
        var futures = initFutures();
        var result = await Future.wait(futures);

        cleanInitData(result[0].data['distinctLabelsQuery']);
        addLabels(initLabelData);
        preloadLabel = initLabelData.last;

        cleanInitData(result[1].data['distinctNamesQuery']);

        addNames(initNameData);
        preloadName = initNameData.last;

        cleanInitData(result[2].data['distinctDaysQuery']);

        addDays(initDayData);
        preloadDay = initDayData.last;

        var dataFutures = getInitFutures();
        resultData = await Future.wait(dataFutures);

        cleanData(resultData[0].data['metrics']);

        cleanPieChartData(resultData[1].data['getPieChartData']);

        log.d(
            'total time taken for fetching Initial data: ${stopwatchx.elapsed}');

        log.i(
            "Initial Data for linechart and piechart is fetched, cleaned and passed to the UI");

        DateTime time = DateTime.now().add(Duration(hours: 24));
        prefs.setString('dateTime', time.toString());
        prefs.setInt('initDayData', preloadDay);
        List<String> initDayList = [];
        initDayData.forEach((element) {
          initDayList.add(element.toString());
        });
        prefs.setStringList('initDayList', initDayList);
        prefs.setString('initLabelData', preloadLabel);
        prefs.setStringList('initLabelList', initLabelData);
        prefs.setString('initNameData', preloadName);
        prefs.setStringList('initNameList', initNameData);
      } else {
        initDayData = [];
        initLabelData = [];
        initNameData = [];
        days = [];
        names = [];
        labels = [];
        resultData = [];

        Stopwatch stopwatch2 = Stopwatch()..start();
        log.i(
            "Initial data is already available, no need for fetching, displaying UI right away!");

        preloadLabel = prefs.getString('initLabelData');
        preloadDay = prefs.getInt('initDayData');
        preloadName = prefs.getString('initNameData');

        List<int> getDays = [];
        prefs.getStringList('initDayList').forEach((element) {
          getDays.add(int.parse(element));
        });

        addDays(getDays);
        addLabels(prefs.getStringList('initLabelList'));
        addNames(prefs.getStringList('initNameList'));

        hourlyData = [];
        for (int i = 0; i < prefs.getStringList('hourList').length; i++) {
          hourlyData.add(FlSpot(
              int.parse(prefs.getStringList('hourList')[i]) * 1.0,
              num.parse(num.parse(prefs.getStringList('lineDataList')[i])
                  .toStringAsFixed(2))));
        }

        pieData = [];
        pieDataTitles = prefs.getStringList('pieTitles');
        prefs.getStringList('pieData').forEach((element) {
          pieData.add(num.parse(element));
        });
        resultData.add(hourlyData);
        log.i('Total time taken for fetching data is: ${stopwatch2.elapsed}');
      }
    } else {
      resultData = [];
      var futures = initFutures();
      var result = await Future.wait(futures);

      cleanInitData(result[0].data['distinctLabelsQuery']);
      addLabels(initLabelData);
      preloadLabel = initLabelData.last;

      cleanInitData(result[1].data['distinctNamesQuery']);

      addNames(initNameData);
      preloadName = initNameData.last;

      cleanInitData(result[2].data['distinctDaysQuery']);

      addDays(initDayData);
      preloadDay = initDayData.last;

      var dataFutures = getInitFutures();
      resultData = await Future.wait(dataFutures);

      List<String> hourlyLineDataCached = [];
      List<String> hourListCached = [];
      cleanData(resultData[0].data['metrics']);
      resultData[0].data['metrics'].forEach((element) {
        hourListCached.add(element['hour'].toString());
        hourlyLineDataCached.add(element['avgScore'].toString());
      });

      cleanPieChartData(resultData[1].data['getPieChartData']);
      List<String> pieDataCachedValues = [];

      pieData.forEach((element) {
        pieDataCachedValues.add(element.toString());
      });

      log.d(
          'total time taken for fetching Initial data: ${stopwatchx.elapsed}');

      log.i(
          "Initial Data for linechart and piechart is fetched, cleaned and passed to the UI");

      DateTime time = DateTime.now().add(Duration(hours: 24));
      prefs.setString('dateTime', time.toString());
      prefs.setInt('initDayData', preloadDay);
      List<String> initDayList = [];
      initDayData.forEach((element) {
        initDayList.add(element.toString());
      });
      prefs.setStringList('initDayList', initDayList);
      prefs.setString('initLabelData', preloadLabel);
      prefs.setStringList('initLabelList', initLabelData);
      prefs.setString('initNameData', preloadName);
      prefs.setStringList('initNameList', initNameData);
      prefs.setStringList('hourList', hourListCached);
      prefs.setStringList('lineDataList', hourlyLineDataCached);
      prefs.setStringList('pieTitles', pieDataTitles);
      prefs.setStringList('pieData', pieDataCachedValues);
    }
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
    Stopwatch stop1 = new Stopwatch()..start();
    String filteredDataQuery =
        MetricsAtLocationsQueries.returnMainQuery(int.parse(day), name, label);
    filteredResults = await _client.query(QueryOptions(
        documentNode: gql(filteredDataQuery),
        variables: {'day': day, 'name': name, 'label': label}));

    cleanData(filteredResults.data['metrics']);
    log.d('Time taken for fetching filtered line chart data: ${stop1.elapsed}');
    log.i(
        "OnSubmit data has been fetched, cleaned and sent back to repopulate the LineChart View in UI");
    notifyListeners();
  }

  void getFilteredPieData(String day, String name, String label) async {
    Stopwatch stop1 = new Stopwatch()..start();
    String filteredPieDataQuery = MetricsAtLocationsQueries.returnPieChartQuery(
        int.parse(day), name, label);

    pieResults = await _client.query(QueryOptions(
        documentNode: gql(filteredPieDataQuery),
        variables: {'day': day, 'name': name, 'label': label}));

    cleanPieChartData(pieResults.data['getPieChartData']);
    log.d('Time taken for fetching filtered pie chart data: ${stop1.elapsed}');
    log.i(
        "OnSubmit data has been fetched, cleaned and sent back to repopulate the PieChart View in UI");
    notifyListeners();
  }
}
