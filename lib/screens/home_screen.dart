import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/constants/colors.dart';
import 'package:instagram/widgets/post_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(                                   //app bar
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: SvgPicture.asset(                  //logo app
          'assets/ic_instagram.svg',
          color: primaryColor,
          height: 36,
        ),
        actions: [
          IconButton(                                   //chat
            onPressed: () {},
            icon: const Icon(Icons.chat)
          ),
        ],
      ),
      body: StreamBuilder(                              //dùng stream để load ra các post
        stream: FirebaseFirestore.instance.collection('posts').orderBy('uploadDate', descending: true).snapshots(),
        //stream sẽ là các bài post, khi có các bài post mới đc add lên, stream builder sẽ build lại
        builder:(context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          //mặc định thì builder sẽ có snapshot
          // cta sẽ định nghĩa snapshot ở đây là AsyncSnapshot vì sẽ build các post dựa vào realtime changes
          // và kiểu của AsyncSnapshot này sẽ là QuerySnapshot của cloud_firestore chứa DocumentSnapshot
          //và cta sẽ cast cái document (JSON obj) đó thành 1 Map (giống fromSnapShot trong file user và post.dart)

          //nếu không định nghĩa loại snapshot cụ thể ở đây thì itemCount bên dưới sẽ kh lấy đc docs.length
          //vì nó kh biết docs muốn lấy là docs async, kh thể lấy liền đc
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: snapshot.data!.docs.length,      //bắt buộc phải truyền vô
            itemBuilder:(context, index) {
              return PostCard(
                snap: snapshot.data!.docs[index].data(),    //truyền vô cái snap chứa thông tin của post đó, ****nơi xét follow???
              );
            }
          );
        }  ,
      ),
    );
  }
}