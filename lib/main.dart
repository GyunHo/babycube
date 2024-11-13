import 'package:babycubes/controller/firebase_controller.dart';
import 'package:babycubes/done_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'model/Cube.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.put(FirebaseController());
    return GetMaterialApp(
      title: 'cube counter helper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff85A389)),
        useMaterial3: true,
      ),
      home: const CubeApp(),
    );
  }
}

class CubeApp extends StatefulWidget {
  const CubeApp({super.key});

  @override
  State<CubeApp> createState() => _CubeAppState();
}

class _CubeAppState extends State<CubeApp> {
  final _formKey = GlobalKey<FormState>();
  FirebaseController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Get.to(const DonePage());
              },
              icon: const Icon(Icons.history)),
          IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () async {
                await _displayTextInputDialog(context).then((bool? value) {
                  if (value ?? false) {
                    Get.snackbar(
                      '추가완료',
                      '큐브 추가완료',
                      duration: const Duration(seconds: 1),
                    );
                  }
                });
              })
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("도윤이 하율이 큐브창고"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: controller.instance
              .orderBy("date", descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List? docList = snapshot.data?.docs;

              return ListView.builder(
                  itemCount: docList?.length,
                  itemBuilder: (BuildContext ctx, int count) {
                    Cube cube = Cube.fromQuerySnapshot(docList![count]);
                    if (cube.count < 1) {
                      return const SizedBox();
                    }
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
                              TextButton(
                                  onPressed: () {
                                    controller.minusCount(docList[count]);
                                  },
                                  child: const Text(
                                    '-1',
                                    style: TextStyle(fontSize: 16),
                                  )),
                              TextButton(
                                  onPressed: () {
                                    controller.plusCount(docList[count]);
                                  },
                                  child: const Text('+1',
                                      style: TextStyle(fontSize: 16))),
                            ],
                          ),
                          onLongPress: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('큐브삭제?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          child: const Text('취소')),
                                      TextButton(
                                          onPressed: () {
                                            Get.back();
                                            controller.delCube(docList[count]);
                                          },
                                          child: const Text('확인'))
                                    ],
                                  );
                                });
                          },
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cube.name,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '무게 : ${cube.weight}g ${DateTime.now().difference(cube.date).inDays}일 지남',
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
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Future<bool?> _displayTextInputDialog(BuildContext context) async {
    Cube cube = Cube(name: '노네임', date: DateTime.now(), count: 0, weight: 0);
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: EasyDateTimeLine(
                        onDateChange: (time) {
                          cube.date = time;
                        },
                        initialDate: DateTime.now(),
                        activeColor: const Color(0xff85A389),
                        dayProps: const EasyDayProps(
                          todayHighlightStyle:
                              TodayHighlightStyle.withBackground,
                          todayHighlightColor: Color(0xffE1ECC8),
                        ),
                        locale: 'ko_KR',
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(hintText: "재료"),
                      autovalidateMode: AutovalidateMode.always,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '재료 입력 필수';
                        }
                        cube.name = value;
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(hintText: "수량"),
                      autovalidateMode: AutovalidateMode.always,
                      validator: (value) {
                        if (value == null ||
                            value == isBlank ||
                            !GetUtils.isNum(value)) {
                          return '숫자만 입력';
                        }
                        cube.count = int.parse(value);
                        return null;
                      },
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(hintText: "무게"),
                      autovalidateMode: AutovalidateMode.always,
                      validator: (value) {
                        if (value == null ||
                            value == isBlank ||
                            !GetUtils.isNum(value)) {
                          return '숫자만 입력';
                        }
                        cube.weight = int.parse(value);
                        return null;
                      },
                      keyboardType: TextInputType.number,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text('취소'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: const Text('등록'),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              controller.addCube(cube).then((value) {
                                Get.back(result: true);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
