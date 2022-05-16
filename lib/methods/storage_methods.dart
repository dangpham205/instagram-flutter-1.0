import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ADD avatar to firebase storage
  Future<String> uploadImgToStorage(String folderName, Uint8List? image, bool isPost) async{
    
    if(image != null){
    //nếu image mà null thì sẽ trả về String 'default avatar'
    //sau này trong profile của user sẽ check xem nếu photoUrl của user đó mà là 'default avatar'
    
      Reference reference = _storage.ref().child(folderName).child(_auth.currentUser!.uid);
      // reference này là con trỏ dùng để chỉ tới folder trên db: folderName/uid

      if (isPost == true){    //tại vì 1 user có thể có nhiều post nên lúc up ảnh sẽ hiện theo cấu trúc: postPics/uid/picId
        String id = const Uuid().v1();
        reference = reference.child(id);
      }

      UploadTask uploadTask = reference.putData(image);   //uploadTask này sẽ dùng để điều khiển cách mà cta upload img lên storage

      TaskSnapshot snapshot =  await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();    
      //dùng để lấy url của tấm hình vừa up lên storage để sau sẽ dùng link bỏ vô networkImage hiển thị cho các ng dùng khác coi
    
      return downloadUrl;
    }
    else {
      //đây là url của default avatar
      return 'https://images.squarespace-cdn.com/content/v1/54b7b93ce4b0a3e130d5d232/1519987020970-8IQ7F6Z61LLBCX85A65S/icon.png?format=1000w';
    }
  }
}