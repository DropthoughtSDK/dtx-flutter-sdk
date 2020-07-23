import 'package:bct_dashboard/GraphQLClient/graphQlClient.dart';
import 'package:bct_dashboard/Queries/NPSDetails_Queries.dart';
import 'package:bct_dashboard/UI/Low/Logger.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<FlSpot> hourlyData, detractorsData, passivesData, promotersData;
  List<String> pieTitles;
  List<double> pieData;
  List<Future> futures = [];
  List resultData = [];

  List<DropdownMenuItem> days;
  String initNpsMetricsDay, initNpsMetrics, initDistinctLabels;
  List<String> legendTitles = ['Detractors', 'Passives', 'Promoters'];
  Logger log = ReturnLogger.returnLogger();

  List<Future> initFutures() {
    initNpsMetricsDay = NPSDetailsQueries.returnNpsMetricsDay(preloadDay);

    futures.add(_client.query(QueryOptions(
        documentNode: gql(initNpsMetricsDay), variables: {'day': preloadDay})));

    initNpsMetrics = NPSDetailsQueries.returnNpsMetrics(preloadDay);

    futures.add(_client.query(QueryOptions(
        documentNode: gql(initNpsMetrics), variables: {'day': preloadDay})));

    npsDistinctScores =
        NPSDetailsQueries.returnNpsDistinctScores(preloadDay, 'Detractors');

    futures.add(_client.query(QueryOptions(
        documentNode: gql(npsDistinctScores),
        variables: {'day': preloadDay, 'label': 'Detractors'})));

    npsDistinctScores =
        NPSDetailsQueries.returnNpsDistinctScores(preloadDay, 'Promoters');

    futures.add(_client.query(QueryOptions(
        documentNode: gql(npsDistinctScores),
        variables: {'day': preloadDay, 'label': 'Promoters'})));

    npsDistinctScores =
        NPSDetailsQueries.returnNpsDistinctScores(preloadDay, 'Passives');

    futures.add(_client.query(QueryOptions(
        documentNode: gql(npsDistinctScores),
        variables: {'day': preloadDay, 'label': 'Passives'})));

    npsGetPieChartData = NPSDetailsQueries.returnNpsGetPieChartData(preloadDay);
    futures.add(_client.query(QueryOptions(
        documentNode: gql(npsGetPieChartData),
        variables: {'day': preloadDay})));

    return futures;
  }

  void getData() async {
    initDayData = [];
    distinctLabel = [];
    days = [];
    hourlyData = [];
    pieTitles = [];
    pieData = [];
    Stopwatch stopwatch = new Stopwatch()..start();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Duration diff;

    if (prefs.getString('dateTimeNPS') != null) {
      detractorsData = [];
      passivesData = [];
      promotersData = [];
      pieData = [];
      pieTitles = [];
      hourlyData = [];

      DateTime timeToLive = DateTime.parse(prefs.getString('dateTimeNPS'));
      DateTime now = DateTime.now();
      diff = timeToLive.difference(now);

      if (diff.inMinutes <= 0) {
        result = await _client.query(QueryOptions(
            documentNode: gql(NPSDetailsQueries.distinctDayNPS),
            variables: {}));

        cleanInitData(result.data['distinctDayNPS']);
        addDays(initDayData);
        preloadDay = initDayData.last;
        var dataFutures = initFutures();
        resultData = await Future.wait(dataFutures);

        cleanData(resultData[0].data['npsMetricsDay']);
        addToHourlyData(resultData[1].data['npsMetrics']);

        addToDistinctScores(
            resultData[2].data['npsDistinctScores'], 'Detractors');
        addToDistinctScores(
            resultData[3].data['npsDistinctScores'], 'Promoters');
        addToDistinctScores(
            resultData[4].data['npsDistinctScores'], 'Passives');
        addToPieChart(resultData[5].data['npsGetPieChartData']);

        DateTime time = DateTime.now().add(Duration(hours: 24));
        prefs.setString('dateTimeNPS', time.toString());

        List<String> initDayList = [];
        initDayData.forEach((element) {
          initDayList.add(element.toString());
        });
        prefs.setStringList('DayList', initDayList);

        log.i('Time Taken to fetch initial data is: ${stopwatch.elapsed}');
      } else {
        detractorsData = [];
        passivesData = [];
        promotersData = [];
        pieData = [];
        pieTitles = [];
        hourlyData = [];

        log.i(
            'Initial data is already available, no need for fetching. Displaying UI right away');
        Stopwatch stopwatchx = new Stopwatch()..start();
        var getDays = prefs.getStringList('DayList');
        getDays.forEach((element) {
          int.parse(element);
        });

        addDays(getDays);
        preloadDay = int.parse(getDays.last);
        npsDayData = num.parse(prefs.getString('npsMetricsDay'));

        for (int i = 0; i < prefs.getStringList('npsHourList').length; i++) {
          hourlyData.add(FlSpot(
              num.parse(prefs.getStringList('npsHourList')[i]) * 1.0,
              num.parse(num.parse(prefs.getStringList('npsLineData')[i])
                  .toStringAsFixed(2))));

          detractorsData.add(FlSpot(
              num.parse(prefs.getStringList('npsHourList')[i]) * 1.0,
              num.parse(num.parse(prefs.getStringList('detractorsLineData')[i])
                  .toStringAsFixed(2))));

          promotersData.add(FlSpot(
              num.parse(prefs.getStringList('npsHourList')[i]) * 1.0,
              num.parse(num.parse(prefs.getStringList('promotersLineData')[i])
                  .toStringAsFixed(2))));

          passivesData.add(FlSpot(
              num.parse(prefs.getStringList('npsHourList')[i]) * 1.0,
              num.parse(num.parse(prefs.getStringList('passivesLineData')[i])
                  .toStringAsFixed(2))));
        }

        resultData.add(hourlyData);

        pieTitles = prefs.getStringList('npsPieTitles');
        prefs.getStringList('npsPieData').forEach((element) {
          pieData.add(num.parse(element));
        });

        log.i('Time taken for entire data fetch: ${stopwatchx.elapsed}');
      }
    } else {
      detractorsData = [];
      passivesData = [];
      promotersData = [];
      pieData = [];
      pieTitles = [];
      hourlyData = [];

      Stopwatch stopwatchy = new Stopwatch()..start();
      result = await _client.query(QueryOptions(
          documentNode: gql(NPSDetailsQueries.distinctDayNPS), variables: {}));

      cleanInitData(result.data['distinctDayNPS']);
      addDays(initDayData);
      preloadDay = initDayData.last;
      var dataFutures = initFutures();
      resultData = await Future.wait(dataFutures);

      cleanData(resultData[0].data['npsMetricsDay']);
      prefs.setString('npsMetricsDay', npsDayData.toString());
      addToHourlyData(resultData[1].data['npsMetrics']);

      List<String> hourList = [];
      List<String> npsLineDataList = [];

      resultData[1].data['npsMetrics'].forEach((element) {
        hourList.add(element['hour'].toString());
        npsLineDataList.add(element['avgScore'].toString());
      });

      prefs.setStringList('npsHourList', hourList);
      prefs.setStringList('npsLineData', npsLineDataList);

      List<String> detractorsLineData = [];
      List<String> promotersLineData = [];
      List<String> passivesLineData = [];

      addToDistinctScores(
          resultData[2].data['npsDistinctScores'], 'Detractors');

      resultData[2].data['npsDistinctScores'].forEach((element) {
        detractorsLineData.add(element['distinctContributorsCount'].toString());
      });

      addToDistinctScores(resultData[3].data['npsDistinctScores'], 'Promoters');
      resultData[3].data['npsDistinctScores'].forEach((element) {
        promotersLineData.add(element['distinctContributorsCount'].toString());
      });

      addToDistinctScores(resultData[4].data['npsDistinctScores'], 'Passives');
      resultData[4].data['npsDistinctScores'].forEach((element) {
        passivesLineData.add(element['distinctContributorsCount'].toString());
      });

      prefs.setStringList('detractorsLineData', detractorsLineData);
      prefs.setStringList('promotersLineData', promotersLineData);
      prefs.setStringList('passivesLineData', passivesLineData);

      addToPieChart(resultData[5].data['npsGetPieChartData']);
      prefs.setStringList('npsPieTitles', pieTitles);

      List<String> pieDataCached = [];
      resultData[5].data['npsGetPieChartData'].forEach((element) {
        pieDataCached.add((element['labelPercent'] * 1.0).toString());
      });

      prefs.setStringList('npsPieData', pieDataCached);

      DateTime time = DateTime.now().add(Duration(hours: 24));
      prefs.setString('dateTimeNPS', time.toString());

      List<String> initDayList = [];
      initDayData.forEach((element) {
        initDayList.add(element.toString());
      });
      prefs.setStringList('DayList', initDayList);

      log.i('Total time taken for loading initData: ${stopwatchy.elapsed}');
    }

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
    npsDayData = resultData[0].data['npsMetricsDay'][0]['avgScoreDay'];
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
    npsDayData = result.data['npsMetricsDay'][0]['avgScoreDay'];

    notifyListeners();
  }

  void getNPSMetrics(String day) async {
    String filteredQuery = NPSDetailsQueries.returnNpsMetrics(int.parse(day));
    result = await _client.query(QueryOptions(
        documentNode: gql(filteredQuery), variables: {'day': day}));

    addToHourlyData(result.data['npsMetrics']);

    notifyListeners();
  }

  void getDistinctScores(String day) async {
    if (day == '' || day == null) {
      day = preloadDay.toString();
    }
    String filteredQuery =
        NPSDetailsQueries.returnNpsDistinctScores(int.parse(day), 'Promoters');
    result = await _client.query(QueryOptions(
        documentNode: gql(filteredQuery),
        variables: {'day': day, 'label': 'Promoters'}));

    addToDistinctScores(result.data['npsDistinctScores'], 'Promoters');

    filteredQuery =
        NPSDetailsQueries.returnNpsDistinctScores(int.parse(day), 'Detractors');
    result = await _client.query(QueryOptions(
        documentNode: gql(filteredQuery),
        variables: {'day': day, 'label': 'Detractors'}));

    addToDistinctScores(result.data['npsDistinctScores'], 'Detractors');

    filteredQuery =
        NPSDetailsQueries.returnNpsDistinctScores(int.parse(day), 'Passives');
    result = await _client.query(QueryOptions(
        documentNode: gql(filteredQuery),
        variables: {'day': day, 'label': 'Passives'}));

    addToDistinctScores(result.data['npsDistinctScores'], 'Passives');

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

  void addToDistinctScores(List data, String label) {
    if (label == 'Promoters') {
      promotersData = [];
      data.forEach((element) {
        promotersData.add(FlSpot(
            element['hour'] * 1.0, element['distinctContributorsCount'] * 1.0));
      });
    } else if (label == 'Passives') {
      passivesData = [];
      data.forEach((element) {
        passivesData.add(FlSpot(
            element['hour'] * 1.0, element['distinctContributorsCount'] * 1.0));
      });
    } else if (label == 'Detractors') {
      detractorsData = [];
      data.forEach((element) {
        detractorsData.add(FlSpot(
            element['hour'] * 1.0, element['distinctContributorsCount'] * 1.0));
      });
    }
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
