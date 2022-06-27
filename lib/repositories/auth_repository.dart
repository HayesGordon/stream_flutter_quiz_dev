import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DemoUserData {
  final String email;
  final String name;
  final String photoUrl;

  const DemoUserData({
    required this.email,
    required this.name,
    required this.photoUrl,
  });
}

enum StreamDemoUsers {
  sacha(
    DemoUserData(
        email: 'sacha@getstream.io',
        name: 'Sacha',
        photoUrl: 'https://avatars.githubusercontent.com/u/18029834?v=4'),
  ),
  gordon(
    DemoUserData(
        email: 'gordon.hayes@getstream.io',
        name: 'Gordon',
        photoUrl: 'https://avatars.githubusercontent.com/u/13705472?v=4'),
  ),
  deven(
    DemoUserData(
        email: 'deven@getstream.io',
        name: 'Deven',
        photoUrl: 'https://avatars.githubusercontent.com/u/26357843?v=4'),
  ),
  sahil(
    DemoUserData(
        email: 'sahil@getstream.io',
        name: 'Sahil',
        photoUrl: 'https://avatars.githubusercontent.com/u/25670178?v=4'),
  ),
  reuben(
    DemoUserData(
        email: 'reuben.turner@getstream.io',
        name: 'Reuben',
        photoUrl: 'https://avatars.githubusercontent.com/u/4250470?v=4'),
  ),
  salvatore(
    DemoUserData(
        email: 'salvatore@getstream.io',
        name: 'Salvatore',
        photoUrl: 'https://avatars.githubusercontent.com/u/20601437?v=4'),
  );

  final DemoUserData demoUserData;
  const StreamDemoUsers(this.demoUserData);
}

class AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  final functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  Stream<User?> authState() {
    return FirebaseAuth.instance.authStateChanges();
  }

  /// Gets a Stream user token for current authenticated user
  ///
  /// Need to be authenticated to Firebase to call this function.
  Future<String?> getToken() async {
    try {
      final result = await functions
          .httpsCallable('ext-auth-chat-getStreamUserToken')
          .call();

      return result.data;
    } on FirebaseFunctionsException catch (error) {
      debugPrint(error.code);
      debugPrint(error.details);
      debugPrint(error.message);
    }
    return null;
  }

  Future<UserCredential> dummySignIn() async {
    if (kDebugMode) {
      return FirebaseAuth.instance.signInWithEmailAndPassword(
          email: 'test5@email.com', password: 'password');
    } else {
      throw Exception('Can only be used in debug mode');
    }
  }

  Future<UserCredential> dummySignIn2() async {
    if (kDebugMode) {
      return FirebaseAuth.instance.signInWithEmailAndPassword(
          email: 'test6@email.com', password: 'password');
    } else {
      throw Exception('Can only be used in debug mode');
    }
  }

  Future<UserCredential> dummyRegister() {
    if (kDebugMode) {
      return FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'test6@email.com',
        password: 'password',
      );
    } else {
      throw Exception('Can only be used in debug mode');
    }
  }

  Future<UserCredential> dummySignInStream(StreamDemoUsers user) async {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user.demoUserData.email, password: 'password');
  }

  Future<UserCredential> dummyRegisterStream(StreamDemoUsers user) async {
    final userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: user.demoUserData.email,
      password: 'password',
    );
    await userCredential.user?.updateDisplayName(user.demoUserData.name);
    await userCredential.user?.updatePhotoURL(user.demoUserData.photoUrl);
    return userCredential;
  }

  Future<UserCredential> signInAnonymously() async {
    return FirebaseAuth.instance.signInAnonymously();
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }

  Future<void> signOut() {
    print('signing out');
    return FirebaseAuth.instance.signOut();
  }
}
