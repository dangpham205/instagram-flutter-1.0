import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/constants/colors.dart';
import 'package:instagram/constants/utils.dart';
import 'package:instagram/methods/firestore_methods.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/providers/user_provider.dart';
import 'package:provider/provider.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({ Key? key }) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  
  Uint8List? image;
  Uint8List? _image;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;


  _selectImage(BuildContext context) async {
    return showDialog(context: context, builder: (context) {
      return SimpleDialog(
        title: const Text('Upload Media'),
        children: [
          SimpleDialogOption(
            padding: const EdgeInsets.all(12),
            child: const Text('Take a photo'),
            onPressed: () async {
              Navigator.of(context).pop();
              try{
                image = await pickImage(ImageSource.camera);
              }
              catch (error){
                image = null;
              }
              setState(() {
                if( image != null){
                  _image = image;
                }
              });
            },
          ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(12),
            child: const Text('Choose from gallery'),
            onPressed: () async {
              Navigator.of(context).pop();
              try{
                image = await pickImage(ImageSource.gallery);
              }
              catch (error){
                image = null;
              }
              setState(() {
                if (image != null){
                  _image = image;
                }
              });
            },
          ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(12),
            child: const Text('Cancel'),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }

  void uploadPost(
    String uid,
    String username,
    String avatarUrl,
  ) async {
    setState(() {
      _isLoading = true;
    });
    try{
      String res = await FirestoreMethods().uploadPost(
          uid, 
          username, 
          _descriptionController.text, 
          _image!, 
          avatarUrl
      );

      if (res == 'Upload Succeed'){
        setState(() {
          _isLoading = false;
        });
        showSnackBar(context, res);
        clearScreen();
      }
      else{
        setState(() {
          _isLoading = false;
        });
        showSnackBar(context, res);
      }
    }
    catch(error){
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, error.toString());
    }
  }

  void clearScreen(){
    setState(() {
      _image = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final User? user = Provider.of<UserProvider>(context).getUser;      //get thằng user hiện tại ra

    return _image == null ? Center(
      child: IconButton(
        iconSize: 50,
        icon: const Icon(Icons.upload),
        onPressed: () => _selectImage(context),
      ),
    ) :

    SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: mobileBackgroundColor,
            leading: IconButton(
              onPressed: clearScreen,
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text('Post to'),
            actions: [                //nút Post
              TextButton(
                onPressed: () => uploadPost( user!.uid, user.username, user.photoUrl),
                child: const Text(
                  'POST', 
                  style: TextStyle(
                    color: Colors.blueAccent, 
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              _isLoading ? const LinearProgressIndicator() : Container(),   //show indicator khi bấm nút POST
              const Divider(color: Colors.white,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      user!.photoUrl,
                    ),   
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.7,
                    child: TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText: "What's on your mind?",
                        border: InputBorder.none,
                      ),
                      maxLines: 10,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white,),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*0.4,
                child: AspectRatio(
                  aspectRatio: 487/451,
                  child: Container(
                    decoration: BoxDecoration(
                      color: blueColor,
                      image: DecorationImage(
                        image: MemoryImage(_image!),
                        fit: BoxFit.contain,
                        alignment: FractionalOffset.topCenter
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}