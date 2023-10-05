import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../helpers/gravatar.dart';
import '../models/user_model.dart';
import '../ui/auth/sign_in_ui.dart';
import '../ui/components/loading.dart';
import '../ui/home_ui.dart';

//our user and authentication functions for creating, logging in and out our
// user and saving our user data.
class AuthController extends GetxController {
  static AuthController to = Get.find();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Rxn<User> firebaseUser = Rxn<User>();
  Rxn<UserModel> firestoreUser = Rxn<UserModel>();
  final RxBool admin = false.obs;
  late UserModel _user;

  @override
  void onReady() async {
//It sets up an authentication state change listener, which triggers
// the handleAuthChanged method whenever the firebaseUser value changes.
    ever(firebaseUser, handleAuthChanged);

// allows you to receive real-time updates of the authentication state changes
    firebaseUser.bindStream(user);
// By binding the stream to the user property, you can access the user's authentication
// state and perform actions such as displaying different screens based on whether the user
// is logged in or not, updating the UI based on the user's profile information, or triggering
// specific logic based on the user's authentication status.
    super.onReady();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  handleAuthChanged(_firebaseUser) async {
    //get user data from firestore
    if (_firebaseUser?.uid != null) {
      firestoreUser.bindStream(streamFirestoreUser());
      await isAdmin();
    }

    if (_firebaseUser == null) {
      print('Send to signin');
      Get.offAll(()=>SignInUI());//resets the navigation stack to have only the destination screen
    } else {
      Get.offAll(()=>HomeUI());//HomeUI OnboardingUI()
    }
  }

  // Firebase user one-time fetch
  Future<User> get getUser async => _auth.currentUser!;

  // emit null when the user is not authenticated and emit the authenticated user object when the user is logged in.
  Stream<User?> get user => _auth.authStateChanges();

  //Streams the firestore user from the firestore collection
  Stream<UserModel> streamFirestoreUser() {
    print('streamFirestoreUser()');

    if (firebaseUser.value != null) {
      return _db
          .doc('/users/${firebaseUser.value!.uid}')
          .snapshots()
          .map((snapshot) {
        if (snapshot.data() != null) {
          return UserModel.fromMap(snapshot.data()!);
        } else {
          print('Document does not exist or has no data');
          return UserModel(uid:'',email:'', name:'Anonymous User', photoUrl: ''); // Return a default UserModel or null, depending on your requirements
        }
      });
    } else {
      print('firebaseUser.value is null');
      return Stream<UserModel>.empty(); // Return an empty stream as a fallback
    }
  }

  //get the firestore user from the firestore collection
  Future<UserModel> getFirestoreUser() {
    return _db.doc('/users/${firebaseUser.value!.uid}').get().then(
        (documentSnapshot) => UserModel.fromMap(documentSnapshot.data()!));
  }

  //Method to handle user sign in using email and password
  signInWithEmailAndPassword(BuildContext context) async {
    showLoadingIndicator();
    try {
      await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      emailController.clear();
      passwordController.clear();
      hideLoadingIndicator();
    } catch (error) {
      hideLoadingIndicator();
      Get.snackbar('auth.signInErrorTitle'.tr, 'auth.signInError'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 7),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    }
  }

  registerWithEmailAndPassword(BuildContext context) async {
    showLoadingIndicator();
    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      ).then((result) async {
        // Get photo url from gravatar if user has one
        Gravatar gravatar = Gravatar(emailController.text);
        String gravatarUrl = gravatar.imageUrl(
          size: 200,
          defaultImage: GravatarImage.retro,
          rating: GravatarRating.pg,
          fileExtension: true,
        );

        // Create the new user object
        _user = UserModel(
          uid: result.user!.uid,
          email: result.user!.email!,
          name: nameController.text,
          photoUrl: gravatarUrl, // Use the setter to update the photoUrl field
        );

        // Create the user in Firestore
        _createUserFirestore(_user, result.user!);
        emailController.clear();
        passwordController.clear();
        hideLoadingIndicator();
      });
    } on FirebaseAuthException catch (error) {
      hideLoadingIndicator();
      Get.snackbar(
        'auth.signUpErrorTitle'.tr,
        error.message!,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 10),
        backgroundColor: Get.theme.snackBarTheme.backgroundColor,
        colorText: Get.theme.snackBarTheme.actionTextColor,
      );
    }
  }

  //handles updating the user when updating profile
  Future<void> updateUser(BuildContext context, UserModel user, String oldEmail,
      String password) async {
    String _authUpdateUserNoticeTitle = 'auth.updateUserSuccessNoticeTitle'.tr;
    String _authUpdateUserNotice = 'auth.updateUserSuccessNotice'.tr;
    try {
      showLoadingIndicator();
      try {
        await _auth
            .signInWithEmailAndPassword(email: oldEmail, password: password)
            .then((_firebaseUser) async {
          await _firebaseUser.user!
              .updateEmail(user.email)
              .then((value) => updateUserFirestore(user, _firebaseUser.user!));
        });
      } catch (err) {
        print('Caught error: $err');
        //not yet working, see this issue https://github.com/delay/shopping_lister/issues/21
        if (err.toString() ==
            "[firebase_auth/email-already-in-use] The email address is already in use by another account.") {
          _authUpdateUserNoticeTitle = 'auth.updateUserEmailInUse'.tr;
          _authUpdateUserNotice = 'auth.updateUserEmailInUse'.tr;
        } else {
          _authUpdateUserNoticeTitle = 'auth.wrongPasswordNotice'.tr;
          _authUpdateUserNotice = 'auth.wrongPasswordNotice'.tr;
        }
      }
      hideLoadingIndicator();
      Get.snackbar(_authUpdateUserNoticeTitle, _authUpdateUserNotice,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    } on PlatformException catch (error) {
      //List<String> errors = error.toString().split(',');
      // print("Error: " + errors[1]);
      hideLoadingIndicator();
      print(error.code);
      String authError;
      switch (error.code) {
        case 'ERROR_WRONG_PASSWORD':
          authError = 'auth.wrongPasswordNotice'.tr;
          break;
        default:
          authError = 'auth.unknownError'.tr;
          break;
      }
      Get.snackbar('auth.wrongPasswordNoticeTitle'.tr, authError,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 10),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    }
  }

  //updates the firestore user in users collection
  void updateUserFirestore(UserModel user, User _firebaseUser) {
    _db.doc('/users/${_firebaseUser.uid}').update(user.toJson());
    update();
  }

  //create the firestore user in users collection
  void _createUserFirestore(UserModel user, User _firebaseUser) {
    _db.doc('/users/${_firebaseUser.uid}').set(user.toJson());
    update();
  }

  //password reset email
  Future<void> sendPasswordResetEmail(BuildContext context) async {
    showLoadingIndicator();
    try {
      await _auth.sendPasswordResetEmail(email: emailController.text);
      hideLoadingIndicator();
      Get.snackbar(
          'auth.resetPasswordNoticeTitle'.tr, 'auth.resetPasswordNotice'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    } on FirebaseAuthException catch (error) {
      hideLoadingIndicator();
      Get.snackbar('auth.resetPasswordFailed'.tr, error.message!,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 10),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    }
  }

  //check if user is an admin user
  isAdmin() async {
    await getUser.then((user) async {
      DocumentSnapshot adminRef =
          await _db.collection('admin').doc(user.uid).get();
      if (adminRef.exists) {
        admin.value = true;
      } else {
        admin.value = false;
      }
      update();
    });
  }

  // Sign out
  Future<void> signOut() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    return _auth.signOut();
  }
}

/*
The AuthController class extends GetxController from the GetX package, which is
a state management library for Flutter.
The AuthController class contains various methods and properties for user authentication and user management.
It initializes Firebase authentication (FirebaseAuth) and Firestore (FirebaseFirestore) instances.
The class uses Get for dependency injection to access the instance of AuthController from anywhere in the app.
The onReady method is called when the controller is initialized and sets up the
authentication state change listener using ever and binds the firebaseUser stream to user.
The handleAuthChanged method is responsible for handling authentication state
changes and navigating the user to the appropriate UI screens based on their authentication status.
The class provides methods for signing in with email and password
(signInWithEmailAndPassword), registering a new user with email and password
(registerWithEmailAndPassword), updating the user profile (updateUser), sending
a password reset email (sendPasswordResetEmail), and signing out (signOut).
The getUser method retrieves the currently authenticated user using Firebase authentication.
The user stream provides real-time updates of the authentication state changes.
The streamFirestoreUser method retrieves the user data from Firestore by
streaming the document corresponding to the authenticated user's UID.
The getFirestoreUser method retrieves the user data from Firestore as a one-time fetch.
The class also includes methods for updating the Firestore user document
(updateUserFirestore) and creating a new user document (_createUserFirestore).
The isAdmin method checks if the current user has admin privileges by querying the admin collection in Firestore.
The signOut method handles the sign-out process.
Overall, this code provides a foundation for managing user authentication and
user data in a Flutter app using Firebase services.
 */
