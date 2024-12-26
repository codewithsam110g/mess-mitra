import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_mate/objects/complaint.dart'; // Ensure this import path is correct
import 'package:mess_mate/pages/show_complaints.dart';

class GlobalComplaints extends StatefulWidget {
  const GlobalComplaints({super.key});

  @override
  State<GlobalComplaints> createState() => _GlobalComplaintsState();
}

class _GlobalComplaintsState extends State<GlobalComplaints> {
  late Future<Map<String, Map<String, List<Complaint>>>>
      complaintsByCategoryFuture;

  final List<Color> categoryColors = [
    Colors.orange.shade400,
    Colors.green,
    Colors.purple,
    Colors.deepPurple,
    Colors.blue.shade700,
  ];

  @override
  void initState() {
    super.initState();
    complaintsByCategoryFuture = _fetchComplaintsByCategoryAndDate();
  }

  Future<Map<String, Map<String, List<Complaint>>>>
      _fetchComplaintsByCategoryAndDate() async {
    final complaints = await Complaint.getAllComplaints();

    // Sort complaints by time (latest first)
    complaints.sort((a, b) =>
        DateTime.parse(b.raisedAt).compareTo(DateTime.parse(a.raisedAt)));

    final Map<String, Map<String, List<Complaint>>> groupedComplaints = {};

    for (var complaint in complaints) {
      // Group by category
      if (!groupedComplaints.containsKey(complaint.category)) {
        groupedComplaints[complaint.category] = {};
      }

      // Group by date (formatted as "yyyy-MM-dd")
      final dateKey =
          DateFormat('yyyy-MM-dd').format(DateTime.parse(complaint.raisedAt));
      if (!groupedComplaints[complaint.category]!.containsKey(dateKey)) {
        groupedComplaints[complaint.category]![dateKey] = [];
      }
      groupedComplaints[complaint.category]![dateKey]!.add(complaint);
    }

    return groupedComplaints;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const Text(
                    "Complaints Raised",
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
                child: FutureBuilder<Map<String, Map<String, List<Complaint>>>>(
                  future: complaintsByCategoryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    final complaintsByCategory = snapshot.data ?? {};

                    if (complaintsByCategory.isEmpty) {
                      return const Center(
                        child: Text(
                          'No complaints available',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      );
                    }

                    final categories = complaintsByCategory.keys.toList();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final complaintsByDate =
                              complaintsByCategory[category]!;
                          final color = categoryColors[index %
                              categoryColors.length]; // Rotate through colors

                          return _buildCategoryCard(
                              category, complaintsByDate, color);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category,
      Map<String, List<Complaint>> complaintsByDate, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: color,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Theme(
            data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                splashColor: Colors.transparent),
            child: ExpansionTile(
              iconColor: Colors.white,
              collapsedIconColor: Colors.white,
              title: Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              trailing: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              children: complaintsByDate.keys.map((date) {
                return Container(
                  color: color.withOpacity(0.2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              DateFormat('dd MMM yyyy')
                                  .format(DateTime.parse(date)),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Complaints under this date
                      ...complaintsByDate[date]!.map(
                        (complaint) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ShowComplaint(complaint: complaint),
                                ),
                              );
                            },
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            title: Text(
                              complaint.title,
                              style: const TextStyle(fontSize: 20),
                            ),
                            subtitle: Text(
                              DateFormat('hh:mm a')
                                  .format(DateTime.parse(complaint.raisedAt)),
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person,
                                        size: 20, color: Colors.blue),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${complaint.supportCount}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  height: 12,
                                  width: 12,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(complaint.status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getStatusString(complaint.status),
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusString(int status) {
    switch (status) {
      case 0:
        return "Created";
      case 1:
        return "In Progress";
      case 2:
        return "Solved";
      case 3:
        return "Rejcted";
      case 4:
        return "Re Raised";
      default:
        return "Unknown";
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
