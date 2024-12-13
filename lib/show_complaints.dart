import 'package:flutter/material.dart';

class ShowComplaint extends StatefulWidget {
  final String title;
  const ShowComplaint({
    super.key,
    required this.title,
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

  @override
  Widget build(BuildContext context) {
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
                Text('Complaint Title', style: headingStyle),
                const SizedBox(height: 8),
                Text(widget.title, style: contentStyle),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: const Divider(height: 24, thickness: 1, color: Colors.grey)
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Mess: ', style: headingStyle),
                    Expanded(child: Text('DH4', style: contentStyle)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Category: ', style: headingStyle),
                    Expanded(
                      child: Text('Neatness of Surroundings', style: contentStyle),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: const Divider(height: 24, thickness: 1, color: Colors.grey)
                ),
                Text('Description', style: headingStyle),
                const SizedBox(height: 8),
                Text(
                  'The description of the complaint goes here. Provide details about the issue.',
                  style: contentStyle,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: const Divider(height: 24, thickness: 1, color: Colors.grey)
                ),
                Text('Images', style: headingStyle),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: const Center(
                    child: Text('No images uploaded', style: TextStyle(color: Colors.grey)),
                  ),
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
