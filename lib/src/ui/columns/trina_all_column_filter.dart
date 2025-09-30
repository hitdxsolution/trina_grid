import 'package:trina_grid/src/manager/event/trina_grid_change_all_column_filter_event.dart';
import 'package:trina_grid/trina_grid.dart';

class TrinaAllColumnFilter {
  TrinaAllColumnFilter({required this.stateManager});

  final TrinaGridStateManager stateManager;

  void handleOnChanaged(String value) {
    stateManager.eventManager!.addEvent(
      TrinaGridChangeAllColumnFilterEvent(
        filterType: TrinaFilterTypeContains(),
        filterValue: value,
        eventType: TrinaGridEventType.debounce,
        debounceMilliseconds: stateManager.configuration.columnFilter.debounceMilliseconds,
      ),
    );
  }
}
