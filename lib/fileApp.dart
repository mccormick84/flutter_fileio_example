import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileApp extends StatefulWidget {
  const FileApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FileApp();
}

class _FileApp extends State<FileApp> {
  int _count = 0;
  List<String> itemList = List.empty(growable: true);
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    readCountFile();
    initData();
  }

  // initState() 함수에는 async 키워드를 사용할 수 없으므로 별도로 initData() 함수를 선언
  void initData() async {
    var result = await readListFile();
    setState(() {
      itemList.addAll(result);
    });
  }

  // readListFile(): 데이터를 리스트로 만들어 반환
  // 첫 호출 시 에셋에 등록한 파일을 읽어 내부 저장소에 똑가은 파일을 만들어서 동작
  // 이후는 내부 저장소의 파일을 읽어서 동작
  Future<List<String>> readListFile() async {
    List<String> itemList = List.empty(growable: true);

    // first 키를 이용해 bool 값을 가져와 firstCheck 변수에 저장
    var key = 'first';
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? firstCheck = pref.getBool(key); // 이후에 파일 처음 열었는 지 확인

    var dir = await getApplicationDocumentsDirectory();
    // 내부 저장소에 fruit.txt 파일이 있는지 확인 후 fileExist 변수에 bool 값으로 저장
    bool fileExist = await File(dir.path + '/fruit.txt').exists();

    // 파일을 처음 열었거나 없을 경우
    // 공유 환경 설정에 true 값을 기록하여 파일은 연것으로 기록하고
    // 에셋에 등록한 repo/fruit.txt 파일을 읽어서 내부 저장소에 똑같은 파일을 만듬
    if (firstCheck == null || firstCheck == false || fileExist == false) {
      pref.setBool(key, true);
      var file =
          await DefaultAssetBundle.of(context).loadString('repo/fruit.txt');

      File(dir.path + '/fruit.txt').writeAsString(file);

      var array = file.split('\n');
      for (var item in array) {
        debugPrint(item);
        itemList.add(item);
      }
      return itemList;
    } else {
      // 파일을 처음 연 것이 아닐경우
      // 파일의 데이터를 리스트로 만들어서 반환하고 대상 파일을 내부 저장소의 fruit.txt 파일로 지정
      var file = await File(dir.path + '/fruit.txt').readAsString();
      var array = file.split('\n');
      for (var item in array) {
        debugPrint(item);
        itemList.add(item);
      }
      return itemList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Example'),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              TextField(
                controller: controller,
                keyboardType: TextInputType.text,
              ),
              Expanded( // 남은 공간을 모두 사용
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Card(
                      child: Center(
                        child: Text(
                          itemList[index],
                          style: TextStyle(fontSize: 30),
                        ),
                      ),
                    );
                  },
                  itemCount: itemList.length,
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void writeCountFile(int count) async {
    var dir = await getApplicationDocumentsDirectory();
    File(dir.path + '/count.txt').writeAsStringSync(count.toString());
  }

  void readCountFile() async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      var file = await File(dir.path + '/count.txt').readAsString();
      debugPrint(file);
      setState(() {
        _count = int.parse(file);
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
