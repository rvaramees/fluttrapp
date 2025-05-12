import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttr_app/domain/entities/child.dart';
import 'package:fluttr_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:fluttr_app/presentation/bloc/child/child_bloc.dart';
import 'package:fluttr_app/presentation/widgets/loading.dart';
import 'package:fluttr_app/services/firestore.dart';
import 'package:uuid/uuid.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({Key? key}) : super(key: key);

  @override
  State<AddChildScreen> createState() => _AddChildState();
}

class _AddChildState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final FirestoreService _firestore = FirestoreService();
  TimeOfDay? _morningTime;
  TimeOfDay? _eveningTime;
  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
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
      appBar: AppBar(
        title: const Text('Add Child'),
        backgroundColor: const Color.fromARGB(255, 7, 76, 227),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(
                context, '/parent_dashboard'); // Close the add child screen
          },
        ),
      ),
      body: BlocConsumer<ChildBloc, ChildState>(
        listener: (context, state) {
          if (state is ChildLoaded) {
            if (BlocProvider.of<AuthBloc>(context).state is AuthSuccess) {
              String parentId =
                  (BlocProvider.of<AuthBloc>(context).state as AuthSuccess)
                      .user
                      .id;
              BlocProvider.of<ChildBloc>(context)
                  .add(LoadChildren(parentId: parentId));
              Navigator.pushReplacementNamed(context,
                  '/parent_home'); // Close the add child screen after adding
            }
          } else if (state is ChildError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ChildLoading) {
            return const LoadingPage();
          }
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue,
                  Color.fromARGB(255, 7, 76, 227),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'Set Child Information',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: Colors.white)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _ageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          labelText: 'Age',
                          labelStyle: TextStyle(color: Colors.white)),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an age';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number for age';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Set Preferences',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text(
                        'Morning Time',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                          onPressed: () => _pickBrushingTime(true),
                          child: const Text('Select')),
                    ]),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text(
                        'Evening Time',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                          onPressed: () => _pickBrushingTime(false),
                          child: const Text('Select')),
                    ]),
                    const SizedBox(height: 20),
                    // TimePickerDialog(initialTime: TimeOfDay.now()),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final name = _nameController.text;
                          final age = int.parse(_ageController.text);
                          final morningTime = _nameController.text;
                          final eveningTime = _ageController.text;
                          // Get the parent ID (You might need to pass this in)
                          final parentId = BlocProvider.of<AuthBloc>(context)
                                  .state is AuthSuccess
                              ? (BlocProvider.of<AuthBloc>(context).state
                                      as AuthSuccess)
                                  .user
                                  .id
                              : null;
                          if (parentId != null) {
                            final newChild = Child(
                              childId:
                                  const Uuid().v4(), // Generate a unique ID
                              parentId: parentId,
                              name: name,
                              age: age,
                              level: 1, // Default level
                              exp: 0,
                              preferences: {
                                'morning': formatTimeOfDay(_morningTime!),
                                'evening': formatTimeOfDay(_eveningTime!),
                              },
                              password: 'default_password',
                            );
                            BlocProvider.of<ChildBloc>(context)
                                .add(AddChild(child: newChild));
                            if (state is ChildLoaded) {
                              _firestore
                                  .initializeBrushingRecord(newChild.childId);
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please Login')));
                          }
                        }
                      },
                      child: const Text('Add Child'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
