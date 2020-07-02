import 'package:flutter/material.dart';

class SimpleDropDownWidget extends StatefulWidget {
  final List<DropdownMenuItem> items;
  final Function(String) callback;

  SimpleDropDownWidget({this.items, this.callback});
  @override
  _SimpleDropDownWidgetState createState() => _SimpleDropDownWidgetState();
}

class _SimpleDropDownWidgetState extends State<SimpleDropDownWidget> {
  String selectedValue;

  @override
  void initState() {
    selectedValue = widget.items[0].value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          child: DropdownButton(
            isDense: true,
            elevation: 8,
            dropdownColor: Colors.grey[900],
            iconEnabledColor: Colors.purple,
            value: selectedValue,
            items: widget.items,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            onChanged: (val) {
              setState(() {
                selectedValue = val;
                widget.callback(val);
              });
            },
          ),
        ),
      ],
    );
  }
}
