import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _mcorUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMcorUsers();
  }

  Future<void> fetchMcorUsers() async {
    final snapshot = await _userRef.child('users').get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      setState(() {
        _mcorUsers = data.entries
            .where((entry) {
              final user = Map<String, dynamic>.from(entry.value['user'] ?? {});
              return user['accountType'] == 'student';
            })
            .map((entry) {
              final user = Map<String, dynamic>.from(entry.value['user'] ?? {});
              return {
                'name': '${user['firstname'] ?? ''} ${user['middlename'] ?? ''} ${user['lastname'] ?? ''}'.trim(),
                'phone': user['phone'] ?? 'N/A',
                'mess': user['mess'] ?? 'N/A',
              };
            })
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCOR Users'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _mcorUsers.isEmpty
              ? const Center(
                  child: Text(
                    'No users found.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _mcorUsers.length,
                  itemBuilder: (context, index) {
                    final user = _mcorUsers[index];
                    return _buildUserCard(user);
                  },
                ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', user['name']),
            _buildInfoRow('Phone', user['phone']),
            _buildInfoRow('Mess', user['mess']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$title:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
