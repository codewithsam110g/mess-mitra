import 'package:flutter/material.dart';
import 'package:mess_mate/show_complaints.dart';

class GlobalComplaints extends StatefulWidget {
  const GlobalComplaints({super.key});

  @override
  State<GlobalComplaints> createState() => _GlobalComplaintsState();
}

class _GlobalComplaintsState extends State<GlobalComplaints> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(199, 194, 245, 1),
      appBar: AppBar(
        title: const Text('Complaints Raised', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(89, 83, 141, 1),
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ComplaintWidget(title: 'Complaint 1', date: 'date 1',),
          ComplaintWidget(title: 'Complaint 2', date: 'date 2',),
          ComplaintWidget(title: 'Complaint 3', date: 'date 3',),
        ],
      ),
    );
  }
}

class ComplaintWidget extends StatelessWidget {
  final String title;
  final String date;

  const ComplaintWidget({
    super.key,
    required this.title,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ShowComplaint(title: title,)));
        },
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
        ),
        title: Text(title, style: TextStyle(fontSize: 20),),
        subtitle: Text(date, style: TextStyle(fontSize: 14),),
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}