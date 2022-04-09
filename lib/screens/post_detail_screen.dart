import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../methods/firestore_methods.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../widgets/comment_card.dart';
import '../widgets/like_animation.dart';
import '../widgets/yes_no_dialog.dart';

class PostDetailScreen extends StatefulWidget {
  final snap;
  const PostDetailScreen({ Key? key,required this.snap }) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {

  bool postImageReady = false;
  String postImageUrl = '';
  bool gettingUserData = false;
  var userData = {};
  String avatarUrl = '';
  String username = '';
  bool isLikeDisplaying = false; //mặc định thì like sẽ không hiển thị lên
  final TextEditingController _commentController = TextEditingController();


  @override
  void initState() {
    getAvatarAndUsername();
    loadPostImages();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }


  void getAvatarAndUsername() async {
    setState(() {
      gettingUserData = true;
    });
    var userSnapShot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.snap['uid'])
        .get();
    userData = userSnapShot.data()!;

    avatarUrl = userData['photoUrl'].toString();
    username = userData['username'].toString();
    if (mounted){
    setState(() {
      gettingUserData = false;
    });
    }
  }

  void loadPostImages() async {
    setState(() {
      postImageReady = false;
    });
    postImageUrl = await widget.snap['postUrl'];
    setState(() {
        postImageReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    final User? user = Provider.of<UserProvider>(context).getUser; //lấy ra th user hiện tại

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: mobileBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        color: mobileBackgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: gettingUserData ? const Center(child: CircularProgressIndicator(),)
        : 
        ListView(
          children: [Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  // borderRadius: BorderRadius.vertical(top: Radius.circular(26.0)),
                  color: darkColor,
                ),
                //container chứa avatar, tên ng dùng và dấu 3 chấm trên đầu bài viết
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20)
                    .copyWith(right: 0),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          uid: widget.snap['uid'],
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        //avatar
                        radius: 16,
                        backgroundColor: darkColor,
                        backgroundImage: NetworkImage(avatarUrl), //dùng snap lấy ra avatar của user
                      ),
                      Expanded(
                        //username
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username, //dùng snap lấy ra username
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        //3 chấm options
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: ListView(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                shrinkWrap: true,
                                children: [
                                  widget.snap['uid'].toString() == user!.uid.toString() ?
                                  InkWell(
                                    onTap: () async {
                                      Navigator.of(context).pop();      
                                      showDialog(
                                        context: context,
                                        builder: (context) => YesNoDialog(
                                          title: 'Delete',
                                          content:
                                              'Do you really want to delete this post?',
                                          function: () async {
                                            FirestoreMethods().deletePost(widget.snap['postId']);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16),
                                      child: const Text('Delete'),
                                    ),
                                  )
                                  : const SizedBox(), 
                                  InkWell(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16),
                                      child: const Text('Cancel'),
                                    ),
                                    onTap: () async {
                                      Navigator.of(context).pop(); 
                                    }
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ) ,
              ),
                  
              //image display image display image display image display
              GestureDetector(
                onDoubleTap: () async {
                  await FirestoreMethods().likePost(
                    widget.snap['postId'],
                    user!.uid,
                    widget.snap['likes'],
                  );
                  setState(() {
                    isLikeDisplaying = true;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey, width: 0.2),
                          bottom: BorderSide(color: Colors.grey, width: 0.2),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: postImageReady == false ?
                        const Center(child: Text('Waiting for internet connection', style: TextStyle(color: Colors.white),),)
                        : Image.network(
                          postImageUrl,
                          fit: BoxFit.fitWidth,
                        ), //dùng snap lấy url ảnh bài post
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: isLikeDisplaying ? 1 : 0,
                      //cái nút like vẫn luôn ở đó, chỉ là check xem ng dùng có bấm like không để chỉnh opa thôi
                      duration: const Duration(
                          milliseconds:
                              100), //mất 10 milisec để hiện từ opa 0 lên 1
                      child: LikeAnimation(
                        child: const Icon(
                          Icons.thumb_up,
                          color: Colors.blue,
                          size: 70,
                        ),
                        isDisplaying: isLikeDisplaying,
                        duration: const Duration(milliseconds: 200),
                        //nó sẽ foward và reverse (scale trong file like_animation) trong 200 milisec sau đó hiện thêm 1s (startAnimation trong cùng file)
                        onEnd: () {
                          setState(() {
                            isLikeDisplaying =
                                false; //khi chỉnh này thành false lại thì opa thành 0 ===> biến mất
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
                  
              Row(
                children: [
                  LikeAnimation(
                    // isDisplaying: true,
                    isDisplaying: widget.snap['likes'].contains(user!.uid),
                    smallLike:
                        true, //smallLike là like bằng nút like, mặc định là false(like bằng double   tap)
                    child: IconButton(
                      //LIKE
                      onPressed: () async {
                        await FirestoreMethods().likePost(
                          widget.snap['postId'],
                          user.uid,
                          widget.snap['likes'],
                        );
                        setState(() {
                          
                        });
                      },
                      icon: widget.snap['likes'].contains(user.uid) ? 
                        const Icon(
                          Icons.thumb_up,
                          color: Colors.blue,)
                        : const Icon(
                          Icons.thumb_up,)
                    ),
                  ),
                  IconButton(
                    //COMMENT
                    onPressed: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => CommentScreen(snap: widget.snap),
                      //   ),
                      // );
                    },
                    icon: const Icon(
                      Icons.comment,
                    ),
                  ),
                  IconButton(
                    //SEND
                    onPressed: () {},
                    icon: const Icon(Icons.send),
                  ),
                  Expanded(
                    child: Align(
                      //ARCHIVE
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.bookmark_border,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
                  
              Container(
                decoration: const BoxDecoration(
                  // borderRadius: BorderRadius.vertical(bottom: Radius.circular(26.0)),
                  // color: darkColor,
                  border: Border(bottom: BorderSide(color: darkColor, width: 2)) 
                ),
                padding: const EdgeInsets.only(left: 8,right: 8, bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      //số like
                      '${widget.snap['likes'].length} likes',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Container(
                      //caption
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: primaryColor),
                          children: [
                            TextSpan(
                              text: username, //dùng snap lấy ra username
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const TextSpan(
                              text: "  ",
                            ),
                            TextSpan(
                              text: widget
                                  .snap['description'], //dùng snap lấy ra caption
                              style: const TextStyle(
                                  fontWeight: FontWeight.w300, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      //NGÀY POST
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        DateFormat.yMMMd().format(
                          widget.snap['uploadDate'].toDate(),
                        ),
                        style: const TextStyle(fontSize: 12, color: secondaryColor),
                      ),
                    ),
                  ],
                ),
              ),  
            ],
          ),

          StreamBuilder(                                              //comments của bài post
              stream: FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.snap['postId'])
                .collection('comments')
                .orderBy('uploadDate', descending: false)
                .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator(),);
                }
                
                return ListView.builder(
                  controller: ScrollController(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) => CommentCard(
                    snap: snapshot.data!.docs[index].data(),    //truyền vô cái snap chứa thông tin của comment đó
                  ),
                );
              },
            ),
          ]
        )
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          // color: Colors.white,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: darkColor, width: 3))
          ),
          height: kToolbarHeight,
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom+4),
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                //avatar
                radius: 18,
                backgroundImage: NetworkImage(user!.photoUrl), //dùng snap lấy ra avatar của user
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 4),
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Type your comment',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  await FirestoreMethods().uploadComment(
                      widget.snap['postId'],
                      user.uid,
                      user.username,
                      user.photoUrl,
                      _commentController.text,
                  );
                  _commentController.text = '';         //sau khi comment xong thi set phần comment về trống không
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: const Text(
                    'POST',
                    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}