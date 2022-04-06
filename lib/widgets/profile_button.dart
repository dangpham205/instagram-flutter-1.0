import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {
  final Function()? function;
  final Color buttonColor;
  final Color borderColor;
  final String buttonText;
  final Color buttonTextColor;
  const ProfileButton(
      {Key? key,
      this.function,
      required this.buttonColor,
      required this.borderColor,
      required this.buttonText, 
      required this.buttonTextColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton(
        onPressed: function,
        child: Container(
          decoration: BoxDecoration(
            color: buttonColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(buttonText, style: TextStyle(fontWeight: FontWeight.bold, color: buttonTextColor),),
          width: MediaQuery.of(context).size.width*0.8,
          height: 36,
        ),
      ),
    );
  }
}