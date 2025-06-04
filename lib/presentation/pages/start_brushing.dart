import 'package:brighter_bites/presentation/bloc/selected_child/selected_child_bloc.dart';
import 'package:brighter_bites/presentation/pages/brusher.dart';
import 'package:brighter_bites/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StartBrushingPage extends StatefulWidget {
  const StartBrushingPage({super.key});

  @override
  _StartBrushingPageState createState() => _StartBrushingPageState();
}

class _StartBrushingPageState extends State<StartBrushingPage> {
  final PreferencesService preferencesService = PreferencesService();
  String? morningTime;
  String? eveningTime;
  bool isBrushingTime = false;
  DateTime _selectedMonth = DateTime.now();
  Map<String, Map<String, bool>> brushingRecords = {};
  String? userId;
  String? childId;
  bool isLoading = false; // Add loading state

  @override
  void initState() {
    super.initState();
    _fetchBrushingRecords();
    // _loadData(); // Combined data loading
  }
  Future<void> _fetchBrushingRecords() async {
    if (BlocProvider.of<SelectedChildBloc>(context).state is ChildSelected) {
      final selectedChildState =
          BlocProvider.of<SelectedChildBloc>(context).state as ChildSelected;
      final temp = selectedChildState.child.childId; //Store ChildId

      String monthYear = DateFormat('yyyy-MM').format(_selectedMonth);

      QuerySnapshot brushingSnapshot = await FirebaseFirestore.instance
          .collection('brushes')
          .doc(temp)
          .collection('records')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: monthYear)
          .get();

      print('brushingRecord Collected!');

      Map<String, Map<String, bool>> tempRecords = {};
      for (var doc in brushingSnapshot.docs) {
        tempRecords[doc.id] = {
          'morning': doc['morning'] ?? false,
          'evening': doc['evening'] ?? false,
        };
      }

      setState(() {
        childId = temp;
        brushingRecords = tempRecords;
      });
    } else {
      print("Noting Selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> monthDays = _generateMonthDays(_selectedMonth);

    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 2, 166, 255),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 2, 166, 255),
          title: const Text("Brushing Tracker"),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator()) // Show loading indicator

            : Column(
                children: [
                  _buildMonthSelector(),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: monthDays.length,
                      itemBuilder: (context, index) {
                        DateTime day = monthDays[index];
                        String formattedDay =
                            DateFormat('yyyy-MM-dd').format(day);
                        bool morningDone =
                            brushingRecords[formattedDay]?['morning'] ?? false;
                        bool eveningDone =
                            brushingRecords[formattedDay]?['evening'] ?? false;

                        return _buildDayBox(day, morningDone, eveningDone);
                      },
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 20),
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       padding: const EdgeInsets.symmetric(
                  //           horizontal: 30, vertical: 12),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(16),
                  //       ),
                  //       backgroundColor: const Color.fromARGB(255, 8, 237, 122),
                  //     ),
                  //     onPressed: isBrushingTime
                  //         ? () {
                  //             bool isMorning = DateTime.now().hour < 12;
                  //             goToBrusher(context, isMorning);
                  //           }
                  //         : null, // Disable button if not brushing time
                  //     child: const Text(
                  //       "Brush",
                  //       style: TextStyle(
                  //           fontSize: 18, fontWeight: FontWeight.bold),
                  //     ),
                  //   ),
                  // ),
                ],
              ));
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _changeMonth(-1)),
        Text(
          DateFormat('MMMM yyyy').format(_selectedMonth),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => _changeMonth(1)),
      ],
    );
  }

  Widget _buildDayBox(DateTime day, bool morningDone, bool eveningDone) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 144, 223, 251),
        border: Border.all(color: Colors.grey, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${day.day}',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wb_sunny,
                  size: 28, color: morningDone ? Colors.orange : Colors.grey),
              const SizedBox(width: 10),
              Icon(Icons.nightlight_round,
                  size: 28, color: eveningDone ? Colors.blue : Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  goToBrusher(BuildContext context, bool isMorning) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Brusher(
                  sessionType: isMorning ? "Morning" : "Evening",
                  // sessionType: isMorning ? "Morning" : "Evening",
                  // userId: userId!,
                  // childId: childId!,
                )),
      );

  void _changeMonth(int step) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + step, 1);
      _fetchBrushingRecords();
    });
  }

  List<DateTime> _generateMonthDays(DateTime month) {
    List<DateTime> days = [];
    int totalDays = DateTime(month.year, month.month + 1, 0).day;
    for (int i = 1; i <= totalDays; i++) {
      days.add(DateTime(month.year, month.month, i));
    }
    return days;
  }
}
