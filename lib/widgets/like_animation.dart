import 'package:flutter/material.dart';

class LikeAnimation extends StatefulWidget {          //LikeAnimation sẽ là 1 custom widget
  //các properties của LikeAnimation widget
  final Widget child;                   // thằng widget con mà sẽ hiện lên khi double tap
  final bool isDisplaying;            
  final Duration duration;      // animation này sẽ hiển thị bao lâu
  final VoidCallback? onEnd;      //khi mà kết thúc thì làm gì
  final bool smallLike;         // like theo hình thức nào, smallLike là bấm nút Like bên dưới post, còn không là like bằng double tap

  const LikeAnimation({ 
    Key? key, 
    required this.child, 
    required this.isDisplaying, 
    this.duration = const Duration(milliseconds: 150),      //nếu kh truyền vô thì mặc định sẽ là 150
    this.onEnd, 
    this.smallLike = false,             //mặc định là false
  }) : super(key: key);

  @override
  State<LikeAnimation> createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<LikeAnimation> with SingleTickerProviderStateMixin{     // phải có

  late AnimationController _controller; 
  late Animation<double> scale; 

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    scale = Tween<double>(begin: 1, end: 1.2).animate(_controller);  
    //cái animation lúc bắt đầu xuất hiện sẽ ở tỉ lệ 1 sau đó zoom lên 1.2
    //double tap để thấy hình thumb up zoom ra
  }

  @override
  void didUpdateWidget(covariant LikeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDisplaying != oldWidget.isDisplaying ){
      startAnimation();
    }

    //sẽ đc gọi ra mỗi lần config của widget này thay đổi
  }

  startAnimation() async {
    if ( widget.isDisplaying || widget.smallLike ) {        //nếu mà ng dùng đang bấm nút like hoặc double tap thì
      await _controller.forward();    //Starts running this animation forwards (towards the end).
      await _controller.reverse();    //Starts running this animation in reverse (towards the beginning).
      //liên kết với scale ở trên, widget con sẽ hiển thị từ 1 -> 1.2 -> 1 do có reverse
      
      await Future.delayed(const Duration(seconds: 1));     //widget con sau khi reverse sẽ hiển thị 1 giây trc khi mất

      if ( widget.onEnd != null){     //sau khi hết 1 giây nếu hàm onEnd không null thì sẽ thực hiện hàm onEnd() 
        widget.onEnd!();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();          //cái này bắt buộc phải gọi trc, không thì sẽ có lỗi
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: widget.child,
    );
  }
}