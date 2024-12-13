import 'package:flutter/material.dart';
import 'package:mess_mate/show_complaints.dart';

class MyComplaints extends StatefulWidget {
  const MyComplaints({super.key});

  @override
  State<MyComplaints> createState() => _MyComplaintsState();
}

class _MyComplaintsState extends State<MyComplaints> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(199, 194, 245, 1),
      appBar: AppBar(
        title: const Text('My Activity', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(89, 83, 141, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Complaints raised', style: TextStyle(fontSize: 24),),
                  ComplaintWidget(title: 'Complaint 1', date: 'date 1',),
                  ComplaintWidget(title: 'Complaint 2', date: 'date 2',),
                  ComplaintWidget(title: 'Complaint 3', date: 'date 3',),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16)
              ),
              child: Column(
                children: [
                  Text(
                    'Activity Summary',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SummaryItem(name: 'Total Complaints', count: 8,),
                      SummaryItem(name: 'Resolved', count: 5),
                      SummaryItem(name: 'Pending', count: 3)
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SummaryItem extends StatelessWidget {
  final String name;
  final int count;
  const SummaryItem({
    super.key,
    required this.name,
    required this.count
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(name, style: TextStyle(fontSize: 16),),
        Text(count.toString(), style: TextStyle(fontSize: 28),)
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ShowComplaint(title: title)));
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