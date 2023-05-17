import 'package:flutter/material.dart';

class LocationPointer extends StatelessWidget{
  const LocationPointer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          width: 3,
          color: Colors.white
        )
      ),
    );
  }

}