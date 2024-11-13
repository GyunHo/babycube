import 'package:babycubes/model/Cube.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'controller/firebase_controller.dart';
import 'package:get/get.dart';

class DonePage extends StatelessWidget {
  const DonePage({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text('다 먹은 이유식'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder(
          future: controller.getDone(),
          builder: (BuildContext ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              List<QueryDocumentSnapshot> docList = snapshot.data!.docs;
              return ListView.builder(
                  itemCount: docList.length,
                  itemBuilder: (BuildContext ctx, int count) {
                    Cube cube = Cube.fromQuerySnapshot(docList[count]);

                    return Column(
                      children: [
                        ListTile(
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${cube.count}개',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cube.name,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '무게 : ${cube.weight}g ',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          subtitle: Text(
                              '제조 : ${cube.date.year}년 ${cube.date.month}월 ${cube.date.day}일'),
                        ),
                        const Divider(),
                      ],
                    );
                  });
            }
            return const CircularProgressIndicator();
          }),
    );
  }
}
