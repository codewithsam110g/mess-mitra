import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mess_mate/objects/complaint.dart';
import 'package:mess_mate/objects/user.dart' as _User;
import 'package:flutter/services.dart';

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

  _User.User? assignedUser;
  _User.User? reassignedUser;

  final TextStyle contentStyle = const TextStyle(
    fontSize: 16,
    color: Colors.black54,
  );

  final Map<int, Map<String, dynamic>> statusInfo = {
    0: {'label': 'Created', 'color': Colors.grey},
    1: {'label': 'In Progress', 'color': Colors.orange},
    2: {'label': 'Solved', 'color': Colors.green},
    3: {'label': 'Unsolved', 'color': Colors.red},
    4: {'label': 'Re Raised', 'color': Colors.red},
  };

  late String currentUserUid;
  late String accountType = "";
  bool isSupportDisabled = false;
  late _User.User? currentUser;
  late String buttonText = "unw";
  late int mode = -1;

  @override
  void initState() {
    super.initState();
    setData();
  }

  void setData() async {
    currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    await _getUserData();
    _getAccountType();
    if (widget.complaint.assignedTo.isNotEmpty) {
      await _getAssignedUserData(); // Fetch assigned user details if assigned
    }
    setMode();
  }

  Future<void> _getAssignedUserData() async {
    _User.UserService us = _User.UserService();
    assignedUser = await us.fetchUserByUID(widget.complaint.assignedTo);
    reassignedUser = await us.fetchUserByUID(widget.complaint.reassignedTo);
    setState(() {}); // Refresh UI after fetching user data
  }

  void _getAccountType() async {
    _User.UserService us = _User.UserService();
    _User.User? u = await us
        .fetchUserByEmail(FirebaseAuth.instance.currentUser?.email ?? "");
    accountType = u?.accountType ?? "";
  }

  Future<void> _getUserData() async {
    _User.UserService us = _User.UserService();
    currentUser =
        await us.fetchUserByEmail(FirebaseAuth.instance.currentUser!.email!);
    _checkSupportStatus();
  }

  void _checkSupportStatus() {
    // Check if the current user has already supported this complaint
    if (currentUser!.complaintIds.contains(widget.complaint.complaintId)) {
      setState(() {
        isSupportDisabled =
            true; // Disable the support button if already supported
      });
    } else {
      setState(() {
        isSupportDisabled =
            false; // Enable support button if not already supported
      });
    }
  }

  void setMode() {
    if ((widget.complaint.raisedBy != currentUserUid) &&
        (widget.complaint.status == 0 || widget.complaint.status == 4) &&
        (accountType != "student") &&
        (widget.complaint.reassignedTo == "") &&
        (widget.complaint.assignedTo != currentUserUid)) {
      setState(() {
        mode = 0;
        buttonText = "Take";
      });
    } else if ((widget.complaint.assignedTo == currentUserUid ||
            widget.complaint.reassignedTo == currentUserUid) &&
        (widget.complaint.status == 1)) {
      setState(() {
        mode = 1;
        buttonText = "Change Status";
      });
    } else if ((widget.complaint.status == 2 || widget.complaint.status == 3) &&
        widget.complaint.raisedBy == currentUserUid) {
      setState(() {
        mode = 2;
        buttonText = "Re Raise";
      });
    } else {
      setState(() {
        mode = -1;
      });
    }
  }

  void _handleTakeAction() {
    setState(() {
      if (widget.complaint.status == 0) {
        widget.complaint.status = 1;
        widget.complaint.assignedTo = currentUserUid;
        widget.complaint.assignedAuthType = accountType;
        Complaint.updateComplaint(
            widget.complaint.complaintId, widget.complaint.toMap());
        setMode();
      } else if (widget.complaint.status == 4) {
        widget.complaint.status = 1;
        widget.complaint.reassignedTo = currentUserUid;
        Complaint.updateComplaint(
            widget.complaint.complaintId, widget.complaint.toMap());
        setMode();
      }
    });
  }

  void _handleChangeStatus() {
    int? selectedStatus;
    TextEditingController reasonController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Change Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Radio buttons for status selection
                  Row(
                    children: [
                      Radio<int>(
                        value: 2,
                        groupValue: selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value;
                            errorText = null;
                          });
                        },
                      ),
                      Text('Solved'),
                      Radio<int>(
                        value: 3,
                        groupValue: selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value;
                            errorText = null;
                          });
                        },
                      ),
                      Text('Unsolved'),
                    ],
                  ),
                  // Text field for reason
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                      errorText: errorText,
                    ),
                    onChanged: (_) {
                      setState(() {
                        errorText = null;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                // No button
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('No'),
                ),
                // Yes button
                TextButton(
                  onPressed: () {
                    if (selectedStatus == null ||
                        reasonController.text.isEmpty) {
                      setState(() {
                        errorText = reasonController.text.isEmpty
                            ? 'Field is empty'
                            : null;
                      });
                      return;
                    }
                    Navigator.pop(context, {
                      'status': selectedStatus,
                      'reason': reasonController.text,
                    });
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );
      },
    ).then((result) {
      if (result != null) {
        setState(() {
          if(widget.complaint.isReRaised){
            widget.complaint.status = result['status'];
            widget.complaint.recloseReason = result['reason'];
            Complaint.updateComplaint(
                widget.complaint.complaintId, widget.complaint.toMap());
            setMode();
          }else{
            widget.complaint.status = result['status'];
            widget.complaint.reason = result['reason'];
            Complaint.updateComplaint(
                widget.complaint.complaintId, widget.complaint.toMap());
            setMode();
          }
        });
      }
    });
  }

  void _handleReRaise() async {
    TextEditingController reasonController = TextEditingController();
    String? reason;
    bool hasError = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Do you really want to re-raise the issue?'),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    errorText: hasError ? 'Reason is required' : null,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  if (reasonController.text.trim().isEmpty) {
                    setState(() {
                      hasError = true;
                    });
                  } else {
                    reason = reasonController.text.trim();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Yes'),
              ),
            ],
          );
        });
      },
    );

    if (reason != null) {
      setState(() {
        widget.complaint.isReRaised = true;
        widget.complaint.reRaiseReason = reason ?? "";
        widget.complaint.status = 4;
        Complaint.updateComplaint(
            widget.complaint.complaintId, widget.complaint.toMap());
        setMode();
      });
    }
  }

  void _handleAction() {
    switch (mode) {
      case 0:
        {
          _handleTakeAction();
          break;
        }
      case 1:
        {
          _handleChangeStatus();
          break;
        }
      case 2:
        {
          _handleReRaise();
          break;
        }
    }
  }

  void _handleSupportAction() {
    if (!isSupportDisabled) {
      setState(() {
        widget.complaint.supportCount++;
        currentUser!.complaintIds.add(widget.complaint.complaintId);
        Complaint.updateComplaint(
            widget.complaint.complaintId, widget.complaint.toMap());
        _User.UserService().updateUser(currentUser!);
        _checkSupportStatus();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Support added successfully!')),
      );
    }
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
                      color: const Color(
                          0xFFF8FAFF), // Almost white with a very slight blue tint
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(
                            0xFFE0E0E0), // Light border for elevation effect
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
                                      overflow: TextOverflow
                                          .ellipsis, // Handle long titles gracefully
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: isSupportDisabled
                                        ? null
                                        : () {
                                            _handleSupportAction();
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSupportDisabled
                                          ? Colors.grey // Use a disabled color
                                          : Colors
                                              .blueAccent, // Customize button color
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            12), // Slightly rounded corners
                                      ),
                                    ),
                                    child: Text(
                                      isSupportDisabled
                                          ? 'Already Supported'
                                          : 'Support',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.person,
                                          size: 20, color: Colors.blue),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.complaint.supportCount
                                            .toString(),
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

                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '#${widget.complaint.complaintId}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                      text: widget.complaint.complaintId));
                                },
                                child: const Icon(
                                  Icons.copy,
                                  size: 18,
                                  color: Colors.grey,
                                ),
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
                                  color: statusInfo[widget.complaint.status]
                                          ?['color'] ??
                                      Colors.black,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                statusInfo[widget.complaint.status]?['label'] ??
                                    'Unknown',
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
                                    border:
                                        Border.all(color: Colors.grey.shade400),
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
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image: NetworkImage(image),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                          if (assignedUser != null) ...[
                            const SizedBox(height: 16),
                            const Divider(height: 24, color: Colors.grey),
                            const Text(
                              'Working Authority',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final maxWidth = constraints.maxWidth *
                                    0.9; // Adjust the width dynamically
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxWidth: maxWidth),
                                          child: Text(
                                            "${assignedUser!.firstname} ${assignedUser!.middlename} ${assignedUser!.lastname}",
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxWidth: maxWidth),
                                          child: Text(
                                            assignedUser!.email,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxWidth: maxWidth),
                                          child: Text(
                                            assignedUser!.mobileno,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxWidth: maxWidth),
                                          child: Text(
                                            assignedUser!.mess,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                          if (widget.complaint.status > 1) ...[
                            const Divider(height: 24, color: Colors.grey),
                            Text(
                                "This issue is Closed With Reason:\n${widget.complaint.reason}"),
                          ],
                          if (widget.complaint.isReRaised) ...[
                            const Divider(height: 24, color: Colors.grey),
                            Text(
                                "This issue is Reraised With Reason:\n${widget.complaint.reRaiseReason}")
                          ],
                          if (reassignedUser != null) ...[
                            const SizedBox(height: 8),
                            const Divider(height: 24, color: Colors.grey),
                            const Text(
                              'Reassigned Authority',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final maxWidth = constraints.maxWidth *
                                    0.9; // Adjust the width dynamically
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxWidth: maxWidth),
                                          child: Text(
                                            "${reassignedUser!.firstname} ${reassignedUser!.middlename} ${reassignedUser!.lastname}",
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxWidth: maxWidth),
                                          child: Text(
                                            reassignedUser!.email,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxWidth: maxWidth),
                                          child: Text(
                                            reassignedUser!.mobileno,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxWidth: maxWidth),
                                          child: Text(
                                            reassignedUser!.mess,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                          (mode == -1)
                              ? const SizedBox(height: 8)
                              : Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _handleAction();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .blueAccent, // Customize button color
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              12), // Slightly rounded corners
                                        ),
                                      ),
                                      child: Text(
                                        buttonText,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
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
