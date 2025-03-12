import 'package:flutter/material.dart';
import 'package:fluttr_app/pages/brusher.dart';
// import 'package:fluttr_app/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttr_app/services/preferences_service.dart';

class StartBrushingPage extends StatefulWidget {
  final String userId;
  final String childId;

  StartBrushingPage({
    required this.userId,
    required this.childId,
  });

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

  @override
  void initState() {
    super.initState();
    _loadChildSession();
  }

  // Future<void> _loadBrushingTimes() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     morningTime = prefs.getString('morning_brushing_time');
  //     eveningTime = prefs.getString('evening_brushing_time');
  //   });
  //   _checkBrushingTime();
  // }

  Future<void> getBrushTimings() async {
    Map<String, dynamic>? preferences =
        await preferencesService.getBrushingPreferences(userId, childId);
    setState(() {
      morningTime = preferences?["morningTime"];
      eveningTime = preferences?["eveningTime"];
    });
  }

  void _checkBrushingTime() async {
    await getBrushTimings();
    DateTime now = DateTime.now();
    String currentTime = DateFormat.Hm().format(now);

    if (morningTime != null && _isWithinTimeRange(morningTime!, currentTime)) {
      setState(() {
        isBrushingTime = true;
      });
    } else if (eveningTime != null &&
        _isWithinTimeRange(eveningTime!, currentTime)) {
      setState(() {
        isBrushingTime = true;
      });
    } else {
      setState(() {
        isBrushingTime = false;
      });
    }
    print(currentTime);
    print(isBrushingTime);
  }

  bool _isWithinTimeRange(String brushingTime, String currentTime) {
    try {
      // Parse brushing time and current time into DateTime with today's date
      DateTime now = DateTime.now();
      DateTime brushingDateTime = _parseTime(brushingTime, now);
      DateTime currentDateTime = _parseTime(currentTime, now);

      print("Brushing Time: $brushingDateTime");
      print("Current Time: $currentDateTime");

      return currentDateTime
              .isAfter(brushingDateTime.subtract(Duration(minutes: 1))) &&
          currentDateTime.isBefore(brushingDateTime.add(Duration(hours: 3)));
    } catch (e) {
      print("Error in _isWithinTimeRange: $e");
      return false;
    }
  }

  /// **Parses time string (e.g., "7:00 PM") into DateTime with today's date**
  DateTime _parseTime(String timeString, DateTime today) {
    try {
      DateFormat format = DateFormat.jm(); // Format like "7:00 PM"
      DateTime parsedTime =
          format.parse(timeString); // Converts to DateTime with 1970-01-01

      // Set today's date with the parsed time
      return DateTime(today.year, today.month, today.day, parsedTime.hour,
          parsedTime.minute);
    } catch (e) {
      print("Error parsing time: $e");
      return today; // Return current date as fallback
    }
  }

  Future<void> _loadChildSession() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedParentId = prefs.getString('parentId');
    String? storedChildId = prefs.getString('childId');

    if (storedChildId != null) {
      setState(() {
        childId = storedChildId;
        userId = storedParentId;
      });
      _fetchBrushingRecords();
      _checkBrushingTime();
    }
  }

  Future<void> _fetchBrushingRecords() async {
    if (childId == null) return;

    String monthYear = DateFormat('yyyy-MM').format(_selectedMonth);
    Map<String, Map<String, bool>> records = {};

    QuerySnapshot brushingSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('children')
        .doc(childId)
        .collection('brushingRecords')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: monthYear)
        .get();
    print('brushingRecord Collected!');

    for (var doc in brushingSnapshot.docs) {
      records[doc.id] = {
        'morning': doc['morning'] ?? false,
        'evening': doc['evening'] ?? false,
      };
    }

    setState(() {
      brushingRecords = records;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> monthDays = _generateMonthDays(_selectedMonth);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 166, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 2, 166, 255),
        title: Text("Brushing Tracker"),
      ),
      body: childId == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildMonthSelector(),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                if (isBrushingTime)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: const Color.fromARGB(255, 8, 237, 122),
                      ),
                      onPressed: () {
                        bool isMorning = DateTime.now().hour < 12;
                        goToBrusher(context, isMorning);
                      },
                      child: Text(
                        "Brush",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            icon: Icon(Icons.arrow_back), onPressed: () => _changeMonth(-1)),
        Text(
          DateFormat('MMMM yyyy').format(_selectedMonth),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
            icon: Icon(Icons.arrow_forward), onPressed: () => _changeMonth(1)),
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
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${day.day}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wb_sunny,
                  size: 28, color: morningDone ? Colors.orange : Colors.grey),
              SizedBox(width: 10),
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
                  userId: widget.userId,
                  childId: childId!,
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
