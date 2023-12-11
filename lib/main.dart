import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'firebase_options.dart'; 







void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase was initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _textEditingController = TextEditingController();
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firestore Example'),
        ),
        body: Container(
          color: const Color.fromARGB(255, 200, 230, 255), 
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    labelText: 'Add a new user',
                  ),
                ),
                SizedBox(height: 16.0), 
                ElevatedButton(
                  onPressed: () {
                    _addUser();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0), 
                    child: Text(
                      'Add',
                      style: TextStyle(fontSize: 16.0), 
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 100, 200, 100), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), 
                    ),
                  ),
                ),
                SizedBox(height: 16.0), 
                StreamBuilder<QuerySnapshot>(
                  stream: _usersCollection.snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error loading data: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading...");
                    }

                    if (snapshot.hasData && snapshot.data != null) {
                      return Expanded(
                        child: ListView(
                          children: snapshot.data!.docs.map((DocumentSnapshot document) {
                            return ListTile(
                              title: Text('Username: ${document.id}'),
                              subtitle: Text('Data: ${document.data()}'),
                            );
                          }).toList(),
                        ),
                      );
                    } else {
                      return Text('No data available');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addUser() {
    String username = _textEditingController.text.trim();
    if (username.isNotEmpty) {
      _usersCollection.doc(username).set({'timestamp': DateTime.now()});
      _textEditingController.clear();

      setState(() {});
    }
  }
}
