class MetricsAtLocationsQueries {
  static String initLabelQuery = """{
      distinctLabelsQuery{
        distinctLabel
        }
    }""";
  static String initNameQuery = """{
      distinctNamesQuery{
        distinctName
      }
  }""";

  static String initDayQuery = """{
    distinctDaysQuery{
      distinctDay
      }
  }""";

  static String mainQuery;

  static String returnMainQuery(int day, String name, String label) {
    mainQuery = """ {
                      metrics(day: $day, name: "$name", label: "$label"){
                          hour
                          avgScore
                      }
                    }""";
    return mainQuery;
  }

  static String getPieChartData;

  static String returnPieChartQuery(int day, String name, String label) {
    getPieChartData = """{
      getPieChartData(day: $day, name: "$name" , label: "$label"){
        labelName
        labelPercent
      }
    }""";
    return getPieChartData;
  }
}
