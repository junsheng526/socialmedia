import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:socialmedia/components/comment_button.dart';
import 'package:socialmedia/components/like_button.dart';
import 'package:socialmedia/pages/comment_page.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final int commentCount;
  final List<String> likes;

  const WallPost(
      {super.key,
      required this.message,
      required this.user,
      required this.postId,
      required this.commentCount,
      required this.likes,
      required this.time});

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  // comment text controller
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  // toggle like

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    // Access the document is Firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      // if the post is now liked add the user's email to the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      // if the post is now unliked, remove the user's email from the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  // add a comment
  void addComment(String commentText) {
    // write the comment to firestore under the comments collection for this post
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email!.split('@')[0],
      "CommentTime": Timestamp.now() //remember to format this when displaying
    });
  }

  // show a dialog box for adding comment
  void showCommentDislog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Comment"),
        content: TextField(
          controller: _commentTextController,
          decoration: const InputDecoration(hintText: "Write a comment..."),
        ),
        actions: [
          // cancel button
          TextButton(
            onPressed: () {
              // pop box
              Navigator.pop(context);
              // clear controller
              _commentTextController.clear();
            },
            child: const Text("Cancel"),
          ),
          // post button
          TextButton(
            onPressed: () {
              // add comment
              addComment(_commentTextController.text);
              // pop box
              Navigator.pop(context);
              // clear controller
              _commentTextController.clear();
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  void _goToCommentPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentPage(postId: widget.postId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int commentCount = 0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // message and user email
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // id
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.postId,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(widget.time),
                ],
              ),

              const SizedBox(height: 15),
              // message
              ReadMoreText(
                widget.message,
                trimLines: 3,
                textAlign: TextAlign.justify,
                trimMode: TrimMode.Line,
                trimCollapsedText: " Show More ",
                trimExpandedText: " Show Less ",
                moreStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                lessStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 5),
            ],
          ),

          const SizedBox(height: 20),

          // button
          // Like and Comment buttons in a row
          Row(
            children: [
              LikeButton(
                isLiked: isLiked,
                onTap: toggleLike,
              ),
              const SizedBox(width: 20),
              GestureDetector(
                // Navigate to CommentPage
                child: CommentButton(
                  onTap: () => _goToCommentPage(context),
                ),
              ),
            ],
          ),

          // Like and Comment count numbers in a row
          Row(
            children: [
              const SizedBox(width: 5),
              Column(
                children: [
                  const SizedBox(height: 5),
                  Text(
                    "${widget.likes.length} likes",
                  ),
                ],
              ),
              const SizedBox(width: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .doc(widget.postId)
                    .collection("Comments")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(); // Return an empty widget if there's no data yet
                  }

                  // Update commentCount with the new count
                  commentCount = snapshot.data!.docs.length;

                  return Column(
                    children: [
                      const SizedBox(height: 5),
                      Text(
                        '$commentCount replies',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
