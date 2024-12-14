import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_mate/pages/show_complaints.dart';
import 'package:mess_mate/objects/complaint.dart'; // Adjust this import based on your project structure

class GlobalComplaints extends StatefulWidget {
  const GlobalComplaints({super.key});

  @override
  State<GlobalComplaints> createState() => _GlobalComplaintsState();
}

class _GlobalComplaintsState extends State<GlobalComplaints> with SingleTickerProviderStateMixin {
  late Future<Map<String, Map<String, List<Complaint>>>> complaintsByCategoryFuture;

  // Fetch complaints, group by category, then by date
  Future<Map<String, Map<String, List<Complaint>>>> _fetchComplaintsByCategoryAndDate() async {
    final complaints = await Complaint.getAllComplaints();

    // Sort complaints by time (latest first)
    complaints.sort((a, b) => DateTime.parse(b.raisedAt).compareTo(DateTime.parse(a.raisedAt)));

    final Map<String, Map<String, List<Complaint>>> groupedComplaints = {};

    for (var complaint in complaints) {
      // Group by category
      if (!groupedComplaints.containsKey(complaint.category)) {
        groupedComplaints[complaint.category] = {};
      }

      // Group by date (formatted as "yyyy-MM-dd")
      final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.parse(complaint.raisedAt));
      if (!groupedComplaints[complaint.category]!.containsKey(dateKey)) {
        groupedComplaints[complaint.category]![dateKey] = [];
      }
      groupedComplaints[complaint.category]![dateKey]!.add(complaint);
    }

    return groupedComplaints;
  }

  @override
  void initState() {
    super.initState();
    complaintsByCategoryFuture = _fetchComplaintsByCategoryAndDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(199, 194, 245, 1),
      appBar: AppBar(
        title: const Text(
          'Complaints Raised',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(89, 83, 141, 1),
      ),
      body: FutureBuilder<Map<String, Map<String, List<Complaint>>>>(
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

          return ListView(
            children: complaintsByCategory.keys.map((category) {
              final complaintsByDate = complaintsByCategory[category]!;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: complaintsByDate.keys.map((date) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(230, 230, 250, 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  DateFormat('dd MMM yyyy').format(DateTime.parse(date)),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Complaints under this date
                          ...complaintsByDate[date]!.map(
                            (complaint) => ComplaintWidget(
                              title: complaint.title,
                              date: DateFormat('hh:mm a').format(DateTime.parse(complaint.raisedAt)),
                              isChild: true,
                              complaint: complaint,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
class ComplaintWidget extends StatelessWidget {
  final String title;
  final String date;
  final bool isChild;
  final Complaint complaint;

  const ComplaintWidget({
    super.key,
    required this.title,
    required this.date,
    this.isChild = false,
    required this.complaint,
  });

  // Map for status colors and labels
  static const Map<int, Map<String, dynamic>> statusInfo = {
    0: {'label': 'Created', 'color': Colors.grey},
    1: {'label': 'In Progress', 'color': Colors.orange},
    2: {'label': 'Solved', 'color': Colors.green},
    3: {'label': 'Unsolved', 'color': Colors.red},
  };

  @override
  Widget build(BuildContext context) {
    // Retrieve the status label and color based on complaint.status
    final complaintStatus = statusInfo[complaint.status] ??
        {'label': 'Unknown', 'color': Colors.black};

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ShowComplaint(
                complaint: complaint, // Pass the entire complaint if needed
              ),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        tileColor: isChild
            ? const Color.fromRGBO(230, 230, 250, 1)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20),
        ),
        subtitle: Text(
          date,
          style: const TextStyle(fontSize: 14),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // To prevent excessive width
          children: [
            // Support count with an icon
            Row(
              children: [
                const Icon(
                  Icons.person, // Support icon
                  size: 20,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  '${complaint.supportCount}', // Display support count
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 12), // Space between support and status
            // Status indicator
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: complaintStatus['color'],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              complaintStatus['label'],
              style: TextStyle(
                color: complaintStatus['color'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
