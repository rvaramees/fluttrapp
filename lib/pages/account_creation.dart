import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttr_app/services/firestore.dart';
import 'package:fluttr_app/services/preferences_service.dart'; // Import Preferences Service

class AccountCreation extends StatefulWidget {
  final String uid;
  final String email;

  const AccountCreation({super.key, required this.uid, required this.email});

  @override
  State<AccountCreation> createState() => _AccountCreationState();
}

class _AccountCreationState extends State<AccountCreation> {
  final _firestore = FirestoreService();
  final _preferencesService = PreferencesService(); // Preferences Service
  final _nameController = TextEditingController();
  final _childNameController = TextEditingController();
  final _childAgeController = TextEditingController();
  final _picturePasswordController = TextEditingController();

  TimeOfDay? _morningTime;
  TimeOfDay? _eveningTime;

  @override
  void dispose() {
    _nameController.dispose();
    _childNameController.dispose();
    _childAgeController.dispose();
    _picturePasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickBrushingTime(bool isMorning) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isMorning
          ? _morningTime ?? TimeOfDay(hour: 7, minute: 0)
          : _eveningTime ?? TimeOfDay(hour: 20, minute: 0),
    );

    if (pickedTime != null) {
      setState(() {
        if (isMorning) {
          _morningTime = pickedTime;
        } else {
          _eveningTime = pickedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Parent Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              decoration: const InputDecoration(labelText: "Your Name"),
              controller: _nameController,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addParent,
              child: const Text("Save Parent"),
            ),
            const SizedBox(height: 30),

            const Text("Add Child",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              decoration: const InputDecoration(labelText: "Child Name"),
              controller: _childNameController,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Child Age"),
              keyboardType: TextInputType.number,
              controller: _childAgeController,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Picture Password"),
              controller:
                  _picturePasswordController, // Replace with image picker later
            ),
            const SizedBox(height: 20),

            // 🕒 Select Brushing Times
            const Text("Set Brushing Times",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              title: const Text("Morning Brushing Time"),
              subtitle: Text(_morningTime == null
                  ? "Not Set"
                  : _morningTime!.format(context)),
              trailing: IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () => _pickBrushingTime(true),
              ),
            ),
            ListTile(
              title: const Text("Evening Brushing Time"),
              subtitle: Text(_eveningTime == null
                  ? "Not Set"
                  : _eveningTime!.format(context)),
              trailing: IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () => _pickBrushingTime(false),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _addChild,
              child: const Text("Add Child"),
            ),
            const SizedBox(height: 20),

            const Text("Registered Children",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(child: _buildChildrenList()), // Show added children
          ],
        ),
      ),
    );
  }

  void _addParent() async {
    String name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage("Please enter your name");
      return;
    }

    await _firestore.addParent(widget.uid, name, widget.email);
    _showMessage("Parent account created successfully");
  }

  void _addChild() async {
    String childName = _childNameController.text.trim();
    String ageText = _childAgeController.text.trim();
    String picturePassword = _picturePasswordController.text.trim();

    if (childName.isEmpty || ageText.isEmpty || picturePassword.isEmpty) {
      _showMessage("Please fill all child details");
      return;
    }

    int age = int.tryParse(ageText) ?? 0;
    if (age <= 0) {
      _showMessage("Please enter a valid age");
      return;
    }

    // Add Child to Firestore
    String childId = await _firestore.addChild(
      widget.uid,
      childName,
      age,
      picturePassword,
    );

    // Save Brushing Preferences to Firestore
    if (childId.isNotEmpty && _morningTime != null && _eveningTime != null) {
      await _preferencesService.saveBrushingPreferences(
        parentId: widget.uid,
        childId: childId,
        morningTime: _morningTime!.format(context),
        eveningTime: _eveningTime!.format(context),
        reminderEnabled: true,
      );
    }

    _showMessage("Child added successfully");
    _childNameController.clear();
    _childAgeController.clear();
    _picturePasswordController.clear();
  }

  Widget _buildChildrenList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.getChildrenStream(widget.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Text("No children added yet");
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> child = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(child['name']),
              subtitle: Text("Age: ${child['age']}"),
            );
          }).toList(),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
