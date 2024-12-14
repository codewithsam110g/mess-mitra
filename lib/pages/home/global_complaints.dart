import 'package:flutter/material.dart';
import 'package:mess_mate/pages/show_complaints.dart';
import 'package:mess_mate/objects/complaint.dart'; // Adjust this import based on your project structure

class GlobalComplaints extends StatefulWidget {
  const GlobalComplaints({super.key});

  @override
  State<GlobalComplaints> createState() => _GlobalComplaintsState();
}

class _GlobalComplaintsState extends State<GlobalComplaints> with SingleTickerProviderStateMixin {
  late Future<Map<String, List<Complaint>>> complaintsByCategoryFuture;

  // Fetch complaints from Firebase and group them by category
  Future<Map<String, List<Complaint>>> _fetchComplaintsByCategory() async {
    final complaints = await Complaint.getAllComplaints();
    final Map<String, List<Complaint>> groupedComplaints = {};

    for (var complaint in complaints) {
      if (!groupedComplaints.containsKey(complaint.category)) {
        groupedComplaints[complaint.category] = [];
      }
      groupedComplaints[complaint.category]?.add(complaint);
    }

    return groupedComplaints;
  }

  @override
  void initState() {
    super.initState();
    complaintsByCategoryFuture = _fetchComplaintsByCategory();
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
      body: FutureBuilder<Map<String, List<Complaint>>>(
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
                    children: complaintsByCategory[category]!
                        .map(
                          (complaint) => ComplaintWidget(
                            title: complaint.title,
                            date: complaint.description, // Replace with complaint.date if available
                            isChild: true,
                            complaint: complaint,
                          ),
                        )
                        .toList(),
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
