import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/models/benchmark_result.dart';

class ComparisonChart extends StatelessWidget {
  final List<BenchmarkResult> results;

  const ComparisonChart({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Operations per Second',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildChart(context),
              ),
              const SizedBox(height: 8),
              _buildLegend(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY() * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Theme.of(context).colorScheme.surface,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final result = results[groupIndex];
              String value;
              switch (rodIndex) {
                case 0:
                  value = result.formattedWriteOpsPerSecond;
                  break;
                case 1:
                  value = result.formattedReadOpsPerSecond;
                  break;
                case 2:
                  value = result.formattedDeleteOpsPerSecond;
                  break;
                default:
                  value = '';
              }
              return BarTooltipItem(
                value,
                Theme.of(context).textTheme.bodyMedium!,
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value >= results.length || value < 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    results[value.toInt()].adapterDisplayName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: _getMaxY() / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).dividerColor,
              strokeWidth: 1,
            );
          },
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: _getBarGroups(),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(context, 'Write', Colors.blue),
        const SizedBox(width: 16),
        _buildLegendItem(context, 'Read', Colors.green),
        const SizedBox(width: 16),
        _buildLegendItem(context, 'Delete', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    final groups = <BarChartGroupData>[];
    
    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: result.writeOpsPerSecond,
              color: Colors.blue,
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: result.readOpsPerSecond,
              color: Colors.green,
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: result.deleteOpsPerSecond,
              color: Colors.red,
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }
    
    return groups;
  }

  double _getMaxY() {
    double maxY = 0;
    
    for (final result in results) {
      maxY = maxY > result.writeOpsPerSecond ? maxY : result.writeOpsPerSecond;
      maxY = maxY > result.readOpsPerSecond ? maxY : result.readOpsPerSecond;
      maxY = maxY > result.deleteOpsPerSecond ? maxY : result.deleteOpsPerSecond;
    }
    
    return maxY == 0 ? 100 : maxY;
  }
}
