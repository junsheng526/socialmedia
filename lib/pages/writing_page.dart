import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/components/writing_field.dart';

class WritingPage extends StatefulWidget {
  const WritingPage({super.key});

  @override
  State<WritingPage> createState() => _WritingPageState();
}

class _WritingPageState extends State<WritingPage> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

  // text controller
  final textController = TextEditingController();

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void postMessage() {
    if (textController.text.isNotEmpty) {
      String message = textController.text;
      FirebaseFirestore.instance
          .collection("User Posts")
          .orderBy('TimeStamp', descending: true)
          .limit(1)
          .get()
          .then((querySnapshot) {
        String lastId = 'TC000000'; // Default starting ID
        if (querySnapshot.docs.isNotEmpty) {
          // If there are existing documents, extract the last ID
          lastId = querySnapshot.docs.first.id;
        }

        // Extract the numeric part of the ID, increment it, and pad it with zeros
        int lastNumericId = int.parse(lastId.substring(2));
        int nextNumericId = lastNumericId + 1;
        String nextId = 'TC${nextNumericId.toString().padLeft(6, '0')}';

        // Store the post in Firebase with the generated ID
        FirebaseFirestore.instance.collection("User Posts").doc(nextId).set({
          'UserEmail': currentUser.email,
          'Message': message,
          'TimeStamp': Timestamp.now(),
          'Likes': [],
        });
      });
    }

    // Clear the textfield
    setState(() {
      textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Writing Page"),
      ),
      body: Center(
        child: Column(
          children: [
            // post message
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  // text field
                  Expanded(
                    child: WritingField(
                      controller: textController,
                      hintText: 'Write something on the wall..',
                      obscureText: false,
                    ),
                  ),

                  // post button
                  IconButton(
                      onPressed: postMessage, icon: const Icon(Icons.send))
                ],
              ),
            ),

            // logged in as
            Text(
              "Logged in as: ${currentUser.email!}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
