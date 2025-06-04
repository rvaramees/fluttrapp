import 'package:brighter_bites/presentation/bloc/auth/auth_bloc.dart';
import 'package:brighter_bites/presentation/bloc/selected_child/selected_child_bloc.dart';
import 'package:brighter_bites/presentation/widgets/horiscrolling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParentHome extends StatefulWidget {
  const ParentHome({super.key});

  @override
  State<ParentHome> createState() => _ParentHomeState();
}

class _ParentHomeState extends State<ParentHome> {
  String? parentName;
  @override
  void initState() {
    super.initState();
    getParentName();
  }

  Future<void> getParentName() async {
    String? parent =
        (BlocProvider.of<AuthBloc>(context).state as AuthSuccess).user.name;
    if (parent != null) {
      parentName = parent.split(' ')[0]; // Get first name
    }
    setState(() {
      parentName = parent ?? 'Parent';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Parent Home'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/start');
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                BlocProvider.of<SelectedChildBloc>(context)
                    .add(const ClearSelectedChild());
                BlocProvider.of<AuthBloc>(context)
                    .add(const AuthLogoutRequested());
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
        body: Stack(children: [
          Horiscrolling(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome Parent!',
                  style: const TextStyle(fontSize: 24, color: Colors.black),
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                    icon: Icons.account_box,
                    label: 'Child \nDashboard',
                    color: Colors.white,
                    onTap: () {
                      Navigator.pushNamed(context, '/parent_dashboard');
                    }),
                const SizedBox(height: 16),
                _buildMenuButton(
                    icon: Icons.add_circle,
                    label: 'Add Child',
                    color: Colors.white,
                    onTap: () {
                      Navigator.pushNamed(context, '/add_child');
                    }),
              ],
            ),
          )
        ]));
  }
}

Widget _buildMenuButton({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.black),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
