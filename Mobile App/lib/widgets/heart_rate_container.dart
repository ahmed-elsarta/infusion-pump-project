import 'package:flutter/material.dart';

class HeartRateContainer extends StatelessWidget {
  const HeartRateContainer(
      {super.key, required this.motorSpeed, required this.heartRate});

  final String motorSpeed;
  final String heartRate;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset("assets/images/hr.png"),
        Positioned(
          left: 150,
          top: 50,
          child: Column(
            children: [
              Text(
                motorSpeed,
                style: const TextStyle(fontSize: 50),
              ),
              Text(
                heartRate,
                style: const TextStyle(fontSize: 50),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
