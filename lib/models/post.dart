import 'package:cloud_firestore/cloud_firestore.dart';

class Post{
  final String uid;
  final String postId;
  final String description;
  final DateTime uploadDate;
  final String postUrl;
  final likes;

  Post(
      {required this.uid,
      required this.postId,
      required this.description,
      required this.uploadDate,
      required this.postUrl,
      required this.likes,
  });

  

  Map<String, dynamic> toJSON() => {
    "uid": uid,
    "postId": postId,
    "description": description,
    "uploadDate": uploadDate,
    "postUrl": postUrl,
    'likes': likes
  };

  //static method là method có thể gọi thẳng từ lớp mà kh cần tạo obj
  // User.fromSnapShot()
  static Post fromSnapShot(DocumentSnapshot snapshot){
    var snap = snapshot.data() as Map<String, dynamic>;

    return Post(
        uid: snap['uid'],
        postId: snap['postId'],
        description: snap['description'],
        uploadDate: snap['uploadDate'],
        postUrl: snap['postUrl'],
        likes: snap['likes'], 
    );
  }
}