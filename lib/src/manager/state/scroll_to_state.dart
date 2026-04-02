import 'package:collection/collection.dart';
import 'package:trina_grid/trina_grid.dart';

abstract class IScrollToState {
  /// 특정 row가 화면에 온전히 보이도록 세로 스크롤
  void scrollToRow({TrinaRow? row, int? rowIdx});

  /// 특정 column이 화면에 온전히 보이도록 가로 스크롤
  void scrollToColumn({TrinaColumn? column, String? field, int? columnIdx});

  /// row + column 스크롤을 한번에 처리
  /// [setCurrentCell] true이면 스크롤 후 해당 셀에 포커스까지 설정
  void scrollToCell({
    TrinaRow? row,
    int? rowIdx,
    TrinaColumn? column,
    String? field,
    int? columnIdx,
    bool setCurrentCell = false,
  });
}

mixin ScrollToState implements ITrinaGridState {
  @override
  void scrollToRow({TrinaRow? row, int? rowIdx}) {
    final targetIdx = row != null ? refRows.indexOf(row) : rowIdx;
    if (targetIdx == null || targetIdx < 0 || targetIdx >= refRows.length) {
      return;
    }
    if (scroll.bodyRowsVertical?.hasClients != true) return;

    // row의 top pixel 위치 계산
    double rowTop = 0.0;
    for (int i = 0; i < targetIdx; i++) {
      rowTop += getRowHeight(i) + configuration.style.cellHorizontalBorderWidth;
    }
    final rowBottom = rowTop + getRowHeight(targetIdx);

    final viewportTop = scroll.verticalOffset;
    final viewportHeight = columnRowContainerHeight -
        columnGroupHeight -
        columnHeight -
        columnFilterHeight -
        configuration.style.cellHorizontalBorderWidth;
    final viewportBottom = viewportTop + viewportHeight;

    // 이미 온전히 보이면 스킵
    if (rowTop >= viewportTop && rowBottom <= viewportBottom) return;

    if (rowTop < viewportTop) {
      // row가 viewport 위에 있음 → row top을 viewport top에 맞춤
      scroll.vertical!.jumpTo(rowTop);
    } else {
      // row가 viewport 아래에 있음 → row bottom을 viewport bottom에 맞춤
      scroll.vertical!.jumpTo(rowBottom - viewportHeight);
    }
  }

  @override
  void scrollToColumn({TrinaColumn? column, String? field, int? columnIdx}) {
    final targetColumn = column ??
        (field != null
            ? columns.firstWhereOrNull((c) => c.field == field)
            : null) ??
        (columnIdx != null &&
                columnIdx >= 0 &&
                columnIdx < columns.length
            ? columns[columnIdx]
            : null);

    if (targetColumn == null) return;
    if (maxWidth == null) return;
    if (scroll.bodyRowsHorizontal?.hasClients != true) return;
    // frozen column은 항상 보이므로 스크롤 불필요
    if (showFrozenColumn && targetColumn.frozen.isFrozen) return;

    final colStart = targetColumn.startPosition;
    final colEnd = colStart + targetColumn.width;

    final viewportLeft = scroll.horizontalOffset;
    final viewportWidth = showFrozenColumn
        ? maxWidth! - leftFrozenColumnsWidth - rightFrozenColumnsWidth
        : maxWidth!;
    final viewportRight = viewportLeft + viewportWidth;

    // 이미 온전히 보이면 스킵
    if (colStart >= viewportLeft && colEnd <= viewportRight) return;

    if (colStart < viewportLeft) {
      // column이 viewport 왼쪽에 있음 → column 좌변을 viewport 좌변에 맞춤
      scroll.horizontal!.jumpTo(colStart);
    } else {
      // column이 viewport 오른쪽에 있음 → column 우변을 viewport 우변에 맞춤
      scroll.horizontal!.jumpTo(
        colEnd - viewportWidth + scrollOffsetByFrozenColumn,
      );
    }
  }

  @override
  void scrollToCell({
    TrinaRow? row,
    int? rowIdx,
    TrinaColumn? column,
    String? field,
    int? columnIdx,
    bool setCurrentCell = false,
  }) {
    scrollToRow(row: row, rowIdx: rowIdx);
    scrollToColumn(column: column, field: field, columnIdx: columnIdx);

    if (!setCurrentCell) return;

    final targetRowIdx = row != null ? refRows.indexOf(row) : rowIdx;

    final targetField = field ??
        column?.field ??
        (columnIdx != null && columnIdx >= 0 && columnIdx < columns.length
            ? columns[columnIdx].field
            : null);

    if (targetRowIdx == null ||
        targetField == null ||
        targetRowIdx < 0 ||
        targetRowIdx >= refRows.length) {
      return;
    }

    final cell = refRows[targetRowIdx].cells[targetField];
    if (cell == null) return;

    this.setCurrentCell(cell, targetRowIdx, notify: true);
  }
}
