import 'package:flutter/material.dart';

class RaiseComplaints extends StatefulWidget {
  const RaiseComplaints({super.key});

  @override
  State<RaiseComplaints> createState() => _RaiseComplaintsState();
}

class _RaiseComplaintsState extends State<RaiseComplaints> {


  String selectedMess = 'DH1';
  String selectedCategory = 'Neatness of Surroundings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(199, 194, 245, 1),
      appBar: AppBar(
        title: const Text('Complaint Details', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(89, 83, 141, 1),
      ),
      body: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Complaint Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600
              ),
            ),
            TextFormField(name: 'Title',),
            TextFormField(name: 'Description',),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: DropdownButtonFormField(
                value: selectedMess,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select Mess'
                ),
                items: [
                  DropdownMenuItem(child: Text('DH1'), value: 'DH1',),
                  DropdownMenuItem(child: Text('DH2'), value: 'DH2',),
                  DropdownMenuItem(child: Text('DH3'), value: 'DH3',),
                  DropdownMenuItem(child: Text('DH4'), value: 'DH4',),
                  DropdownMenuItem(child: Text('DH5'), value: 'DH5',),
                  DropdownMenuItem(child: Text('DH6'), value: 'DH6',),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedMess = value!;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: DropdownButtonFormField(
                value: selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select Category'
                ),
                items: [
                  DropdownMenuItem(child: Text('Neatness of Surroundings'), value: 'Neatness of Surroundings',),
                  DropdownMenuItem(child: Text('Timeliness of services'), value: 'Timeliness of services',),
                  DropdownMenuItem(child: Text('Quantity'), value: 'Quantity',),
                  DropdownMenuItem(child: Text('Quality'), value: 'Quality',),
                  DropdownMenuItem(child: Text('Taste'), value: 'Taste',),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
            ),
            TextFormField(name: 'Add Images',),
            Container(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xC92010FF)
                ),
                onPressed: (){},
                child: Text('Submit Complaint', style: TextStyle(color: Colors.white),),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TextFormField extends StatelessWidget {
  final String name;
  const TextFormField({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: name,
        ),
      ),
    );
  }
}