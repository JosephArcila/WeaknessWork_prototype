import 'package:flutter/material.dart';
import 'package:flutter_material_symbols/flutter_material_symbols.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:google_speech/speech_client_authenticator.dart';
import 'package:google_speech/google_speech.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

const int kAudioSampleRate = 16000;
const int kAudioNumChannels = 1;

void main() => runApp(WeaknessWorkApp());

class WeaknessWorkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeaknessWork',
      theme: ThemeData(
        fontFamily: 'Klee One',
        primaryColor: Color(0xFF759E80),
        canvasColor: Color(0xFFE8E2CA), // Add this line to change the default Material color
        appBarTheme: AppBarTheme(backgroundColor: Color(0xFF759E80),
          iconTheme: IconThemeData(color: Colors.black),
          toolbarTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Klee One',
          ),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Klee One',
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  stt.SpeechToText? _speech;
  bool _isListening = false;
  bool _isNavigating = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<_WarmupState> _warmupStateKey = GlobalKey<_WarmupState>();
  final GlobalKey<_AudioRecognizeState> _audioRecognizeKey = GlobalKey<_AudioRecognizeState>();
  _WarmupState? get _warmupState => _warmupStateKey.currentState;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listen();
    });
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
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'General Warm-Ups to Address Weaknesses \n',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Klee One',
                              fontSize: 20.0
                          ),
                        ),
                        TextSpan(
                          text: '\u2022',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Klee One',
                          ),
                        ),
                        TextSpan(
                          text:
                          ' Based on the CrossFit Training Level 2 Guide\n',
                        ),
                        TextSpan(
                          text: '\u2022',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Klee One',
                          ),
                        ),
                        TextSpan(
                          text:
                          ' Use them to add skill work by modality\n',
                        ),
                        TextSpan(
                          text: '\u2022',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Klee One',
                          ),
                        ),
                        TextSpan(
                          text:
                          ' Performed for 2-3 rounds, each more complicated\n',
                        ),
                        TextSpan(
                          text: '\u2022',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Klee One',
                          ),
                        ),
                        TextSpan(
                          text:
                          ' 5-15 reps per movement',
                        ),
                      ],
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                        fontFamily: 'Klee One',
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Voice Command Guide \n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Klee One',
                              fontSize: 20.0
                          ),
                        ),
                        TextSpan(
                          text: 'All right record: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Klee One',
                          ),
                        ),
                        TextSpan(
                          text:
                          'Starts recording the workout result.\n',
                        ),
                      ],
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                        fontFamily: 'Klee One',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech!.initialize(
        onStatus: (val) {
          if (val == 'notListening') {
            setState(() => _isListening = false);
          } else {
            setState(() => _isListening = true);
          }
        },
        onError: (val) => print('Error: $val'),
      );
      if (available) {
        _speech!.listen(
          onResult: (val) async {
            print('Recognized words: ${val.recognizedWords}');
            final recognizedWords = val.recognizedWords.toLowerCase().trim();
            if (recognizedWords == 'all right record' && !_isNavigating) {
              _isNavigating = true; // Set flag to prevent navigation loop
              _speech?.stop();
              await Future.delayed(Duration(milliseconds: 500));
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AudioRecognize(startImmediately: true)),
              );
              _audioRecognizeKey.currentState!.startRecording();
              bool available = await _speech!.initialize(
                onStatus: (val) {
                  if (val == 'notListening') {
                    setState(() => _isListening = false);
                  } else {
                    setState(() => _isListening = true);
                  }
                },
                onError: (val) => print('Error: $val'),
              );
              if (available) {
                _speech?.listen(); // Start listening again
                setState(() => _isListening = true); // Ensure _isListening is set to true
              }
              _isNavigating = false;
            }
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeaknessWork',
      theme: ThemeData(
        fontFamily: 'Klee One',
        primaryColor: Color(0xFF759E80),
        canvasColor: Color(0xFFE8E2CA), // Add this line to change the default Material color
        appBarTheme: AppBarTheme(backgroundColor: Color(0xFF759E80),
          iconTheme: IconThemeData(color: Colors.black),
          toolbarTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Klee One',
          ),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Klee One',
          ),
        ),
      ),
      home: Builder(
        builder: (context) => Scaffold(
          key: _scaffoldKey, // assign the key here
          backgroundColor: Color(0xFFE8E2CA),
          appBar: AppBar(
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'W',
                    style: TextStyle(color: Color(0xFFD2DCEA), fontSize: 20.0, fontFamily: 'Klee One'),
                  ),
                  TextSpan(
                    text: 'W',
                    style: TextStyle(color: Color(0xFFB84F52), fontSize: 20.0, fontFamily: 'Klee One'),
                  ),
                  TextSpan(
                    text: ' WeaknessWork',
                    style: TextStyle(color: Colors.black, fontSize: 20.0, fontFamily: 'Klee One'),
                  ),
                ],
                style: DefaultTextStyle.of(context).style.copyWith(decoration: TextDecoration.none),
              ),
            ),
            backgroundColor: Color(0xFF759E80),
          ),

          body: Warmup(warmupKey: _warmupStateKey), // Pass the key to WarmupPage
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      _showAppInfoModalBottomSheet(context);
                    },
                    icon: Icon(Icons.info_outline),
                    color: Colors.black,
                  ),
                  FloatingActionButton.extended(
                    icon: Icon(
                      Icons.score,
                      color: Colors.black,
                    ),
                    label: Text('Results',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AudioRecognize()),
                      );
                    },
                    heroTag: "micButton",
                    backgroundColor: Color(0xFFEA8176),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1.0),
                      side: BorderSide(color: Colors.black, width: 2.0),
                    ),
                  ),
                  FloatingActionButton.small(
                    heroTag: "weaknessAssessmentButton", // Add unique tag here
                    onPressed: () async {
                      int result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WeaknessAssessmentPage()),
                      );
                      setState(() {
                        _warmupState?.selectedMovementIndex = result;
                      });
                    },
                    child: Icon(
                      MaterialSymbols.conditions,
                      color: Colors.black,
                    ),
                    backgroundColor: Color(0xFFD2DCEA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1.0),
                      side: BorderSide(color: Colors.black, width: 2.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AudioRecognize extends StatefulWidget {
  final bool startImmediately;

  const AudioRecognize({Key? key, this.startImmediately = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AudioRecognizeState();
}

class _AudioRecognizeState extends State<AudioRecognize> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  bool recognizing = false;
  bool recognizeFinished = false;
  String text = '';
  StreamSubscription<List<int>>? _audioStreamSubscription;
  BehaviorSubject<List<int>>? _audioStream;
  StreamController<Food>? _recordingDataController;
  StreamSubscription? _recordingDataSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.startImmediately) {
        startRecording();
      }
    });
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
          text = responseText;
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
      speechContexts: [SpeechContext(["AMRAP", "EMOM", "WOD", "Metcon", "PR", "RX", "deadlift",
        "plank hold", "calorie row", "box jump", "wall-ball", "burpee",
        "Clean and jerk", "Snatch", "double-under", "kipping", "Thruster",
        "Muscle-up", "handstand push-ups", "toes-to-bar", "kettlebell swing",
        "Fran", "Cindy", "Murph", "Lynne", "bench press", "pull-up", "round",
        "rep", "max reps", "body weight", "Angie", "Barbara", "Chelsea", "Diane",
        "Elizabeth", "Grace", "Helen", "Isabel", "Jackie", "Karen", "Linda", "Mary",
        "Nancy", "Annie", "Eva", "Kelly", "Nicole", "Amanda", "Gwen", "Marguerita",
        "Candy", "Maggie", "Hope", "Grettel", "Ingrid", "Barbara Ann", "Lyla",
        "Ellen", "Andi", "Lane", "clean and jerks", "snatches", "thrusters",
        "sumo deadlift high pulls", "front squats", "hang power snatches",
        "push presses", "handstand push-ups", "one-legged squats", "burpees over the bar",
        "bodyweight clean and jerks", "dumbbell snatches", "dumbbell thrusters",
        "for time", "rounds for time", "reps for time", "complete as many rounds as possible",
        "every minute on the minute", "max reps", "rest precisely", "body-weight",
        "same load", "rotate", "score", "single dumbbell", "pair", "single-arm",
        "double-arm", "alternating legs", "touch and go", "no dumping", "re-grip",
        "foul"])
      ]
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: recognizing ? const Text('Recording...') : const Text('Results'),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                if (recognizing)
                  LinearProgressIndicator(
                    backgroundColor: Color(0xFFD2DCEA),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB84F52)),
                  ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text(
                            'Your Spoken Workout Log:',
                          ),
                        ),
                        if (recognizeFinished)
                          _RecognizeContent(
                            text: text,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: FloatingActionButton.extended(
                  onPressed: recognizing ? stopRecording : streamingRecognize,
                  label: Text(recognizing ? 'Stop' : 'Start Voice Log', style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
                  icon: Icon(recognizing ? Icons.stop : Icons.mic, color: Colors.black,),
                  backgroundColor: Color(0xFFEA8176),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1.0),
                    side: BorderSide(color: Colors.black, width: 2.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecognizeContent extends StatelessWidget {
  final String text;

  const _RecognizeContent({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(2.0),
        color: Color(0xFFF4F1E6), // background color
        child: Text(
          text,
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
        '* Round 1: Deadlift, Hang power clean, Front squat, Press, Thruster\n' +
        '* Round 2: Deadlift, Hang power snatch, Overhead squat, Snatch',
    'Rings Complex Warm-Up\n' +
        '(Create a mini routine by going through the list. Omit the more difficult variations until skilled enough.)\n' +
        '* Tuck to inverted hang, then skin the cat\n' +
        '* Pike to inverted hang, then skin the cat\n' +
        '* Strict muscle-up to support to L-sit\n' +
        '* Shoulder stand back to L-support or straddle support\n' +
        '* Forward roll back to L-support\n' +
        '* Forward roll to hang\n' +
        '*  Pike or tuck to inverted hang to back-lever attempt, pull back to inverted hang\n' +
        '* Front-lever attempt\n' +
        '* Ring swings\n' +
        '* Fly-away dismount (skin the cat and let go)',
    'Basic Body Weight (BBW) Complex Warm-Up\n' +
        '* Round 1: Squat, Push-up, Sit-up, Pull-up (strict), Hip extension\n' +
        '* Round 3: Pistol, Handstand push-up, Toes-to-bar (straight leg and strict), Muscle-up (strict), Hip and back extension\n'
            '* Round 4: Pose running drill',
    'Dumbbell Complex Warm-Up\n' +
        '(Performed with two dumbbells at a time)\n' +
        '* Round 1: Deadlift, Hang power clean, Front squat, Press, Thruster\n' +
        '(Performed with one dumbbell at a time)\n' +
        '* Round 2: Deadlift, Hang power snatch, Overhead squat, Snatch, Turkish get-up',
    'Parallettes Complex Warm-Up\n' +
        '(Create a mini routine by going through the list. Omit the more difficult variations until skilled enough.)\n' +
        '* Push-up/dive bomber push-up\n' +
        '* Shoot-through to push-up to frog stand\n' +
        '* L-sit pass-through to tuck planche\n' +
        '* L-sit pass-through to shoulder stand\n' +
        '* Tuck up to handstand/press to handstand (from L or press from bottom of shoulder stand)\n' +
        '* Handstand pirouette walk',
    'Kettlebell Complex Warm-Up\n' +
        '(Can be performed with one or both kettlebells or with hand-to-hand techniques)\n' +
        '* Swing, Clean, Clean and press, Snatch, Turkish get-up'
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
      if (line.startsWith('*')) {
        spans.add(TextSpan(
            text: '\u2022',
            style: TextStyle(fontWeight: FontWeight.bold, height: 1.5, fontFamily: 'Klee One')));

        // Check for the identifiers and remove them from the line
        bool displayDumbbellImages = line.contains('[ID:DB_IMAGES]');
        bool displayBarbellImages = line.contains('[ID:BB_IMAGES]');
        bool displayDumbbell2Images = line.contains('[ID:DB_IMAGES_2]');
        bool displayBarbell2Images = line.contains('[ID:BB_IMAGES_2]');
        line = line.replaceAll('[ID:DB_IMAGES]', '').replaceAll('[ID:BB_IMAGES]', '');
        line = line.replaceAll('[ID:DB_IMAGES_2]', '').replaceAll('[ID:BB_IMAGES_2]', '');

        spans.add(TextSpan(
            text: line.substring(1),
            style: TextStyle(height: 1.5, fontSize: 20.0, color: Colors.black, fontFamily: 'Klee One')));

        if (displayDumbbellImages) {
          List<String> imageList = [
            'images/dumbbelldeadlift.jpg',
            'images/dumbbellhangpowerclean.jpg',
            'images/dumbbellfrontsquat.jpg',
            'images/dumbbellpress.jpg',
            'images/dumbbelloverheadsquat.jpg',
          ];
          spans.add(WidgetSpan(child: CarouselSlider(
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
          spans.add(WidgetSpan(child: CarouselSlider(
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
          spans.add(WidgetSpan(child: CarouselSlider(
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
          spans.add(WidgetSpan(child: CarouselSlider(
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
      } else if (line.startsWith('(Can be performed') ||
          line.startsWith('(Create a mini routine') ||
          line.startsWith('(Performed with two dumbbells') ||
          line.startsWith('(Performed with one dumbbell')) {
        spans.add(TextSpan(
            text: line,
            style: TextStyle(fontStyle: FontStyle.italic, height: 1.5, fontFamily: 'Klee One')));
      } else {
        spans.add(TextSpan(
            text: line,
            style: TextStyle(height: 1.5, fontFamily: 'Klee One')));
      }
      spans.add(TextSpan(text: '\n'));
    }
    return spans;
  }

  void updateParagraphs() {
    if (selectedMovementIndex == 2) { // index for overheadsquat.jpg
      warmups[0] = 'Barbell Complex Warm-Up for Overhead Squat\n' +
          '* Round 1: Deadlift, Hang power clean, Front squat, Press, Overhead squat[ID:BB_IMAGES]\n' +
          '* Round 2: Deadlift, Hang power snatch, Overhead squat (with pause), Sots press, Snatch balance[ID:BB_IMAGES_2]';
      warmups[1] = 'Rings Complex Warm-Up for Overhead Squat \n' +
          '(Create a mini routine by going through the list. Omit the more difficult variations until skilled enough.) \n' +
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
      warmups[2] = 'Basic Body Weight (BBW) Complex Warm-Up for Overhead Squat\n' +
          '* Round 1: Squat, Push-up, Sit-up, Pull-up (strict), Hip extension, Overhead squat with PVC pipe or broomstick \n' +
          '* Round 2: Lunge, Dip (strict), V-up, Kipping pull-up, Back extension, Overhead squat with PVC pipe or broomstick (focus on improving mobility and control)\n' +
          '* Round 3: Pistol, Handstand push-up, Toes-to-bar (straight leg and strict), Muscle-up (strict), Hip and back extension, Overhead squat with PVC pipe or broomstick (add a pause at the bottom for stability)';
      warmups[3] = 'Dumbbell Complex Warm-Up for Overhead Squat\n' +
          '(Performed with two dumbbells at a time)\n' +
          '* Round 1: Deadlift, Hang power clean, Front squat, Press, Overhead squat[ID:DB_IMAGES]\n' +
          '(Performed with one dumbbell at a time)\n' +
          '* Round 2: Deadlift, Hang power snatch, Single-arm overhead squat, Snatch, Turkish get-up[ID:DB_IMAGES_2]';
      warmups[4] = 'Parallettes Complex Warm-Up for Overhead Squat\n' +
          '(Create a mini routine by going through the list. Omit the more difficult variations until skilled enough.)\n' +
          '* Push-up/dive bomber push-up\n' +
          '* Shoot-through to push-up to frog stand\n' +
          '* L-sit pass-through to tuck planche\n' +
          '* L-sit pass-through to shoulder stand\n' +
          '* Tuck up to handstand/press to handstand (from L or press from bottom of shoulder stand)\n' +
          '* Handstand pirouette walk\n' +
          '* Handstand holds with focus on overhead stability and shoulder activation (hold for 15-30 seconds)\n' +
          '* Handstand push-up with a narrow grip (to target shoulder and triceps strength, which are important for overhead squat stability)\n' +
          '* Handstand shoulder shrugs (to improve shoulder stability and scapular control)';
      warmups[5] = 'Kettlebell Complex Warm-Up for Overhead Squat\n' +
          '(Can be performed with one or both kettlebells or with hand-to-hand techniques)\n' +
          '* Round 1: Swing, Goblet squat, Clean, Press, Single-arm overhead squat\n' +
          '* Round 2: Swing, Clean, Clean and press, Snatch, Turkish get-up';
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
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: RichText(
                text: TextSpan(
                  children: parseText(warmups[warmupNumber]),
                  style: TextStyle(fontSize: 20.0, color: Colors.black),
                ),
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

    double screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize = screenWidth < 350 ? 16.0 : 18.0;

    return DefaultTabController(
      length: 3, // Update the length to 3
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
          iconTheme: IconThemeData(color: Colors.black),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Color(0xFFB84F52),
              child: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                labelStyle: TextStyle(fontSize: 12.0),
                tabs: [
                  Tab(
                    icon: Icon(Icons.foundation),
                    text: 'Movements',
                  ),
                  Tab(
                    icon: Icon(Icons.hexagon_outlined),
                    text: 'Domains',
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
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      children: [
                        GridView.builder(
                          itemCount: imageNames.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.6,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            bool disabled = imageNames[index] != 'overheadsquat.jpg';

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
                                              child: Image.asset('images/${imageNames[index]}', fit: BoxFit.scaleDown),
                                            ),
                                            if (disabled)
                                              Container(
                                                color: Color.fromRGBO(128, 128, 128, 0.5), // semi-transparent grey color
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
                                      child: Text(
                                        movementNames[index],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: InkWell(
                          onTap: () {
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
                            avatar: InkWell(
                              child: Icon(Icons.key),
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
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Center(
                    child: Stack(
                      children: [
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Color.fromRGBO(128, 128, 128, 0.5), // semi-transparent grey color
                            BlendMode.modulate, // Use BlendMode.modulate instead
                          ),
                          child: Image.asset('images/decagon.png', fit: BoxFit.scaleDown),
                        ),
                        Positioned(
                          top: 4.0,
                          left: 4.0,
                          child: Icon(
                            Icons.lock,
                            size: 24.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.0),
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
                      avatar: InkWell(
                        child: Icon(Icons.key),
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
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      children: [
                        GridView.builder(
                          itemCount: imageNames.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.6,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            bool disabled = imageNames[index] != 'overheadsquat.jpg';

                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: InkWell(
                                onTap: disabled
                                    ? null
                                    : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ExpandedCardScreen(
                                        imageName: imageNames[index],
                                        movementName: movementNames[index],
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
                                                child: Image.asset('images/${imageNames[index]}', fit: BoxFit.scaleDown),
                                              ),
                                              if (disabled)
                                                Container(
                                                  color: Color.fromRGBO(128, 128, 128, 0.5), // semi-transparent grey color
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
                                      child: Text(
                                        movementNames[index],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        // Add your action here
                      },
                      child: Chip(
                        elevation: 10.0,
                        label: Text(
                          '¥500',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        avatar: InkWell(
                          child: Icon(Icons.key),
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
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);

    if(result != null) {
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