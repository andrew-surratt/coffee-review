import 'package:coffee_review/components/scaffold.dart';
import 'package:coffee_review/providers/compare_coffees.dart';
import 'package:coffee_review/repositories/ratings.dart';
import 'package:coffee_review/services/finance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/coffee.dart';
import 'coffees.dart';

enum MenuItem { clearComparison }

class ComparisonChart extends ConsumerWidget {
  final List<ChartComponent> chartComponents;

  const ComparisonChart({super.key, required this.chartComponents});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = Theme.of(context);

    var compareCoffeesNotifier = ref.watch(compareCoffeesProvider);
    if(kDebugMode) {
      print({"Using coffees for chart:", compareCoffeesNotifier.state});
    }

    return ScaffoldBuilder(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 100,child:
                Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(children: [Text(
                        'Opportunity Cost Of Coffee Over Time',
                        style: themeData.textTheme.titleMedium,
                      ),
                      Text(
                        "Shows potentially what the money spent on each coffee would become over time,"
                        " assuming average yearly stock market returns (${(sp500AvgYearlyReturn * 100).truncate()}%),"
                        " and average of $defaultNumberOfOzPerDay oz coffee per day",
                        style: themeData.textTheme.bodySmall,
                      ),
                    ])
                )
              ),
            Expanded(child:
            buildChartBody(
            flBorderData: buildFlBorderData(themeData),
            themeData: themeData,
            context: context,
            chartComponent: chartComponents,
            coffeeData: compareCoffeesNotifier.state)
            )]),
        appBarActions: [
          PopupMenuButton<MenuItem>(
            onSelected: (MenuItem i) {
              switch (i) {
                case MenuItem.clearComparison:
                  ref.read(compareCoffeesProvider).clearCoffees();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Coffees()),
                  );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<MenuItem>(
                  value: MenuItem.clearComparison,
                  child: Text('Clear compared coffees'),
                ),
              ];
            },
          ),
        ]
        );
  }

  Padding buildChartBody(
      {required FlBorderData flBorderData,
      required ThemeData themeData,
      required BuildContext context,
      required List<ChartComponent> chartComponent,
      required List<CoffeeWithRating> coffeeData}) {
    LineTouchData lineTouchData = buildLineTouchData(themeData, coffeeData);
    LineChart lineChart = buildLineChart(
        lineTouchData: lineTouchData,
        flBorderData: buildFlBorderData(themeData),
        themeData: themeData,
        context: context,
        chartComponent: chartComponents,
        coffeeData: coffeeData);
    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 40, 20), child: lineChart);
  }
}

class ChartComponent {
  ComponentName componentName;

  ChartComponent(this.componentName);
}

enum ComponentName {
  price,
  rating,
}

LineChart buildLineChart(
    {required LineTouchData lineTouchData,
    required FlBorderData flBorderData,
    required ThemeData themeData,
    required BuildContext context,
    required List<ChartComponent> chartComponent,
    required List<CoffeeWithRating> coffeeData}) {
  List<LineChartBarData> data = coffeeData.map((e) {
    LineChartBarData data = createLineData(e.coffee.costPerOz, Colors.green);
    double? rating = e.rating?.rating;
    const maxAlpha = 255;
    const minAlpha = 100;
    const maxRating = 10;
    return data.copyWith(
      color:
          chartComponent.any((c) => c.componentName == ComponentName.rating) &&
                  rating != null
              ? data.color?.withAlpha(
                  (rating * (maxAlpha - minAlpha) / maxRating + minAlpha)
                      .truncate())
              : data.color,
    );
  }).toList();

  const double chartYLabelDivisions = 1000;
  double maxYValue = data
      .map((e) => e.spots.reduce((value, element) => element.y > value.y ? element : value).y)
      .fold(chartYLabelDivisions, (value, element) => element > value ? element : value);
  var maxYLabel = maxYValue * 1.5;
  return LineChart(LineChartData(
      minX: 0,
      maxX: 10,
      minY: 0,
      maxY: maxYLabel - (maxYLabel % chartYLabelDivisions),
      lineTouchData: lineTouchData,
      titlesData: buildFlTitlesData(themeData, context),
      borderData: flBorderData,
      gridData: const FlGridData(show: false),
      lineBarsData: data));
}

FlBorderData buildFlBorderData(ThemeData themeData) {
  return FlBorderData(
    show: true,
    border: Border(
      bottom: BorderSide(color: themeData.primaryColorDark),
      left: BorderSide(color: themeData.primaryColorDark),
      right: const BorderSide(color: Colors.transparent),
      top: const BorderSide(color: Colors.transparent),
    ),
  );
}

FlTitlesData buildFlTitlesData(ThemeData themeData, BuildContext context) {
  return FlTitlesData(
    bottomTitles: AxisTitles(
      axisNameWidget: Text(
        'Time (years)',
        style: themeData.textTheme.labelMedium,
      ),
      sideTitles: getXTitles(context),
    ),
    rightTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    leftTitles: AxisTitles(
      axisNameWidget: Text(
        'Ending Balance (\$k)',
        style: themeData.textTheme.labelMedium,
      ),
      sideTitles: getYTitles(context),
    ),
  );
}

LineTouchData buildLineTouchData(ThemeData themeData, List<CoffeeWithRating> coffeeData) {
  return LineTouchData(
    handleBuiltInTouches: true,
    touchTooltipData: LineTouchTooltipData(
        maxContentWidth: 300,
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots.map((LineBarSpot touchedSpot) {
            var coffeeDataSelected = coffeeData[touchedSpot.barIndex % 4];
            return LineTooltipItem(
                "${coffeeDataSelected.coffee.name} \$${touchedSpot.y.toString()} (\$${coffeeDataSelected.coffee.costPerOz}/oz)",
                TextStyle(
                  color: touchedSpot.bar.gradient?.colors.first ??
                      touchedSpot.bar.color ??
                      themeData.colorScheme.primary,
                ));
          }).toList();
        }),
  );
}

SideTitles getYTitles(BuildContext context) {
  const double interval = 1000;
  return getSideTitles(
      interval: interval,
      context: context,
      reservedSize: 30,
      getTitleText: (double value, BuildContext context) => Text(
          (value ~/ interval).toInt().toString(),
          style: Theme.of(context).textTheme.labelMedium));
}

SideTitles getXTitles(BuildContext context) {
  return getSideTitles(
      context: context,
      reservedSize: 30,
      getTitleText: (double value, BuildContext context) => Text(
          value.toInt().toString(),
          style: Theme.of(context).textTheme.labelMedium));
}

SideTitles getSideTitles({
  required BuildContext context,
  required Text Function(double, BuildContext) getTitleText,
  double interval = 1,
  double reservedSize = 50,
}) {
  return SideTitles(
      showTitles: true,
      reservedSize: reservedSize,
      interval: interval,
      getTitlesWidget: (double value, TitleMeta meta) {
        return SideTitleWidget(
          meta: meta,
          child: getTitleText(value, context),
        );
      });
}
