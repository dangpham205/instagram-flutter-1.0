import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/constants/colors.dart';
import 'package:instagram/methods/firestore_methods.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';
import '../widgets/comment_card.dart';

class CommentScreen extends StatefulWidget {
  final snap;
  const CommentScreen({ Key? key, this.snap, }) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {

  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser; //lấy ra th user hiện tại


    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Comments'),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .orderBy('uploadDate', descending: false)
          .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) => CommentCard(
              snap: snapshot.data!.docs[index].data(),    //truyền vô cái snap chứa thông tin của comment đó
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          // color: Colors.white,
          height: kToolbarHeight,
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom+4),
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                //avatar
                radius: 18,
                backgroundImage: NetworkImage(user!.photoUrl), //dùng snap lấy ra avatar của user
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 4),
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Type your comment',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  await FirestoreMethods().uploadComment(
                      widget.snap['postId'],
                      user.uid,
                      user.username,
                      user.photoUrl,
                      _commentController.text,
                  );
                  _commentController.text = '';         //sau khi comment xong thi set phần comment về trống không
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: const Text(
                    'POST',
                    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}