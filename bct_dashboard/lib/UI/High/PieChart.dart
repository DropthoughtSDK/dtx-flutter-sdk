import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../Low/indicatorLegend.dart';

class PieChartWidget extends StatefulWidget {
  final List<double> pieData;
  final List<String> pieDataTitles;
  PieChartWidget({this.pieData, this.pieDataTitles});
  @override
  _PieChartWidgetState createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex;
  List<Color> colorArray;
  List<int> rgb;

  Random random = new Random();

  @override
  void initState() {
    colorArray = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    for (int iter = 0; iter < widget.pieData.length; iter++) {
      Color tempColor =
          Colors.primaries[Random().nextInt(Colors.primaries.length)];
      if (colorArray.contains(tempColor)) {
        colorArray
            .add(Colors.primaries[Random().nextInt(Colors.primaries.length)]);
      } else {
        colorArray.add(tempColor);
      }
    }
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Column(
        children: [
          SizedBox(
            height: 8.0,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25.0, 5.0, 10.0, 5.0),
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.pieData.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return new Indicator(
                              color: colorArray[index],
                              text: widget.pieDataTitles[index],
                              isSquare: false,
                              size: touchedIndex == index ? 20 : 15,
                              fontWeight: touchedIndex == index
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              textColor: touchedIndex == index
                                  ? Colors.white
                                  : Colors.grey,
                            );
                          }),
                    ),
                  )
                ],
              ),
            ),
          ),
          PieChart(
            PieChartData(
                pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
                  setState(() {
                    if (pieTouchResponse.touchInput is FlLongPressEnd ||
                        pieTouchResponse.touchInput is FlPanEnd) {
                      touchedIndex = -1;
                    } else {
                      touchedIndex = pieTouchResponse.touchedSectionIndex;
                    }
                  });
                }),
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 20,
                centerSpaceRadius: 40,
                sections: showingSections()),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(
      widget.pieDataTitles.length,
      (i) {
        return PieChartSectionData(
          color: colorArray[i].withOpacity(0.8),
          value: widget.pieData[i],
          title: '${widget.pieData[i]}%',
          radius: MediaQuery.of(context).size.height * 0.12,
          titleStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900]),
          titlePositionPercentageOffset: 0.6,
        );
      },
    );
  }
}
