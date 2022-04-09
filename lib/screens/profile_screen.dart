import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/constants/colors.dart';
import 'package:instagram/methods/firestore_methods.dart';
import 'package:instagram/screens/edit_profile_screen.dart';
import 'package:instagram/screens/post_detail_screen.dart';
import 'package:instagram/widgets/profile_button.dart';
import 'package:instagram/widgets/profile_drawer.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  bool isFollowing = false;
  bool isLoading = false;

  // DocumentSnapshot? snapshot;
  // String? username,bio,avatarUrl;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  // getUserData() async {
  //     await FirebaseFirestore.instance.collection('users').doc(widget.uid).get().then((value) {
  //       snapshot = value;
  //     });
  //     //xuống dưới lúc gọi ra phải toString vì value trả về ở trên là Map<String, dynamic> nên phải toString
  //     username = snapshot!['username'];
  //     bio = snapshot!['bio'];
  //     avatarUrl = snapshot!['photoUrl'];
  //     setState(() {
  //     });
  // }

  Future getUserData() async {
    setState(() {
      isLoading = true;
    });
    var userSnapShot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();
    userData = userSnapShot.data()!;

    var postSnapShot = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: widget.uid)
        .get();
    postCount = postSnapShot.docs.length;
    followerCount = userSnapShot.data()!['followers'].length;
    followingCount = userSnapShot.data()!['following'].length;
    isFollowing = userSnapShot
        .data()!['followers']
        .contains(FirebaseAuth.instance.currentUser!.uid);
    if (mounted){
      setState(() {
        isLoading = false;
      });
    }
    
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center(
      child: CircularProgressIndicator(),
    )
    :
    Scaffold(
      endDrawer: const ProfileDrawer() ,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(userData['username'].toString()),
        actions: [
          FirebaseAuth.instance.currentUser!.uid != widget.uid ? IconButton(      //nếu mở trang profile không phải của bản thân (tức là đang vô xem profile ngkhac) thì cần cho phép pop để quay lại (ví dụ về màn home, search)
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ) : const SizedBox(),
          FirebaseAuth.instance.currentUser!.uid == widget.uid ?  IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState!.openEndDrawer(),
          ) : const SizedBox(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async{
          getUserData();
        },
        child: ListView(
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: darkColor,
                  backgroundImage: NetworkImage(userData['photoUrl'].toString()),
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  userData['username'].toString(),
                  style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 12,
                ),
                userData['bio'].toString().isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(
                            left: 32, right: 32, bottom: 12),
                        child: Text(
                          userData['bio'].toString(),
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontWeight: FontWeight.w300),
                        ),
                      )
                    : const SizedBox(
                        height: 16,
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildProfileColumn('Posts', postCount),
                    const SizedBox(
                      width: 16,
                    ),
                    buildProfileColumn('Followers', followerCount),
                    const SizedBox(
                      width: 16,
                    ),
                    buildProfileColumn('Following', followingCount),
                  ],
                ),
                const SizedBox( height: 12,),
                FirebaseAuth.instance.currentUser!.uid == widget.uid
                    ? ProfileButton(                    //nếu user truyền vô screen là current user (chính chủ) thì hiện nút edit profile
                        buttonColor: Colors.grey,
                        borderColor: Colors.white,
                        buttonText: 'EDIT PROFILE',
                        buttonTextColor: Colors.white,
                        function: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(uid: widget.uid),
                            ),
                          ).then((value) {
                            setState(() {
                              getUserData();
                            });
                          });
                        },)
                    : isFollowing ? ProfileButton(      //nếu follow = true (đang follow) thì hiện nút unfollow
                        buttonColor: Colors.white,
                        borderColor: Colors.white,
                        buttonText: 'UNFOLLOW',
                        buttonTextColor: Colors.black,
                        function: () async {
                          await FirestoreMethods().followUser(FirebaseAuth.instance.currentUser!.uid, widget.uid);
                          setState(() {
                            isFollowing = false;
                            followerCount--;
                          });
                        },)
                    : ProfileButton(                          //còn không thì hiện nút follow
                        buttonColor: Colors.blueAccent,
                        borderColor: Colors.white,
                        buttonText: 'FOLLOW',
                        buttonTextColor: Colors.white,
                        function: () async {
                          await FirestoreMethods().followUser(FirebaseAuth.instance.currentUser!.uid, widget.uid);
                          setState(() {
                            isFollowing = true;
                            followerCount++;
                          });
                        },
                      ),
                const SizedBox( height: 16,),
                FutureBuilder(                                  //hiển thị các post dưới dạng grid
                  future: FirebaseFirestore.instance.collection('posts').where('uid', isEqualTo: widget.uid).get(),
                  builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(),);
                    }
                    else{
                      return GridView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          childAspectRatio: 1,
                        ), 
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => StreamBuilder(
                                    stream: FirebaseFirestore.instance.collection('posts').snapshots(),
                                    builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting){
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      return PostDetailScreen(snap: snapshot.data!.docs[index].data());
                                    }
                                  ),
                                  //  PostDetailScreen(snap: snapshot.data!.docs[index].data(),),
                                ),
                              );
                            },
                            child: Image(
                              fit: BoxFit.cover,
                              image: NetworkImage(snapshot.data!.docs[index]
                                        .data()['postUrl']
                                        .toString(),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Column buildProfileColumn(String name, int number) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 13, color: secondaryColor),
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          number.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
