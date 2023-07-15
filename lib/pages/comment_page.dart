import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/components/comment.dart';
import 'package:socialmedia/components/writing_field.dart';
import 'package:socialmedia/helper/helper_methods.dart';

class CommentPage extends StatefulWidget {
  final String postId;

  const CommentPage({super.key, required this.postId});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  late Stream<QuerySnapshot> _commentsStream;
  late List<DocumentSnapshot> _comments;
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _commentsStream = FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .orderBy("CommentTime", descending: true)
        .snapshots();
    _comments = [];
  }

  Future<void> _fetchComments() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("User Posts")
          .doc(widget.postId)
          .collection("Comments")
          .orderBy("CommentTime", descending: true)
          .get();

      setState(() {
        _comments = snapshot.docs;
      });
    } catch (error) {
      //print('Error fetching comments: $error');
    }
  }

  void postComment() {
    final commentText = _commentTextController.text.trim();
    if (commentText.isNotEmpty) {
      final currentUser = FirebaseAuth.instance.currentUser!;
      final userEmail = currentUser.email!;
      final usersCollection =
          FirebaseFirestore.instance.collection("Users").doc(userEmail);

      usersCollection.get().then((userDoc) {
        if (userDoc.exists) {
          final username = userDoc.data()?['username'];

          FirebaseFirestore.instance
              .collection("User Posts")
              .doc(widget.postId)
              .collection("Comments")
              .add({
            "CommentText": commentText,
            "CommentedBy": username,
            "CommentTime": Timestamp.now(),
          }).then((_) {
            setState(() {
              _commentTextController.clear();
            });
          }).catchError((error) {
            // Handle error
            //print('Error posting comment: $error');
          });
        }
      }).catchError((error) {
        // Handle error
        //print('Error retrieving user: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchComments,
              child: StreamBuilder<QuerySnapshot>(
                stream: _commentsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    _comments = snapshot.data!.docs;

                    if (_comments.isEmpty) {
                      return const Center(
                        child: Text('No comments yet'),
                      );
                    }

                    return ListView.builder(
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final commentData =
                            _comments[index].data() as Map<String, dynamic>;
                        return Comment(
                          text: commentData["CommentText"],
                          user: commentData["CommentedBy"],
                          time: returnAgos(commentData["CommentTime"]),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: WritingField(
                    controller: _commentTextController,
                    hintText: 'Write a comment..',
                    obscureText: false,
                  ),
                ),
                IconButton(
                  onPressed: postComment,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
