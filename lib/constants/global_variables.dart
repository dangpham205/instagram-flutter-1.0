
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/explore_screen.dart';
import 'package:instagram/screens/home_screen.dart';
import 'package:instagram/screens/post_screen.dart';
import 'package:instagram/screens/profile_screen.dart';

const webScreenSize = 600;

final homeScreenItems = [
  const HomeScreen(),
  const ExploreScreen(),
  const PostScreen(),
  Text('notiiiiiiiiiiiiiiiiii'),
  ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid),
];