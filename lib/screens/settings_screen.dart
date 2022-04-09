import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({ Key? key }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();        //phải pop 2 lần (1 lần quay lại màn profile, 1 lần đóng cái drawer)
            Navigator.of(context).pop();
          },
        ),
      ),
      body: const Center(child: Text('Setting Screen')),
    );
  }
}