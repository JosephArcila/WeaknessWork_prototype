import 'package:flutter/material.dart';

void main() => runApp(WeaknessWorkApp());

class WeaknessWorkApp extends StatefulWidget {
  @override
  _WeaknessWorkAppState createState() => _WeaknessWorkAppState();
}

class _WeaknessWorkAppState extends State<WeaknessWorkApp> {
  // Create a global key for the _WarmupState
  final GlobalKey<_WarmupState> _warmupStateKey = GlobalKey<_WarmupState>();

  // Add this getter
  _WarmupState get _warmupState => _warmupStateKey.currentState;

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
          body: Warmup(warmupKey: _warmupStateKey), // Pass the key to WarmupPage
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
                  onPressed: () async {
                    int result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MovementSelectionPage()),
                    );
                    if (result != null) {
                      setState(() {
                        _warmupState.selectedMovementIndex = result;
                      });
                    }
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

class Warmup extends StatefulWidget {
  final GlobalKey<_WarmupState> warmupKey;

  Warmup({@required this.warmupKey}) : super(key: warmupKey);

  @override
  _WarmupState createState() => _WarmupState();
}

class _WarmupState extends State<Warmup> {
  int warmupNumber = 0;
  int selectedMovementIndex;
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

  void updateParagraphs() {
    if (selectedMovementIndex == 2) { // index for overheadsquat.jpg
      // Modify paragraphs list based on the new requirements
      paragraphs[0] = 'Barbell Complex Warm-Up \n' +
          '* Round 1: Overhead squat with a 2.5-lb on the dowel pressing the bar up and pull it back over midfoot, deadlift, hang power clean, front squat, press, thruster, overhead squat with a 5-lb on the dowel pressing the bar up and pull it back over midfoot \n' +
          '* Round 2: overhead squat with a 7.5-lb on the dowel pressing the bar up and pull it back over midfoot, deadlift, hang power snatch, overhead squat with a 10-lb on the dowel pressing the bar up and pull it back over midfoot, snatch balance \n' +
          '* Round 3: Overhead squat using a 15-lb training bar while maintaining perfect form, thruster to overhead squat';
      paragraphs[2] = 'Basic Body Weight (BBW) \n' +
          '* Round 1: Maintain a rock-bottom squat with your back arched, head and eyes forward, and body weight predominantly on your heels for 3 to 5 minutes, push-up, sit-up, pull-up (strict), hip extension, pass-throughs starting with a grip wide enough to easily pass through, and then repeatedly bring the hands in closer until passing through presents a moderate stretch of the shoulders \n' +
          '* Round 2: Lunge, dip (strict), V-up, kipping pull-up, back extension, Pass-through at the top, the bottom, and everywhere in between while descending into the squat. Practice by stopping at several points on the path to the bottom, hold, and gently, slowly, swing the dowel from front to back, again, with locked arms. At the bottom of each squat, slowly bring the dowel back and forth moving from front to back \n' +
          '* Round 3: Pistol, handstand push-up, toes-to-bar (straight leg and strict), muscle-up (strict), hip and back extension, with your eyes closed, find the frontal plane with the dowel from every position in the squat. Bring the dowel to a stop in the frontal plane and hold briefly with each pass-through \n' +
          '* Round 4: Pose running drill, stand tall with the dowel held as high as possible in the frontal plane directly overhead. Very slowly lower to the bottom of the squat, keeping the dowel in the frontal plane the entire time. Pull the dowel back very deliberately as you descend';
      paragraphs[3] = 'Dumbbell \n' +
          '(Can be performed with one or two dumbbell(s) at a time) \n' +
          '* Round 1: Deadlift, hang power clean, front squat, press, single-arm overhead squat \n' +
          '* Round 2: Deadlift, hang power snatch, overhead squat, single-arm snatch balance, Turkish get-up';
      paragraphs[4] = 'Parallettes \n' +
          '(Create a mini routine by going through the list. Omit the more difficult variations until skilled enough.) \n' +
          '* Handstand push-ups \n' +
          '* Push-up/dive bomber push-up \n' +
          '* Shoot-through to push-up to frog stand \n' +
          '* L-sit pass-through to tuck planche \n' +
          '* L-sit pass-through to shoulder stand \n' +
          '* Tuck up to handstand/press to handstand (from L or press from bottom of shoulder stand) \n' +
          '* Handstand pirouette walk';
      paragraphs[5] = 'Kettlebell \n' +
          '(Can be performed with one or both kettlebells or with hand-to-hand techniques) \n' +
          '* Swing, clean, clean and press, snatch, single-arm overhead squat, Turkish get-up';
    }
  }


  @override
  Widget build(BuildContext context) {
    updateParagraphs();
    return Center(
      child: TextButton(
        onPressed: () {
          setState(() {
            warmupNumber = (warmupNumber + 1) % paragraphs.length;
          });
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: RichText(
              text: TextSpan(
                children: parseText(paragraphs[warmupNumber]),
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
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
                      // Pass the selected movement index to the previous screen
                      Navigator.pop(context, index);
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
                Navigator.pop(context, null); // Pass the selected movement index
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