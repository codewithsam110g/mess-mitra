import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:mess_mate/objects/complaint.dart';  // Import your Complaint class

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  List<Complaint> complaints = [];
  bool isLoading = true;
  Map<int, bool> isExpanded = {};  // Track expanded state for each category

  // Function to group complaints by category and status
  Map<String, Map<String, double>> groupComplaintsByCategory(List<Complaint> complaints) {
    Map<String, Map<String, double>> categoryData = {};

    for (var complaint in complaints) {
      String category = complaint.category;
      String statusLabel = complaint.getStatusLabel();

      // If the category doesn't exist in the map, initialize it
      if (!categoryData.containsKey(category)) {
        categoryData[category] = {
          "Created": 0.0,
          "In Progress": 0.0,
          "Solved": 0.0,
          "Unsolved": 0.0,
        };
      }

      // Increment the count of the respective status
      categoryData[category]![statusLabel] = categoryData[category]![statusLabel]! + 1;
    }

    return categoryData;
  }

  // Fetch data from Firebase
  Future<void> fetchComplaints() async {
    try {
      List<Complaint> fetchedComplaints = await Complaint.getAllComplaints();
      setState(() {
        complaints = fetchedComplaints;
        isLoading = false;
      });
    } catch (e) {
      // Handle errors here
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchComplaints(); // Fetch complaints from Firebase on page load
  }

  @override
  Widget build(BuildContext context) {
    // Group complaints by category and status
    final Map<String, Map<String, double>> categorizedData = groupComplaintsByCategory(complaints);

    // Define chart colors
    final Map<String, Color> colorMap = {
      "Created": Colors.grey,
      "In Progress": Colors.orange,
      "Solved": Colors.green,
      "Unsolved": Colors.red,
    };

    final categories = categorizedData.entries.toList();

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())  // Show loading indicator
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 64),
              child: Column(
                children: List.generate(categories.length, (index) {
                  final entry = categories[index];
                  final category = entry.key;
                  final data = entry.value;

                  // Total count for this category
                  final double categoryTotal = data.values.reduce((a, b) => a + b);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Category title with dropdown toggle
                          ListTile(
                            title: Text(
                              category,
                              style: const TextStyle(fontSize: 20),
                            ),
                            subtitle: const Text(
                              "Status of complaints",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isExpanded[index] == true
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                              ),
                              onPressed: () {
                                setState(() {
                                  isExpanded[index] = !(isExpanded[index] ?? false);
                                });
                              },
                            ),
                          ),
                          // Pie Chart and details (visible only when expanded)
                          if (isExpanded[index] == true)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SizedBox(
                                height: 200,
                                child: PieChart(
                                  dataMap: data,
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
                            ),
                          // Total issues text (always visible)
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
                }),
              ),
            ),
    );
  }
}
