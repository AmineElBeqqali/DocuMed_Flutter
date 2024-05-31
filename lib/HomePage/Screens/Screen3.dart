import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Login/SignIn.dart';

class Screen3 extends StatefulWidget {
  const Screen3({super.key});

  @override
  State<Screen3> createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  User? _currentUser;
  String? _userImageURL;
  String? _userName;
  String? _userCIN;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _loadUserImage();
      _loadUserData();
    }
  }

  Future<void> _loadUserImage() async {
    if (_currentUser != null) {
      try {
        String imageName = 'profile.png';
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('user_files')
            .child(_currentUser!.uid)
            .child(imageName);
        String imageURL = await ref.getDownloadURL();
        setState(() {
          _userImageURL = imageURL;
        });
      } catch (e) {
        print('Error loading user image: $e');
        setState(() {
          _userImageURL = ''; // Set to empty string if there's an error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user image. Please check the storage path and permissions.')),
        );
      }
    }
  }

  Future<void> _loadUserData() async {
    if (_currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        setState(() {
          _userName = userDoc['name'];
          _userCIN = userDoc['CIN'].toString(); // Convert CIN to string
        });
      } catch (e) {
        print('Error loading user data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data. Please check the Firestore path and permissions.')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()), // Ensure the correct widget is used for SignIn
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.lightBlueAccent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 100),
                Center(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    padding: EdgeInsets.all(8),
                    child: ClipOval(
                      child: _userImageURL != null && _userImageURL!.isNotEmpty
                          ? Image.network(
                        _userImageURL!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      )
                          : _userImageURL == null
                          ? CircularProgressIndicator()
                          : Text('No image found.'),
                    ),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(width: 0.4, color: Colors.white),
                    ),
                  ),
                ),
                Divider(
                  height: 150,
                  endIndent: 60,
                  indent: 60,
                  color: Colors.blue[700],
                  thickness: 5,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        border: Border.all(width: 3, color: Colors.blue),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: Text('Name', style: TextStyle(color: Colors.blue[700])),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Text(
                                _userName ?? 'Loading...',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: Text('CIN', style: TextStyle(color: Colors.blue[700])),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Text(
                                _userCIN ?? 'Loading...',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.email, color: Colors.blue[700]),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    child: Text(
                                      _currentUser?.email ?? 'Loading...',
                                      style: TextStyle(color: Colors.blue[700]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: FloatingActionButton(
              elevation: 30,
              onPressed: _signOut,
              backgroundColor: Colors.white,
              child: Icon(Icons.exit_to_app, color: Colors.lightBlueAccent),
            ),
          ),
        ],
      ),
    );
  }
}
