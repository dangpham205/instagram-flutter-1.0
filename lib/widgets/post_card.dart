import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/constants/colors.dart';
import 'package:instagram/constants/utils.dart';
import 'package:instagram/methods/firestore_methods.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/providers/user_provider.dart';
import 'package:instagram/screens/comment_screen.dart';
import 'package:instagram/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeDisplaying = false; //mặc định thì like sẽ không hiển thị lên
  int numberOfComments = 0;
  bool postImageReady = false;
  String postImageUrl = '';
  var userData = {};
  String avatarUrl = '';
  String username = '';
  bool gettingUserData = false;
  


  @override
  void initState() {
    super.initState();
    getNumberOfComments();
    loadPostImages();
    getAvatarAndUsername();
  }

  void getNumberOfComments() async {

    try{
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('posts').doc(widget.snap['postId']).collection('comments').get();
      numberOfComments = snapshot.docs.length;
    }
    catch(error){
      showSnackBar(context, error.toString());
    }
    if (mounted){
      setState(() {});
    }
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

    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: gettingUserData ? const Center(child: CircularProgressIndicator(),)
      :
      Column(
        children: [
          Container(
            //container chứa avatar, tên ng dùng và dấu 3 chấm trên đầu bài viết
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12)
                .copyWith(right: 0),
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  //3 chấm options
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => Dialog(
                              child: ListView(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                shrinkWrap: true,
                                children: [
                                  const Text(
                                      'Delete'), //cho 1 cái text chứa chữ delete sau đó map nó tới inkwell (là sẽ có onTap)
                                ]
                                    .map(
                                      (e) => InkWell(
                                        onTap: () async {
                                          FirestoreMethods().deletePost(widget.snap['postId']);
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal:
                                                  16), //size của 1 row trong dialog
                                          child: e,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ));
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),

          //image display
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
                SizedBox(
                  width: double.infinity,
                  child: postImageReady == false ?
                  const Center(child: Text('Waiting for internet connection', style: TextStyle(color: Colors.white),),)
                  : Image.network(
                    postImageUrl,
                    fit: BoxFit.fitWidth,
                  ), //dùng snap lấy url ảnh bài post
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

          //like comment share
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentScreen(snap: widget.snap),
                    ),
                  );
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

          //CAPTION VÀ SỐ LIKE, NUMBER OF COMMENT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommentScreen(snap: widget.snap),
                      ),
                    );
                  },
                  child: Container(
                    //VIEW COMMENTS
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'View all ${numberOfComments.toString()} comments',
                      style:
                          const TextStyle(fontSize: 14, color: secondaryColor),
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
          )
        ],
      ),
    );
  }
}
