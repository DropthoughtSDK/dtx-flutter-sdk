import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:logger/logger.dart';
import '../ViewModels/MetricsAtLocations_ViewModel.dart';
import '../ServiceLocator/service_locator.dart';
import 'package:provider/provider.dart';
import './High/LineChart.dart';
import './Low/DropDown.dart';
import 'package:carousel_slider/carousel_slider.dart';
import './High/PieChart.dart';
import '../UI/Low/Logger.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MetricsAtLocationsUI extends StatefulWidget {
  @override
  _MetricsAtLocationsUIState createState() => _MetricsAtLocationsUIState();
}

class _MetricsAtLocationsUIState extends State<MetricsAtLocationsUI> {
  String selectedValueName = '', selectedValueLabel = '', selectedValueDay = '';
  Logger log = ReturnLogger.returnLogger();

  callback(val, id) {
    setState(() {
      if (id == "names") {
        if (val == null) {
          setState(() {
            _visibleName = true;
          });
        } else {
          setState(() {
            _visibleName = false;
          });
        }
        selectedValueName = val;
      } else if (id == "labels") {
        if (val == null) {
          setState(() {
            _visibleLabel = true;
          });
        } else {
          setState(() {
            _visibleLabel = false;
          });
        }
        selectedValueLabel = val;
      } else if (id == "days") {
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

  MetricsAtLocationsViewModel viewModel =
      serviceLocator<MetricsAtLocationsViewModel>();
  bool _visibleDay, _visibleName, _visibleLabel;
  int _current;

  @override
  void initState() {
    _visibleDay = false;
    _visibleLabel = false;
    _visibleName = false;
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
                        _visibleLabel = false;
                        _visibleName = false;
                        _visibleDay = false;
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
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
                          child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              color: Color(0xff24292E),
                              elevation: 8.0,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    15.0, 5.0, 15.0, 5.0),
                                child: Column(children: [
                                  DropDownWidget(
                                      dropDownitems: viewModel.names,
                                      preLoadValue: viewModel.preloadName,
                                      callback: callback,
                                      id: "names"),
                                  Visibility(
                                    visible: _visibleName,
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
                                  DropDownWidget(
                                      dropDownitems: viewModel.labels,
                                      preLoadValue: viewModel.preloadLabel,
                                      callback: callback,
                                      id: "labels"),
                                  Visibility(
                                    visible: _visibleLabel,
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
                                    onPressed: (selectedValueLabel == null ||
                                            selectedValueLabel == '' ||
                                            selectedValueName == '' ||
                                            selectedValueDay == '' ||
                                            selectedValueName == null ||
                                            selectedValueDay == null)
                                        ? null
                                        : () {
                                            viewModel.getFilteredData(
                                                selectedValueDay,
                                                selectedValueName,
                                                selectedValueLabel);

                                            viewModel.getFilteredPieData(
                                                selectedValueDay,
                                                selectedValueName,
                                                selectedValueLabel);
                                          },
                                    child: Text('Apply Filters'),
                                    color: Colors.green[800],
                                  ),
                                ]),
                              )),
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
                                      MediaQuery.of(context).size.height * 0.65,
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
