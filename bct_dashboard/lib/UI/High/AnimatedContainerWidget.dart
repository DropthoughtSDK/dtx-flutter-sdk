import 'package:animations/animations.dart';
import 'package:bct_dashboard/UI/Low/DropDown.dart';
import 'package:bct_dashboard/ViewModels/MetricsAtLocations_ViewModel.dart';
import 'package:bct_dashboard/ViewModels/NPSDetails_ViewModel.dart';
import 'package:flutter/material.dart';

class AnimatedContainerWidget extends StatefulWidget {
  final NPSDetailsViewModel viewModelNps;
  final MetricsAtLocationsViewModel viewModelMetrics;
  final Function(String, String, String) callback;
  final String id;

  AnimatedContainerWidget(
      {this.viewModelNps, this.callback, this.id, this.viewModelMetrics});
  @override
  _AnimatedContainerWidgetState createState() =>
      _AnimatedContainerWidgetState();
}

class _AnimatedContainerWidgetState extends State<AnimatedContainerWidget> {
  String selectedValueDay = '', selectedValueLabel = '', selectedValueName = '';
  callback(val, id, section) {
    if (id == "NPS Metrics") {
      setState(() {
        selectedValueDay = val;
      });
    } else if (id == "MetricsAtLocations") {
      if (section == "names") {
        setState(() {
          selectedValueName = val;
        });
      } else if (section == "labels") {
        setState(() {
          selectedValueLabel = val;
        });
      } else if (section == "days") {
        setState(() {
          selectedValueDay = val;
        });
      }
    }
  }

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedColor: Color(0xff121212),
      closedShape: RoundedRectangleBorder(),
      closedBuilder: (BuildContext _, VoidCallback openContainer) {
        return ClipOval(
          child: Material(
            color: Colors.green[800], // button color
            child: InkWell(
                splashColor: Colors.red[800], // inkwell color
                child: SizedBox(
                    width: 56, height: 56, child: Icon(Icons.filter_list)),
                onTap: openContainer),
          ),
        );
      },
      openBuilder: (BuildContext _, VoidCallback openContainer) {
        if (widget.id == "NPS Metrics") {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5.0, 30.0, 5.0, 0),
              child: Column(
                children: [
                  DropDownWidget(
                      dropDownitems: widget.viewModelNps.days,
                      preLoadValue: widget.viewModelNps.preloadDay.toString(),
                      callback: callback,
                      id: "NPS Metrics"),
                  SizedBox(
                    height: 10.0,
                  ),
                  RaisedButton(
                    disabledColor: Colors.grey[800],
                    onPressed: () {
                      widget.viewModelNps.getNPSMetricsDay(selectedValueDay);
                      widget.viewModelNps.getNPSMetrics(selectedValueDay);
                      widget.viewModelNps.getDistinctScores(selectedValueDay);
                      widget.viewModelNps.getPieChartData(selectedValueDay);
                      widget.callback(selectedValueDay, "NPS Metrics", "");
                      Navigator.pop(context);
                    },
                    child: Text('Apply Filters'),
                    color: Colors.green[800],
                  ),
                ],
              ),
            ),
          );
        } else if (widget.id == "MetricsAtLocations") {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5.0, 30.0, 5.0, 0.0),
              child: Column(children: [
                DropDownWidget(
                  dropDownitems: widget.viewModelMetrics.names,
                  preLoadValue: widget.viewModelMetrics.preloadName,
                  callback: callback,
                  id: "MetricsAtLocations",
                  section: "names",
                ),
                SizedBox(
                  height: 10.0,
                ),
                DropDownWidget(
                  dropDownitems: widget.viewModelMetrics.labels,
                  preLoadValue: widget.viewModelMetrics.preloadLabel,
                  callback: callback,
                  id: "MetricsAtLocations",
                  section: "labels",
                ),
                SizedBox(
                  height: 10.0,
                ),
                DropDownWidget(
                    dropDownitems: widget.viewModelMetrics.days,
                    preLoadValue: widget.viewModelMetrics.preloadDay.toString(),
                    callback: callback,
                    id: "MetricsAtLocations",
                    section: "days"),
                SizedBox(
                  height: 10.0,
                ),
                RaisedButton(
                  onPressed: () {
                    widget.viewModelMetrics.getFilteredData(selectedValueDay,
                        selectedValueName, selectedValueLabel);
                    widget.viewModelMetrics.getFilteredPieData(selectedValueDay,
                        selectedValueName, selectedValueLabel);
                    widget.callback(selectedValueName, selectedValueLabel,
                        selectedValueDay);
                    Navigator.pop(context);
                  },
                  child: Text('Apply Filters'),
                  color: Colors.green[800],
                ),
              ]),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
