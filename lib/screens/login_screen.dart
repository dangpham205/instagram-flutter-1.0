
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/constants/colors.dart';
import 'package:instagram/responsive/responsive_layout.dart';
import 'package:instagram/screens/signup_screen.dart';
import 'package:instagram/methods/auth_methods.dart';

import '../constants/utils.dart';
import '../responsive/mobile_screen_layout.dart';
import '../responsive/web_screen_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({ Key? key }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;


  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();      //very important
    _passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });   

    String res = await AuthMethods().logIn(email: _emailController.text, password: _passwordController.text);
    if (res == 'Log In Succeed'){   //succeed thif chuyen sang trang main
      Navigator.of(context).pushReplacement(    //nếu chỉ dùng push thì bấm back vẫn có thể quay lại screen trc
      MaterialPageRoute(
        builder: (context) => const ResponsiveLayout(
                                                webScreenLayout: WebScreenLayout(),
                                                mobileScreenLayout: MobileScreenLayout(),
                                              ),
      ),
    );
    }
    else{
      showSnackBar(context, res);
    }

    setState(() {
      _isLoading = false;
    }); 
  }

  void navigateToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
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
                const SizedBox(height: 64,),
                UserEmail(emailController: _emailController),
                const SizedBox(height: 28,),
                UserPassword(passwordController: _passwordController),
                const SizedBox(height: 28,),
                InkWell(                        //button login
                  onTap: loginUser,
                  child: Container(        
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('LOG IN'),
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
                    const Text("Don't have an account?"),
                    const SizedBox(width: 10,),
                    GestureDetector(
                      onTap: navigateToSignUp,
                      child: const Text(
                        'Sign Up',
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

class UserEmail extends StatelessWidget {
  const UserEmail({
    Key? key,
    required TextEditingController emailController,
  }) : _emailController = emailController, super(key: key);

  final TextEditingController _emailController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.next,
      controller: _emailController,
      decoration: const InputDecoration(
        hintText: 'Enter Email or Username',
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }
}