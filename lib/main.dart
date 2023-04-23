import 'package:flutter/material.dart';

void main() => runApp(WeaknessWorkApp());

class WeaknessWorkApp extends StatelessWidget {
  // Method to show the dialog
  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('GENERAL WARM-UPS TO ADDRESS WEAKNESSES'),
          content: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '\u2022',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      ' These are general warm-ups by modality (weightlifting, gymnastics, cardio) from the CrossFit Level 2 Training Guide. Use them to add skill work to your program.\n',
                ),
                TextSpan(
                  text: '\u2022',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      ' Think of them as an opportunity to touch on skills that may or may not be present during today’s WOD.\n',
                ),
                TextSpan(
                  text: '\u2022',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      ' The general warm-ups below are progressive, performed for 2-3 rounds each, each getting slightly more complicated than the round before.\n',
                ),
                TextSpan(
                  text: '\u2022',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      ' Perform each movement for 5-15 repetitions; the repetitions should give enough time to practice without fatiguing for the workout.',
                ),
              ],
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Understood'),
            ),
          ],
        );
      },
    );
  }

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    _showDialog(context);
                  },
                  icon: Icon(Icons.info_outline),
                  color: Colors.white,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MovementSelectionPage()),
                    );
                  },
                  child: Text('Movements'),
                  style: ElevatedButton.styleFrom(primary: Colors.blue),
                ),
              ],
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
    'Barbell Complex Warm-Up \n' +
        '* Round 1: Deadlift, hang power clean, front squat, press, thruster \n' +
        '* Round 2: Deadlift, hang power snatch, overhead squat, snatch',
    'Rings \n' +
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
    'Basic Body Weight (BBW) \n' +
        '* Round 1: Squat, push-up, sit-up, pull-up (strict), hip extension \n' +
        '* Round 2: Lunge, dip (strict), V-up, kipping pull-up, back extension \n' +
        '* Round 3: Pistol, handstand push-up, toes-to-bar (straight leg and strict), muscle-up (strict), hip and back extension \n' +
        '* Round 4: Pose running drill',
    'Dumbbell \n' +
        '(Can be performed with one or two dumbbell(s) at a time) \n' +
        '* Round 1: Deadlift, hang power clean, front squat, press, thruster \n' +
        '* Round 2: Deadlift, hang power snatch, overhead squat, snatch, Turkish get-up',
    'Parallettes \n' +
        '(Create a mini routine by going through the list. Omit the more difficult variations until skilled enough.) \n' +
        '* Push-up/dive bomber push-up \n' +
        '* Shoot-through to push-up to frog stand \n' +
        '* L-sit pass-through to tuck planche \n' +
        '* L-sit pass-through to shoulder stand \n' +
        '* Tuck up to handstand/press to handstand (from L or press from bottom of shoulder stand) \n' +
        '* Handstand pirouette walk',
    'Kettlebell \n' +
        '(Can be performed with one or both kettlebells or with hand-to-hand techniques) \n' +
        '* Swing, clean, clean and press, snatch, Turkish get-up \n'
  ];

  List<InlineSpan> parseText(String text) {
    List<String> lines = text.split('\n');
    List<InlineSpan> spans = [];
    for (String line in lines) {
      if (line.startsWith('*')) {
        spans.add(TextSpan(
            text: '\u2022',
            style: TextStyle(fontWeight: FontWeight.bold, height: 1.5)));
        spans.add(
            TextSpan(text: line.substring(1), style: TextStyle(height: 1.5)));
      } else if (line.startsWith('(Can be performed') ||
          line.startsWith('(Create a mini routine')) {
        spans.add(TextSpan(
            text: line,
            style: TextStyle(fontStyle: FontStyle.italic, height: 1.5)));
      } else {
        spans.add(TextSpan(
            text: line,
            style:
                TextStyle(decoration: TextDecoration.underline, height: 1.5)));
      }
      spans.add(TextSpan(text: '\n'));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          setState(() {
            tabataNumber = (tabataNumber + 1) % paragraphs.length;
          });
        },
        child: RichText(
          text: TextSpan(
            children: parseText(paragraphs[tabataNumber]),
            style: TextStyle(fontSize: 20.0, color: Colors.white),
          ),
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
      backgroundColor: Colors.grey[500],
      appBar: AppBar(
        title: Text('Select Your Weakest Movement'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
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
                  child: InkWell(
                    onTap: () {
                      // Handle image button click here
                      print('Image ${index + 1} clicked');
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset('images/${imageNames[index]}',
                          fit: BoxFit.scaleDown),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Update'),
              style: ElevatedButton.styleFrom(primary: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}