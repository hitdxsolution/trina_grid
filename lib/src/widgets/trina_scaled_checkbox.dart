import 'package:flutter/material.dart';

class TrinaScaledCheckbox extends StatelessWidget {
  final bool? value;

  final Function(bool? changed)? handleOnChanged;

  final bool tristate;

  final double scale;

  final Color unselectedColor;

  final Color? activeColor;

  final Color checkColor;

  final BorderSide? side;

  final double? checkBoxSize;

  final EdgeInsets? checkBoxPadding;

  const TrinaScaledCheckbox({
    super.key,
    required this.value,
    required this.handleOnChanged,
    this.tristate = false,
    this.scale = 1.0,
    this.unselectedColor = Colors.black26,
    this.activeColor = Colors.lightBlue,
    this.checkColor = const Color(0xFFDCF5FF),
    this.side,
    this.checkBoxSize,
    this.checkBoxPadding,
  });

  Widget _buildCheckboxSize({required Widget child}) {
    if (checkBoxSize == null) {
      return Transform.scale(
        scale: scale,
        child: child,
      );
    }

    return Container(
      alignment: Alignment.center,
      padding: checkBoxPadding,
      child: SizedBox(
        width: checkBoxSize,
        height: checkBoxSize,
        child:child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildCheckboxSize(
      child: Checkbox(
        hoverColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        value: value,
        tristate: tristate,
        onChanged: handleOnChanged,
        activeColor: value == null ? unselectedColor : activeColor,
        checkColor: checkColor,
        side: side,
      ),
    );
  }
}
