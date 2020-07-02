class NPSDetailsQueries {
  static String distinctDayNPS = """{
    distinctDayNPS{
      distinctDay
    }
  }
 """;

  static String npsMetrics;

  static String returnNpsMetrics(int day) {
    npsMetrics = """{
    npsMetrics(day: $day){
      hour
      avgScore
    }
  }
  """;
    return npsMetrics;
  }

  static String npsMetricsDay;

  static String returnNpsMetricsDay(int day) {
    npsMetricsDay = """{
    npsMetricsDay(day: $day){
      avgScoreDay
    }
  }
  """;
    return npsMetricsDay;
  }

  static String npsDistinctLabelName;

  static String returnNpsDistinctLabelName() {
    npsDistinctLabelName = """{
    npsDistinctLabelName{
    distinctLabel 
    }
  }
  """;
    return npsDistinctLabelName;
  }

  static String npsDistinctScores;

  static String returnNpsDistinctScores(int day, String label) {
    npsDistinctScores = """{
    npsDistinctScores(day: $day, label: "$label"){
      hour
      distinctContributorsCount
    }
  }
  """;
    return npsDistinctScores;
  }

  static String npsGetPieChartData;

  static String returnNpsGetPieChartData(int day) {
    npsGetPieChartData = """{
    npsGetPieChartData(day: $day){
      labelName
      labelPercent
    }
  }
  """;
    return npsGetPieChartData;
  }
}
