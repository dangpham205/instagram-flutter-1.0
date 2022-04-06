import 'package:flutter/material.dart';
import 'package:instagram/constants/global_variables.dart';
import 'package:instagram/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;

  
  const ResponsiveLayout({ Key? key, required this.webScreenLayout, required this.mobileScreenLayout }) : super(key: key);

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {

  @override
  void initState() {
    super.initState();
    addData();
  }

  addData() async {
    UserProvider _userProvider = Provider.of(context, listen: false);
    await _userProvider.reloadUser();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(         // helps to build responsive layout
      builder: (context, constraints){      //come with a constraint, can use to get the width, height of the parrent
        if (constraints.maxWidth > webScreenSize){
          return widget.webScreenLayout;     //nếu màn hình to thì load web layout
        }
        //else mobile screen
        return widget.mobileScreenLayout;
      },
    );
  }

  
}