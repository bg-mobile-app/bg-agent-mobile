import 'package:flutter/material.dart';

class StyledDataTableCard extends StatelessWidget {
  const StyledDataTableCard({
    super.key,
    required this.columns,
    required this.rows,
    this.dataRowMaxHeight = 72,
    this.columnSpacing = 28,
  });

  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double dataRowMaxHeight;
  final double columnSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF12051B).withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 16),
            spreadRadius: -4,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFC3C6D7).withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Theme(
          data: Theme.of(
            context,
          ).copyWith(dividerColor: const Color(0xFFE5E7EB)),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F3FF)),
            dataRowColor: WidgetStateProperty.all(Colors.white),
            dividerThickness: 1,
            dataRowMaxHeight: dataRowMaxHeight,
            columnSpacing: columnSpacing,
            headingTextStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF434655),
              letterSpacing: 0.5,
            ),
            columns: columns,
            rows: rows,
          ),
        ),
      ),
    );
  }
}
