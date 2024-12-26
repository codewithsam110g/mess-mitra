import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mess_mate/objects/complaint.dart';
import 'package:mess_mate/pages/show_complaints.dart';

class MyComplaints extends StatefulWidget {
  const MyComplaints({super.key});

  @override
  State<MyComplaints> createState() => _MyComplaintsState();
}

class _MyComplaintsState extends State<MyComplaints> with TickerProviderStateMixin {
  late Future<Map<String, List<Complaint>>> complaintsFuture;
  late TabController _tabController;

  // Fetch complaints raised by the user and those assigned to the user
  Future<Map<String, List<Complaint>>> _fetchComplaints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    // Fetch complaints raised by the user
    final raisedComplaints =
        await Complaint.filterComplaints(raisedBy: user.uid);

    // Fetch complaints assigned to the user
    final assignedComplaints =
        await getAssignedAndReassignedComplaints(user.uid);

    return {
      'myComplaints': raisedComplaints,
      'takenIssues': assignedComplaints,
    };
  }

  Future<List<Complaint>> getAssignedAndReassignedComplaints(String userId) async {
    // Fetch all complaints
    final allComplaints = await Complaint.getAllComplaints();
  
    // Filter complaints assigned to the user
    final assignedComplaints = allComplaints.where((complaint) => complaint.assignedTo == userId);
  
    // Filter complaints reassigned to the user
    final reassignedComplaints = allComplaints.where((complaint) => complaint.reassignedTo == userId);
  
    // Combine both lists and remove duplicates
    final combinedComplaints = <Complaint>{
      ...assignedComplaints,
      ...reassignedComplaints,
    }.toList();
  
    return combinedComplaints;
  }

  
  @override
  void initState() {
    super.initState();
    complaintsFuture = _fetchComplaints();
    _tabController = TabController(length: 2, vsync: this); // Default initialization
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
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const Text(
                    "Complaints",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
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

                      if (myComplaints.isNotEmpty && takenIssues.isNotEmpty) {
                        // Initialize TabController
                        _tabController = TabController(
                          length: 2,
                          vsync: this,
                        );

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal:8.0),
                              child: TabBar(
                                controller: _tabController,
                                indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.blueAccent, width: 2),
                                  color: const Color(0xFFF8FAFF),
                                ),
                                labelColor: Colors.blueAccent,
                                unselectedLabelColor: Colors.black54,
                                dividerColor: Colors.transparent,
                                labelPadding: EdgeInsets.zero, // Remove padding for proper width alignment
                                tabs: const [
                                  Tab(text: 'Raised'),
                                  Tab(text: 'Taken'),
                                ],
                                indicatorSize: TabBarIndicatorSize.tab, // Full tab width
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical:8.0),
                                    child: _buildComplaintList(myComplaints),
                                  ),Padding(
                                    padding: const EdgeInsets.symmetric(vertical:8.0),
                                    child: _buildComplaintList(takenIssues),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      // Show a single list
                      if (myComplaints.isNotEmpty) {
                        return _buildComplaintList(myComplaints, sectionTitle: 'Raised');
                      }
                      return _buildComplaintList(takenIssues, sectionTitle: 'Taken');
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a complaint list with an optional title
  Widget _buildComplaintList(List<Complaint> complaints, {String? sectionTitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectionTitle != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              sectionTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              return ComplaintWidget(
                title: complaint.title,
                date: complaint.description,
                complaint: complaint,
              );
            },
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Material(
        elevation: 0, // No shadow
        color: Colors.transparent, // Transparent background for Material
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF), // Slight blue tint
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE0E0E0), // Light border
              width: 1.5,
            ),
          ),
          child: ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ShowComplaint(complaint: complaint),
                ),
              );
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            tileColor: Colors.transparent, // No additional background color for ListTile
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
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
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
      case 4:
        return Colors.red;
      default:
        return Colors.black; // Fallback color for unknown status
    }
  }
}
