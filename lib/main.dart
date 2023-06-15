import 'package:flutter/material.dart';
import 'package:flutter_material_symbols/flutter_material_symbols.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:google_speech/google_speech.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

const int kAudioSampleRate = 16000;
const int kAudioNumChannels = 1;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(WeaknessWorkApp());
}

class WeaknessWorkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeaknessWork',
      theme: ThemeData(
        fontFamily: 'Klee One',
        primaryColor: Color(0xFF759E80),
        canvasColor: Color(0xFFE8E2CA),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF759E80),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        colorScheme: ColorScheme.light().copyWith(primary: Color(0xFFA3424B)),
      ),
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/',
      routes: {
        '/sign-in': (context) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pushReplacementNamed(context, '/');
              }),
            ],
          );
        },
        '/profile': (context) {
          return ProfileScreen(
            providers: [
              EmailAuthProvider(),
            ],
            actions: [
              SignedOutAction((context) {
                Navigator.pushReplacementNamed(context, '/sign-in');
              }),
            ],
          );
        },
        '/': (context) => HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  stt.SpeechToText? _speech;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<_WarmupState> _warmupStateKey = GlobalKey<_WarmupState>();
  _WarmupState? get _warmupState => _warmupStateKey.currentState;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _speech?.stop();
    super.dispose();
  }

  void _showAppInfoModalBottomSheet(BuildContext context) {
    ScrollController _modalScrollController = ScrollController();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(0xFFE8E2CA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: SingleChildScrollView(
              controller: _modalScrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'General Warm-Ups to Address Weaknesses \n',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            '\u2022 Based on the CrossFit Training Level 2 Guide\n',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextSpan(
                        text: '\u2022 Use them to add skill work by modality\n',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextSpan(
                        text:
                            '\u2022 Performed for 2-3 rounds, each more complicated\n',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextSpan(
                        text: '\u2022 5-15 reps per movement',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ], style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFE8E2CA),
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Color(0xFFA3424B)),
          child: RichText(
            text: TextSpan(
              text: 'WeaknessWork',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        backgroundColor: Color(0xFF759E80),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              if (FirebaseAuth.instance.currentUser != null) {
                Navigator.pushNamed(context, '/profile');
              } else {
                Navigator.pushNamed(context, '/sign-in');
              }
            },
          ),
        ],
      ),
      body: Warmup(warmupKey: _warmupStateKey),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () async {
                  int result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WeaknessAssessmentPage()),
                  );
                  setState(() {
                    _warmupState?.selectedMovementIndex = result;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD2DCEA),
                  side: BorderSide(color: Colors.black, width: 2.0),
                  shape: RoundedRectangleBorder(),
                ),
                child: Icon(MaterialSymbols.conditions, color: Colors.black),
              ),
              FloatingActionButton.extended(
                heroTag: "resutsButton",
                icon: Icon(
                  Icons.score,
                  color: Colors.black,
                ),
                label: Text(
                  'Results',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AudioRecognize()),
                  );
                },
                backgroundColor: Color(0xFFCF8E88),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black, width: 2.0),
                ),
              ),
              TextButton(
                onPressed: () {
                  _showAppInfoModalBottomSheet(context);
                },
                child: Icon(Icons.info_outline, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AudioRecognize extends StatefulWidget {
  final bool startImmediately;

  const AudioRecognize({Key? key, this.startImmediately = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AudioRecognizeState();
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => controller.clear(),
      );
}

class LogEntry {
  final String text;
  final DateTime date;

  LogEntry(this.text, this.date);

  // Convert a LogEntry object into a Map
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'date': date.toIso8601String(),
    };
  }

  // Convert a Map into a LogEntry object
  static LogEntry fromMap(Map<String, dynamic> map) {
    return LogEntry(
      map['text'],
      DateTime.parse(map['date']),
    );
  }

  // Convert a LogEntry object into a JSON string
  String toJson() => json.encode(toMap());

  // Convert a JSON string into a LogEntry object
  static LogEntry fromJson(String source) => fromMap(json.decode(source));
}

class _AudioRecognizeState extends State<AudioRecognize> {
  List<LogEntry> logs = [];
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool recognizing = false;
  bool recognizeFinished = false;
  String text = '';
  StreamSubscription<List<int>>? _audioStreamSubscription;
  BehaviorSubject<List<int>>? _audioStream;
  StreamController<Food>? _recordingDataController;
  StreamSubscription? _recordingDataSubscription;
  TextEditingController _textEditingController = TextEditingController();

  Future<void> saveLogs(List<LogEntry> logs) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'audioLogs', json.encode(logs.map((log) => log.toJson()).toList()));
  }

  Future<List<LogEntry>> loadLogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = prefs.getString('audioLogs') ?? '[]';
    List<dynamic> jsonList = json.decode(jsonString);
    List<LogEntry> logs =
        jsonList.map((item) => LogEntry.fromJson(item)).toList();
    return logs;
  }

  @override
  void initState() {
    super.initState();
    loadLogs().then((savedLogs) {
      setState(() {
        logs = savedLogs;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.startImmediately) {
        startRecording();
      }
    });
  }

  @override
  void dispose() {
    saveLogs(logs); // Save the logs before the state is disposed of
    super.dispose();
  }

  void addLog(LogEntry log) {
    setState(() {
      logs.add(log);
    });
    saveLogs(logs);
  }

  void removeLog(LogEntry log) {
    setState(() {
      logs.remove(log);
    });
    saveLogs(logs);
  }

  void startRecording() {
    if (!recognizing) {
      streamingRecognize();
    }
  }

  void streamingRecognize() async {
    await _recorder.openAudioSession();
    // Stream to be consumed by speech recognizer
    _audioStream = BehaviorSubject<List<int>>();

    // Create recording stream
    _recordingDataController = StreamController<Food>();
    _recordingDataSubscription =
        _recordingDataController?.stream.listen((buffer) {
      if (buffer is FoodData) {
        _audioStream!.add(buffer.data!);
      }
    });

    setState(() {
      recognizing = true;
    });

    await Permission.microphone.request();

    await _recorder.startRecorder(
        toStream: _recordingDataController!.sink,
        codec: Codec.pcm16,
        numChannels: kAudioNumChannels,
        sampleRate: kAudioSampleRate);

    final serviceAccount = ServiceAccount.fromString(
        (await rootBundle.loadString('assets/test_service_account.json')));
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);

    final config = _getConfig();

    final responseStream = speechToText.streamingRecognize(
        StreamingRecognitionConfig(config: config, interimResults: true),
        _audioStream!);

    var responseText = '';

    responseStream.listen((data) {
      if (data.results.first.isFinal) {
        final currentText =
            data.results.map((e) => e.alternatives.first.transcript).join('\n');

        responseText += responseText.isEmpty ? currentText : '\n' + currentText;
        setState(() {
          text = responseText; // update here
          _textEditingController.text = responseText; // update here
          recognizeFinished = true;
        });
      }
    }, onDone: () {
      setState(() {
        recognizing = false;
      });
    });
  }

  void stopRecording() async {
    await _recorder.stopRecorder();
    await _audioStreamSubscription?.cancel();
    await _audioStream?.close();
    await _recordingDataSubscription?.cancel();
    setState(() {
      recognizing = false;
    });
  }

  RecognitionConfig _getConfig() => RecognitionConfig(
          encoding: AudioEncoding.LINEAR16,
          model: RecognitionModel.command_and_search,
          enableAutomaticPunctuation: true,
          sampleRateHertz: 16000,
          languageCode: 'en-US',
          speechContexts: [
            SpeechContext([
              "AMRAP",
              "EMOM",
              "WOD",
              "Metcon",
              "PR",
              "RX",
              "deadlift",
              "plank hold",
              "calorie row",
              "box jump",
              "wall-ball",
              "burpee",
              "Clean and jerk",
              "Snatch",
              "double-under",
              "kipping",
              "Thruster",
              "Muscle-up",
              "handstand push-ups",
              "toes-to-bar",
              "kettlebell swing",
              "Fran",
              "Cindy",
              "Murph",
              "Lynne",
              "bench press",
              "pull-up",
              "round",
              "rep",
              "max reps",
              "body weight",
              "Angie",
              "Barbara",
              "Chelsea",
              "Diane",
              "Elizabeth",
              "Grace",
              "Helen",
              "Isabel",
              "Jackie",
              "Karen",
              "Linda",
              "Mary",
              "Nancy",
              "Annie",
              "Eva",
              "Kelly",
              "Nicole",
              "Amanda",
              "Gwen",
              "Marguerita",
              "Candy",
              "Maggie",
              "Hope",
              "Grettel",
              "Ingrid",
              "Barbara Ann",
              "Lyla",
              "Ellen",
              "Andi",
              "Lane",
              "clean and jerks",
              "snatches",
              "thrusters",
              "sumo deadlift high pulls",
              "front squats",
              "hang power snatches",
              "push presses",
              "handstand push-ups",
              "one-legged squats",
              "burpees over the bar",
              "bodyweight clean and jerks",
              "dumbbell snatches",
              "dumbbell thrusters",
              "for time",
              "rounds for time",
              "reps for time",
              "complete as many rounds as possible",
              "every minute on the minute",
              "max reps",
              "rest precisely",
              "body-weight",
              "same load",
              "rotate",
              "score",
              "single dumbbell",
              "pair",
              "single-arm",
              "double-arm",
              "alternating legs",
              "touch and go",
              "no dumping",
              "re-grip",
              "foul"
            ])
          ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: recognizing
            ? Text('Recording...',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold))
            : Text('Results',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                if (recognizing)
                  LinearProgressIndicator(
                    backgroundColor: Color(0xFFD2DCEA),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFB84F52)),
                  ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextField(
                          controller: TextEditingController(),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _ClearButton(
                                controller: TextEditingController()),
                            labelText: 'Search logs',
                            filled: true,
                          ),
                        ),
                      ),
                      for (var log in logs)
                        Column(
                          children: [
                            ListTile(
                              title: Text(
                                DateFormat('EEEE yyMMdd').format(log.date),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Container(
                                color: Color(0xFFF4F1E6),
                                child: Text(
                                  log.text,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              trailing: PopupMenuButton<int>(
                                icon: Icon(Icons.more_horiz),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 1,
                                    child: Text(
                                      "Edit",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 2,
                                    child: Text(
                                      "Delete",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 1) {
                                    // Edit the ListTile...
                                  } else if (value == 2) {
                                    // Delete the ListTile...
                                    setState(() {
                                      logs.remove(log);
                                    });
                                  }
                                },
                              ),
                            ),
                            Divider(
                              height: 25.0,
                              thickness: 2.0,
                              color: Color(0xFF759E80),
                              indent: 20,
                              endIndent: 20,
                            ),
                          ],
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 0),
                        child: Text(
                          DateFormat('EEEE yyMMdd').format(DateTime.now()),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _RecognizeContent(textController: _textEditingController),
                      FilledButton.icon(
                          onPressed: () {
                            setState(() {
                              logs.add(LogEntry(
                                  _textEditingController.text, DateTime.now()));
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xFFD2DCEA)),
                            side: MaterialStateProperty.all<BorderSide>(
                                BorderSide(color: Colors.black, width: 2.0)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.note_add, color: Colors.black),
                          label: Text(
                            "Save",
                            style: TextStyle(color: Colors.black),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFE8E2CA),
        child: recognizing
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: FilledButton(
                  child: Icon(Icons.stop, color: Colors.black),
                  onPressed: stopRecording,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFFD2DCEA)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide(width: 2.0),
                      ),
                    ),
                    elevation: MaterialStateProperty.all<double>(12.0),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      child: Icon(Icons.search, color: Colors.black),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.black, width: 2.0),
                        shape: RoundedRectangleBorder(),
                      ),
                      onPressed: () {
                        // Add your history function here
                      },
                    ),
                    FloatingActionButton(
                      heroTag: "micButton",
                      child: Icon(Icons.mic, color: Colors.black),
                      backgroundColor: Color(0xFFCF8E88),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black, width: 2.0),
                      ),
                      onPressed: () {
                        try {
                          streamingRecognize();
                        } catch (e) {
                          print('Error: $e');
                        }
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _RecognizeContent extends StatelessWidget {
  final TextEditingController textController;

  const _RecognizeContent({Key? key, required this.textController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(2.0),
          color: Color(0xFFF4F1E6), // background color
          child: TextField(
            style: Theme.of(context).textTheme.bodyMedium,
            controller: textController,
            maxLines: null,
            textInputAction: TextInputAction.done,
            onChanged: (value) {
              // The textController is updated automatically
            },
            onSubmitted: (value) {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
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
  final List<String> warmups = [
    'Barbell Complex Warm-Up\n' +
        '\u2022 Round 1: Deadlift, Hang power clean, Front squat, Press, Thruster\n' +
        '\u2022 Round 2: Deadlift, Hang power snatch, Overhead squat, Snatch',
    'Rings Complex Warm-Up\n' +
        '(Create a mini routine by going through the list. Omit the more difficult variations until skilled enough.)\n' +
        '\u2022 Tuck to inverted hang, then skin the cat\n' +
        '\u2022 Pike to inverted hang, then skin the cat\n' +
        '\u2022 Strict muscle-up to support to L-sit\n' +
        '\u2022 Shoulder stand back to L-support or straddle support\n' +
        '\u2022 Forward roll back to L-support\n' +
        '\u2022 Forward roll to hang\n' +
        '\u2022  Pike or tuck to inverted hang to back-lever attempt, pull back to inverted hang\n' +
        '\u2022 Front-lever attempt\n' +
        '\u2022 Ring swings\n' +
        '\u2022 Fly-away dismount (skin the cat and let go)',
    'Basic Body Weight (BBW) Complex Warm-Up\n' +
        '\u2022 Round 1: Squat, Push-up, Sit-up, Pull-up (strict), Hip extension\n' +
        '\u2022 Round 3: Pistol, Handstand push-up, Toes-to-bar (straight leg and strict), Muscle-up (strict), Hip and back extension\n'
            '\u2022 Round 4: Pose running drill',
    'Dumbbell Complex Warm-Up\n' +
        '(Performed with two dumbbells at a time)\n' +
        '\u2022 Round 1: Deadlift, Hang power clean, Front squat, Press, Thruster\n' +
        '(Performed with one dumbbell at a time)\n' +
        '\u2022 Round 2: Deadlift, Hang power snatch, Overhead squat, Snatch, Turkish get-up',
    'Parallettes Complex Warm-Up\n' +
        '(Create a mini routine by going through the list. Omit the more difficult variations until skilled enough.)\n' +
        '\u2022 Push-up/dive bomber push-up\n' +
        '\u2022 Shoot-through to push-up to frog stand\n' +
        '\u2022 L-sit pass-through to tuck planche\n' +
        '\u2022 L-sit pass-through to shoulder stand\n' +
        '\u2022 Tuck up to handstand/press to handstand (from L or press from bottom of shoulder stand)\n' +
        '\u2022 Handstand pirouette walk',
    'Kettlebell Complex Warm-Up\n' +
        '(Can be performed with one or both kettlebells or with hand-to-hand techniques)\n' +
        '\u2022 Swing, Clean, Clean and press, Snatch, Turkish get-up'
  ];

  Widget displayImages() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      children: [
        Image.asset('images/deadlift.jpg'),
        Image.asset('images/hangpowerclean.jpg'),
        Image.asset('images/frontsquat.jpg'),
        Image.asset('images/press.jpg'),
        Image.asset('images/overheadsquat.jpg'),
      ],
    );
  }

  List<InlineSpan> parseText(String text) {
    List<String> lines = text.split('\n');
    List<InlineSpan> spans = [];
    for (String line in lines) {
      if (line.startsWith('\u2022')) {
        spans.add(TextSpan(
            text: '\u2022',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith()));

        // Check for the identifiers and remove them from the line
        bool displayDumbbellImages = line.contains('[ID:DB_IMAGES]');
        bool displayBarbellImages = line.contains('[ID:BB_IMAGES]');
        bool displayDumbbell2Images = line.contains('[ID:DB_IMAGES_2]');
        bool displayBarbell2Images = line.contains('[ID:BB_IMAGES_2]');
        line = line
            .replaceAll('[ID:DB_IMAGES]', '')
            .replaceAll('[ID:BB_IMAGES]', '');
        line = line
            .replaceAll('[ID:DB_IMAGES_2]', '')
            .replaceAll('[ID:BB_IMAGES_2]', '');

        spans.add(TextSpan(
          text: line.substring(1),
        ));

        if (displayDumbbellImages) {
          List<String> imageList = [
            'images/dumbbelldeadlift.jpg',
            'images/dumbbellhangpowerclean.jpg',
            'images/dumbbellfrontsquat.jpg',
            'images/dumbbellpress.jpg',
            'images/dumbbelloverheadsquat.jpg',
          ];
          spans.add(WidgetSpan(
              child: CarouselSlider(
            options: CarouselOptions(
              height: 100.0,
              enableInfiniteScroll: false,
            ),
            items: imageList.map((imageAsset) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Image.asset(imageAsset),
                  );
                },
              );
            }).toList(),
          )));
        } else if (displayBarbellImages) {
          List<String> imageList = [
            'images/deadlift.jpg',
            'images/hangpowerclean.jpg',
            'images/frontsquat.jpg',
            'images/shoulderpress.jpg',
            'images/overheadsquat.jpg',
          ];
          spans.add(WidgetSpan(
              child: CarouselSlider(
            options: CarouselOptions(
              height: 100.0,
              enableInfiniteScroll: false,
            ),
            items: imageList.map((imageAsset) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Image.asset(imageAsset),
                  );
                },
              );
            }).toList(),
          )));
        } else if (displayBarbell2Images) {
          List<String> imageList = [
            'images/deadlift.jpg',
            'images/hangpowersnatch.jpg',
            'images/overheadsquat.jpg',
            'images/sotspress.jpg',
            'images/snatchbalance.jpg',
          ];
          spans.add(WidgetSpan(
              child: CarouselSlider(
            options: CarouselOptions(
              height: 100.0,
              enableInfiniteScroll: false,
            ),
            items: imageList.map((imageAsset) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Image.asset(imageAsset),
                  );
                },
              );
            }).toList(),
          )));
        } else if (displayDumbbell2Images) {
          List<String> imageList = [
            'images/dumbbelldeadlift.jpg',
            'images/dumbbellhangpowersnatch.jpg',
            'images/dumbbelloverheadsquat.jpg',
            'images/dumbbellsnatch.jpg',
            'images/dumbbellturkishgetup.jpg',
          ];
          spans.add(WidgetSpan(
              child: CarouselSlider(
            options: CarouselOptions(
              height: 100.0,
              enableInfiniteScroll: false,
            ),
            items: imageList.map((imageAsset) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Image.asset(imageAsset),
                  );
                },
              );
            }).toList(),
          )));
        }
      } else if (line.startsWith('(')) {
        spans.add(TextSpan(
            text: line,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontStyle: FontStyle.italic)));
      } else {
        spans.add(TextSpan(
            text: line,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold)));
      }
      spans.add(TextSpan(text: '\n'));
    }
    return spans;
  }

  void updateParagraphs() {
    if (selectedMovementIndex == 2) {
      // index for overheadsquat.jpg
      warmups[0] = 'Barbell Complex Warm-Up for Overhead Squat\n' +
          '\u2022 Round 1: Deadlift, Hang power clean, Front squat, Press, Overhead squat[ID:BB_IMAGES]\n' +
          '\u2022 Round 2: Deadlift, Hang power snatch, Overhead squat (with pause), Sots press, Snatch balance[ID:BB_IMAGES_2]';
      warmups[1] = 'Rings Complex Warm-Up for Overhead Squat \n' +
          '(Create a mini routine by going through the list. Omit the more difficult variations until skilled enough.) \n' +
          '\u2022 Tuck to inverted hang, then skin the cat \n' +
          '\u2022 Pike to inverted hang, then skin the cat \n' +
          '\u2022 Strict muscle-up to support to L-sit \n' +
          '\u2022 Shoulder stand back to L-support or straddle support \n' +
          '\u2022 Forward roll back to L-support \n' +
          '\u2022 Forward roll to hang \n' +
          '\u2022 Pike or tuck to inverted hang to back-lever attempt, pull back to inverted hang \n' +
          '\u2022 Front-lever attempt \n' +
          '\u2022 False grip hang with active shoulders (to improve grip strength and stability for overhead movements) \n' +
          '\u2022 Ring swings with an emphasis on maintaining a strong overhead position during the swing';
      warmups[2] = 'Basic Body Weight (BBW) Complex Warm-Up for Overhead Squat\n' +
          '\u2022 Round 1: Squat, Push-up, Sit-up, Pull-up (strict), Hip extension, Overhead squat with PVC pipe or broomstick \n' +
          '\u2022 Round 2: Lunge, Dip (strict), V-up, Kipping pull-up, Back extension, Overhead squat with PVC pipe or broomstick (focus on improving mobility and control)\n' +
          '\u2022 Round 3: Pistol, Handstand push-up, Toes-to-bar (straight leg and strict), Muscle-up (strict), Hip and back extension, Overhead squat with PVC pipe or broomstick (add a pause at the bottom for stability)';
      warmups[3] = 'Dumbbell Complex Warm-Up for Overhead Squat\n' +
          '(Performed with two dumbbells at a time)\n' +
          '\u2022 Round 1: Deadlift, Hang power clean, Front squat, Press, Overhead squat[ID:DB_IMAGES]\n' +
          '(Performed with one dumbbell at a time)\n' +
          '\u2022 Round 2: Deadlift, Hang power snatch, Single-arm overhead squat, Snatch, Turkish get-up[ID:DB_IMAGES_2]';
      warmups[4] = 'Parallettes Complex Warm-Up for Overhead Squat\n' +
          '(Create a mini routine by going through the list. Omit the more difficult variations until skilled enough.)\n' +
          '\u2022 Push-up/dive bomber push-up\n' +
          '\u2022 Shoot-through to push-up to frog stand\n' +
          '\u2022 L-sit pass-through to tuck planche\n' +
          '\u2022 L-sit pass-through to shoulder stand\n' +
          '\u2022 Tuck up to handstand/press to handstand (from L or press from bottom of shoulder stand)\n' +
          '\u2022 Handstand pirouette walk\n' +
          '\u2022 Handstand holds with focus on overhead stability and shoulder activation (hold for 15-30 seconds)\n' +
          '\u2022 Handstand push-up with a narrow grip (to target shoulder and triceps strength, which are important for overhead squat stability)\n' +
          '\u2022 Handstand shoulder shrugs (to improve shoulder stability and scapular control)';
      warmups[5] = 'Kettlebell Complex Warm-Up for Overhead Squat\n' +
          '(Can be performed with one or both kettlebells or with hand-to-hand techniques)\n' +
          '\u2022 Round 1: Swing, Goblet squat, Clean, Press, Single-arm overhead squat\n' +
          '\u2022 Round 2: Swing, Clean, Clean and press, Snatch, Turkish get-up';
    }
  }

  ScrollController _warmupScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    updateParagraphs();
    return Center(
      child: TextButton(
        onPressed: () {
          setState(() {
            warmupNumber = (warmupNumber + 1) % warmups.length;
          });
        },
        child: Scrollbar(
          // Add these lines to set the isAlwaysShown property and the controller
          thumbVisibility: true,
          controller: _warmupScrollController,
          child: SingleChildScrollView(
            // Add this line to set the controller for the SingleChildScrollView
            controller: _warmupScrollController,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: RichText(
                text: TextSpan(
                    children: parseText(warmups[warmupNumber]),
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WeaknessAssessmentPage extends StatelessWidget {
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

    final List<String> movementNames = [
      'Air Squat',
      'Front Squat',
      'Overhead Squat',
      'Shoulder Press',
      'Push Press',
      'Push Jerk',
      'Deadlift',
      'SDHP',
      'Ball Clean',
    ];

    return DefaultTabController(
      length: 2, // Update the length to 3
      child: Scaffold(
        backgroundColor: Color(0xFFE8E2CA),
        appBar: AppBar(
          backgroundColor: Color(0xFF759E80),
          title: Text('Assess Weaknesses',
              maxLines: 2,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          iconTheme: IconThemeData(color: Colors.black),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Color(0xFFA3424B),
              child: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                labelStyle: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(
                    icon: Icon(Icons.foundation),
                    text: 'Movements',
                  ),
                  Tab(
                    icon: Icon(Icons.videocam), // Add the videocam icon
                    text: 'Correcting', // Add the 'Correcting' tab
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Accelerate progress with tailored warm-ups to improve your weakest movement',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      children: [
                        GridView.builder(
                          itemCount: imageNames.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.6,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            bool disabled =
                                imageNames[index] != 'overheadsquat.jpg';

                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: InkWell(
                                onTap: disabled
                                    ? null
                                    : () {
                                        Navigator.pop(context, index);
                                      },
                                child: Column(
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 1,
                                      child: Card(
                                        elevation: 10.0,
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.center,
                                              child: Image.asset(
                                                  'images/${imageNames[index]}',
                                                  fit: BoxFit.scaleDown),
                                            ),
                                            if (disabled)
                                              Container(
                                                color: Color.fromRGBO(
                                                    128,
                                                    128,
                                                    128,
                                                    0.5), // semi-transparent grey color
                                              ),
                                            if (disabled)
                                              Icon(
                                                Icons.lock,
                                                size: 24.0,
                                                color: Colors.white,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 1.0),
                                      child: Text(movementNames[index],
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Correcting view
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Upload a video to identify and assess movement faults to correct mechanics',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      children: [
                        GridView.builder(
                          itemCount: imageNames.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.6,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            bool disabled =
                                imageNames[index] != 'overheadsquat.jpg';

                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: InkWell(
                                onTap: disabled
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ExpandedCardScreen(
                                              imageName: imageNames[index],
                                              movementName:
                                                  movementNames[index],
                                            ),
                                          ),
                                        );
                                      },
                                child: Column(
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 1,
                                      child: Hero(
                                        tag: imageNames[index],
                                        child: Card(
                                          elevation: 10.0,
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.center,
                                                child: Image.asset(
                                                    'images/${imageNames[index]}',
                                                    fit: BoxFit.scaleDown),
                                              ),
                                              if (disabled)
                                                Container(
                                                  color: Color.fromRGBO(
                                                      128,
                                                      128,
                                                      128,
                                                      0.5), // semi-transparent grey color
                                                ),
                                              if (disabled)
                                                Icon(
                                                  Icons.lock,
                                                  size: 24.0,
                                                  color: Colors.white,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 1.0),
                                      child: Text(movementNames[index],
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandedCardScreen extends StatefulWidget {
  final String imageName;
  final String movementName;

  ExpandedCardScreen({required this.imageName, required this.movementName});

  @override
  _ExpandedCardScreenState createState() => _ExpandedCardScreenState();
}

class _ExpandedCardScreenState extends State<ExpandedCardScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  Future<void> _pickVideo() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      File file = File(result.files.single.path!);

      setState(() {
        _videoPlayerController = VideoPlayerController.file(file);
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: true,
          looping: true,
        );
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8E2CA),
      appBar: AppBar(
        title: Text(
          'Overhead squat correction',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Color(0xFF759E80), // Set the border color here
              width: 8.0, // Set the border width here
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Hero(
                      tag: widget.imageName,
                      child: Image.asset(
                        'images/${widget.imageName}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                if (_chewieController != null)
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Chewie(
                        controller: _chewieController!,
                      ),
                    ),
                  ),
                SizedBox(height: 16.0),
                InkWell(
                  onTap: () async {
                    await _pickVideo();
                  },
                  child: Chip(
                    elevation: 10.0,
                    label: Text(
                      'Upload Video',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    avatar: InkWell(
                      child: Icon(Icons.file_upload),
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
        ),
      ),
    );
  }
}
