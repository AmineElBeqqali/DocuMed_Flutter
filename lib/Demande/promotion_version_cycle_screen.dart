import 'package:flutter/material.dart';
import 'summary_screen.dart'; // Ensure to replace with the actual import path

class PromotionVersionCycleScreen extends StatefulWidget {
  final String documentName;

  const PromotionVersionCycleScreen({Key? key, required this.documentName}) : super(key: key);

  @override
  _PromotionVersionCycleScreenState createState() => _PromotionVersionCycleScreenState();
}

class _PromotionVersionCycleScreenState extends State<PromotionVersionCycleScreen> {
  late TextEditingController _promotionController;
  late TextEditingController _versionController;
  late TextEditingController _cycleController;

  @override
  void initState() {
    super.initState();
    _promotionController = TextEditingController();
    _versionController = TextEditingController();
    _cycleController = TextEditingController();
  }

  @override
  void dispose() {
    _promotionController.dispose();
    _versionController.dispose();
    _cycleController.dispose();
    super.dispose();
  }

  void _navigateToSummary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryScreen(
          promotion: _promotionController.text,
          version: _versionController.text,
          cycle: _cycleController.text,
          documentName: widget.documentName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,

      body: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Container(
            height: 500.0,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 3,
                  offset: Offset(5, 5),
                ),
              ],
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: TextStyle(color: Colors.lightBlueAccent),
                    controller: _promotionController,
                    decoration: InputDecoration(
                      labelText: 'Enter Promotion',
                      labelStyle: TextStyle(color: Colors.lightBlueAccent),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _versionController,
                    decoration: InputDecoration(
                      labelText: 'Enter Version',
                      labelStyle: TextStyle(color: Colors.lightBlueAccent),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _cycleController,
                    decoration: InputDecoration(
                      labelText: 'Enter Cycle',
                      labelStyle: TextStyle(color: Colors.lightBlueAccent),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
                  child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.lightBlueAccent)),
                    onPressed: _navigateToSummary,
                    child: Center(
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
