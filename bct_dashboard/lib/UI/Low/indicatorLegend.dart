import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;
  final FontWeight fontWeight;

  const Indicator(
      {Key key,
      this.color,
      this.text,
      this.isSquare,
      this.size = 15,
      this.textColor = const Color(0xff505050),
      this.fontWeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 3,
        ),
        Text(
          text,
          style:
              TextStyle(fontSize: 13, fontWeight: fontWeight, color: textColor),
        ),
        const SizedBox(
          width: 3,
        )
      ],
    );
  }
}
