import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

class Complaint {
  String complaintId;
  String title;
  String description;
  String mess;
  String category;
  List<String> imageLinks;
  int status;
  String raisedBy;

  Complaint({
    required this.complaintId,
    required this.title,
    required this.description,
    required this.mess,
    required this.category,
    required this.imageLinks,
    required this.status,
    required this.raisedBy,
  });

  // Factory constructor to create a new complaint with a UUID
  factory Complaint.newComplaint({
    required String title,
    required String description,
    required String mess,
    required String category,
    List<String>? imageLinks,
    int status = 0, // Default status code
    required String raisedBy,
  }) {
    return Complaint(
      complaintId: const Uuid().v4(),
      title: title,
      description: description,
      mess: mess,
      category: category,
      imageLinks: imageLinks ?? [],
      status: status,
      raisedBy: raisedBy,
    );
  }

  // Convert a Complaint object to a Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'complaintId': complaintId,
      'title': title,
      'description': description,
      'mess': mess,
      'category': category,
      'imageLinks': imageLinks,
      'status': status,
      'raisedBy': raisedBy,
    };
  }

  // Create a Complaint object from a Map (Firebase snapshot)
  factory Complaint.fromMap(Map<String, dynamic> map) {
    return Complaint(
      complaintId: map['complaintId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      mess: map['mess'] ?? '',
      category: map['category'] ?? '',
      imageLinks: List<String>.from(map['imageLinks'] ?? []),
      status: map['status'] ?? 0,
      raisedBy: map['raisedBy'] ?? '',
    );
  }

  // Firebase Reference
  static final databaseRef = FirebaseDatabase.instance.ref('complaints');

  // Create a new complaint in Firebase
  static Future<void> createComplaint(Complaint complaint) async {
    await databaseRef
        .child(complaint.complaintId)
        .child('complaint')
        .set(complaint.toMap());
  }

  // Read a single complaint by ID
  static Future<Complaint?> readComplaintById(String id) async {
    final snapshot = await databaseRef.child(id).child('complaint').get();
    if (snapshot.exists) {
      return Complaint.fromMap(
          Map<String, dynamic>.from(snapshot.value as Map));
    }
    return null;
  }

  static Future<List<Complaint>> getAllComplaints() async {
    final snapshot = await databaseRef.get();
    if (snapshot.exists) {
      final complaints = <Complaint>[];

      // Cast the Firebase data to Map<String, dynamic>
      final data =
          Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);

      data.forEach((id, value) {
        if (value is Map<Object?, Object?>) {
          final complaintData = value['complaint'] as Map<Object?, Object?>?;
          if (complaintData != null) {
            complaints.add(
                Complaint.fromMap(Map<String, dynamic>.from(complaintData)));
          }
        }
      });

      return complaints;
    }
    return [];
  }

  // Update a complaint by ID
  static Future<void> updateComplaint(
      String id, Map<String, dynamic> updates) async {
    await databaseRef.child(id).child('complaint').update(updates);
  }

  // Delete a complaint by ID
  static Future<void> deleteComplaint(String id) async {
    await databaseRef.child(id).remove();
  }

  static Future<List<Complaint>> filterComplaints({
    String? mess,
    int? status,
    String? category,
    String? raisedBy,
  }) async {
    final snapshot = await databaseRef.get();
    if (snapshot.exists) {
      final complaints = <Complaint>[];

      // Cast the Firebase data to Map<String, dynamic>
      final data =
          Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);

      data.forEach((id, value) {
        if (value is Map<Object?, Object?>) {
          final complaintData = value['complaint'] as Map<Object?, Object?>?;
          if (complaintData != null) {
            final complaint =
                Complaint.fromMap(Map<String, dynamic>.from(complaintData));

            // Apply filters
            final messMatch = mess == null || complaint.mess == mess;
            final statusMatch = status == null || complaint.status == status;
            final categoryMatch =
                category == null || complaint.category == category;
            final raisedByMatch =
                raisedBy == null || complaint.raisedBy == raisedBy;

            if (messMatch && statusMatch && categoryMatch && raisedByMatch) {
              complaints.add(complaint);
            }
          }
        }
      });

      return complaints;
    }
    return [];
  }

  String getStatusLabel() {
    switch (status) {
      case 0:
        return 'Created';
      case 1:
        return 'In Progress';
      case 2:
        return 'Solved';
      case 3:
        return 'Unsolved';
      default:
        return 'Unknown Status';
    }
  }
}
