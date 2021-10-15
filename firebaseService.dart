import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'fUser.dart';
import 'HomePage.dart';

final FirebaseService authService = FirebaseService();

class FirebaseService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  String verificationCode;
  Stream<User> user;
  Stream<Map<String, dynamic>> profile;
  PublishSubject loading = PublishSubject();

  FirebaseService() {
    user = Stream.castFrom(auth.authStateChanges());
    profile = user.switchMap((User u) {
      if (u != null) {
        return db
            .collection('users')
            .doc(u.uid)
            .snapshots()
            .map((snap) => snap.data());
      } else {
        return Stream.value({});
      }
    });
  }

  Future<User> googleSignIn(context) async {
    loading.add(true);
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    final authResult = await auth.signInWithCredential(credential);
    if (authResult.user != null) {
      Navigator.pushNamed(context, HomePage.id);
    }
    updateUserData(authResult.user);
    print('signed in' + authResult.user.displayName);
    loading.add(false);
    return authResult.user;
  }

  void updateUserData(User user) async {
    DocumentReference ref = db.collection('users').doc(user.uid);
    return ref.set(
      {
        'uid': user.uid,
        'email': user.email,
        'photoUrl': user.photoURL,
        'displayName': user.displayName,
        'lastSeen': DateTime.now(),
        'phone': user.phoneNumber,
      },
    );
  }

  void signOut() {
    auth.signOut();
  }

  verifyPhone(context, phone) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+90$phone',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false);
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verficationID, int resendToken) {
          verificationCode = verficationID;
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          verificationCode = verificationID;
        },
        timeout: Duration(seconds: 120));
  }

  verifyOTP(context, pin) async {
    try {
      await FirebaseAuth.instance
          .signInWithCredential(PhoneAuthProvider.credential(
              verificationId: verificationCode, smsCode: pin))
          .then((value) async {
        if (value.user != null) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false);
          updateUserData(value.user);
        }
      });
    } catch (e) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('invalid OTP')));
    }
  }
}
