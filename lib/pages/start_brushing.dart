import 'package:flutter/material.dart';

class StartBrushing extends StatelessWidget {
  const StartBrushing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Start Brushing"),
      ),
      body: Center(
        child: Text("Start Brushing Page"),
      ),
    );
  }
}
