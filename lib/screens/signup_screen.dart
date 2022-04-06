import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/constants/colors.dart';
import 'package:instagram/constants/utils.dart';
import 'package:instagram/methods/auth_methods.dart';
import 'package:instagram/widgets/input_text.dart';

import '../responsive/mobile_screen_layout.dart';
import '../responsive/responsive_layout.dart';
import '../responsive/web_screen_layout.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({ Key? key }) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Uint8List? _avatar;
  bool _isLoading = false;


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

  void signUpUser() async {        
    setState(() {
      _isLoading = true;
    });        

    String res = await AuthMethods().signUp(
      email: _emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      image: _avatar);
    if (res != 'Sign Up Succeed'){
      showSnackBar(context, res);
    }
    else{
      Navigator.of(context).pushReplacement(      //nếu chỉ dùng push thì bấm back vẫn có thể quay lại screen trc
      MaterialPageRoute(
        builder: (context) => const ResponsiveLayout(
                                                webScreenLayout: WebScreenLayout(),
                                                mobileScreenLayout: MobileScreenLayout(),
                                              ),
      ),
    );
    }

    setState(() {
      _isLoading = false;
    }); 
  }

  void navigateToLogIn() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                SvgPicture.asset('assets/ic_instagram.svg', color: primaryColor, height: 48,),
                const SizedBox(height: 36,),
                Stack(
                children:  [
                  _avatar != null ?     //nếu image khác null thì hiện image đó lên
                  CircleAvatar(
                    radius: 64,
                    backgroundImage: MemoryImage(_avatar!),
                  )
                  : const CircleAvatar(   //còn không thì hiện avt mặc định
                    radius: 64,
                    backgroundImage: NetworkImage('https://images.squarespace-cdn.com/content/v1/54b7b93ce4b0a3e130d5d232/1519987020970-8IQ7F6Z61LLBCX85A65S/icon.png?format=1000w'),
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
                  onTap: signUpUser,      //gọi hàm signUpUser
                  child: Container(        
                    child: _isLoading
                        ? const Center(         //nếu mà bấm sign up thì sẽ hiện vòng load
                            child: CircularProgressIndicator(color: Colors.white,),
                          ) 
                        : const Text('SIGN UP'),  //sign up xong thì sẽ quay lại hiện chữ trong button (đọc hàm signUpUser)
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
                      onTap: navigateToLogIn,
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
    return TextInput(
        textEditingController: _passwordController,
        hintText: 'Enter Password',
        textInputType: TextInputType.text,
        isPassword: true,
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
    return TextInput(

        textEditingController: _usernameController,
        hintText: 'Enter Username',
        textInputType: TextInputType.text,
        
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
    return TextInput(
        textEditingController: _emailController,
        hintText: 'Enter Email',
        textInputType: TextInputType.emailAddress,
    );
  }
}

