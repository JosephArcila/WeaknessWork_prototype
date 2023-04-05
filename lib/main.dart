import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(
      MaterialApp(
        title: 'WeaknessWork',
        home: Scaffold(
          backgroundColor: Colors.redAccent,
          appBar: AppBar(
            title: Text('WeaknessWork'),
            backgroundColor: Colors.redAccent,
          ),
          body: TabataPage(),
        ),
      ),
    );

class Tabata extends StatefulWidget {
  @override
  _TabataState createState() => _TabataState();
}

class _TabataState extends State<Tabata> {
  int tabataNumber = 0;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
          onPressed: () {
            setState(() {
              tabataNumber = Random().nextInt(8) + 1;
            });
          },
          child: Image.asset('images/tabata$tabataNumber.png')),
    );
  }
}

class TabataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tabata();
  }
}
