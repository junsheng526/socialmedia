import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/components/drawer.dart';
import 'package:socialmedia/components/wall_post.dart';
import 'package:socialmedia/helper/helper_methods.dart';
import 'package:socialmedia/pages/profile_page.dart';
import 'package:socialmedia/pages/settings_page.dart';
import 'package:socialmedia/pages/writing_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

  // text controller
  final textController = TextEditingController();

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void postMessage() {
    // only post if there is something in the textfield
    if (textController.text.isNotEmpty) {
      // store in firebase
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }

    // clear the textfield
    setState(() {
      textController.clear();
    });
  }

  // navigate to profile page
  void goToProfilePage() {
    //pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  // navigate to writing page
  void goToWritingPage() {
    //pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WritingPage(),
      ),
    );
  }

  // navigate to settings page
  void goToSettingsPage() {
    //pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  late Stream<QuerySnapshot> _postsStream;
  late List<DocumentSnapshot> _data;
  List<DocumentSnapshot> _filteredData = [];

  @override
  void initState() {
    super.initState();
    _isSearching = false;
    _postsStream = FirebaseFirestore.instance
        .collection("User Posts")
        .orderBy("TimeStamp", descending: true)
        .snapshots();
    _data = [];
    _filteredData = [];
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("User Posts")
          .orderBy("TimeStamp", descending: true)
          .get();

      setState(() {
        _data = snapshot.docs;
        _filteredData = _data;
      });
    } catch (error) {
      //print('Error fetching data: $error');
    }
  }

  void searchPosts(String postId) {
    setState(() {
      _filteredData = filterPosts(_data, _searchQuery);
    });
  }

  String _searchQuery = '';
  bool _isSearching = false;
  IconData _searchIcon = Icons.search;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: _isSearching
            ? TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  searchPosts(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search by ID',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                ),
              )
            : const Text("TARUMT Confession"),
        actions: [
          IconButton(
            icon: Icon(_searchIcon),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (_isSearching) {
                  _searchIcon = Icons.close;
                } else {
                  _searchIcon = Icons.search;
                  _searchQuery = '';
                  searchPosts('');
                }
              });
            },
          ),
        ],
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onWritingTap: goToWritingPage,
        onSignOut: signOut,
        onSettingsTap: goToSettingsPage,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: ListView.builder(
          itemCount: _filteredData.length,
          itemBuilder: (context, index) {
            final post = _filteredData[index].data() as Map<String, dynamic>;
            return WallPost(
              message: post['Message'],
              user: post['UserEmail'],
              postId: _filteredData[index].id,
              likes: List<String>.from(post['Likes'] ?? []),
              commentCount: post['CommentCount'] ?? 0,
              time: formatDateTime(post['TimeStamp']),
            );
          },
        ),
      ),
    );
  }
}

List<DocumentSnapshot> filterPosts(List<DocumentSnapshot> data, String postId) {
  if (postId.isEmpty) {
    return data;
  } else {
    return data
        .where((snapshot) =>
            snapshot.id.toLowerCase().contains(postId.toLowerCase()))
        .toList();
  }
}
