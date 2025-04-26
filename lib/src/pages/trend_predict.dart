import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'home.dart'; // Navigate back to home

/// A simple model to hold each data point with a day and a value.
class DataPoint {
  final double day;
  final double value;

  DataPoint({required this.day, required this.value});
}

/// Computes the linear regression (slope and intercept) for a list of data points.
Map<String, double> computeLinearRegression(List<DataPoint> dataPoints) {
  final n = dataPoints.length;
  final sumX = dataPoints.fold(0.0, (sum, dp) => sum + dp.day);
  final sumY = dataPoints.fold(0.0, (sum, dp) => sum + dp.value);
  final meanX = sumX / n;
  final meanY = sumY / n;

  double numerator = 0;
  double denominator = 0;
  for (final dp in dataPoints) {
    numerator += (dp.day - meanX) * (dp.value - meanY);
    denominator += (dp.day - meanX) * (dp.day - meanX);
  }

  final slope = denominator == 0 ? 0 : numerator / denominator;
  final intercept = meanY - slope * meanX;
  return {"slope": slope, "intercept": intercept};
}

/// A page that shows a line chart with actual data points and a predicted trend line.
class TrendPredictionPage extends StatefulWidget {
  const TrendPredictionPage({Key? key}) : super(key: key);

  @override
  _TrendPredictionPageState createState() => _TrendPredictionPageState();
}

class _TrendPredictionPageState extends State<TrendPredictionPage> {
  // Sample data representing, for example, a metric measured over days.
  final List<DataPoint> actualData = [
    DataPoint(day: 1, value: 50),
    DataPoint(day: 2, value: 55),
    DataPoint(day: 3, value: 53),
    DataPoint(day: 4, value: 60),
    DataPoint(day: 5, value: 58),
    DataPoint(day: 6, value: 65),
    DataPoint(day: 7, value: 63),
  ];

  late double slope;
  late double intercept;
  late List<DataPoint> predictedData;

  @override
  void initState() {
    super.initState();
    // Calculate the linear regression parameters from the actualData.
    final regression = computeLinearRegression(actualData);
    slope = regression["slope"]!;
    intercept = regression["intercept"]!;

    // Generate predicted data for the next 3 days.
    // We include the last actual point to make a continuous transition.
    predictedData = [];
    final lastDay = actualData.last.day;
    
    for (int i = 0; i < 4; i++) {
      final day = lastDay + i;
      final predictedValue = intercept + slope * day;
      predictedData.add(DataPoint(day: day, value: predictedValue));
    }
  }

  List<FlSpot> getActualSpots() {
    return actualData
        .map((dp) => FlSpot(dp.day, dp.value))
        .toList();
  }

  List<FlSpot> getPredictedSpots() {
    return predictedData
        .map((dp) => FlSpot(dp.day, dp.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Predicted Trends', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.redAccent),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
        ],
      ),
      //I added some code to let user come back to homepage
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (context, _) =>
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (context, _) =>
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    // Actual data line
                    LineChartBarData(
                      spots: getActualSpots(),
                      isCurved: true,
                      colors: [Colors.greenAccent],
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                    // Predicted trend line (dashed line)
                    LineChartBarData(
                      spots: getPredictedSpots(),
                      isCurved: true,
                      colors: [Colors.redAccent],
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 4,
                          color: Colors.redAccent,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        ),
                      ),
                      // You can simulate a dashed line by using intervals with spacing in a more advanced implementation.
                      dashArray: [8, 4],
                    ),
                  ],
                  minX: actualData.first.day,
                  maxX: predictedData.last.day,
                  minY: (actualData.map((dp) => dp.value).reduce((a, b) => a < b ? a : b)) * 0.9,
                  maxY: (actualData.map((dp) => dp.value).reduce((a, b) => a > b ? a : b)) * 1.1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Regression Line: y = ${intercept.toStringAsFixed(2)} + ${slope.toStringAsFixed(2)}x',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
