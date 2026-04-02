import 'package:collection/collection.dart';
import 'package:trina_grid/trina_grid.dart';

/// 절대 위치 기반 스크롤 API
///
/// 기존 [ScrollState]의 [moveScrollByRow], [moveScrollByColumn]은
/// 키보드 네비게이션(한 칸씩 이동) 전용으로 설계되어 있어
/// direction 파라미터와 ±1 offset 보정이 필수였다.
///
/// 이 state는 direction 없이 대상 row/column의 절대 pixel 위치를 계산하여
/// 셀이 viewport 안에 **온전히** 보이도록 스크롤한다.
///
/// ## 기존 방식의 문제점
/// - [moveScrollByRow]: direction에 따라 rowIdx ± 1 위치를 계산하므로
///   임의 위치 점프 시 offset이 부정확
/// - [moveScrollByColumn]: `columnIdx + direction.offset`으로 인접 컬럼을 참조하므로
///   frozen column에 가려지는 문제 발생 → +1 편법 필요
///
/// ## 해결
/// - [scrollToRow]: row의 절대 top/bottom을 viewport와 비교하여 최소 스크롤
/// - [scrollToColumn]: column의 startPosition + width를 viewport와 비교,
///   frozen 영역을 정확히 차감하여 셀 우변까지 온전히 노출
/// - [scrollToCell]: 위 둘을 조합 + 선택적 포커스 설정
abstract class IScrollToState {
  /// 특정 row가 화면에 온전히 보이도록 세로 스크롤
  ///
  /// [row] 또는 [rowIdx] 중 하나를 전달한다.
  /// 둘 다 전달 시 [row]가 우선된다.
  ///
  /// ```dart
  /// stateManager.scrollToRow(rowIdx: 5);
  /// stateManager.scrollToRow(row: targetRow);
  /// ```
  void scrollToRow({TrinaRow? row, int? rowIdx});

  /// 특정 column이 화면에 온전히 보이도록 가로 스크롤
  ///
  /// [column], [field], [columnIdx] 중 하나를 전달한다.
  /// 우선순위: [column] > [field] > [columnIdx]
  /// frozen column이면 항상 보이므로 스크롤하지 않는다.
  ///
  /// ```dart
  /// stateManager.scrollToColumn(field: 'productName');
  /// stateManager.scrollToColumn(column: priceColumn);
  /// stateManager.scrollToColumn(columnIdx: 3);
  /// ```
  void scrollToColumn({TrinaColumn? column, String? field, int? columnIdx});

  /// row + column 스크롤을 한번에 처리
  ///
  /// [setCurrentCell]이 true이면 스크롤 후 해당 셀에 포커스까지 설정한다.
  ///
  /// ```dart
  /// // 스크롤만
  /// stateManager.scrollToCell(rowIdx: 5, field: 'price');
  ///
  /// // 스크롤 + 포커스
  /// stateManager.scrollToCell(rowIdx: 5, field: 'price', setCurrentCell: true);
  /// ```
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
  /// row 0부터 [targetIdx]-1까지의 height를 합산하여 대상 row의 top pixel 위치를 구하고,
  /// viewport 범위와 비교하여 최소한의 스크롤만 수행한다.
  ///
  /// - row가 viewport 위에 있으면: row top → viewport top
  /// - row가 viewport 아래에 있으면: row bottom → viewport bottom
  /// - 이미 온전히 보이면: 스크롤하지 않음
  @override
  void scrollToRow({TrinaRow? row, int? rowIdx}) {
    final targetIdx = row != null ? refRows.indexOf(row) : rowIdx;
    if (targetIdx == null || targetIdx < 0 || targetIdx >= refRows.length) {
      return;
    }
    if (scroll.bodyRowsVertical?.hasClients != true) return;

    // row의 top pixel 위치 계산 (각 row는 개별 height를 가질 수 있음)
    double rowTop = 0.0;
    for (int i = 0; i < targetIdx; i++) {
      rowTop += getRowHeight(i) + configuration.style.cellHorizontalBorderWidth;
    }
    final rowBottom = rowTop + getRowHeight(targetIdx);

    // viewport 범위 계산 (columnGroup, columnTitle, columnFilter 영역 제외)
    final viewportTop = scroll.verticalOffset;
    final viewportHeight = columnRowContainerHeight -
        columnGroupHeight -
        columnHeight -
        columnFilterHeight -
        configuration.style.cellHorizontalBorderWidth;
    final viewportBottom = viewportTop + viewportHeight;

    if (rowTop >= viewportTop && rowBottom <= viewportBottom) return;

    if (rowTop < viewportTop) {
      scroll.vertical!.jumpTo(rowTop);
    } else {
      scroll.vertical!.jumpTo(rowBottom - viewportHeight);
    }
  }

  /// column의 [startPosition]과 width로 좌변/우변을 구하고,
  /// frozen column 영역을 차감한 body viewport와 비교하여 스크롤한다.
  ///
  /// - column이 viewport 왼쪽에 있으면: column 좌변 → viewport 좌변
  /// - column이 viewport 오른쪽에 있으면: column 우변 → viewport 우변
  ///   (이때 [scrollOffsetByFrozenColumn]으로 frozen 경계 border 보정)
  /// - 이미 온전히 보이면: 스크롤하지 않음
  ///
  /// [startPosition]은 [VisibilityLayoutState.updateVisibilityLayout]에서
  /// body/left/right 영역별로 개별 계산된 값이다.
  @override
  void scrollToColumn({TrinaColumn? column, String? field, int? columnIdx}) {
    final targetColumn = column ??
        (field != null
            ? columns.firstWhereOrNull((c) => c.field == field)
            : null) ??
        (columnIdx != null && columnIdx >= 0 && columnIdx < columns.length
            ? columns[columnIdx]
            : null);

    if (targetColumn == null) return;
    if (maxWidth == null) return;
    if (scroll.bodyRowsHorizontal?.hasClients != true) return;
    if (showFrozenColumn && targetColumn.frozen.isFrozen) return;

    final colStart = targetColumn.startPosition;
    final colEnd = colStart + targetColumn.width;

    final viewportLeft = scroll.horizontalOffset;
    // body 영역의 가시 폭 = 전체 폭 - 좌우 frozen 영역
    final viewportWidth = showFrozenColumn
        ? maxWidth! - leftFrozenColumnsWidth - rightFrozenColumnsWidth
        : maxWidth!;
    final viewportRight = viewportLeft + viewportWidth;

    if (colStart >= viewportLeft && colEnd <= viewportRight) return;

    if (colStart < viewportLeft) {
      scroll.horizontal!.jumpTo(colStart);
    } else {
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
