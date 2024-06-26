// ignore_for_file: unused_import

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_interfaces/features/Congrats.dart';
import 'package:flutter_interfaces/features/Forgotpassword.dart';
import 'package:flutter_interfaces/features/LandPage.dart';
import 'package:flutter_interfaces/features/Login.dart';
import 'package:flutter_interfaces/features/Managerinterface.dart';
import 'package:flutter_interfaces/features/Passwordchangedsuccessfully.dart';
import 'package:flutter_interfaces/features/Report.dart';
import 'package:flutter_interfaces/features/Resetpassword.dart';
import 'package:flutter_interfaces/features/Signup.dart';
import 'package:flutter_interfaces/features/Userinterface.dart';
import 'package:flutter_interfaces/features/reservation_requests.dart';
import 'package:flutter_interfaces/features/voice_recording/voice_recording_page.dart';
import 'package:flutter_interfaces/features/voice_recording/voice_recording_params.dart';
import 'package:flutter_interfaces/firebase_options.dart';
import 'package:flutter_interfaces/routes/routes_constants.dart';
import 'package:flutter_interfaces/features/finalverify.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_interfaces/features/Speechtotextt.dart';
import 'package:flutter_interfaces/features/Randomtext.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/LandPage",
      onGenerateRoute: (settings) {
        if (settings.name == RoutesConstants.voiceRecording) {
          final VoiceRecordParams params = settings.arguments as VoiceRecordParams;
          return MaterialPageRoute(
            builder: (context) => VoiceRecordPage(params: params),
          );
        }
        return null;
      },
      routes: {
        "/LandPage": (context) => const LandPage(),
        "/Signup": (context) => const Signup(),
        "/Login": (context) => const Login(),
        "/Forgotpassword": (context) => ForgotPassword(),
        "/Resetpassword": (context) => Resetpassword(),
        "/Passwordchangedsuccessfully": (context) => Passwordchangedsuccessfully(),
        "/Speechtotextt":(context) => const Speechtotextt(),
        "/Userinterface": (context) => const Userinterface(),
        "/Managerinterface": (context) => const Managerinterface(),
        // RoutesConstants.voiceRecording: (context) => VoiceRecordPage(params: VoiceRecordParams()),
        "/RegistrationRequestsPage": (context) => const RegistrationRequestsPage(),
        "/Congrats": (context) => const Congrats(),
        "/Report": (context) =>  Report(),
        "/finalverfiy": (context) => finalverfiy(),
        "/Randomtext": (context) => const Randomtext(),



      },
    );
  }
}
