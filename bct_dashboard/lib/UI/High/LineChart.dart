import 'package:bct_dashboard/UI/Low/indicatorLegend.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class LineChartWidget extends StatefulWidget {
  final List<FlSpot> primaryScore, detractorScore, passiveScore, promoterScore;
  final List<String> legendTitles;
  LineChartWidget(
      {this.primaryScore,
      this.detractorScore,
      this.passiveScore,
      this.promoterScore,
      this.legendTitles});
  @override
  _LineChartWidgetState createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  List<Color> gradientColors = [
        Color(0xffcc99ff),
        Color(0xffa64dff),
      ],
      gradientColors1 = [Colors.red[300], Colors.red[800]],
      gradientColors2 = [Colors.green[300], Colors.green[800]],
      gradientColors3 = [Colors.yellow[400], Colors.yellow[700]];
  Map<int, String> convertToHours = {
    0: "12AM",
    2: "2AM",
    4: "4AM",
    6: "6AM",
    8: "8AM",
    10: "10AM",
    12: "12PM",
    14: "2PM",
    16: "4PM",
    18: "6PM",
    20: "8PM",
    22: "10PM"
  };

  Map<int, String> intToHours = {
    0: "12AM",
    1: "1AM",
    2: "2AM",
    3: "3AM",
    4: "4AM",
    5: "5AM",
    6: "6AM",
    7: "7AM",
    8: "8AM",
    9: "9AM",
    10: "10AM",
    11: "11AM",
    12: "12PM",
    13: "1PM",
    14: "2PM",
    15: "3PM",
    16: "4PM",
    17: "5PM",
    18: "6PM",
    19: "7PM",
    20: "8PM",
    21: "9PM",
    22: "10PM",
    23: "11PM"
  };

  Map<String, Color> colorDict;
  List<String> legendTitles;
  double tempMaxVal, tempMinVal, tempMaxValAll, tempMinValAll;
  @override
  void initState() {
    colorDict = {
      'Promoters': Colors.yellow[700],
      'Passives': Colors.green[800],
      'Detractors': Colors.red[800]
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<double> tempList = [];
    int touchedIndex;

    if (widget.primaryScore != null) {
      widget.primaryScore.forEach((element) {
        tempList.add(element.y);
      });

      tempMaxVal = tempList.reduce(max);
      tempMinVal = tempList.reduce(min);
    } else if (widget.primaryScore != null ||
        widget.promoterScore != null ||
        widget.detractorScore != null) {
      List<double> tempListAll = [];
      widget.promoterScore.forEach((element) {
        tempListAll.add(element.y);
      });
      widget.detractorScore.forEach((element) {
        tempListAll.add(element.y);
      });
      widget.passiveScore.forEach((element) {
        tempListAll.add(element.y);
      });

      tempMaxValAll = tempListAll.reduce(max);
      tempMinValAll = tempListAll.reduce(min);
    }

    return Column(
      children: [
        (() {
          if (widget.legendTitles != null) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.15, 0, 15.0, 5.0),
              child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.legendTitles.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return new Indicator(
                          color: colorDict[widget.legendTitles[index]],
                          text: widget.legendTitles[index],
                          isSquare: false,
                          size: touchedIndex == index ? 20 : 15,
                          fontWeight: touchedIndex == index
                              ? FontWeight.bold
                              : FontWeight.w500,
                          textColor: touchedIndex == index
                              ? Colors.white
                              : Colors.grey,
                        );
                      })),
            );
          } else {
            return SizedBox(height: 1.0);
          }
        }()),
        Padding(
          padding: EdgeInsets.fromLTRB(
              0.0, MediaQuery.of(context).size.height * 0.10, 15.0, 0.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5,
            child: LineChart(LineChartData(
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    List<LineTooltipItem> listItems = [];
                    for (int iter = 0; iter < touchedSpots.length; iter++) {
                      listItems.add(LineTooltipItem(
                          '${intToHours[touchedSpots[iter].x.round()]}, ${touchedSpots[iter].y.round()}',
                          TextStyle(
                              color: Colors.grey[900],
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600)));
                    }
                    return listItems;
                  },
                ),
              ),
              axisTitleData: FlAxisTitleData(
                  leftTitle: AxisTitle(
                      showTitle: true,
                      titleText: 'Value ->',
                      margin: 0,
                      textStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.yellowAccent[700],
                          fontWeight: FontWeight.bold)),
                  bottomTitle: AxisTitle(
                      showTitle: true,
                      margin: 3,
                      titleText: 'Hour of the day ->',
                      textStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.yellowAccent[700],
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right)),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: SideTitles(
                  rotateAngle: -45,
                  showTitles: true,
                  reservedSize: 30,
                  textStyle: const TextStyle(
                      color: Color(0xffFAF9F9),
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                  getTitles: (value) {
                    for (int i = 0; i < 24; i += 2) {
                      if (value == i) {
                        return convertToHours[i];
                      }
                    }
                    return '';
                  },
                  margin: 30,
                ),
                leftTitles: SideTitles(
                  showTitles: true,
                  textStyle: const TextStyle(
                    color: Color(0xffFAF9F9),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  getTitles: (value) {
                    if (widget.primaryScore != null) {
                      if (tempMaxVal <= 0 && tempMinVal >= -5) {
                        for (int it = -5; it <= 0; it += 1) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      } else if (tempMaxVal <= 0 && tempMinVal >= -25) {
                        for (int it = -25; it <= 0; it += 5) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      } else if (tempMaxVal <= 0 && tempMinVal >= -50) {
                        for (int it = -50; it <= 0; it += 10) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      } else if (tempMaxVal < 0 && tempMinVal >= -100) {
                        for (int it = -100; it <= 0; it += 20) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      } else if (tempMinVal > 0 && tempMaxVal <= 5) {
                        for (int it = 0; it <= 5; it += 1) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      } else if (tempMinVal > 0 && tempMaxVal <= 25) {
                        for (int it = 0; it <= 25; it += 5) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      } else if (tempMinVal > 0 && tempMaxVal <= 50) {
                        for (int it = 0; it <= 50; it += 10) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      } else if (tempMinVal > 0 && tempMaxVal <= 100) {
                        for (int it = 0; it <= 100; it += 20) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      } else if (tempMinVal > 0 && tempMaxVal <= 500) {
                        for (int it = 0; it <= 500; it += 100) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      } else if (tempMinVal > 0 && tempMaxVal <= 1000) {
                        for (int it = 0; it <= 1000; it += 200) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      } else if (tempMinVal > -25 && tempMaxVal < 25) {
                        for (int it = -25; it <= 25; it += 5) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      }
                      return '';
                    } else {
                      if (tempMinValAll > 0 && tempMaxValAll <= 25) {
                        for (int it = 0; it <= 25; it += 5) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      } else if (tempMinValAll > 0 && tempMaxValAll <= 50) {
                        for (int it = 0; it <= 50; it += 10) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      } else if (tempMinValAll > 0 && tempMaxValAll <= 100) {
                        for (int it = 0; it <= 100; it += 20) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      } else if (tempMinValAll > 0 && tempMaxValAll <= 500) {
                        for (int it = 0; it <= 500; it += 100) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      } else if (tempMinValAll > 0 && tempMaxValAll <= 1000) {
                        for (int it = 0; it <= 1000; it += 200) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      } else if (tempMinValAll > 0 && tempMaxValAll <= 5000) {
                        for (int it = 0; it <= 5000; it += 1000) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      } else if (tempMinValAll > 0 && tempMaxValAll <= 10000) {
                        for (int it = 0; it <= 10000; it += 2000) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      } else if (tempMinValAll > 0 && tempMaxValAll <= 15000) {
                        for (int it = 0; it <= 15000; it += 3000) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      } else if (tempMinValAll > 0 && tempMaxValAll <= 20000) {
                        for (int it = 0; it <= 20000; it += 4000) {
                          if (value == it) {
                            return it.toString();
                          }
                        }
                      }
                    }
                    return '';
                  },
                  reservedSize: 30,
                  margin: 5,
                ),
              ),
              backgroundColor: Color(0xff121212),
              gridData: FlGridData(
                show: false,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: const Color(0xff37434d),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: const Color(0xff37434d),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(
                  show: true,
                  border: Border(
                      bottom:
                          BorderSide(color: const Color(0xff37434d), width: 1),
                      left: BorderSide(
                          color: const Color(0xff37434d), width: 1))),
              minX: 0,
              maxX: 23,
              minY: (() {
                if (widget.primaryScore != null) {
                  if (tempMaxVal <= 0 && tempMinVal >= -5) {
                    return -5.0;
                  }
                  if (tempMaxVal <= 0 && tempMinVal >= -25) {
                    return -25.0;
                  }
                  if (tempMaxVal > 0 && tempMinVal <= 0) {
                    return -25.0;
                  }
                  if (tempMaxVal <= 0 && tempMinVal >= -50) {
                    return -50.0;
                  }
                  if (tempMaxVal <= 0 && tempMinVal >= -100) {
                    return -100.0;
                  }
                  if (tempMaxVal <= 0 && tempMinVal >= -500) {
                    return -500.0;
                  } else {
                    return 0.0;
                  }
                } else {
                  return 0.0;
                }
              }()),
              maxY: (() {
                if (widget.primaryScore != null) {
                  if (tempMinVal > 0 && tempMaxVal <= 5) {
                    return 5.0;
                  }
                  if (tempMinVal > 5 && tempMaxVal <= 25) {
                    return 25.0;
                  }
                  if (tempMinVal > 5 && tempMaxVal <= 50) {
                    return 50.0;
                  }
                  if (tempMinVal > 5 && tempMaxVal <= 100) {
                    return 100.0;
                  }
                  if (tempMinVal > 5 && tempMaxVal <= 100) {
                    return 100.0;
                  }
                  if (tempMinVal > 5 && tempMaxVal <= 500) {
                    return 500.0;
                  }
                  if (tempMinVal > 5 && tempMaxVal <= 1000) {
                    return 1000.0;
                  }
                } else {
                  if (tempMinValAll > 0 && tempMaxValAll <= 5) {
                    return 5.0;
                  }
                  if (tempMinValAll > 5 && tempMaxValAll <= 25) {
                    return 25.0;
                  }
                  if (tempMinValAll > 5 && tempMaxValAll <= 50) {
                    return 50.0;
                  }
                  if (tempMinValAll > 5 && tempMaxValAll <= 100) {
                    return 100.0;
                  }
                  if (tempMinValAll > 5 && tempMaxValAll <= 500) {
                    return 500.0;
                  }
                  if (tempMinValAll > 5 && tempMaxValAll <= 1000) {
                    return 1000.0;
                  }
                  if (tempMinValAll > 5 && tempMaxValAll <= 5000) {
                    return 5000.0;
                  }
                  if (tempMinValAll > 5 && tempMaxValAll <= 10000) {
                    return 10000.0;
                  }
                }
              }()),
              lineBarsData: (() {
                LineChartBarData lineChartBarData1,
                    lineChartBarData2,
                    lineChartBarData3,
                    lineChartBarData4;

                if (widget.primaryScore != null) {
                  lineChartBarData1 = LineChartBarData(
                    spots: widget.primaryScore,
                    isCurved: true,
                    colors: gradientColors,
                    barWidth: 5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: false,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      colors: gradientColors
                          .map((color) => color.withOpacity(0.3))
                          .toList(),
                    ),
                  );
                }

                if (widget.detractorScore != null) {
                  lineChartBarData2 = LineChartBarData(
                    spots: widget.detractorScore,
                    isCurved: true,
                    colors: gradientColors1,
                    barWidth: 5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: false,
                    ),
                  );
                }
                if (widget.passiveScore != null) {
                  lineChartBarData3 = LineChartBarData(
                    spots: widget.passiveScore,
                    isCurved: true,
                    colors: gradientColors2,
                    barWidth: 5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: false,
                    ),
                  );
                }
                if (widget.promoterScore != null) {
                  lineChartBarData4 = LineChartBarData(
                    spots: widget.promoterScore,
                    isCurved: true,
                    colors: gradientColors3,
                    barWidth: 5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: false,
                    ),
                  );
                }

                if (widget.detractorScore != null ||
                    widget.passiveScore != null ||
                    widget.promoterScore != null) {
                  if (widget.detractorScore != null &&
                      widget.passiveScore != null &&
                      widget.promoterScore != null) {
                    return [
                      lineChartBarData2,
                      lineChartBarData3,
                      lineChartBarData4
                    ];
                  } else if (widget.detractorScore != null &&
                      widget.passiveScore != null) {
                    return [lineChartBarData2, lineChartBarData3];
                  } else if (widget.detractorScore != null &&
                      widget.promoterScore != null) {
                    return [lineChartBarData2, lineChartBarData4];
                  } else if (widget.passiveScore != null &&
                      widget.promoterScore != null) {
                    return [lineChartBarData3, lineChartBarData4];
                  } else if (widget.detractorScore != null) {
                    return [lineChartBarData2];
                  } else if (widget.passiveScore != null) {
                    return [lineChartBarData3];
                  } else if (widget.promoterScore != null) {
                    return [lineChartBarData4];
                  }
                } else if (widget.primaryScore != null) {
                  return [lineChartBarData1];
                }
              }()),
            )),
          ),
        ),
      ],

    );
  }
}
