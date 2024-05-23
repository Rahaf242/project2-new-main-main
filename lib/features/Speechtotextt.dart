import 'dart:async';
import 'dart:math';

import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import '../core/models/user_model.dart';
import 'package:flutter_interfaces/features/finalverify.dart';


import '../Widgets/Appbuttons.dart';
import 'Congrats.dart';

class Speechtotextt extends StatefulWidget {
  const Speechtotextt({Key? key}) : super(key: key);

  @override
  State<Speechtotextt> createState() => _SpeechtotexttState();
}

class _SpeechtotexttState extends State<Speechtotextt> with SingleTickerProviderStateMixin {
  SpeechToText _speechToText = SpeechToText();
  String _recognizedWords = '';
  bool isListening = false;
  int successCounter = 0;
  String noun = '';
  bool showResult = false;
  bool verification1Success = false;

  late AnimationController _animationController;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    requestPermission();
    _initSpeech();
    _initTTS();
    _fetchRandomSentence().then((sentence) {
      setState(() {
        noun = sentence;
      });
    });
    _animationController = AnimationController(vsync: this);
  }

  void requestPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speechToText.stop();
    flutterTts.stop();
    super.dispose();
  }

  /*void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }
*/

  bool _speechInitialized = false;

  void _initSpeech() async {
    bool available = await _speechToText.initialize(onError: (val) => print('Error initializing speech: $val'), onStatus: (val) => print('Speech status: $val'));
    if (!available) {
      print("The user has denied the use of speech recognition.");
    } else {
      setState(() {});
    }
    try {
      _speechInitialized = await _speechToText.initialize(
          onError: (val) => print('Error initializing speech: $val'),
          onStatus: (val) => print('Speech status: $val')
      );
      setState(() {});
      if (!_speechInitialized) {
        print("Speech initialization failed");
      }
    } catch (e) {
      print("An error occurred in speech initialization: $e");
    }
  }


  void _initTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

 /* void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      isListening = true;
      showResult = false;
      _animationController.repeat();
    });
    print('Speech recognition started');
  }*/

  void _startListening() async {
    if (_speechInitialized) {
      await _speechToText.listen(onResult: _onSpeechResult);
      setState(() {
        isListening = true;
        showResult = false;
        _animationController.repeat();
      });
      print('Speech recognition started');
    } else {
      print("Speech service not initialized.");
      _initSpeech();  // Attempt to initialize again if not initialized
    }
  }


  void _stopListening() async {
    await _speechToText.stop();
    _animationController.reset();
    print('Speech recognition stopped');

    Timer(Duration(seconds: 1), () {
      bool result = _verifyText();
      setState(() {
        isListening = false;
        showResult = true;
        verification1Success = result;
      });

      // Store result in Firestore
      _saveResultToFirestore(result);

      Timer(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            showResult = false;
          });
        }
      });
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _recognizedWords = result.recognizedWords;
    });
    print('Recognized speech: $_recognizedWords');
  }

  Future<String> _fetchRandomSentence() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('random_text')
          .get();

      List<String> sentences = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('texts')) {
          var texts = data['texts'] as List;
          sentences.addAll(texts.map((text) => text.toString()));
        }
      }

      Random random = Random();
      return sentences[random.nextInt(sentences.length)];
    } catch (e) {
      print('Error fetching random sentences: $e');
      return '';
    }
  }

  void _regenerateSen() {
    _fetchRandomSentence().then((sentence) {
      setState(() {
        noun = sentence;
        _recognizedWords = '';
        showResult = false;
        verification1Success = false;
      });
    });
  }

  bool _verifyText() {
    var cleanedRecognizedWords = _recognizedWords.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    var cleanedNoun = noun.trim().toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

    print('Verifying text: Recognized Words: $cleanedRecognizedWords, Noun: $cleanedNoun');
    if (cleanedRecognizedWords == cleanedNoun) {
      successCounter++;
      print('Success counter: $successCounter');
      return true;
    }
    print('ASR failed - no match');
    return false;
  }


  Future<void> _saveResultToFirestore(bool result) async {
    var user = FirebaseAuth.instance.currentUser;

    if (user != null) {

      UserModel userModel = await fetchUserModel(user.uid);

      await FirebaseFirestore.instance.collection('auth_results').add({
        'timestamp': FieldValue.serverTimestamp(),
        'result': result,
        'user_id': userModel.uid,
        'user_role': userModel.role,
        'first_name': userModel.firstName,
        'last_name': userModel.lastName,
      });
      print('Authentication result saved with user details');
    }
  }

  Future<UserModel> fetchUserModel(String userId) async {
    var doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return UserModel.fromMap(doc.data()! as Map<String, dynamic>);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color.fromARGB(255, 205, 239, 255)!,
      ),
      backgroundColor: Color.fromARGB(255, 211, 241, 255)!,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'To authenticate, tap the mic icon and read the sentence below:',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded( // Wraps the Text widget to prevent overflow
                    child: Text(
                      '"$noun"',
                      style: TextStyle(
                        fontSize: 24,
                        color: isListening ? Colors.yellow.shade800 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.volume_up),
                    onPressed: () {
                      if (noun.isNotEmpty) {
                        flutterTts.speak(noun);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                _recognizedWords.isNotEmpty
                    ? 'Recognized Speech: $_recognizedWords'
                    : '',
                style: TextStyle(
                  fontSize: 24,
                  color: isListening ? Colors.indigo : Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              if (showResult)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(seconds: 1),
                  child: Center(
                    child: SizedBox(
                      width: 250,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: verification1Success ? Colors.green.withOpacity(0.6) : Colors.red.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              verification1Success ? Icons.check_circle_outline : Icons.highlight_off,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(width: 10),
                            Text(
                              verification1Success ? "Matched" : "Mismatched",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  if (!_speechToText.isListening) {
                    _startListening();
                  } else {
                    _stopListening();
                  }
                },
                child: Container(
                  width: 150,
                  height: 150,
                  child: Lottie.asset(
                    'assets/microphone.json',
                    controller: _animationController,
                    onLoaded: (composition) {
                      _animationController
                        ..duration = composition.duration;
                    },
                    frameRate: FrameRate.max,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 60),
              Appbuttons(
                onPressed: _regenerateSen,
                text: "Regenerate a New Sentence",
              ),
              SizedBox(height: 25),
              Theme(
                data: Theme.of(context).copyWith(
                  buttonTheme: ButtonThemeData(
                    disabledColor: Colors.grey,
                  ),
                ),
                child: Appbuttons(
                  text: "Next",
                  onPressed: verification1Success ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => finalverfiy(),
                      ),
                    );
                  } : null,
                  backgroundColor: verification1Success ? Color(0xFF2D2689) : Colors.grey,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
