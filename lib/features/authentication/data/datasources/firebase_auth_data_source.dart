import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

abstract class FirebaseAuthDataSource {
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithFacebook();
  Future<void> sendPhoneOtp(String phoneNumber);
  Future<UserModel> verifyPhoneOtp(String verificationId, String otp);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final FacebookAuth facebookAuth;
  final FirebaseFirestore firestore;

  FirebaseAuthDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.facebookAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to sign in with Google');
      }

      // Create or update user profile in Firestore
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        profilePicture: user.photoURL,
        phoneNumber: user.phoneNumber ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _saveUserToFirestore(userModel);
      return userModel;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult result = await facebookAuth.login();

      if (result.status != LoginStatus.success) {
        throw Exception('Facebook login failed: ${result.message}');
      }

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential = 
          FacebookAuthProvider.credential(result.accessToken!.token);

      // Sign in to Firebase with the Facebook credential
      final UserCredential userCredential = 
          await firebaseAuth.signInWithCredential(facebookAuthCredential);
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to sign in with Facebook');
      }

      // Create or update user profile in Firestore
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        profilePicture: user.photoURL,
        phoneNumber: user.phoneNumber ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _saveUserToFirestore(userModel);
      return userModel;
    } catch (e) {
      throw Exception('Facebook sign in failed: $e');
    }
  }

  @override
  Future<void> sendPhoneOtp(String phoneNumber) async {
    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification completed
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception('Phone verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          // Store verification ID for later use
          // You might want to store this in local storage or state management
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  @override
  Future<UserModel> verifyPhoneOtp(String verificationId, String otp) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final UserCredential userCredential = 
          await firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to verify phone number');
      }

      // Create or update user profile in Firestore
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        profilePicture: user.photoURL,
        phoneNumber: user.phoneNumber ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _saveUserToFirestore(userModel);
      return userModel;
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
        facebookAuth.logOut(),
      ]);
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final User? user = firebaseAuth.currentUser;
      if (user == null) return null;

      // Get user data from Firestore
      final doc = await firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }

      // If no Firestore document, create from Firebase Auth user
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        profilePicture: user.photoURL,
        phoneNumber: user.phoneNumber ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _saveUserToFirestore(userModel);
      return userModel;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((User? user) async {
      if (user == null) return null;
      
      try {
        final doc = await firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromJson(doc.data()!);
        }
        
        // Create user document if it doesn't exist
        final userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          profilePicture: user.photoURL,
          phoneNumber: user.phoneNumber ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _saveUserToFirestore(userModel);
        return userModel;
      } catch (e) {
        print('Error in auth state changes: $e');
        return null;
      }
    });
  }

  Future<void> _saveUserToFirestore(UserModel user) async {
    try {
      await firestore.collection('users').doc(user.id).set(
        user.toJson(),
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error saving user to Firestore: $e');
      // Don't throw here as authentication was successful
    }
  }
}