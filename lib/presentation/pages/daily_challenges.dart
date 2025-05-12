import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttr_app/domain/entities/child.dart';
import 'package:fluttr_app/presentation/bloc/selected_child/selected_child_bloc.dart';
// import 'package:flame/game.dart';
import 'package:fluttr_app/presentation/pages/my_game.dart';
import 'package:fluttr_app/presentation/widgets/horiscrolling.dart';
import 'package:fluttr_app/services/firestore.dart';

// ignore: must_be_immutable
class DailyChallenges extends StatefulWidget {
  const DailyChallenges({super.key});

  @override
  State<DailyChallenges> createState() => _DailyChallengesState();
}

class _DailyChallengesState extends State<DailyChallenges> {
  final int score = 100;
  final FirestoreService _firestoreService = FirestoreService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Daily Challenges'),
        ),
        body: Scaffold(
          body: Stack(children: [
            Horiscrolling(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Daily Challenges'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    leading: IconButton(
                                      icon: const Icon(Icons.arrow_back),
                                      onPressed: () {
                                        Navigator.pushReplacementNamed(
                                            context, '/home');
                                        BlocProvider.of<SelectedChildBloc>(
                                                context)
                                            .add(
                                                const CheckPreviousSelectedChild());
                                        final Child? childRef = (context
                                                .read<SelectedChildBloc>()
                                                .state is ChildSelected)
                                            ? (context
                                                    .read<SelectedChildBloc>()
                                                    .state as ChildSelected)
                                                .child
                                            : null;
                                        if (childRef != null) {
                                          _firestoreService
                                              .updateExp(childRef.childId);
                                        }
                                      },
                                    ),
                                    title: Text('Pixel Adventure'),
                                    backgroundColor: Colors.blue,
                                  ),
                                  body: MainGamePage(),
                                )),
                      );
                    },
                    child: const Text('Start Game'),
                  ),
                ],
              ),
            ),
          ]),
        ));
  }
}
