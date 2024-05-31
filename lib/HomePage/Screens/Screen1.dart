import 'package:documed/HomePage/Screens/Screen2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../Demande/document_request_screen.dart';
import '../HMSS_Pages/Messages.dart';
import '../HMSS_Pages/Scolarite.dart';
import '../HMSS_Pages/Support.dart';
import 'package:documed/download_option/dropdownpage.dart';
import 'package:documed/download_option/download_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Screen1(),
      ),
    );
  }
}

class Screen1 extends StatefulWidget {
  @override
  _Screen1State createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;

  User? _currentUser;
  String? _userImageURL;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _heightAnimation = Tween<double>(begin: 0.50, end: 0.50).animate(_controller);
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _loadUserImage();
    }
  }

  Future<void> _loadUserImage() async {
    if (_currentUser != null) {
      try {
        // Use UID as the identifier and look for profile.png inside the user's folder
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.fromLTRB(0, 110, 0, 0),
      color: Colors.lightBlueAccent,
      child: Column(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 50),
              padding: EdgeInsets.all(7),
              child: ClipOval(
                child: _userImageURL != null && _userImageURL!.isNotEmpty
                    ? Image.network(
                  _userImageURL!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
                    : _userImageURL == null
                    ? CircularProgressIndicator()
                    : Text('No image found.'),
              ),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(90),
                border: Border.all(width: 0.5, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
            child: Align(
              alignment: Alignment.center,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Material(
                      elevation: 200.0,
                      borderRadius: BorderRadius.circular(20.0),
                      shadowColor: Colors.black,
                      child: Container(
                        width: screenWidth * 0.93,
                        height: screenHeight * _heightAnimation.value*0.42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ListTile(
                                  title: const Text(
                                    'Scolarite',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 18,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => DocumentRequestScreen()));
                                  },
                                ),
                                const Divider(color: Colors.grey),
                                ListTile(
                                  title: const Text(
                                    'Support',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 18,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => Support()));
                                  },
                                ),
                                const Divider(color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
