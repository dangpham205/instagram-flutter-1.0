import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/constants/colors.dart';
import 'package:instagram/constants/global_variables.dart';
// import 'package:instagram/models/user.dart' as model;        //user của class này trùng tên với instance user của firebase nên phải as


class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({ Key? key }) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {

  int _tab = 0;
  late PageController pageController;

  

  Color tabColor(int tab){
    if (_tab == tab){
      return primaryColor;
    }
    return secondaryColor;
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void tabNavigate(int tab){
    pageController.jumpToPage(tab);
  }

  void onPageChanged(int tab){    //dùng để đổi màu khi bấm vào icon dưới thanh nav
    setState(() {
      _tab = tab;
    });
  }


  @override
  Widget build(BuildContext context) {
    // model.User? user = Provider.of<UserProvider>(context).getUser;       
    // user này có thể null vì lúc đầu có thể chưa kết nối tới firebase kịp để get
    return Scaffold(
      body: PageView(
        children: homeScreenItems,  //trong file global_var //liệt kê các page sẽ có (số lượng tương ứng với số icon dưới thanh nav)
        physics: const NeverScrollableScrollPhysics(), //tắt chuyển tab bằng cách kéo ngang
        controller: pageController,     
        onPageChanged: onPageChanged,   //thay đổi state của _tab bằng index của tab trong list homeScreenItems trong file global _var
      ),
      bottomNavigationBar: CupertinoTabBar(
        onTap: tabNavigate,       //dùng để chuyển trang
        backgroundColor: mobileBackgroundColor,
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: tabColor(0),     //xét xem _tab hiện tại có bằng argument truyền vào tabColor có bằng nhau kh để nổi bật màu lên
              ),
              label: '',
              backgroundColor: primaryColor),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                color: tabColor(1),
              ),
              label: '',
              backgroundColor: primaryColor),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.add,
                color: tabColor(2),
              ),
              label: '',
              backgroundColor: primaryColor),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications,
                color: tabColor(3),
              ),
              label: '',
              backgroundColor: primaryColor),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: tabColor(4),
              ),
              label: '',
              backgroundColor: primaryColor),
        ],
      ),
    );
  }
}