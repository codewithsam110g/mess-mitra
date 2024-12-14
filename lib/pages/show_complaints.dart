import 'package:flutter/material.dart';
import 'package:mess_mate/objects/complaint.dart';

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

  // Map for status colors and labels
  final Map<int, Map<String, dynamic>> statusInfo = {
    0: {'label': 'Created', 'color': Colors.grey},
    1: {'label': 'In Progress', 'color': Colors.orange},
    2: {'label': 'Solved', 'color': Colors.green},
    3: {'label': 'Unsolved', 'color': Colors.red},
  };

  @override
  Widget build(BuildContext context) {
    // Retrieve the status label and color based on complaint.status
    final complaintStatus = statusInfo[widget.complaint.status] ??
        {'label': 'Unknown', 'color': Colors.black};

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
                Row(
                  children: [
                    Text('Complaint Title: ', style: headingStyle),
                    Expanded(child: Text(widget.complaint.title, style: contentStyle)),
                  ],
                ),
                const SizedBox(height: 8),
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
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: const Divider(height: 24, thickness: 1, color: Colors.grey),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Mess: ', style: headingStyle),
                    Expanded(child: Text(widget.complaint.mess, style: contentStyle)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Category: ', style: headingStyle),
                    Expanded(
                      child: Text(widget.complaint.category, style: contentStyle),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: const Divider(height: 24, thickness: 1, color: Colors.grey),
                ),
                Text('Description', style: headingStyle),
                const SizedBox(height: 8),
                Text(
                  widget.complaint.description,
                  style: contentStyle,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: const Divider(height: 24, thickness: 1, color: Colors.grey),
                ),
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
                          child: Text('No images uploaded', style: TextStyle(color: Colors.grey)),
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
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(89, 83, 141, 1),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Implement the Recommend button functionality here
                      },
                      child: const Text(
                        'Recommend',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
