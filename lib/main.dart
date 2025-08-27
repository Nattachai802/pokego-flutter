import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pokego/page/teams_list_page.dart';
import 'package:pokego/team_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  // [ย้ายมาที่นี่] สร้าง Controller ที่นี่เพื่อให้แน่ใจว่าถูกสร้างแค่ครั้งเดียว
  Get.put(TeamController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokémon Team Builder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // [ลบ] ไม่จำเป็นต้องใช้ initialBinding แล้ว
      // initialBinding: InitialBinding(),
      home: const TeamsListPage(),
    );
  }
}
