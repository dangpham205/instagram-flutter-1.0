import 'package:flutter/material.dart';
import 'package:instagram/constants/colors.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatefulWidget {
  final snap;
  const CommentCard({ Key? key,required this.snap }) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    return Container( 
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
                //avatar
                radius: 18,
                backgroundImage: NetworkImage(widget.snap['avatarUrl']), //dùng snap lấy ra avatar của user
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start ,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: widget.snap['username']+" ", style: const TextStyle(fontWeight: FontWeight.bold),),
                        TextSpan(text: widget.snap['comment'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat.yMMMd().format(widget.snap['uploadDate'].toDate(),),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: secondaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Icon(
                Icons.thumb_up,
                color: Colors.blue,
              ),
        ],
      ),
    );
  }
}