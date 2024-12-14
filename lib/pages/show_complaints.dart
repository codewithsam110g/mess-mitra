import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:mess_mate/objects/complaint.dart'; // Assuming you have this file
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
      Complaint.updateComplaint(widget.complaint.complaintId, widget.complaint.toMap());
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
      Complaint.updateComplaint(widget.complaint.complaintId, widget.complaint.toMap());
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
      Complaint.updateComplaint(widget.complaint.complaintId, widget.complaint.toMap());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Complaint taken successfully!')),
    );
  }

  void _showChangeStatusDialog() {
    final TextEditingController reasonController = TextEditingController();
    int? selectedStatus; // Variable to track selected status

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Change Complaint Status',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select a new status for the complaint and provide a reason.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<int>(
                    title: const Text('Solved'),
                    value: 2,
                    groupValue: selectedStatus,
                    onChanged: (int? value) {
                      setDialogState(() {
                        selectedStatus = value; // Update selectedStatus
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('Unsolved'),
                    value: 3,
                    groupValue: selectedStatus,
                    onChanged: (int? value) {
                      setDialogState(() {
                        selectedStatus = value; // Update selectedStatus
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Reason',
                      hintText: 'Provide a reason for this status change',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedStatus == null || reasonController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a status and provide a reason.'),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop(); // Close the dialog
                _handleChangeStatus(selectedStatus!, reasonController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final complaintStatus = statusInfo[widget.complaint.status] ??
        {'label': 'Unknown', 'color': Colors.black};

    // Ensure the user data is fetched
    setData();

    // Determine if the current user raised the complaint
    bool isCurrentUser = (widget.complaint.raisedBy == currentUserUid) ||
        (accountType == 'mcor' || accountType == 'mcom');

    // Check if the complaint is assigned to the current user
    bool isAssignedToCurrentUser =
        widget.complaint.assignedTo == currentUserUid;

    // Check if the status is "In Progress"
    bool isInProgress = widget.complaint.status == 1;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(199, 194, 245, 1),
      appBar: AppBar(
        title: const Text(
          'Complaint Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(89, 83, 141, 1),
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Complaint Title
                Row(
                  children: [
                    Text('Complaint Title: ', style: headingStyle),
                    Expanded(
                        child:
                            Text(widget.complaint.title, style: contentStyle)),
                  ],
                ),
                const SizedBox(height: 8),

                // Complaint Status
                Row(
                  children: [
                    Text('Status: ', style: headingStyle),
                    const SizedBox(width: 8),
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
                      style: contentStyle.copyWith(
                        color: complaintStatus['color'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Divider
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: const Divider(
                      height: 24, thickness: 1, color: Colors.grey),
                ),

                // Complaint Details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Mess: ', style: headingStyle),
                    Expanded(
                        child:
                            Text(widget.complaint.mess, style: contentStyle)),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Category: ', style: headingStyle),
                    Expanded(
                        child:
                            Text(widget.complaint.category, style: contentStyle)),
                  ],
                ),
                const SizedBox(height: 16),

                Text('Description', style: headingStyle),
                const SizedBox(height: 8),
                Text(
                  widget.complaint.description,
                  style: contentStyle,
                ),
                const SizedBox(height: 16),

                // Complaint Images
                Text('Images', style: headingStyle),
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
                          child: Text('No images uploaded',
                              style: TextStyle(color: Colors.grey)),
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
                const SizedBox(height: 16),

                // Conditionally Render the Button
                if (accountType != "student")
                  if (widget.complaint.status == 0) // Only show "Take" button if status is 0
                    ElevatedButton(
                      onPressed: () {
                        _handleTakeAction(); // Handle the "Take" action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Take',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    )
                  else if (widget.complaint.status == 1 && isAssignedToCurrentUser)
                    // Show "Change Status" button if status is 1 (In Progress) and assigned to the current user
                    ElevatedButton(
                      onPressed: () {
                        _showChangeStatusDialog(); // Handle the "Change Status" action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Change Status',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
