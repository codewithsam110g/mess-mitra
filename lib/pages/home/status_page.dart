import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final List<Map<String, dynamic>> categories = [
    {
      "title": "Neatness of surroundings",
      "subtitle": "Cleanliness issues",
      "data": {
        "Opened": 3.0,
        "In Progress": 2.0,
        "Solved": 5.0,
        "Unsolved": 1.0,
      }
    },
    {
      "title": "Timeliness of services",
      "subtitle": "Delays in service",
      "data": {
        "Opened": 2.0,
        "In Progress": 1.0,
        "Solved": 6.0,
        "Unsolved": 0.0,
      }
    },
    {
      "title": "Quantity",
      "subtitle": "Portion size issues",
      "data": {
        "Opened": 4.0,
        "In Progress": 0.0,
        "Solved": 3.0,
        "Unsolved": 2.0,
      }
    },
    {
      "title": "Quality",
      "subtitle": "Food quality complaints",
      "data": {
        "Opened": 1.0,
        "In Progress": 3.0,
        "Solved": 4.0,
        "Unsolved": 2.0,
      }
    },
    {
      "title": "Taste",
      "subtitle": "Taste-related feedback",
      "data": {
        "Opened": 0.0,
        "In Progress": 1.0,
        "Solved": 8.0,
        "Unsolved": 1.0,
      }
    },
  ];

  final Map<int, bool> isExpanded = {};

  @override
  Widget build(BuildContext context) {
    // Calculate totals for the "Total" category
    final Map<String, double> totalData = {
      "Opened": 0.0,
      "In Progress": 0.0,
      "Solved": 0.0,
      "Unsolved": 0.0,
    };

    for (var category in categories) {
      (category["data"] as Map<String, double>).forEach((key, value) {
        totalData[key] = totalData[key]! + value;
      });
    }

    // Total count of issues
    final double totalCount = totalData.values.reduce((a, b) => a + b);

    // Define chart colors
    final Map<String, Color> colorMap = {
      "Opened": Colors.grey,
      "In Progress": Colors.orange,
      "Solved": Colors.green,
      "Unsolved": Colors.red,
    };

    return Scaffold(
      backgroundColor: const Color.fromRGBO(199, 194, 245, 1),
      appBar: AppBar(
        title: const Text(
          'Status',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(89, 83, 141, 1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 64),
        child: Column(
          children: [
            // Total Widget
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Total Issues Summary",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        dataMap: totalData,
                        colorList: colorMap.values.toList(),
                        chartType: ChartType.disc,
                        chartRadius: MediaQuery.of(context).size.width / 3,
                        legendOptions: const LegendOptions(
                          showLegends: true,
                          legendPosition: LegendPosition.right,
                        ),
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValues: true,
                          showChartValuesInPercentage: false,
                          decimalPlaces: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Total Issues: ${totalCount.toInt()}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Individual Categories
            ...categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;

              // Total count for individual categories
              final double categoryTotal =
                  (category["data"] as Map<String, double>)
                      .values
                      .reduce((a, b) => a + b);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Title and toggle button
                      ListTile(
                        title: Text(
                          category["title"],
                          style: const TextStyle(fontSize: 20),
                        ),
                        subtitle: Text(
                          category["subtitle"],
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isExpanded[index] == true
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                          ),
                          onPressed: () {
                            setState(() {
                              isExpanded[index] =
                                  !(isExpanded[index] ?? false);
                            });
                          },
                        ),
                      ),
                      // Pie chart (visible only when expanded)
                      if (isExpanded[index] == true)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            height: 200,
                            child: PieChart(
                              dataMap: Map<String, double>.from(
                                  category["data"]),
                              colorList: colorMap.values.toList(),
                              chartType: ChartType.disc,
                              chartRadius:
                                  MediaQuery.of(context).size.width / 3,
                              legendOptions: const LegendOptions(
                                showLegends: true,
                                legendPosition: LegendPosition.right,
                              ),
                              chartValuesOptions: const ChartValuesOptions(
                                showChartValues: true,
                                showChartValuesInPercentage: false,
                                decimalPlaces: 0,
                              ),
                            ),
                          ),
                        ),
                      // Total issues text
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          "Total Issues: ${categoryTotal.toInt()}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
