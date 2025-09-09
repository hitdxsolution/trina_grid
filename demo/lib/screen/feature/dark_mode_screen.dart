import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class DarkModeScreen extends StatefulWidget {
  static const routeName = 'feature/dark-mode';

  const DarkModeScreen({super.key});

  @override
  _DarkModeScreenState createState() => _DarkModeScreenState();
}

class _DarkModeScreenState extends State<DarkModeScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();

    // Create columns with selection and date/time types for testing popups
    columns.addAll([
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.number(),
        width: 80,
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
        width: 150,
      ),
      TrinaColumn(
        title: 'Status',
        field: 'status',
        type: TrinaColumnType.select(<String>[
          'Active',
          'Inactive',
          'Pending',
          'Completed',
          'Cancelled',
        ]),
        width: 120,
      ),
      TrinaColumn(
        title: 'Priority',
        field: 'priority',
        type: TrinaColumnType.select(<String>[
          'Low',
          'Medium',
          'High',
          'Critical',
        ]),
        width: 100,
      ),
      TrinaColumn(
        title: 'Date',
        field: 'date',
        type: TrinaColumnType.date(),
        width: 120,
      ),
      TrinaColumn(
        title: 'Time',
        field: 'time',
        type: TrinaColumnType.time(),
        width: 100,
      ),
      TrinaColumn(
        title: 'Amount',
        field: 'amount',
        type: TrinaColumnType.currency(),
        width: 120,
      ),
    ]);

    // Create sample rows
    rows.addAll([
      TrinaRow(cells: {
        'id': TrinaCell(value: 1),
        'name': TrinaCell(value: 'Project Alpha'),
        'status': TrinaCell(value: 'Active'),
        'priority': TrinaCell(value: 'High'),
        'date': TrinaCell(value: DateTime.now()),
        'time': TrinaCell(value: '09:30'),
        'amount': TrinaCell(value: 15000.50),
      }),
      TrinaRow(cells: {
        'id': TrinaCell(value: 2),
        'name': TrinaCell(value: 'Project Beta'),
        'status': TrinaCell(value: 'Pending'),
        'priority': TrinaCell(value: 'Medium'),
        'date': TrinaCell(value: DateTime.now().add(const Duration(days: 1))),
        'time': TrinaCell(value: '14:15'),
        'amount': TrinaCell(value: 8500.75),
      }),
      TrinaRow(cells: {
        'id': TrinaCell(value: 3),
        'name': TrinaCell(value: 'Project Gamma'),
        'status': TrinaCell(value: 'Completed'),
        'priority': TrinaCell(value: 'Low'),
        'date':
            TrinaCell(value: DateTime.now().subtract(const Duration(days: 2))),
        'time': TrinaCell(value: '11:45'),
        'amount': TrinaCell(value: 22000.00),
      }),
      TrinaRow(cells: {
        'id': TrinaCell(value: 4),
        'name': TrinaCell(value: 'Project Delta'),
        'status': TrinaCell(value: 'Inactive'),
        'priority': TrinaCell(value: 'Critical'),
        'date': TrinaCell(value: DateTime.now().add(const Duration(days: 3))),
        'time': TrinaCell(value: '16:20'),
        'amount': TrinaCell(value: 12500.25),
      }),
      TrinaRow(cells: {
        'id': TrinaCell(value: 5),
        'name': TrinaCell(value: 'Project Epsilon'),
        'status': TrinaCell(value: 'Cancelled'),
        'priority': TrinaCell(value: 'High'),
        'date':
            TrinaCell(value: DateTime.now().subtract(const Duration(days: 1))),
        'time': TrinaCell(value: '08:00'),
        'amount': TrinaCell(value: 5000.00),
      }),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Dark mode',
      topTitle: 'Dark mode',
      topContents: const [
        Text('Change the entire theme of the grid to Dark.'),
        SizedBox(height: 8),
        Text(
            'Click on Status, Priority, Date, or Time columns to test dark mode popups.'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/dark_mode_screen.dart',
        ),
      ],
      body: Theme(
        data: ThemeData.dark(),
        child: TrinaGrid(
          columns: columns,
          rows: rows,
          onChanged: (TrinaGridOnChangedEvent event) {
            print(event);
          },
          configuration: const TrinaGridConfiguration.dark(),
        ),
      ),
    );
  }
}
