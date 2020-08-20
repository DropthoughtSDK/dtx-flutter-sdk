import 'package:flutter/material.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class DropDownWidget extends StatefulWidget {
  final List<DropdownMenuItem> dropDownitems;
  final String preLoadValue;
  final Function(String, String, String) callback;
  final String id;
  final String section;

  DropDownWidget(
      {this.dropDownitems,
      this.preLoadValue,
      this.callback,
      this.id,
      this.section});
  @override
  _DropDownWidgetState createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget> {
  String selectedValue;

  @override
  void initState() {
    selectedValue = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SearchableDropdown.single(
      iconEnabledColor: Colors.redAccent,
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      items: widget.dropDownitems,
      menuBackgroundColor: Colors.grey[300],
      value: selectedValue,
      hint: Text(
        widget.preLoadValue,
        style: TextStyle(color: Color(0xff9C9C9C), fontWeight: FontWeight.w600),
      ),
      searchHint: "Select any one of the options",
      onChanged: (text) {
        setState(() {
          selectedValue = text;
          widget.callback(selectedValue, widget.id, widget.section);
        });
      },
      doneButton: "Done",
      displayItem: (item, selected) {
        return (Row(children: [
          selected
              ? Icon(
                  Icons.radio_button_checked,
                  color: Colors.red,
                )
              : Icon(
                  Icons.radio_button_unchecked,
                  color: Colors.black,
                ),
          SizedBox(width: 5),
          Expanded(
            child: item,
          ),
        ]));
      },
      isExpanded: true,
    );
  }
}
