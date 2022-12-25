import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_project/screens/main_page.dart';
import 'package:mi_project/widgets/custom_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static String id = "HomePageID";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text(
              "Heart Rate Monitioring\nDrug Infusion System",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 40),
          TweenAnimationBuilder(
            curve: Curves.bounceOut,
            duration: const Duration(seconds: 2),
            tween: Tween<double>(begin: 90, end: 0),
            builder: (context, value, child) {
              return Padding(
                padding: EdgeInsets.all(value),
                child: CircleAvatar(
                  backgroundColor: Colors.blue[600],
                  radius: 120,
                  child: Image.asset("assets/images/pump.png"),
                ),
              );
            },
          ),
          const Center(
            child: Text(
              "Team 14",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                onPressed: () => Navigator.of(context).pushNamed(MainPage.id),
                text: "Connect",
              ),
              CustomButton(
                onPressed: () => SystemNavigator.pop(),
                text: "Exit",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
