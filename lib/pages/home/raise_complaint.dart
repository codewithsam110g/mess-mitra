import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mess_mate/objects/complaint.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RaiseComplaints extends StatefulWidget {
  const RaiseComplaints({super.key});

  @override
  State<RaiseComplaints> createState() => _RaiseComplaintsState();
}

class _RaiseComplaintsState extends State<RaiseComplaints> {
  String selectedMess = 'DH1';
  String selectedCategory = 'Neatness of Surroundings';
  final List<File> _selectedImages = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only upload up to 3 images.')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  void submitComplaint() {
    Complaint c = Complaint.newComplaint(
        title: titleController.text,
        description: descriptionController.text,
        category: selectedCategory,
        mess: selectedMess,
        imageLinks: [],
        status: 0,
        raisedBy: FirebaseAuth.instance.currentUser?.uid ?? "");
    Complaint.createComplaint(c);
    Navigator.of(context).pop();
  }

  // Future<String?> uploadImage(File image) async {
  //   const String uploadUrl = "https://your-backend-url/upload-image";
  //   final request = http.MultipartRequest("POST", Uri.parse(uploadUrl));

  //   request.files.add(
  //     http.MultipartFile.fromBytes(
  //       'image',
  //       await image.readAsBytes(),
  //       filename: image.path.split('/').last,
  //     ),
  //   );

  //   try {
  //     final response = await request.send();
  //     if (response.statusCode == 200) {
  //       final responseData = await response.stream.bytesToString();
  //       final json = jsonDecode(responseData);
  //       return json['imageUrl']; // Assuming the server returns the image URL
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(199, 194, 245, 1),
      appBar: AppBar(
        title: const Text(
          'Complaint Details',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(89, 83, 141, 1),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Complaint Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Title',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Description',
                  ),
                  maxLines: 3,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: DropdownButtonFormField(
                  value: selectedMess,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Select Mess'),
                  items: const [
                    DropdownMenuItem(
                      child: Text('DH1'),
                      value: 'DH1',
                    ),
                    DropdownMenuItem(
                      child: Text('DH2'),
                      value: 'DH2',
                    ),
                    DropdownMenuItem(
                      child: Text('DH3'),
                      value: 'DH3',
                    ),
                    DropdownMenuItem(
                      child: Text('DH4'),
                      value: 'DH4',
                    ),
                    DropdownMenuItem(
                      child: Text('DH5'),
                      value: 'DH5',
                    ),
                    DropdownMenuItem(
                      child: Text('DH6'),
                      value: 'DH6',
                    ),
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
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select Category'),
                  items: const [
                    DropdownMenuItem(
                      child: Text('Neatness of Surroundings'),
                      value: 'Neatness of Surroundings',
                    ),
                    DropdownMenuItem(
                      child: Text('Timeliness of services'),
                      value: 'Timeliness of services',
                    ),
                    DropdownMenuItem(
                      child: Text('Quantity'),
                      value: 'Quantity',
                    ),
                    DropdownMenuItem(
                      child: Text('Quality'),
                      value: 'Quality',
                    ),
                    DropdownMenuItem(
                      child: Text('Taste'),
                      value: 'Taste',
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Images',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._selectedImages.map(
                          (image) => Stack(
                            children: [
                              Image.file(
                                image,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.remove(image);
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedImages.length < 3)
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(89, 83, 141, 1)),
                onPressed: submitComplaint,
                child: const Text(
                  'Submit Complaint',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
