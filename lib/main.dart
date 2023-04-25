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
          title: Text('General Warm-Ups to Address Weaknesses'),
          content: SingleChildScrollView(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '\u2022',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        ' These are warm-ups by modality from the CrossFit Traning Level 2 Guide. Use them to add skill work to your program.\n\n',
                  ),
                  TextSpan(
                    text: '\u2022',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        ' Think of them as an opportunity to touch on skills.\n\n',
                  ),
                  TextSpan(
                    text: '\u2022',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        ' The warm-ups below are progressive, performed for 2-3 rounds, each getting slightly more complicated.\n\n',
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
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
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
                  child: Text('Choose Movement'),
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
        '* Round 1: Deadlift, Hang power clean, Front squat, Press, Thruster \n' +
        '* Round 2: Deadlift, Hang power snatch, Overhead squat, Snatch',
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
        '* Round 1: Squat, Push-up, Sit-up, Pull-up (strict), Hip extension \n' +
        '* Round 2: Lunge, Dip (strict), V-up, Kipping pull-up, Back extension \n' +
        '* Round 3: Pistol, Handstand push-up, Toes-to-bar (straight leg and strict), Muscle-up (strict), Hip and back extension \n' +
        '* Round 4: Pose running drill',
    'Dumbbell \n' +
        '(Performed with two dumbbells at a time) \n' +
        '* Round 1: Deadlift, Hang power clean, Front squat, Press, Thruster \n' +
        '(Performed with one dumbbell at a time) \n' +
        '* Round 2: Deadlift, Hang power snatch, Overhead squat, Snatch, Turkish get-up',
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
        '* Swing, Clean, Clean and press, Snatch, Turkish get-up \n'
  ];

  List<InlineSpan> parseText(String text) {
    List<String> lines = text.split('\n');
    List<InlineSpan> spans = [];
    for (String line in lines) {
      if (line.startsWith('*')) {
        spans.add(TextSpan(
            text: '\u2022',
            style: TextStyle(fontWeight: FontWeight.bold, height: 1.5)));
        spans.add(TextSpan(
            text: ' ',
            style: TextStyle(fontSize: 20, letterSpacing: 6.0, height: 1.5)));
        spans.add(TextSpan(
            text: line.substring(1),
            style: TextStyle(height: 1.5, fontSize: 20.0, color: Colors.white)));
      } else if (line.startsWith('(Can be performed') ||
          line.startsWith('(Create a mini routine') ||
          line.startsWith('(Performed with two dumbbells') ||
          line.startsWith('(Performed with one dumbbell')) {
        spans.add(TextSpan(
            text: line,
            style: TextStyle(fontStyle: FontStyle.italic, height: 1.5)));
      } else {
        spans.add(TextSpan(
            text: line,
            style: TextStyle(
                decoration: TextDecoration.underline, height: 1.5)));
      }
      spans.add(TextSpan(text: '\n'));
    }
    return spans;
  }


  void updateParagraphs() {
    if (selectedMovementIndex == 2) { // index for overheadsquat.jpg
      paragraphs[0] = 'Barbell Complex Warm-Up for Overhead Squat \n' +
          '* Round 1: Deadlift, Hang power clean, Front squat, Press, Overhead squat \n' +
          '* Round 2: Deadlift, Hang power snatch, Overhead squat (with pause), Sots press, Snatch balance';
      paragraphs[1] = 'Rings Warm-Up for Overhead Squat \n' +
          '* Tuck to inverted hang, then skin the cat \n' +
          '* Pike to inverted hang, then skin the cat \n' +
          '* Strict muscle-up to support to L-sit \n' +
          '* Shoulder stand back to L-support or straddle support \n' +
          '* Forward roll back to L-support \n' +
          '* Forward roll to hang \n' +
          '* Pike or tuck to inverted hang to back-lever attempt, pull back to inverted hang \n' +
          '* Front-lever attempt \n' +
          '* False grip hang with active shoulders (to improve grip strength and stability for overhead movements) \n' +
          '* Ring swings with an emphasis on maintaining a strong overhead position during the swing';
      paragraphs[2] = 'Basic Body Weight (BBW) Warm-Up for Overhead Squat \n' +
          '* Round 1: Squat, Push-up, Sit-up, Pull-up (strict), Hip extension, Overhead squat with PVC pipe or broomstick \n' +
          '* Round 2: Lunge, Dip (strict), V-up, Kipping pull-up, Back extension, Overhead squat with PVC pipe or broomstick (focus on improving mobility and control) \n' +
          '* Round 3: Pistol, Handstand push-up, Toes-to-bar (straight leg and strict), Muscle-up (strict), Hip and back extension, Overhead squat with PVC pipe or broomstick (add a pause at the bottom for stability)';
      paragraphs[3] = 'Dumbbell Warm-Up for Overhead Squat \n' +
          '(Performed with two dumbbells at a time) \n' +
          '* Round 1: Deadlift, Hang power clean, Front squat, Press, Overhead squat \n' +
          '(Performed with one dumbbell at a time) \n' +
          '* Round 2: Deadlift, Hang power snatch, Single-arm overhead squat, Snatch, Turkish get-up';
      paragraphs[4] = 'Parallettes Warm-Up for Overhead Squat \n' +
          '(Create a mini routine by going through the list. Omit the more difficult variations until skilled enough.) \n' +
          '* Push-up/dive bomber push-up \n' +
          '* Shoot-through to push-up to frog stand \n' +
          '* L-sit pass-through to tuck planche \n' +
          '* L-sit pass-through to shoulder stand \n' +
          '* Tuck up to handstand/press to handstand (from L or press from bottom of shoulder stand) \n' +
          '* Handstand pirouette walk \n' +
          '* Handstand holds with focus on overhead stability and shoulder activation (hold for 15-30 seconds) \n' +
          '* Handstand push-up with a narrow grip (to target shoulder and triceps strength, which are important for overhead squat stability) \n' +
          '* Handstand shoulder shrugs (to improve shoulder stability and scapular control)';
      paragraphs[5] = 'Kettlebell Warm-Up for Overhead Squat \n' +
          '(Can be performed with one or both kettlebells or with hand-to-hand techniques) \n' +
          '* Round 1: Swing, Goblet squat, Clean, Press, Single-arm overhead squat \n' +
          '* Round 2: Swing, Clean, Clean and press, Snatch, Turkish get-up';
    }
    if (selectedMovementIndex == 3) { // index for shoulderpress.jpg
      paragraphs[0] = 'Barbell Complex Warm-Up for Shoulder Press \n' +
          '* Round 1: Deadlift, Hang power clean, Front squat, Strict press (focus on form and control), Thruster \n' +
          '* Round 2: Deadlift, Hang power snatch, Overhead squat, Push press (increase weight to challenge shoulder strength), Snatch \n' +
          '* Round 3: Deadlift, Hang power clean and jerk, Front squat to push press (aka "Thruster"), Shoulder press (with pause at the bottom and top of the movement), Behind the neck push press or snatch grip push press (focus on stability and control)';
      paragraphs[1] = 'Rings Warm-Up for Shoulder Press \n' +
          '* Tuck to inverted hang, then skin the cat \n' +
          '* Pike to inverted hang, then skin the cat \n' +
          '* Strict muscle-up to support to L-sit \n' +
          '* Shoulder stand back to L-support or straddle support \n' +
          '* Forward roll back to L-support \n' +
          '* Forward roll to hang \n' +
          '* Pike or tuck to inverted hang to back-lever attempt, pull back to inverted hang \n' +
          '* Front-lever attempt \n' +
          '* Ring swings \n' +
          '* Ring dips (focus on full range of motion and controlled movement) \n' +
          '* Ring push-ups (emphasize control and proper form) \n' +
          '* Fly-away dismount (skin the cat and let go)';
      paragraphs[2] = 'Basic Body Weight (BBW) Warm-Up for Shoulder Press \n' +
          '* Round 1: Squat, Push-up, Sit-up, Pull-up (strict), Hip extension, Pike push-up (to target shoulders more effectively) \n' +
          '* Round 2: Lunge, Dip (strict), V-up, Kipping pull-up, Back extension, Handstand hold against a wall (to build shoulder strength and stability) \n' +
          '* Round 3: Pistol, Handstand push-up, Toes-to-bar (straight leg and strict), Muscle-up (strict), Hip and back extension, Inverted shoulder taps (with feet elevated on a box or bench) \n' +
          '* Round 4: Pose running drill, Shoulder tap push-ups (alternate tapping shoulders after each push-up)';
      paragraphs[3] = 'Dumbbell Warm-Up for Shoulder Press \n' +
          '(Performed with two dumbbells at a time) \n' +
          '* Round 1: Deadlift, Hang power clean, Front squat, Press (focus on shoulder press), Thruster \n' +
          '(Performed with one dumbbell at a time) \n' +
          '* Round 2: Deadlift, Hang power snatch, Overhead squat, Snatch, Turkish get-up \n' +
          '* Round 3: Seated single-arm dumbbell shoulder press (alternate arms, focus on strict form), Dumbbell front raise (alternate arms), Dumbbell lateral raise (alternate arms), Dumbbell rear delt fly (bent-over position), Dumbbell upright row';
      paragraphs[4] = 'Parallettes Warm-Up for Shoulder Press \n' +
          '(Create a mini routine by going through the list. Omit the more difficult variations until skilled enough.) \n' +
          '* Round 1: Push-up/dive bomber push-up (focus on shoulder engagement), Shoot-through to push-up to frog stand, L-sit pass-through to tuck planche, L-sit pass-through to shoulder stand, Pike push-up \n' +
          '* Round 2: Handstand hold (focus on shoulder stability and strength), Tuck up to handstand/press to handstand (from L or press from bottom of shoulder stand), Handstand shoulder taps (focus on shoulder stability), Handstand push-up, Handstand pirouette walk';
      paragraphs[5] = 'Kettlebell Warm-Up for Shoulder Press \n' +
          '(Can be performed with one or both kettlebells or with hand-to-hand techniques) \n' +
          '* Round 1: Swing, clean, Clean and press (focus on shoulder engagement), Turkish get-up (partial, up to the hand-supported sitting position), Halo (circular movement around the head) \n' +
          '* Round 2: Swing, clean, Push press (incorporate a slight dip and drive from the legs to support the shoulder press), snatch, Turkish get-up (full movement)';
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

    double screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize = screenWidth < 350 ? 14.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.grey[500],
      appBar: AppBar(
        title: Text(
          'Update Warm-ups: Choose Your Weakest Movement',
          maxLines: 2,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: titleFontSize),
        ),
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
        ],
      ),
    );
  }
}
