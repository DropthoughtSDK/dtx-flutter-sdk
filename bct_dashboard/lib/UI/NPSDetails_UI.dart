import 'package:bct_dashboard/ServiceLocator/service_locator.dart';
import 'package:bct_dashboard/UI/Low/DropDown.dart';
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

class NPSDetailsUI extends StatefulWidget {
  @override
  _NPSDetailsUIState createState() => _NPSDetailsUIState();
}

class _NPSDetailsUIState extends State<NPSDetailsUI> {
  NPSDetailsViewModel viewModel = serviceLocator<NPSDetailsViewModel>();
  Logger log = ReturnLogger.returnLogger();
  bool _visibleDay;
  String selectedValueDay = '', selectedValueLabel = '';
  int _current;

  callback(val, id) {
    setState(() {
      if (id == "days") {
        if (val == null) {
          setState(() {
            _visibleDay = true;
          });
        } else {
          setState(() {
            _visibleDay = false;
          });
        }
        selectedValueDay = val;
      }
    });
  }

  @override
  void initState() {
    viewModel.getData();
    _visibleDay = false;
    _current = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ChangeNotifierProvider<NPSDetailsViewModel>(
      create: (context) => viewModel,
      child: Consumer<NPSDetailsViewModel>(
        builder: (context, model, child) {
          if (viewModel.result == null) {
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
                        _visibleDay = false;
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
                    //FIXME: Fix bugs, test for all conditions
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            color: Color(0xff24292E),
                            elevation: 5.0,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  15.0, 5.0, 15.0, 5.0),
                              child: Column(
                                children: [
                                  DropDownWidget(
                                      dropDownitems: viewModel.days,
                                      preLoadValue:
                                          viewModel.preloadDay.toString(),
                                      callback: callback,
                                      id: "days"),
                                  Visibility(
                                    visible: _visibleDay,
                                    child: Text(
                                      '* Please select atleast one of the options',
                                      style: TextStyle(
                                          color: Colors.red[800],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  RaisedButton(
                                    disabledColor: Colors.grey[800],
                                    onPressed: () {
                                      viewModel
                                          .getNPSMetricsDay(selectedValueDay);

                                      viewModel.getNPSMetrics(selectedValueDay);

                                      if (selectedValueLabel == '') {
                                        selectedValueLabel =
                                            viewModel.preloadLabel;
                                      }
                                      viewModel
                                          .getDistinctScores(selectedValueDay);
                                      viewModel
                                          .getPieChartData(selectedValueDay);
                                    },
                                    child: Text('Apply Filters'),
                                    color: Colors.green[800],
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                                                          0.175,
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
                                                              0.85,
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
                                                                primaryScore:
                                                                    viewModel
                                                                        .hourlyData,
                                                                detractorScore:
                                                                    viewModel
                                                                        .detractorsData,
                                                                passiveScore:
                                                                    viewModel
                                                                        .passivesData,
                                                                promoterScore:
                                                                    viewModel
                                                                        .promotersData,
                                                                        legendTitles: viewModel.legendTitles
                                                              )
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
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 30, 5, 10),
                                              child: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.7,
                                                width: MediaQuery.of(context)
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
                                                          viewModel.pieTitles),
                                                ),
                                              ),
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
