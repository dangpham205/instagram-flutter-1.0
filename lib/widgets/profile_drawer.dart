import 'package:flutter/material.dart';
import 'package:instagram/constants/colors.dart';
import 'package:instagram/screens/settings_screen.dart';
import 'package:instagram/widgets/yes_no_dialog.dart';

import '../methods/auth_methods.dart';
import '../screens/login_screen.dart';

class ProfileDrawer extends StatefulWidget {
  const ProfileDrawer({ Key? key }) : super(key: key);

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: darkColor,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 48,),
            drawerItem(
              text: 'Settings',
              icon: Icons.settings,
              function: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ));
              },
            ),
            drawerItem(
              text: 'Saved',
              icon: Icons.bookmark,
              function: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ));
              }
            ),
            const Divider(color: Colors.white,),
            drawerItem(
              text: 'Log Out',
              icon: Icons.logout,
              function: () async {
                showDialog(context: context, builder: (context) => YesNoDialog(
                  function: () async {
                    await AuthMethods().signOut();
                    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
                    Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (BuildContext context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  title: 'Log Out', 
                  content: 'Do you really want to log out? :('));
              },
            )
          ],
        ),
      ),
    );
  }

  Widget drawerItem({required String text, required IconData icon, VoidCallback? function}) {
    
    const color = Colors.white;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: const TextStyle(color: color),),
      onTap:function,
    );
  }
}