import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mess_mate/objects/complaint.dart';
import 'package:mess_mate/pages/show_complaints.dart';

class MyComplaints extends StatefulWidget {
  const MyComplaints({super.key});

  @override
  State<MyComplaints> createState() => _MyComplaintsState();
}

class _MyComplaintsState extends State<MyComplaints> {
  late Future<Map<String, List<Complaint>>> complaintsFuture;

  // Fetch complaints raised by the user and those assigned to the user
  Future<Map<String, List<Complaint>>> _fetchComplaints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    // Fetch complaints raised by the user
    final raisedComplaints = await Complaint.filterComplaints(raisedBy: user.uid);

    // Fetch complaints assigned to the user
    final assignedComplaints = await Complaint.filterComplaints(assignedTo: user.uid);

    return {
      'myComplaints': raisedComplaints,
      'takenIssues': assignedComplaints,
    };
  }

  @override
  void initState() {
    super.initState();
    complaintsFuture = _fetchComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(199, 194, 245, 1),
      appBar: AppBar(
        title: const Text(
          'My Activity',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(89, 83, 141, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<Map<String, List<Complaint>>>(
          future: complaintsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final data = snapshot.data ?? {};
            final myComplaints = data['myComplaints'] ?? [];
            final takenIssues = data['takenIssues'] ?? [];

            if (myComplaints.isEmpty && takenIssues.isEmpty) {
              return const Center(
                child: Text(
                  'No activity found!',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              );
            }

            return ListView(
              children: [
                // Section 1: My Complaints
                if (myComplaints.isNotEmpty) ...[
                  const Text(
                    'My Complaints',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...myComplaints.map((complaint) => ComplaintWidget(
                        title: complaint.title,
                        date: complaint.description, // Replace with complaint.date if available
                        complaint: complaint,
                      )),
                  const SizedBox(height: 16),
                ],

                // Section 2: Taken Issues
                if (takenIssues.isNotEmpty) ...[
                  const Text(
                    'Taken Issues',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...takenIssues.map((complaint) => ComplaintWidget(
                        title: complaint.title,
                        date: complaint.description, // Replace with complaint.date if available
                        complaint: complaint,
                      )),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class ComplaintWidget extends StatelessWidget {
  final String title;
  final String date;
  final Complaint complaint;

  const ComplaintWidget({
    super.key,
    required this.title,
    required this.date,
    required this.complaint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ShowComplaint(complaint: complaint),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        tileColor: Colors.white,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display support count with icon
            Row(
              children: [
                const Icon(
                  Icons.person, // Icon for support count
                  size: 16,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4), // Spacing between icon and text
                Text(
                  '${complaint.supportCount}', // Display support count
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 16), // Spacing between support count and status
            // Filled circle for status color
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getStatusColor(complaint.status),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8), // Space between circle and text
            Text(
              complaint.getStatusLabel(),
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  // Determine the background color based on the status
  Color _getStatusColor(int status) {
    switch (status) {
      case 0: // Created
        return Colors.grey;
      case 1: // In Progress
        return Colors.orange;
      case 2: // Solved
        return Colors.green;
      case 3: // Unsolved
        return Colors.red;
      default:
        return Colors.black; // Fallback color for unknown status
    }
  }
}
