import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_interfaces/features/Congrats.dart';
import 'package:flutter_interfaces/features/finalverify.dart';
import 'package:flutter_interfaces/widgets/Appbuttons.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:word_generator/word_generator.dart';
import 'package:lottie/lottie.dart';

final RandomWord = WordGenerator();
String noun = RandomWord.randomNoun();

class Speechtotextt extends StatefulWidget {
  const Speechtotextt({super.key});

  @override
  State<Speechtotextt> createState() => _HomePageState();
}

class _HomePageState extends State<Speechtotextt> with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;
  int successCounter = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    initSpeech();
    _animationController = AnimationController(
      vsync: this,
    );
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
      _animationController.repeat();
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _animationController.stop();
    });
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
      _confidenceLevel = result.confidence;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void regren() {
      setState(() {
        noun = RandomWord.randomNoun();
        _wordsSpoken = '';
      });
    }

    bool SuccessState(successCounter) {
      return successCounter >= 3;
    }

    bool _verifyText() {
      var cleanedRecognizedWords =
      _wordsSpoken.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.lightBlue[200]!, // Light blue ombre
              Colors.orange[200]! // Light orange
            ],
          ),
        ),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 31),
              Text(
                'Read the following text for authentication: $noun',
                style: TextStyle(
                  fontSize: 24,
                  color: _speechToText.isListening ? Colors.black87 : Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  _speechToText.isListening
                      ? "listening..."
                      : _speechEnabled
                      ? "Tap the microphone to start listening..."
                      : "Speech not available",
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              Expanded(
                child: _verifyText() ? const Text("Success") : const Text("Failed"),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    _wordsSpoken,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 45),
              AvatarGlow(
                animate: _speechToText.isListening,
                duration: const Duration(milliseconds: 2000),
                glowColor: const Color(0xFF2F66F5),
                repeat: true,
                child: GestureDetector(
                  onTap: () {
                    _speechToText.isNotListening
                        ? _startListening()
                        : _stopListening();
                  },
                  child: Lottie.asset(
                    "assets/microphone.json",
                    controller: _animationController,
                    onLoaded: (composition) {
                      _animationController.duration = composition.duration;
                    },
                  ),
                ),
              ),
              Expanded(
                child: Text(
                "You need to saay at least 3 words right"
                ),
              ),
              const SizedBox(height: 45),
              Appbuttons(
                onPressed: () {
                  regren();
                },
                text: "Click to regenerate a word",
              ),
              const SizedBox(height: 20),
              Appbuttons(
                text: "Submit",
                onPressed: SuccessState(successCounter)
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => finalverfiy()),
                  );
                }
                    : null,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
