import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:mess_mate/objects/complaint.dart'; // Import your Complaint class
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mess_mate/objects/user.dart' as _User;

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  List<Complaint> complaints = [];
  bool isLoading = true;
  Map<int, bool> isExpanded = {}; // Track expanded state for each category

  // Function to group complaints by category and status
  Map<String, Map<String, double>> groupComplaintsByCategory(
      List<Complaint> complaints) {
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
          "Re Raised": 0.0,
        };
      }

      // Increment the count of the respective status
      categoryData[category]![statusLabel] =
          categoryData[category]![statusLabel]! + 1;
    }

    return categoryData;
  }

  Future<_User.User?> getCurrentUser() async {
    return await _User.UserService()
        .fetchUserByUID(FirebaseAuth.instance.currentUser!.uid);
  }

  // Fetch data from Firebase
  Future<void> fetchComplaints() async {
    try {
      // Assuming you have a method to get the current user details
      final currentUser =
          await getCurrentUser(); // Implement this as per your auth system
      final authType = currentUser?.accountType; // Example field for auth type
      final userMess = currentUser?.mess; // Example field for user's mess

      // Fetch all complaints
      List<Complaint> fetchedComplaints = await Complaint.getAllComplaints();

      // Filter complaints based on user's auth type
      if (authType == "mcor") {
        fetchedComplaints = fetchedComplaints
            .where((complaint) => complaint.mess == userMess)
            .toList();
      }

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

  String? groupBy;
  bool isFetchingUser = true;

  Future<void> determineGroupBy() async {
    try {
      final currentUser = await getCurrentUser();
      setState(() {
        groupBy = (currentUser?.accountType == "mcom") ? "mess" : "category";
        isFetchingUser = false;
      });
    } catch (e) {
      setState(() {
        isFetchingUser = false;
      });
      // Handle errors as needed
      print("Error fetching user: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchComplaints(); // Fetch complaints from Firebase on page load
    determineGroupBy();
  }

  Widget bodyWidget(
      BuildContext context,
      bool isLoading,
      List<MapEntry<String, Map<String, double>>> categories,
      Map<int, bool> isExpanded,
      Map<String, Color> colorMap) {
    // Calculate totals per category for the "Total" card
    final totalData = {
      for (var entry in categories)
        entry.key: entry.value.values.reduce((a, b) => a + b)
    };

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 64),
            child: Column(
              children: [
                // "Total" Card (Always Expanded)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFF), // Slight blue tint
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE0E0E0), // Light border
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        const ListTile(
                          title: Text(
                            "Total",
                            style: TextStyle(fontSize: 20),
                          ),
                          subtitle: Text(
                            "Overview of all categories",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            height: 200,
                            child: PieChart(
                              dataMap: totalData,
                              chartType: ChartType.disc,
                              chartRadius:
                                  MediaQuery.of(context).size.width / 3,
                              legendOptions: const LegendOptions(
                                showLegends: true,
                                legendPosition: LegendPosition.right,
                                legendTextStyle: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              chartValuesOptions: const ChartValuesOptions(
                                showChartValues: true,
                                showChartValuesInPercentage: false,
                                decimalPlaces: 0,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            "Total Issues: ${totalData.values.reduce((a, b) => a + b).toInt()}",
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
                ),
                // Dynamically Generated Category Cards
                ...List.generate(categories.length, (index) {
                  final entry = categories[index];
                  final category = entry.key;
                  final data = entry.value;

                  // Total count for this category
                  final double categoryTotal =
                      data.values.reduce((a, b) => a + b);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(
                            0xFFF8FAFF), // Almost white with a very slight blue tint
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(
                              0xFFE0E0E0), // Light border for elevation effect
                          width: 1.5,
                        ),
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
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isExpanded[index] == true
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                              ),
                              onPressed: () {
                                // Update expansion state
                                setState(() {
                                  isExpanded[index] =
                                      !(isExpanded[index] ?? false);
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
              ],
            ),
          );
  }

  // Function to group complaints dynamically based on a property
  Map<String, Map<String, double>> groupComplaints(
      List<Complaint> complaints, String groupBy) {
    Map<String, Map<String, double>> groupedData = {};

    for (var complaint in complaints) {
      String key = groupBy == 'mess' ? complaint.mess : complaint.category;
      String statusLabel = complaint.getStatusLabel();

      // If the group doesn't exist in the map, initialize it
      if (!groupedData.containsKey(key)) {
        groupedData[key] = {
          "Created": 0.0,
          "In Progress": 0.0,
          "Solved": 0.0,
          "Unsolved": 0.0,
          "Re Raised": 0.0,
        };
      }

      // Increment the count of the respective status
      groupedData[key]![statusLabel] = groupedData[key]![statusLabel]! + 1;
    }

    return groupedData;
  }

  @override
  Widget build(BuildContext context) {
    if (isFetchingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Group complaints based on `groupBy`
    final Map<String, Map<String, double>> groupedData =
        groupComplaints(complaints, groupBy ?? "category");

    // Define chart colors
    final Map<String, Color> colorMap = {
      "Created": Colors.grey,
      "In Progress": Colors.orange,
      "Solved": Colors.green,
      "Unsolved": Colors.red,
      "Re Raised": Colors.blue,
    };

    final categories = groupedData.entries.toList();

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 18.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  Text(
                    "Reports",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Expanded white section with list tiles
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: bodyWidget(
                        context, isLoading, categories, isExpanded, colorMap)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
