import 'package:babycubes/model/Cube.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FirebaseController extends GetxController {
  CollectionReference instance = FirebaseFirestore.instance.collection('cube');

  Future<void> addCube(Cube cube) async {
    try {
      await instance.add(cube.toJson());
    } catch (e) {
      print('큐브 추가 오류');
      print(e);
      Get.snackbar('오류', '추가실패');
    }
  }

  Future<void> delCube(QueryDocumentSnapshot snapshot) async {
    try {
      await snapshot.reference.delete().then((value) {
        Get.snackbar(
          '삭제 완료',
          '큐브 삭제 완료',
          duration: const Duration(milliseconds: 700),
        );
      });
    } catch (e) {
      print('큐브 삭제 오류');
      print(e);
      Get.snackbar('오류', '삭제실패');
    }
  }

  Future<void> plusCount(QueryDocumentSnapshot snapshot) async {
    Cube cube = Cube.fromQuerySnapshot(snapshot);
    cube.count += 1;
    try {
      await snapshot.reference.update(cube.toJson());
    } catch (e) {
      print('큐브 더하기 오류');
      print(e);
      Get.snackbar('오류', '수정실패');
    }
  }

  Future<void> minusCount(QueryDocumentSnapshot snapshot) async {
    Cube cube = Cube.fromQuerySnapshot(snapshot);
    cube.count -= 1;
    try {
      await snapshot.reference.update(cube.toJson());
    } catch (e) {
      print('큐브 빼기 오류');
      print(e);
      Get.snackbar('오류', '수정실패');
    }
  }

  Future<QuerySnapshot> getDone() async {
    return instance.where("count", isLessThan: 1).get();
  }
}
