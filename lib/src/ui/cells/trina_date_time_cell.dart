import 'package:flutter/material.dart';
import 'package:trina_grid/src/ui/widgets/trina_date_picker.dart';
import 'package:trina_grid/src/ui/miscellaneous/trina_popup_cell_state_with_custom_popup.dart';
import 'package:trina_grid/src/ui/widgets/trina_time_picker.dart';
import 'package:trina_grid/trina_grid.dart';

import 'popup_cell.dart';

class TrinaDateTimeCell extends StatefulWidget implements PopupCell {
  @override
  final TrinaGridStateManager stateManager;

  @override
  final TrinaCell cell;

  @override
  final TrinaColumn column;

  @override
  final TrinaRow row;

  const TrinaDateTimeCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  TrinaDateTimeCellState createState() => TrinaDateTimeCellState();
}

class TrinaDateTimeCellState
    extends TrinaPopupCellStateWithCustomPopup<TrinaDateTimeCell> {
  @override
  IconData? get popupMenuIcon => widget.column.type.dateTime.popupIcon;

  @override
  late final Widget popupContent;

  TrinaColumnTypeDateTime get _column => widget.column.type.dateTime;

  late final _dateTimeIsValidNotifier = ValueNotifier<bool>(true);

  /// The selected date and time
  late DateTime? dateTime;

  bool _isTimeValid = true;

  bool isDateTimeInRange(DateTime? initialDateTime) {
    if (initialDateTime == null) return false;

    final startDate = _column.startDate;
    final endDate = _column.endDate;

    final isAfterStart =
        startDate == null || !initialDateTime.isBefore(startDate);
    final isBeforeEnd = endDate == null || !initialDateTime.isAfter(endDate);

    return isAfterStart && isBeforeEnd;
  }

  void onDateChanged(DateTime date) {
    dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      dateTime?.hour ?? 0,
      dateTime?.minute ?? 0,
    );
    updateValidationState();
  }

  void onTimeChanged(TimeOfDay time) {
    final baseDate = dateTime ?? _column.startDate ?? DateTime.now();
    dateTime = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      time.hour,
      time.minute,
    );
    updateValidationState();
  }

  void onTimeValidationChanged(bool isValid) {
    _isTimeValid = isValid;
    updateValidationState();
  }

  void updateValidationState() {
    _dateTimeIsValidNotifier.value =
        isDateTimeInRange(dateTime) && _isTimeValid;
  }

  void onOkPressed() {
    if (dateTime != null) {
      handleSelected(_column.dateFormat.format(dateTime!));
    }
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _dateTimeIsValidNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    dateTime = _getInitialDateTime();
    _dateTimeIsValidNotifier.value = isDateTimeInRange(dateTime);

    popupContent = _PopupContent(
      onDateChanged: onDateChanged,
      onTimeChanged: onTimeChanged,
      onOkPressed: onOkPressed,
      initialDateTime: dateTime,
      startDate: _column.startDate,
      endDate: _column.endDate,
      dateTimeIsValidNotifier: _dateTimeIsValidNotifier,
      onTimeValidationChanged: onTimeValidationChanged,
    );
    // It's important to call super.initState() after initializing [popupContent]
    // because it's used in the super class `initState()`.
    super.initState();
  }

  DateTime? _getInitialDateTime() {
    var initialDateTime = _column.dateFormat.tryParse(widget.cell.value);

    if (initialDateTime != null && isDateTimeInRange(initialDateTime)) {
      return initialDateTime;
    }

    final now = DateTime.now();
    if (isDateTimeInRange(now)) {
      return now;
    }

    if (_column.startDate != null && isDateTimeInRange(_column.startDate)) {
      return _column.startDate;
    }

    return null;
  }
}

class _PopupContent extends StatelessWidget {
  final void Function(DateTime) onDateChanged;
  final void Function(TimeOfDay) onTimeChanged;
  final void Function(bool) onTimeValidationChanged;
  final VoidCallback onOkPressed;
  final DateTime? initialDateTime;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueNotifier<bool> dateTimeIsValidNotifier;

  const _PopupContent({
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onOkPressed,
    required this.initialDateTime,
    required this.startDate,
    required this.endDate,
    required this.dateTimeIsValidNotifier,
    required this.onTimeValidationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, parentConstraints) {
        final screenSize = MediaQuery.of(context).size;
        final showAsVertical = screenSize.width < 640;
        final popupConstraints = showAsVertical
            ? const BoxConstraints(
                maxWidth: 330,
                maxHeight: 530,
                minHeight: 440,
              )
            : const BoxConstraints(maxWidth: 560, maxHeight: 360);

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: popupConstraints,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Flex(
                    direction: showAsVertical ? Axis.vertical : Axis.horizontal,
                    children: [
                      SizedBox(
                        width: 300,
                        height: 330,
                        child: TrinaDatePicker(
                          onDateChanged: onDateChanged,
                          initialDate: initialDateTime,
                          firstDate: startDate,
                          lastDate: endDate,
                        ),
                      ),
                      if (showAsVertical)
                        const Divider(color: Colors.black26)
                      else
                        const VerticalDivider(width: 10, color: Colors.black26),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TrinaTimePicker(
                            autoFocusMode: TrinaTimePickerAutoFocusMode.none,
                            initialTime: initialDateTime != null
                                ? TimeOfDay.fromDateTime(initialDateTime!)
                                : const TimeOfDay(hour: 0, minute: 0),
                            onChanged: onTimeChanged,
                            onValidationChanged: onTimeValidationChanged,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 10),
                        ValueListenableBuilder(
                          valueListenable: dateTimeIsValidNotifier,
                          builder: (context, value, _) {
                            return TextButton(
                              onPressed: value ? onOkPressed : null,
                              child: const Text('OK'),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
