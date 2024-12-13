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

  TextStyle styles = const TextStyle(
    fontSize: 20,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(199, 194, 245, 1),
      appBar: AppBar(
        title: const Text('Complaints Raised', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(89, 83, 141, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Complaint title', style: styles,),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: Text(widget.title),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Mess : ', style: styles,),
                    Text('DH4', style: styles,)
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Category : ', style: styles,),
                    Text('Neatness of Surroundings', style: styles,)
                  ],
                ),
                Text('Description', style: styles,),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: Text('The description of the complaint goes here...'),
                ),
                Text('Images', style: styles,),
                Spacer(),
              ],
            ),
            Column(
              children: [
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Recommend', style: TextStyle(color: Colors.black, fontSize: 16),),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}