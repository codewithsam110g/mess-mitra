import 'package:flutter/material.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(199, 194, 245, 1),
      appBar: AppBar(
        title: const Text('Status', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(89, 83, 141, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ComplaintWidget(title: 'Neatness of surroundings', subtitle: 'Subtitle',),
                  ComplaintWidget(title: 'Timeliness of services', subtitle: 'Subtitle',),
                  ComplaintWidget(title: 'Quantity', subtitle: 'Subtitle',),
                  ComplaintWidget(title: 'Quality', subtitle: 'Subtitle',),
                  ComplaintWidget(title: 'Taste', subtitle: 'Subtitle',),
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
  final String subtitle;

  const ComplaintWidget({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 12),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8)
      ),
      title: Text(title, style: TextStyle(fontSize: 20),),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 14),),
      trailing: Icon(Icons.arrow_forward_ios),
    );
  }
}