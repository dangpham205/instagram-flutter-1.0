import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  
  final TextEditingController textEditingController;
  final bool isPassword;
  final String hintText;
  final TextInputType textInputType;
  const TextInput(
      {Key? key,
      required this.textEditingController,
      this.isPassword = false,    //chỉ lúc nào là trường pass thì mới là true nên set default này là false luôn
      required this.hintText,
      required this.textInputType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context)
      );
    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: hintText, 
        border: inputBorder,
        focusedBorder: inputBorder, 
        enabledBorder: inputBorder, 
        filled: true,
        contentPadding: const EdgeInsets.all(8),
      ),
      keyboardType: textInputType,
      obscureText: isPassword,
    );
  }
}