import 'package:flutter/material.dart';

class TrinaShadowLine extends StatelessWidget {
  final Axis? axis;
  final bool? reverse;
  final Color? color;
  final bool? shadow;

  const TrinaShadowLine({
    this.axis,
    this.reverse,
    this.color,
    this.shadow,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: axis == Axis.vertical ? 1 : 0,
      height: axis == Axis.horizontal ? 1 : 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color ?? Colors.black,
          boxShadow: shadow == true
              ? [
                  //* boxshadow 스타일 custom하여 사용중.
                  BoxShadow(
                    color: Color(0xFF000000).withAlpha(25),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: reverse == true ? const Offset(-4, 0) : const Offset(4, 0), // changes position of shadow
                  ),
                ]
              : [],
        ),
      ),
    );
  }
}
