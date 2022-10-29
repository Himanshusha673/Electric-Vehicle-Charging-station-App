import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../app_utils/app_functions.dart';
import '../app_utils/app_theme.dart';

List<Color> stopChargingScreenColors = [
  Colors.redAccent,
];

List<Color> dashboardScreenColors = [
  AppTheme.primaryColor,
];

class GraphData {
  static LineChartData stopChargingScreenGraph1({
    required BuildContext context,
    required Map details,
  }) {
    List graph1 = details['graph1'];
    var totalCount = 100;
    var maxX =
        (graph1.isNotEmpty) ? graph1.length - 1.toDouble() : 10.toDouble();
    List<FlSpot> spots = <FlSpot>[];
    spots.clear();
    if (graph1.isNotEmpty) {
      for (int index = 0; index < graph1.length; index++) {
        spots.add(
          FlSpot(
            index.toDouble(),
            getGraphPoints(
              totalCount: totalCount,
              value: graph1[index]['cum_time'],
            ),
          ),
        );
      }
    } else {
      spots.add(
        FlSpot(0, 0),
      );
    }
    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1.0,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) =>
              Theme.of(context).textTheme.headline6!.copyWith(
                    fontSize: 16,
                  ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return '0';
              case 1:
                return '1';
              case 2:
                return '2';
              case 3:
                return '3';
              case 4:
                return '4';
              case 5:
                return '5';
              case 6:
                return '6';
              case 7:
                return '7';
              case 8:
                return '8';
              case 9:
                return '9';
              case 10:
                return '10';
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) =>
              Theme.of(context).textTheme.headline6!.copyWith(
                    fontSize: 16,
                  ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return '0';
              case 1:
                return '1';
              case 2:
                return '2';
              case 3:
                return '3';
              case 4:
                return '4';
              case 5:
                return '5';
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).unselectedWidgetColor,
            width: 1,
            style: BorderStyle.solid,
          ),
          bottom: BorderSide(
            color: Theme.of(context).unselectedWidgetColor,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
      ),
      minX: 0,
      maxX: maxX,
      minY: 0,
      maxY: 5,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          colors: stopChargingScreenColors,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: false,
          ),
        ),
      ],
    );
  }

  static LineChartData stopChargingScreenGraph2({
    required BuildContext context,
    required Map details,
  }) {
    List graph2 = details['graph2'];
    var totalCount = 10000;
    var maxX =
        (graph2.isNotEmpty) ? graph2.length - 1.toDouble() : 10.toDouble();
    List<FlSpot> spots = <FlSpot>[];
    spots.clear();
    if (graph2.isNotEmpty) {
      for (int index = 0; index < graph2.length; index++) {
        spots.add(
          FlSpot(
            index.toDouble(),
            getGraphPoints(
              totalCount: totalCount,
              value: graph2[index]['value'],
            ),
          ),
        );
      }
    } else {
      spots.add(
        FlSpot(0, 0),
      );
    }

    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1.0,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) =>
              Theme.of(context).textTheme.headline6!.copyWith(
                    fontSize: 16,
                  ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return '0';
              case 1:
                return '1';
              case 2:
                return '2';
              case 3:
                return '3';
              case 4:
                return '4';
              case 5:
                return '5';
              case 6:
                return '6';
              case 7:
                return '7';
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) =>
              Theme.of(context).textTheme.headline6!.copyWith(
                    fontSize: 16,
                  ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return '0';
              case 1:
                return '1';
              case 2:
                return '2';
              case 3:
                return '3';
              case 4:
                return '4';
              case 5:
                return '5';
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).unselectedWidgetColor,
            width: 1,
            style: BorderStyle.solid,
          ),
          bottom: BorderSide(
            color: Theme.of(context).unselectedWidgetColor,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
      ),
      minX: 0,
      maxX: maxX,
      minY: 0,
      maxY: 5,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          colors: stopChargingScreenColors,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: false,
          ),
        ),
      ],
    );
  }

  static BarChartData dashboardScreenGraphByYear({
    required BuildContext context,
    required Map details,
  }) {
    List graph1 = details['graph1'];
    int totalCount = 150;
    List<BarChartGroupData> barGroups = [
      barChartGroupData(
        graph1: graph1,
        x: 1,
        totalCount: totalCount,
        value: graph1[0]['jan'],
      ),
      barChartGroupData(
        graph1: graph1,
        x: 2,
        totalCount: totalCount,
        value: graph1[1]['feb'],
      ),
      barChartGroupData(
        graph1: graph1,
        x: 3,
        totalCount: totalCount,
        value: graph1[2]['mar'],
      ),
      barChartGroupData(
        graph1: graph1,
        x: 4,
        totalCount: totalCount,
        value: graph1[3]['apr'],
      ),
      barChartGroupData(
        graph1: graph1,
        x: 5,
        totalCount: totalCount,
        value: graph1[4]['may'],
      ),
      barChartGroupData(
        graph1: graph1,
        x: 6,
        totalCount: totalCount,
        value: graph1[5]['jun'],
      ),
      barChartGroupData(
        graph1: graph1,
        x: 7,
        totalCount: totalCount,
        value: graph1[6]['jul'],
      ),
      barChartGroupData(
        graph1: graph1,
        x: 8,
        totalCount: totalCount,
        value: graph1[7]['aug'],
      ),
      barChartGroupData(
        graph1: graph1,
        x: 9,
        totalCount: totalCount,
        value: graph1[8]['sep'],
      ),
      barChartGroupData(
        graph1: graph1,
        x: 10,
        totalCount: totalCount,
        value: graph1[9]['oct'],
      ),
      barChartGroupData(
        graph1: graph1,
        x: 11,
        totalCount: totalCount,
        value: graph1[10]['nov'],
      ),
      barChartGroupData(
        graph1: graph1,
        x: 12,
        totalCount: totalCount,
        value: graph1[11]['dec'],
      ),
    ];
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 5,
      barTouchData: BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: const EdgeInsets.all(0),
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.y.round().toString(),
              Theme.of(context).textTheme.bodyText2!,
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) =>
              Theme.of(context).textTheme.headline6!.copyWith(
                    fontSize: 10,
                  ),
          margin: 8,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 1:
                return 'JAN'; //"1"; //"JAN";
              case 2:
                return '2'; //"FEB";
              case 3:
                return '3'; //'MAR';
              case 4:
                return '4'; //'APR';
              case 5:
                return '5'; //'MAY';
              case 6:
                return '6'; //'JUN';
              case 7:
                return '7'; //'JUL';
              case 8:
                return '8'; //'AUG';
              case 9:
                return '9'; //'SEP';
              case 10:
                return '10'; //'OCT';
              case 11:
                return '11'; //'NOV';
              case 12:
                return '12'; //'DEC';
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) =>
              Theme.of(context).textTheme.headline6!.copyWith(
                    fontSize: 16,
                  ),
          margin: 8,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 0:
                return '0';
              case 1:
                return '1';
              case 2:
                return '2';
              case 3:
                return '3';
              case 4:
                return '4';
              case 5:
                return '5';
              default:
                return '';
            }
          },
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: barGroups,
    );
  }

  static BarChartGroupData barChartGroupData({
    required List graph1,
    required int x,
    required int totalCount,
    required dynamic value,
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
            y: getGraphPoints(
              totalCount: totalCount,
              value: roundDouble(double.parse(value.toString())),
            ),
            colors: dashboardScreenColors)
      ],
      // showingTooltipIndicators: [1],
    );
  }
}
