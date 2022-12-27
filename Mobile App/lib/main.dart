import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_project/screens/discovery_page.dart';
import 'package:mi_project/screens/main_page.dart';
import 'package:mi_project/screens/select_bonded_device_page.dart';
import 'package:mi_project/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData.dark(),
      routes: {
        HomePage.id: (context) => const HomePage(),
        MainPage.id: (context) => const MainPage(),
        DiscoveryPage.id: (context) => const DiscoveryPage(),
        SelectBondedDevicePage.id: (context) => const SelectBondedDevicePage()
      },
    );
  }
}
