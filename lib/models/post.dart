import 'package:cloud_firestore/cloud_firestore.dart';

class Post{
  final String uid;
  final String username;
  final String postId;
  final String description;
  final DateTime uploadDate;
  final String postUrl;
  final String avatarUrl;
  final likes;

  Post(
      {required this.uid,
      required this.username,
      required this.postId,
      required this.description,
      required this.uploadDate,
      required this.postUrl,
      required this.avatarUrl,
      required this.likes,
  });

  

  Map<String, dynamic> toJSON() => {
    "uid": uid,
    "username": username,
    "postId": postId,
    "description": description,
    "uploadDate": uploadDate,
    "postUrl": postUrl,
    "avatarUrl": avatarUrl,
    'likes': likes
  };

  //static method là method có thể gọi thẳng từ lớp mà kh cần tạo obj
  // User.fromSnapShot()
  static Post fromSnapShot(DocumentSnapshot snapshot){
    var snap = snapshot.data() as Map<String, dynamic>;

    return Post(
        uid: snap['uid'],
        username: snap['username'],
        postId: snap['postId'],
        description: snap['description'],
        uploadDate: snap['uploadDate'],
        postUrl: snap['postUrl'],
        avatarUrl: snap['avatarUrl'],
        likes: snap['likes'], 
    );
  }
}