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
  late Future<List<Complaint>> myComplaintsFuture;

  // Fetch complaints raised by the current user
  Future<List<Complaint>> _fetchMyComplaints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    return await Complaint.filterComplaints(raisedBy: user.uid);
  }

  @override
  void initState() {
    super.initState();
    myComplaintsFuture = _fetchMyComplaints();
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
        child: FutureBuilder<List<Complaint>>(
          future: myComplaintsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            final complaints = snapshot.data ?? [];
            if (complaints.isEmpty) {
              return const Center(
                child: Text(
                  'No complaints raised yet!',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              );
            }

            return ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                return ComplaintWidget(
                  title: complaint.title,
                  date: complaint
                      .description, // Replace with complaint.date if available
                  complaint: complaint,
                );
              },
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
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
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
