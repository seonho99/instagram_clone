

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:instagram_clone/providers/feed/feed_provider.dart';
import 'package:instagram_clone/providers/feed/feed_state.dart';
import 'package:instagram_clone/repositories/auth_repository.dart';
import 'package:instagram_clone/repositories/feed_repository.dart';
import 'package:instagram_clone/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // FirebaseAuth.instance.signOut();
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (context) => AuthRepository(
            firebaseAuth: FirebaseAuth.instance,
            firebaseStorage: FirebaseStorage.instance,
            firebaseFirestore: FirebaseFirestore.instance,
          ),
        ),
        Provider<FeedResoitroy>(
            create: (context) => FeedResoitroy(
              firebaseStorage: FirebaseStorage.instance,
              firebaseFirestore: FirebaseFirestore.instance
            ),
        ),
        StreamProvider<User?>(
            create: (context) => FirebaseAuth.instance.authStateChanges(),
            initialData: null,
        ),
        StateNotifierProvider<AuthProvider, AuthState>(
          create: (context) => AuthProvider(),
        ),
        StateNotifierProvider<FeedProvider, FeedState>(
            create: (context) => FeedProvider(),),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: SplashScreen(),
      ),
    );
  }
}

