import 'package:bct_dashboard/ServiceLocator/service_locator.dart';
import 'package:bct_dashboard/UI/Low/Logger.dart';
import 'package:bct_dashboard/ViewModels/NPSDetails_ViewModel.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'High/LineChart.dart';
import 'package:customgauge/customgauge.dart';

import 'High/PieChart.dart';
import 'High/AnimatedContainerWidget.dart';

class NPSDetailsUI extends StatefulWidget {
  @override
  _NPSDetailsUIState createState() => _NPSDetailsUIState();
}

class _NPSDetailsUIState extends State<NPSDetailsUI> {
  NPSDetailsViewModel viewModel = serviceLocator<NPSDetailsViewModel>();
  Logger log = ReturnLogger.returnLogger();
  String selectedValueDay = '', selectedValueLabel = '';
  int _current;

  @override
  void initState() {
    viewModel.getData();
    _current = 0;
    super.initState();
  }

  callback(val, id, placeholder) {
    setState(() {
      selectedValueDay = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ChangeNotifierProvider<NPSDetailsViewModel>(
      create: (context) => viewModel,
      child: Consumer<NPSDetailsViewModel>(
        builder: (context, model, child) {
          if (viewModel.resultData.length == 0) {
            log.i(
                "Data is loading, displaying a circular loading indicator in the meantime");
            return SpinKitWave(
              itemBuilder: (BuildContext context, int index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.red[700] : Colors.blue[700],
                  ),
                );
              },
            );
          } else {
            return SafeArea(
              child: Scaffold(
                backgroundColor: Color(0xff121212),
                body: LiquidPullToRefresh(
                  color: Colors.black,
                  animSpeedFactor: 1.5,
                  backgroundColor: Colors.white,
                  showChildOpacityTransition: false,
                  onRefresh: () async {
                    if (selectedValueDay == '') {
                      setState(() {
                        viewModel.getData();
                      });
                    } else if (selectedValueDay == null) {
                      setState(() {
                        viewModel.getData();
                        viewModel.getDistinctScores(
                          viewModel.preloadDay.toString(),
                        );
                      });
                    } else if (selectedValueDay.length > 0) {
                      viewModel.getNPSMetricsDay(selectedValueDay);

                      viewModel.getNPSMetrics(selectedValueDay);
                      viewModel.getDistinctScores(selectedValueDay);
                      viewModel.getPieChartData(selectedValueDay);
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  25.0, 25.0, 5.0, 10.0),
                              child: Text(
                                selectedValueDay == null ||
                                        selectedValueDay == ''
                                    ? 'Day: ${viewModel.preloadDay}'
                                    : 'Day: $selectedValueDay',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.87),
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 25, 25, 10),
                              child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      15.0, 5.0, 15.0, 5.0),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: AnimatedContainerWidget(
                                        viewModelNps: viewModel,
                                        callback: callback,
                                        id: "NPS Metrics"),
                                  )),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Divider(
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        (() {
                          return CarouselSlider.builder(
                            itemCount: 3,
                            options: CarouselOptions(
                                height:
                                    MediaQuery.of(context).size.height * 0.85,
                                aspectRatio: 2,
                                viewportFraction: 0.95,
                                autoPlay: false,
                                enlargeCenterPage: true,
                                enableInfiniteScroll: false,
                                scrollDirection: Axis.horizontal,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _current = index;
                                  });
                                }),
                            itemBuilder:
                                (BuildContext context, int itemIndex) =>
                                    GestureDetector(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0, 15.0, 0.0, 15.0),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.95,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _current == 0
                                                    ? Color.fromRGBO(
                                                        255, 255, 255, 1)
                                                    : Color.fromRGBO(
                                                        255, 255, 255, 0.5),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8.0,
                                            ),
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _current == 1
                                                    ? Color.fromRGBO(
                                                        255, 255, 255, 0.9)
                                                    : Color.fromRGBO(
                                                        255, 255, 255, 0.4),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8.0,
                                            ),
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _current == 2
                                                    ? Color.fromRGBO(
                                                        255, 255, 255, 0.9)
                                                    : Color.fromRGBO(
                                                        255, 255, 255, 0.4),
                                              ),
                                            ),
                                          ],
                                        ),
                                        (() {
                                          if (itemIndex == 0) {
                                            return Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      10.0,
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.1,
                                                      10.0,
                                                      10.0),
                                                  child: Card(
                                                    elevation: 5.0,
                                                    color: Color(0xff121212),
                                                    child: CustomGauge(
                                                      needleColor:
                                                          Colors.black38,
                                                      startMarkerStyle:
                                                          TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 18.0,
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.88)),
                                                      endMarkerStyle: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 18.0,
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.88)),
                                                      minValue: -100,
                                                      maxValue: 100,
                                                      gaugeSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.7,
                                                      segments: [
                                                        GaugeSegment(
                                                            'Very Low',
                                                            40,
                                                            Color(0xffd580ff)),
                                                        GaugeSegment('Low', 40,
                                                            Color(0xffcc66ff)),
                                                        GaugeSegment(
                                                            'Medium',
                                                            40,
                                                            Color(0xffc44dff)),
                                                        GaugeSegment('High', 40,
                                                            Color(0xffaa00ff)),
                                                        GaugeSegment(
                                                            'Very High',
                                                            40,
                                                            Color(0xff8800cc)),
                                                      ],
                                                      currentValue: viewModel
                                                          .npsDayData
                                                          .toDouble(),
                                                      valueWidget: Text(
                                                          '${viewModel.npsDayData}',
                                                          style: TextStyle(
                                                              fontSize: 30.0,
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.87),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ),
                                                  ),
                                                ),
                                                Card(
                                                  elevation: 5.0,
                                                  color: Color(0xff121212),
                                                  child: LineChartWidget(
                                                    primaryScore:
                                                        viewModel.hourlyData,
                                                  ),
                                                )
                                              ],
                                            );
                                          } else if (itemIndex == 1) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 20, 5, 10),
                                              child: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.80,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.95,
                                                child: Card(
                                                  elevation: 5,
                                                  color: Color(0xff121212),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                5, 20, 5, 10),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Column(
                                                            children: [
                                                              LineChartWidget(
                                                                  detractorScore:
                                                                      viewModel
                                                                          .detractorsData,
                                                                  passiveScore:
                                                                      viewModel
                                                                          .passivesData,
                                                                  promoterScore:
                                                                      viewModel
                                                                          .promotersData,
                                                                  legendTitles:
                                                                      viewModel
                                                                          .legendTitles)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else if (itemIndex == 2) {
                                            return Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          5, 30, 5, 10),
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.7,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.95,
                                                    child: Card(
                                                      color: Color(0xff121212),
                                                      elevation: 5,
                                                      child: PieChartWidget(
                                                          pieData:
                                                              viewModel.pieData,
                                                          pieDataTitles:
                                                              viewModel
                                                                  .pieTitles),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                        }())
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }())
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    ));
  }
}
