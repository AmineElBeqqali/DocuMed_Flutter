import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:documed/HomePage/HomePage.dart'; // Import your HomePage

class SummaryScreen extends StatelessWidget {
  final String cycle;
  final String version;
  final String promotion;
  final String documentName;

  const SummaryScreen({
    Key? key,
    required this.cycle,
    required this.version,
    required this.promotion,
    required this.documentName,
  }) : super(key: key);

  Future<void> _downloadFile(BuildContext context) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user is currently signed in.')),
        );
        return;
      }

      // Map the document name from the dropdown to the exact file names in Firebase Storage
      final Map<String, String> documentNameMap = {
        'Attestation de réussite': 'Attestation_de_réussite.pdf',
        'Attestation de scolarité': 'Attestation_de_scolarité.pdf',
        'Diplôme': 'Diplôme.pdf',
        'Relevé de notes (Semestre)': 'Relevé_de_notes_(Semestre).pdf',
      };

      final String? formattedDocumentName = documentNameMap[documentName];
      if (formattedDocumentName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid document name selected.')),
        );
        return;
      }

      final String filePath = 'user_files/${user.uid}/$formattedDocumentName';
      final Reference storageRef = FirebaseStorage.instance.ref().child(filePath);

      // Debugging: Print the file path
      print('Attempting to download file from path: $filePath');

      // Check if the file exists in Firebase Storage
      try {
        final fullUrl = await storageRef.getDownloadURL();
        print('File exists at: $fullUrl'); // This will throw an error if the file does not exist
      } catch (e) {
        print('Error getting download URL: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No object exists at the desired reference.')),
        );
        return;
      }

      // Request storage permissions
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission not granted.')),
        );
        return;
      }

      final Directory? downloadDir = await getExternalStorageDirectory();
      final String downloadPath = '${downloadDir?.path}/Download';
      final Directory downloadDirectory = Directory(downloadPath);

      if (!await downloadDirectory.exists()) {
        await downloadDirectory.create(recursive: true);
      }

      final File localFile = File('${downloadDirectory.path}/$formattedDocumentName');

      // Download the file
      await storageRef.writeToFile(localFile);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File downloaded to ${localFile.path}')),
      );

      OpenFile.open(localFile.path);
    } catch (e) {
      print('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 3,
                    offset: Offset(5, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 22),
                      Text(
                        'Promotion: $promotion',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      SizedBox(height: 22),
                      Divider(color: Colors.lightBlueAccent),
                      Text(
                        'Version: $version',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      SizedBox(height: 22),
                      Divider(color: Colors.lightBlueAccent),
                      Text(
                        'Cycle: $cycle',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      SizedBox(height: 22),
                      Divider(color: Colors.lightBlueAccent),
                      Text(
                        'Your request has been submitted and will be processed soon. It\'ll be ready to print soon',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Divider(color: Colors.lightBlueAccent),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.lightBlueAccent),
                              elevation: MaterialStateProperty.all(20),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Annuler',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.lightBlueAccent),
                              elevation: MaterialStateProperty.all(20),
                            ),
                            onPressed: () => _downloadFile(context),
                            child: Text(
                              'Download',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Icon(Icons.home, color: Colors.lightBlueAccent),
            ),
          ),
        ],
      ),
    );
  }
}
