import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/colors.dart';
import '../constants/utils.dart';

class EditProfileScreen extends StatefulWidget {
  final String uid;
  const EditProfileScreen({ Key? key, required this.uid }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  var userData = {};
  bool isLoading = false;
  Uint8List? _avatar;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isUpdating = false;


  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _usernameController.dispose();      //very important
    _passwordController.dispose();
  }

  void selectAvatar() async {
    try{        //trường hợp: người dùng bấm chọn ảnh mà cancel không chọn nữa ==> không thể cast null cho Uint8list
      Uint8List img =  await pickImage(ImageSource.gallery);
      setState(() {
      _avatar = img;
      });
    }
    catch (error){
      return;
    }
  }

  getUserData() async {
    setState(() {
      isLoading = true;
    });
    var userSnapShot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();
    userData = userSnapShot.data()!;

    setState(() {
      isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center(
      child: CircularProgressIndicator(),
    )
    :
    Scaffold(
      appBar: AppBar(backgroundColor: mobileBackgroundColor),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SafeArea(
            child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            width: double.infinity,   //return width cua man hinh
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,    //center tat ca children theo chieu truc cross ==> chieu ngang
              children: [
                Flexible(child: Container(), flex: 2,),
                // SvgPicture.asset('assets/ic_instagram.svg', color: primaryColor, height: 48,),
                const SizedBox(height: 36,),
                Stack(
                children:  [
                  _avatar != null ?     //nếu image khác null thì hiện image đó lên
                  CircleAvatar(
                    radius: 64,
                    backgroundImage: MemoryImage(_avatar!),
                  )
                  : CircleAvatar(   //còn không thì hiện avt mặc định
                    radius: 64,
                    backgroundImage: NetworkImage(userData['photoUrl'].toString()),
                  ),   //avatar mặc định
                  Positioned(     //nút thêm ảnh avatar
                    bottom: -6,
                    left: 80,
                    child: IconButton(
                      onPressed: selectAvatar,
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  )
                ],
              ),
                const SizedBox(height: 28,),
                UserName(usernameController: _usernameController),
                const SizedBox(height: 28,),
                UserEmail(emailController: _emailController),
                const SizedBox(height: 28,),
                UserPassword(passwordController: _passwordController),
                const SizedBox(height: 28,),
                InkWell(                        //button login
                  onTap: () {},      //gọi hàm signUpUser
                  child: Container(        
                    child: _isUpdating
                        ? const Center(         //nếu mà bấm sign up thì sẽ hiện vòng load
                            child: CircularProgressIndicator(color: Colors.white,),
                          ) 
                        : const Text('UPDATE'),  //sign up xong thì sẽ quay lại hiện chữ trong button (đọc hàm signUpUser)
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 46,
                    decoration: const ShapeDecoration(
                      color: loginButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28,),
                Flexible(child: Container(), flex: 2,),
                Row(                    //text de chuyen sang sign up screen
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [
                    const Text("Already have an account?"),
                    const SizedBox(width: 10,),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 22,),
              ],
            ),
          )),
        ),
      ),
    );
  }
}

class UserPassword extends StatelessWidget {
  const UserPassword({
    Key? key,
    required TextEditingController passwordController,
  }) : _passwordController = passwordController, super(key: key);

  final TextEditingController _passwordController;

  @override
  Widget build(BuildContext context) {
    // return TextInput(
    //     textEditingController: _passwordController,
    //     hintText: 'Enter Password',
    //     textInputType: TextInputType.text,
    //     isPassword: true,
    // );
    return TextFormField(
      textInputAction: TextInputAction.go,
      controller: _passwordController,
      decoration: const InputDecoration(
        hintText: 'Enter Password',
      ),
      keyboardType: TextInputType.text,
      obscureText: true
    );
  }
}

class UserName extends StatelessWidget {
  const UserName({
    Key? key,
    required TextEditingController usernameController,
  }) : _usernameController = usernameController, super(key: key);

  final TextEditingController _usernameController;

  @override
  Widget build(BuildContext context) {
    // return TextInput(

    //     textEditingController: _usernameController,
    //     hintText: 'Enter Username',
    //     textInputType: TextInputType.text,
        
    // );
    return TextFormField(
      textInputAction: TextInputAction.next,
      controller: _usernameController,
      decoration: const InputDecoration(
        hintText: 'Enter Username',
      ),
      keyboardType: TextInputType.text,
    );
  }
}

class UserEmail extends StatelessWidget {
  const UserEmail({
    Key? key,
    required TextEditingController emailController,
  }) : _emailController = emailController, super(key: key);

  final TextEditingController _emailController;

  @override
  Widget build(BuildContext context) {
    // return TextInput(
    //     textEditingController: _emailController,
    //     hintText: 'Enter Email',
    //     textInputType: TextInputType.emailAddress,
    // );
    return TextFormField(
      textInputAction: TextInputAction.next,
      controller: _emailController,
      decoration: const InputDecoration(
        hintText: 'Enter Email',
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }
}