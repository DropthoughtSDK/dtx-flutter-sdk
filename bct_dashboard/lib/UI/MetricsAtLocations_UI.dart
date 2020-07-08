import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:logger/logger.dart';
import '../ViewModels/MetricsAtLocations_ViewModel.dart';
import '../ServiceLocator/service_locator.dart';
import 'package:provider/provider.dart';
import './High/LineChart.dart';
import 'package:carousel_slider/carousel_slider.dart';
import './High/PieChart.dart';
import '../UI/Low/Logger.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'High/AnimatedContainerWidget.dart';

class MetricsAtLocationsUI extends StatefulWidget {
  @override
  _MetricsAtLocationsUIState createState() => _MetricsAtLocationsUIState();
}

class _MetricsAtLocationsUIState extends State<MetricsAtLocationsUI> {
  String selectedValueName = '', selectedValueLabel = '', selectedValueDay = '';
  Logger log = ReturnLogger.returnLogger();

  callback(name, label, day) {
    setState(() {
      selectedValueName = name;
      selectedValueLabel = label;
      selectedValueDay = day;
    });
  }

  MetricsAtLocationsViewModel viewModel =
      serviceLocator<MetricsAtLocationsViewModel>();

  int _current;

  @override
  void initState() {
    viewModel.getData();
    _current = 0;
    super.initState();
  }

  QueryResult data;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ChangeNotifierProvider<MetricsAtLocationsViewModel>(
      create: (context) => viewModel,
      child: Consumer<MetricsAtLocationsViewModel>(
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
                    log.i("Data is refreshed now");
                    if (selectedValueDay == null &&
                        selectedValueName == null &&
                        selectedValueLabel == null) {
                      setState(() {
                        log.i("Data is refreshed on null");
                        viewModel.getData();
                      });
                    } else if (selectedValueDay == null ||
                        selectedValueLabel == null ||
                        selectedValueName == null) {
                      log.i(
                          "Nothing refreshed since only partial fields are selected");
                    } else if (selectedValueDay == '' ||
                        selectedValueLabel == '' ||
                        selectedValueName == '') {
                      setState(() {
                        log.i("Initial data is refeteched on refresh");
                        viewModel.getData();
                      });
                    } else if (selectedValueDay.length > 0 &&
                        selectedValueName.length > 0 &&
                        selectedValueLabel.length > 0) {
                      setState(() {
                        log.i("The filtered data is refetched on refresh");
                        viewModel.getFilteredData(selectedValueDay,
                            selectedValueName, selectedValueLabel);
                        viewModel.getFilteredPieData(selectedValueDay,
                            selectedValueName, selectedValueLabel);
                      });
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
                              child: Column(
                                children: [
                                  Text(
                                    selectedValueDay == null ||
                                            selectedValueDay == ''
                                        ? 'Day: ${viewModel.preloadDay}'
                                        : 'Day: $selectedValueDay',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.87),
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    selectedValueDay == null ||
                                            selectedValueDay == ''
                                        ? 'Label: ${viewModel.preloadLabel}'
                                        : 'Label: $selectedValueLabel',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.87),
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    selectedValueDay == null ||
                                            selectedValueDay == ''
                                        ? 'Name: ${viewModel.preloadName}'
                                        : 'Name: $selectedValueName',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.87),
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
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
                                        viewModelMetrics: viewModel,
                                        callback: callback,
                                        id: "MetricsAtLocations"),
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
                          if (viewModel.hourlyData.length == 0) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height *
                                      0.25),
                              child: Text(
                                  'The requested data could not be found',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.88),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22.0)),
                            );
                          } else {
                            return CarouselSlider.builder(
                              itemCount: 2,
                              options: CarouselOptions(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
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
                                    width: MediaQuery.of(context).size.width *
                                        0.95,
                                    child: Card(
                                      color: Color(0xff121212),
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
                                              ],
                                            ),
                                            (() {
                                              if (itemIndex == 0) {
                                                return LineChartWidget(
                                                    primaryScore:
                                                        viewModel.hourlyData);
                                              } else if (itemIndex == 1) {
                                                return PieChartWidget(
                                                    pieData: viewModel.pieData,
                                                    pieDataTitles: viewModel
                                                        .pieDataTitles);
                                              }
                                            }())
                                          ],
                                        ),
                                      ),
                                      elevation: 5.0,
                                    ),
                                  ),
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
            );
          }
        },
      ),
    ));
  }
}
