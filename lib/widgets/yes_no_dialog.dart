import 'package:flutter/material.dart';

class YesNoDialog extends StatefulWidget {
  final Function()? function;
  final String title;
  final String content; 
  final Image? image;
  const YesNoDialog({
    Key? key,
    this.function,
    required this.title,
    required this.content,
    this.image,
  }) : super(key: key);

  @override
  State<YesNoDialog> createState() => _YesNoDialogState();
}

class _YesNoDialogState extends State<YesNoDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: buildDialog(context),
    );
  }

  buildDialog(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 30, bottom: 20, left: 16, right: 16),
          // margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10.0,
                offset: Offset(0.0,10.0)
              ),
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),),
              const SizedBox(height: 32,),
              Text(widget.content, style: const TextStyle( color: Colors.black),),
              const SizedBox(height: 40,),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.red
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        }, 
                        child: const Text('Cancel', style: TextStyle(color: Colors.white),),
                        ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue
                      ),
                      child: TextButton(
                        onPressed: widget.function, 
                        child: const Text('Yes', style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        const Positioned(
          top: 0,
          left: 60,
          right: 0,
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            backgroundImage: AssetImage('assets/gif2.gif'),
            radius: 40,
          ),
        )
      ],
    );
  }
}