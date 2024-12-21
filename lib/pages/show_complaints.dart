import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mess_mate/objects/complaint.dart';
import 'package:mess_mate/objects/user.dart' as _User;

class ShowComplaint extends StatefulWidget {
  final Complaint complaint;

  const ShowComplaint({
    super.key,
    required this.complaint,
  });

  @override
  State<ShowComplaint> createState() => _ShowComplaintState();
}

class _ShowComplaintState extends State<ShowComplaint> {
  final TextStyle headingStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  final TextStyle contentStyle = const TextStyle(
    fontSize: 16,
    color: Colors.black54,
  );

  final Map<int, Map<String, dynamic>> statusInfo = {
    0: {'label': 'Created', 'color': Colors.grey},
    1: {'label': 'In Progress', 'color': Colors.orange},
    2: {'label': 'Solved', 'color': Colors.green},
    3: {'label': 'Unsolved', 'color': Colors.red},
  };

  late String currentUserUid;
  late String accountType = "";

  @override
  void initState() {
    super.initState();
    setData();
  }

  void setData() async {
    currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    _getAccountType();
  }

  void _getAccountType() async {
    _User.UserService us = _User.UserService();
    _User.User? u = await us
        .fetchUserByEmail(FirebaseAuth.instance.currentUser?.email ?? "");
    accountType = u?.accountType ?? "";
  }

  void _handleReRaise() {
    setState(() {
      widget.complaint.status = 0; // Reset status to "Created"
      widget.complaint.assignedTo = ""; // Clear assigned user
      widget.complaint.reason = ""; // Clear the reason (if needed)

      // Update the complaint in the database
      Complaint.updateComplaint(
          widget.complaint.complaintId, widget.complaint.toMap());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Complaint re-raised successfully!')),
    );
  }

  void _handleChangeStatus(int status, String reason) {
    setState(() {
      widget.complaint.status = status; // Update complaint status
      widget.complaint.reason = reason; // Save the provided reason

      // Update the complaint in the database
      Complaint.updateComplaint(
          widget.complaint.complaintId, widget.complaint.toMap());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Status changed to ${status == 2 ? 'Solved' : 'Unsolved'} successfully!',
        ),
      ),
    );
  }

  void _handleTakeAction() {
    setState(() {
      widget.complaint.status = 1; // "In Progress" status
      widget.complaint.assignedTo = currentUserUid; // Assign complaint

      // Update the complaint in the database
      Complaint.updateComplaint(
          widget.complaint.complaintId, widget.complaint.toMap());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Complaint taken successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final complaintStatus = statusInfo[widget.complaint.status] ??
        {'label': 'Unknown', 'color': Colors.black};

    // Determine if the current user raised the complaint
    bool isAssignedToCurrentUser =
        widget.complaint.assignedTo == currentUserUid;

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    "Complaint Info",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
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
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFF), // Almost white with a very slight blue tint
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE0E0E0), // Light border for elevation effect
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Complaint Title Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Complaint Title',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.complaint.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis, // Handle long titles gracefully
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // Handle support action here
                                      setState(() {
                                        widget.complaint.supportCount += 1; // Increment support count
                                        // Update the complaint in the database
                                        Complaint.updateComplaint(
                                            widget.complaint.complaintId, widget.complaint.toMap());
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Support added successfully!')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent, // Customize button color
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12), // Slightly rounded corners
                                      ),
                                    ),
                                    child: const Text('Support', style: TextStyle(color:Colors.white)),
                                  ),
                                  const SizedBox(width: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.person, size: 20, color: Colors.blue),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.complaint.supportCount.toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),


                          const Divider(height: 24, color: Colors.grey),
            
                          // Status
                          const Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                height: 12,
                                width: 12,
                                decoration: BoxDecoration(
                                  color: statusInfo[widget.complaint.status]?['color'] ?? Colors.black,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                statusInfo[widget.complaint.status]?['label'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: Colors.grey),
            
                          // Mess
                          const Text(
                            'Mess',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.complaint.mess,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Divider(height: 24, color: Colors.grey),
            
                          // Category
                          const Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.complaint.category,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Divider(height: 24, color: Colors.grey),
            
                          // Description
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.complaint.description,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              color: Colors.black87,
                            ),
                          ),
                          const Divider(height: 24, color: Colors.grey),
            
                          // Images
                          const Text(
                            'Images',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          widget.complaint.imageLinks.isEmpty
                              ? Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade400),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'No images uploaded',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: widget.complaint.imageLinks
                                      .map(
                                        (image) => Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image: NetworkImage(image),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}
