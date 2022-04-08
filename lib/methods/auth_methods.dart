import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/methods/storage_methods.dart';
import 'package:instagram/models/user.dart' as model;        //user của class này trùng tên với instance user của firebase nên phải as

class AuthMethods {

  final FirebaseAuth _auth = FirebaseAuth.instance; 
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<model.User> getUserInfo() async{
    User currentUser = _auth.currentUser!;      //lấy thằng current User ra
    DocumentSnapshot snapshot = await _firestore.collection('users').doc(currentUser.uid).get();    
    //lấy snapshot đang chỉ tới document của thằng current user

    return model.User.fromSnapShot(snapshot);   //chuyển thành object User và return
  }

  // SIGN UP METHOD
  Future<String> signUp({
    required String email,
    required String username,
    required String password,
    Uint8List? image    
    //có thể truyền vô file null (tức là không có ảnh)
    //khi đó thì gọi hàm uploadImgToStorage sẽ check, nếu có ảnh thì sẽ upload lên và trả về url của ảnh đó
    //nếu image mà null thì sẽ trả về String 'default avatar'
    //sau này trong profile của user sẽ check xem nếu photoUrl của user đó mà là 'default avatar'
    //thì networkImage của ng đó sẽ truyền link avt mặc định vô (lên mạng kiếm)
    }) async {
      String res = 'Sign Up Failed';
      try{
        if (email.isNotEmpty && username.isNotEmpty && password.isNotEmpty ){
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
          //print(userCredential.user!.uid.toString());   //đăng kí, chưa lưu các thông tin khác lên database

          String photoUrl = await StorageMethods().uploadImgToStorage('avatarPics', image, false);

          model.User user = model.User(
            uid: userCredential.user!.uid,
            email: email,
            username: username,
            bio: '',
            followers: [],
            following: [],
            photoUrl: photoUrl,
          );
          //lưu thông tin username, avatar vô db
          await _firestore.collection('users').doc(userCredential.user!.uid).set(user.toJSON());
          await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);             //Bắt buộc phải có
          res = 'Sign Up Succeed';
        }
      } on FirebaseAuthException catch (error){
        if (error.code == 'email-already-in-use'){
          res = 'The email address is already in use by another account.';
        }
        else if (error.code == 'weak-password'){
          res = 'Password should be at least 6 characters.';
        }
        else if (error.code == 'invalid-email'){
          res = 'The email address is badly formatted.';
        }
        else{
          res = error.toString();
        }
      }
      return res;
  }

  // LOGIN METHOD
  Future<String> logIn({
    required String email,
    required String password,
    }) async{
      String res = 'Log In Failed';

      try{
        if (email.isNotEmpty &&  password.isNotEmpty ){
          await _auth.signInWithEmailAndPassword(email: email, password: password);
          res = 'Log In Succeed';
        }
        else{
          res = 'Please enter all the fields';
        }
      }
      on FirebaseAuthException catch (error){
        if (error.code == 'wrong-password'){
          res = 'Wrong password !!!';
        }
        else if (error.code == 'user-not-found'){
          res = 'Please enter a valid account.';
        }
        else if (error.code == 'too-many-requests'){
          res = 'Too many requests !!! Please try again later.';
        }
        else if (error.code == 'invalid-email'){
          res = 'The email address is badly formatted.';
        }
        else{
          res = error.toString();
        }
      }

      return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }


  Future<String> updateProfile({
    required String uid,
    required String username,
    required String bio,
    required String oldAvatar,
    Uint8List? image    
    }) async {
      String res = 'Update Failed';
      String avatarUrl = oldAvatar;
      try{
        if (username.isNotEmpty){
          if (image != null){
            avatarUrl = await StorageMethods().uploadImgToStorage('avatarPics', image, false);
          }

          //lưu thông tin username, avatar vô db
          await _firestore.collection('users').doc(uid).update({
            'username': username,
            'bio': bio,
            'photoUrl': avatarUrl,
          });
          res = 'Update Succeed';
        }
      } on FirebaseAuthException catch (error){
        res = error.toString();
      }
      return res;
  }
}