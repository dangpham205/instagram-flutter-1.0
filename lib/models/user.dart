import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  final String uid;
  final String email;
  final String username;
  final String bio;
  final List followers;
  final List following;
  final String photoUrl;

  const User({
      required this.uid,
      required this.email,
      required this.username,
      required this.bio,
      required this.followers,
      required this.following,
      required this.photoUrl,
  });

  Map<String, dynamic> toJSON() => {
    "uid": uid,
    "email": email,
    "username": username,
    "bio": bio,
    "followers": followers,
    "following": following,
    "photoUrl": photoUrl,
  };

  //static method là method có thể gọi thẳng từ lớp mà kh cần tạo obj
  // User.fromSnapShot()
  static User fromSnapShot(DocumentSnapshot snapshot) {

    
    var snap = snapshot.data()! as Map<String, dynamic>;   //cast snapshot thành dạng Map

    return User(    //chuyển thành object User và return
      uid: snap['uid'],
      email: snap['email'],
      username: snap['username'],
      bio: snap['bio'],
      followers: snap['followers'],
      following: snap['following'],
      photoUrl: snap['photoUrl']
    );
  }
    
}