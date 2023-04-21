import 'package:flutter/material.dart';

void main() => runApp(WeaknessWorkApp());

class WeaknessWorkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeaknessWork',
      home: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Colors.redAccent,
          appBar: AppBar(
            title: Text('WeaknessWork'),
            backgroundColor: Colors.redAccent,
          ),
          body: TabataPage(),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MovementSelectionPage()),
                );
              },
              child: Text('Select Movement'),
              style: ElevatedButton.styleFrom(primary: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }
}

class Tabata extends StatefulWidget {
  @override
  _TabataState createState() => _TabataState();
}

class _TabataState extends State<Tabata> {
  int tabataNumber = 0;
  final List<String> paragraphs = [
    'Day 1: Barbell Complex Warm-Up \n' +
        '* Round 1: Deadlift, hang power clean, front squat, press, thruster \n' +
        '* Round 2: Deadlift, hang power snatch, overhead squat, snatch',
    'Day 2: Rings \n' +
        '(Create a mini routine by going through the list. Omit the more difficult variations until skilled enough.) \n' +
        '* Tuck to inverted hang, then skin the cat \n' +
        '* Pike to inverted hang, then skin the cat \n' +
        '* Strict muscle-up to support to L-sit \n' +
        '* Shoulder stand back to L-support or straddle support \n' +
        '* Forward roll back to L-support \n' +
        '* Forward roll to hang \n' +
        '*  Pike or tuck to inverted hang to back-lever attempt, pull back to inverted hang \n' +
        '* Front-lever attempt \n' +
        '* Ring swings \n' +
        '* Fly-away dismount (skin the cat and let go)',
    'Day 3: Basic Body Weight (BBW) \n' +
        '* Round 1: Squat, push-up, sit-up, pull-up (strict), hip extension \n' +
        '* Round 2: Lunge, dip (strict), V-up, kipping pull-up, back extension \n' +
        '* Round 3: Pistol, handstand push-up, toes-to-bar (straight leg and strict), muscle-up (strict), hip and back extension \n' +
        '* Round 4: Pose running drill',
    'Day 4: Dumbbell \n' +
        '(Can be performed with one or two dumbbell(s) at a time) \n' +
        '* Round 1: Deadlift, hang power clean, front squat, press, thruster \n' +
        '* Round 2: Deadlift, hang power snatch, overhead squat, snatch, Turkish get-up',
    'Day 5: Parallettes \n' +
        '(Create a mini routine by going through the list. Omit the more difficult variations until skilled enough.) \n' +
        '* Push-up/dive bomber push-up \n' +
        '* Shoot-through to push-up to frog stand \n' +
        '* L-sit pass-through to tuck planche \n' +
        '* L-sit pass-through to shoulder stand \n' +
        '* Tuck up to handstand/press to handstand (from L or press from bottom of shoulder stand) \n' +
        '* Handstand pirouette walk',
    'Day 6: Kettlebell \n' +
        '(Can be performed with one or both kettlebells or with hand-to-hand techniques) \n' +
        '* Swing, clean, clean and press, snatch, Turkish get-up \n'
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          setState(() {
            tabataNumber = (tabataNumber + 1) % paragraphs.length;
          });
        },
        child: Text(
          paragraphs[tabataNumber],
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
      ),
    );
  }
}

class TabataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tabata();
  }
}

class MovementSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> imageNames = [
      'airsquat.jpg',
      'frontsquat.jpg',
      'overheadsquat.jpg',
      'shoulderpress.jpg',
      'pushpress.jpg',
      'pushjerk.jpg',
      'deadlift.jpg',
      'sdhp.jpg',
      'medicineballclean.jpg',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Weakest Movement'),
      ),
      body: GridView.builder(
        itemCount: imageNames.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image.asset('images/${imageNames[index]}'),
          );
        },
      ),
    );
  }
}
