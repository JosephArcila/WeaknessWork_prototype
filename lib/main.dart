import 'package:flutter/material.dart';
import 'package:flutter_material_symbols/flutter_material_symbols.dart';
import 'dart:ui';

void main() => runApp(WeaknessWorkApp());

class WeaknessWorkApp extends StatefulWidget {
  @override
  _WeaknessWorkAppState createState() => _WeaknessWorkAppState();
}

class _WeaknessWorkAppState extends State<WeaknessWorkApp> {
  // Create a global key for the _WarmupState
  final GlobalKey<_WarmupState> _warmupStateKey = GlobalKey<_WarmupState>();

  // Add this getter
  _WarmupState? get _warmupState => _warmupStateKey.currentState;

  // Method to show the dialog
  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            dialogBackgroundColor: Color(0xFFE8E2CA),
          ),
          child: AlertDialog(
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
                      ' These are warm-ups by modality based on the CrossFit Traning Level 2 Guide. Use them to add skill work to your program\n\n',
                    ),
                    TextSpan(
                      text: '\u2022',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                      ' Think of them as an opportunity to touch on skills\n\n',
                    ),
                    TextSpan(
                      text: '\u2022',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                      ' The warm-ups below are progressive, performed for 2-3 rounds, each getting slightly more complicated\n\n',
                    ),
                    TextSpan(
                      text: '\u2022',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                      ' Perform each movement for 5-15 repetitions; the repetitions should give enough time to practice without fatiguing for the workout',
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
                child: Text('Great!'),
                style: TextButton.styleFrom(
                  primary: Color(0xFFB84F52), // Set the text color
                ),
              ),
            ],
          ),
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
          backgroundColor: Color(0xFFE8E2CA),
          appBar: AppBar(
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'W',
                    style: TextStyle(color: Color(0xFFD2DCEA), fontSize: 20.0),
                  ),
                  TextSpan(
                    text: 'W',
                    style: TextStyle(color: Color(0xFFB84F52), fontSize: 20.0),
                  ),
                  TextSpan(
                    text: ' WeaknessWork',
                    style: TextStyle(color: Colors.black, fontSize: 20.0),
                  ),
                ],
                style: DefaultTextStyle.of(context).style.copyWith(decoration: TextDecoration.none),
              ),
            ),
            backgroundColor: Color(0xFF759E80),
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
                  color: Colors.black,
                ),
                FloatingActionButton(
                  onPressed: () async {
                    int result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MovementSelectionPage()),
                    );
                    if (result != null) {
                      setState(() {
                        _warmupState?.selectedMovementIndex = result;
                      });
                    }
                  },
                  child: Icon(
                    MaterialSymbols.conditions,
                    color: Colors.black, // Change the icon color to black
                  ),
                  backgroundColor: Color(0xFF759E80),
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

  Warmup({required this.warmupKey}) : super(key: warmupKey);

  @override
  _WarmupState createState() => _WarmupState();
}

class _WarmupState extends State<Warmup> {
  int selectedMovementIndex = 0; // Initialize the field with a default value
  int warmupNumber = 0;
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
            style: TextStyle(height: 1.5, fontSize: 20.0, color: Colors.black)));
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
                style: TextStyle(fontSize: 20.0, color: Colors.black),
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
    double titleFontSize = screenWidth < 350 ? 16.0 : 18.0;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xFFE8E2CA),
        appBar: AppBar(
          backgroundColor: Color(0xFF759E80),
          title: Text(
            'Assess Weaknesses',
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black), // Add this line
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Color(0xFFB84F52), // Set the background color of the whole TabBar
              child: TabBar(
                indicatorColor: Colors.white, // Set the indicator color to white
                labelColor: Colors.white, // Set the label color to white
                unselectedLabelColor: Colors.black, // Set the unselected label color to black
                tabs: [
                  Tab(
                    icon: Icon(Icons.foundation),
                    text: 'Movements',
                  ),
                  Tab(
                    icon: Icon(Icons.hexagon_outlined),
                    text: 'Domains',
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Movements view
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView( // Add this line
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Add the title
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Accelerate progress with tailored warm-ups to improve your weakest movement',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                    ),
                    // Use a Column for the GridView.builder
                    Column(
                      children: [
                        GridView.builder(
                          itemCount: imageNames.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.0,
                            mainAxisSpacing: 8.0,
                            crossAxisSpacing: 8.0,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            bool disabled = imageNames[index] != 'overheadsquat.jpg';

                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: InkWell(
                                onTap: disabled
                                    ? null
                                    : () {
                                  // Pass the selected movement index to the previous screen
                                  Navigator.pop(context, index);
                                },
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Card(
                                    elevation: 10.0,
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.center,
                                          child: Image.asset('images/${imageNames[index]}', fit: BoxFit.scaleDown),
                                        ),
                                        // Add the grey overlay
                                        if (disabled)
                                          Container(
                                            color: Color.fromRGBO(128, 128, 128, 0.5), // semi-transparent grey color
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    // Add a transparent SizedBox for spacing
                    SizedBox(
                      height: 16.0,
                    ),
                    // Add the '¥100' button to the Movements page
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            // Add your action here
                          },
                          child: Chip(
                            elevation: 10.0,
                            label: Text(
                              '¥100',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            backgroundColor: Color(0xFFD2DCEA),
                            padding: EdgeInsets.all(4.0),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.black, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),


            // Domains view
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  // Add the title
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Accelerate progress with tailored warm-ups to improve your weak fitness domains',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset('images/decagon.png', fit: BoxFit.scaleDown),
                    ),
                  ),
                  // Call to action button
                  InkWell(
                    onTap: () {
                      // Add your action here
                    },
                    child: Chip(
                      elevation: 10.0,
                      label: Text(
                        '¥100',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      backgroundColor: Color(0xFFD2DCEA),
                      padding: EdgeInsets.all(4.0),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}