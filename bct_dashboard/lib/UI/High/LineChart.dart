import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class LineChartWidget extends StatefulWidget {
  final List<FlSpot> itemList;
  LineChartWidget({this.itemList});
  @override
  _LineChartWidgetState createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  List<Color> gradientColors = [
    Color(0xffcc99ff),
    Color(0xffa64dff),
  ];
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

  @override
  Widget build(BuildContext context) {
    List<double> tempList = [];
    widget.itemList.forEach((element) {
      tempList.add(element.y);
    });
    double tempMaxVal, tempMinVal;

    tempMaxVal = tempList.reduce(max);
    tempMinVal = tempList.reduce(min);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          0.0, MediaQuery.of(context).size.height * 0.15, 15.0, 0.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.4,
        child: LineChart(LineChartData(
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            enabled: true,
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
                if (tempMaxVal < 0 && tempMinVal >= -25) {
                  for (int it = -25; it <= 0; it += 5) {
                    if (value == it) {
                      return it.toString();
                    }
                  }
                } else if (tempMaxVal < -25 && tempMinVal >= -50) {
                  for (int it = -50; it <= 0; it += 10) {
                    if (value == it) {
                      return it.toString();
                    }
                  }
                } else if (tempMaxVal < -50 && tempMinVal >= -100) {
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
                } else if (tempMinVal > 5 && tempMaxVal <= 50) {
                  for (int it = 0; it <= 50; it += 10) {
                    if (value == it) {
                      return it.toString();
                    }
                  }
                } else if (tempMinVal > 50 && tempMaxVal <= 100) {
                  for (int it = 0; it <= 100; it += 20) {
                    if (value == it) {
                      return it.toString();
                    }
                  }
                } else if (tempMinVal > 100 && tempMaxVal <= 1000) {
                  for (int it = 100; it <= 1000; it += 200) {
                    if (value == it) {
                      return it.toString();
                    }
                  }
                } else if (tempMinVal > 1000 && tempMaxVal <= 2000) {
                  for (int it = 1000; it <= 2000; it += 200) {
                    if (value == it) {
                      return it.toString();
                    }
                  }
                } else if (tempMinVal > 2000 && tempMaxVal <= 3000) {
                  for (int it = 2000; it <= 3000; it += 200) {
                    if (value == it) {
                      return it.toString();
                    }
                  }
                } else if (tempMinVal > 2000 && tempMaxVal <= 2500) {
                  for (int it = 2000; it <= 2500; it += 100) {
                    if (value == it) {
                      return it.toString();
                    }
                  }
                }
                return '';
              },
              reservedSize: 25,
              margin: 10,
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
                  bottom: BorderSide(color: const Color(0xff37434d), width: 1),
                  left: BorderSide(color: const Color(0xff37434d), width: 1))),
          minX: 0,
          maxX: 23,
          minY: (() {
            if (tempMinVal >= -25) {
              return -25.0;
            } else if (tempMinVal >= -50) {
              return -50.0;
            } else if (tempMinVal >= -100) {
              return -100.0;
            } else if (tempMinVal >= -200) {
              return -200.0;
            } else {
              return 0.0;
            }
          }()),
          maxY: (() {
            if (tempMaxVal <= 5) {
              return 5.0;
            } else if (tempMaxVal <= 50) {
              return 50.0;
            } else if (tempMaxVal <= 100) {
              return 100.0;
            } else if (tempMaxVal <= 1000) {
              return 1000.0;
            } else if (tempMaxVal <= 2000) {
              return 2000.0;
            } else if (tempMaxVal <= 3000) {
              return 3000.0;
            } else if (tempMaxVal <= 5000) {
              return 5000.0;
            } else if (tempMaxVal <= 10000) {
              return 10000.0;
            } else if (tempMaxVal <= 20000) {
              return 20000.0;
            } else {
              return 0.0;
            }
          }()),
          lineBarsData: [
            LineChartBarData(
              spots: widget.itemList,
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
                    .map((color) => color.withOpacity(0.5))
                    .toList(),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
