import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:telegramchatapp/Pages/HomePage.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences sharedPreferences;

  bool isLoggIn = false;
  bool isLoading = false;

  FirebaseUser firebaseUser;

  //Saving the app state
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isSingIn();
  }

  isSingIn() async {
    this.setState(() {
      isLoggIn = false;
    });

    sharedPreferences = await SharedPreferences.getInstance();

    isLoggIn = await googleSignIn.isSignedIn();
    if (isLoggIn) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                  currentUserId: sharedPreferences.getString("id"))));
    }
    this.setState(() {
      isLoggIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.blueAccent, Colors.purpleAccent])),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Telegram",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 82,
                  fontStyle: FontStyle.italic),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                controlSignIn();
              },
              child: Center(
                child: Container(
                  width: 270,
                  height: 65,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          AssetImage("assets/images/google_signin_button.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(1),
              child: isLoading ? circularProgress() : Container(),
            )
          ],
        ),
      ),
    );
  }

  Future<Null> controlSignIn() async {
    sharedPreferences = await SharedPreferences.getInstance();
    this.setState(() {
      isLoading = true;
    });

    GoogleSignInAccount googleuser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleuser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    FirebaseUser firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;

    //Sign in success
    if (firebaseUser != null) {
      //User Already signIn
      final QuerySnapshot resultquery = await Firestore.instance
          .collection('user')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();

      final List<DocumentSnapshot> documentSnapshot = resultquery.documents;

      //Set data id- user is new

      if (documentSnapshot.length == 0) {
        Firestore.instance
            .collection('user')
            .document(firebaseUser.uid)
            .setData({
          "nickname": firebaseUser.displayName,
          "id": firebaseUser.uid,
          "photoUrl": firebaseUser.photoUrl,
          "aboutme": "I'm using Jahid's Telegram Colne",
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "chattingWith": null,
        });

        //Save data into local
        await sharedPreferences.setString("nickname", firebaseUser.displayName);
        await sharedPreferences.setString("id", firebaseUser.uid);
        await sharedPreferences.setString("photoUrl", firebaseUser.photoUrl);
      } else {
        await sharedPreferences.setString(
            "nickname", documentSnapshot[0]['nickname']);
        await sharedPreferences.setString("id", documentSnapshot[0]['id']);
        await sharedPreferences.setString(
            "photoUrl", documentSnapshot[0]['photoUrl']);
        await sharedPreferences.setString(
            "aboutme", documentSnapshot[0]['aboutme']);
      }
      Fluttertoast.showToast(msg: "Congrats,SignIn Is Successful");
      this.setState(() {
        isLoading = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(currentUserId: firebaseUser.uid)));
    }
    //Sign in is not sucess
    else {
      Fluttertoast.showToast(msg: "Try Again,SignIn Is failed");
      this.setState(() {
        isLoading = false;
      });
    }
  }
}
