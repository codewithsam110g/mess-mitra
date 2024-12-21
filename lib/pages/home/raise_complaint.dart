
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

  bool _isTitleValid = true;
  bool _isDescriptionValid = true;

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
    setState(() {
      // Validate inputs
      _isTitleValid = titleController.text.isNotEmpty && titleController.text.length >= 5;
      _isDescriptionValid =
          descriptionController.text.isNotEmpty && descriptionController.text.length >= 10;
    });

    if (_isTitleValid && _isDescriptionValid) {
      // Create and submit the complaint
      Complaint c = Complaint.newComplaint(
          title: titleController.text,
          description: descriptionController.text,
          category: selectedCategory,
          mess: selectedMess,
          imageLinks: [],
          status: 0,
          raisedBy: FirebaseAuth.instance.currentUser?.uid ?? "");
      Complaint.createComplaint(c);

      // Show success popup with auto-close
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.of(context).pop(); // Close the popup
            Navigator.of(context).pop(); // Close the form
          });
          return AlertDialog(
            title: const Text('Complaint Submitted'),
            content: const Text('Your complaint has been submitted successfully!'),
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: const Text(
          'Raise Complaint',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: const Color(0xFFDCE4FF),
                              width: 1.5,
                            ),
                          ),
                          color: const Color(0xFFF8FAFF),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title Input
                                const Text(
                                  'Title',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    hintText: 'Enter complaint title',
                                    errorText: _isTitleValid
                                        ? null
                                        : 'Title must be at least 5 characters long',
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Description Input
                                const Text(
                                  'Description',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: descriptionController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    hintText: 'Enter complaint details',
                                    errorText: _isDescriptionValid
                                        ? null
                                        : 'Description must be at least 10 characters long',
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Mess Dropdown
                                const Text(
                                  'Mess',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField(
                                  value: selectedMess,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'DH1', child: Text('DH1')),
                                    DropdownMenuItem(value: 'DH2', child: Text('DH2')),
                                    DropdownMenuItem(value: 'DH3', child: Text('DH3')),
                                    DropdownMenuItem(value: 'DH4', child: Text('DH4')),
                                    DropdownMenuItem(value: 'DH5', child: Text('DH5')),
                                    DropdownMenuItem(value: 'DH6', child: Text('DH6')),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedMess = value!;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Category Dropdown
                                const Text(
                                  'Category',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField(
                                  value: selectedCategory,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Neatness of Surroundings',
                                      child: Text('Neatness of Surroundings'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Timeliness of services',
                                      child: Text('Timeliness of services'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Quantity',
                                      child: Text('Quantity'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Quality',
                                      child: Text('Quality'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Taste',
                                      child: Text('Taste'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCategory = value!;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Images Section
                                const Text(
                                  'Images',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
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
                                const SizedBox(height: 16),

                                // Submit Button
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 24),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
