import 'package:flutter/material.dart';
import 'package:instagram/methods/auth_methods.dart';
import 'package:instagram/models/user.dart';

class UserProvider with ChangeNotifier{
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User u1 = const User(
    uid: 'default',
    email: 'default',
    username: 'default',
    bio: 'default',
    followers: [],
    following: [],
    photoUrl: 'default avatar',
  );
  User? get getUser => _user ?? u1;     //cái này đoạn đầu lúc get có thể null vì kết nối mạng chưa có thì sẽ chưa get đc

  Future<void> reloadUser() async{        //load lại user khi có thay đổi trên firebase
    User user = await _authMethods.getUserInfo();
    _user = user;
    notifyListeners();
  }
  
}