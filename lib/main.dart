import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    // Using FlutterFire CLI generated options for project flow
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Sign in anonymously to allow Firestore access
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
      print('Signed in anonymously to Firebase');
    }
    
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Continue with app launch even if Firebase fails to initialize
    // The app will handle Firebase unavailability gracefully
  }
  
  // Run the app wrapped in ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: ProjectFlowApp(),
    ),
  );
}