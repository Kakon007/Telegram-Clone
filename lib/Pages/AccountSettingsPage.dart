import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:telegramchatapp/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.lightBlue,
        title: Text(
          "Account Setting",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController nickNameEdiditingController = TextEditingController();
  TextEditingController abotMeEdiditingController = TextEditingController();
  SharedPreferences sharedPreferences;
  File imageAvater;
  bool isLoaing = false;
  final FocusNode nickNamefocusNode = FocusNode();
  final FocusNode aboutMefocusNode = FocusNode();

  String id = "";
  String nickName = "";
  String aboutme = "";
  String photeUrl = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDataFromlocal();
  }

  void readDataFromlocal() async {
    sharedPreferences = await SharedPreferences.getInstance();
    id = sharedPreferences.getString("id");
    nickName = sharedPreferences.getString("nickname");
    aboutme = sharedPreferences.getString("aboutme");
    photeUrl = sharedPreferences.getString("photoUrl");

    nickNameEdiditingController = TextEditingController(text: nickName);
    abotMeEdiditingController = TextEditingController(text: aboutme);
    setState(() {});
  }

//Get the image from phone garllery

  getImage() async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        this.imageAvater = file;
        isLoaing = true;
      });
    }
    updateImageToFirestoreandStroage();
  }

  updateImageToFirestoreandStroage() {
    String fileName = id;
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(imageAvater);
    StorageTaskSnapshot storageTaskSnapshot;
    storageUploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;

        storageTaskSnapshot.ref.getDownloadURL().then((newImageUrl) {
          photeUrl = newImageUrl;

          Firestore.instance.collection('user').document(id).updateData({
            "photoUrl": photeUrl,
            "nickname": nickName,
            "aboutme": aboutme
          }).then((data) async {
            await sharedPreferences.setString('photoUrl', photeUrl);
            setState(() {
              isLoaing = false;
            });

            Fluttertoast.showToast(msg: "Update Successfully");
          });
        }, onError: (errormsg) {
          setState(() {
            isLoaing = false;
          });
          Fluttertoast.showToast(msg: 'Error occurd in getting Download URL');
        });
      }
    }, onError: (errormsg) {
      setState(() {
        isLoaing = false;
      });
      Fluttertoast.showToast(msg: errormsg.toString());
    });
  }

  void updateData() {
    nickNamefocusNode.unfocus();
    aboutMefocusNode.unfocus();

    setState(() {
      isLoaing = false;
    });

    Firestore.instance.collection('user').document(id).updateData({
      "photoUrl": photeUrl,
      "nickname": nickName,
      "aboutme": aboutme
    }).then((data) async {
      await sharedPreferences.setString('nickname', nickName);
      await sharedPreferences.setString('aboutme', aboutme);

      setState(() {
        isLoaing = false;
      });

      Fluttertoast.showToast(msg: "Update Successfully");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: Center(
                  child: Stack(
                    children: [
                      (imageAvater == null)
                          ? (photeUrl != "")
                              ? Material(
                                  //Show the Already existinh photo-old photo
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.lightBlue),
                                      ),
                                      width: 200,
                                      height: 200,
                                      padding: EdgeInsets.all(20),
                                    ),
                                    imageUrl: photeUrl,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(125)),
                                  clipBehavior: Clip.hardEdge,
                                )
                              : Icon(
                                  Icons.account_circle,
                                  size: 90,
                                  color: Colors.grey,
                                )
                          : Material(
                              //display the new updeate img here
                              child: Image.file(
                                imageAvater,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(125)),
                              clipBehavior: Clip.hardEdge,
                            ),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          size: 100,
                          color: Colors.white54.withOpacity(0.3),
                        ),
                        onPressed: getImage,
                        padding: EdgeInsets.all(0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.grey,
                        iconSize: 200,
                      ),
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20),
              ),

              //Input Filed
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: isLoaing ? CircularProgressIndicator() : Container(),
                  ),

                  //Username
                  Container(
                    child: Text(
                      "UserName",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    margin: EdgeInsets.only(left: 10, bottom: 5, top: 10),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "e.g. Jahid Hasan",
                          contentPadding: EdgeInsets.all(5),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: nickNameEdiditingController,
                        onChanged: (value) {
                          nickName = value;
                        },
                        focusNode: nickNamefocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30, right: 30),
                  ),

                  //AboutMe

                  Container(
                    child: Text(
                      "About Me",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    margin: EdgeInsets.only(left: 10, bottom: 5, top: 30),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "e.g. I'm a App Developer....",
                          contentPadding: EdgeInsets.all(5),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: abotMeEdiditingController,
                        onChanged: (value) {
                          aboutme = value;
                        },
                        focusNode: aboutMefocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30, right: 30),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),

              //Button-upadte & Logout

              Container(
                child: FlatButton(
                  onPressed: updateData,
                  child: Text(
                    "Update",
                    style: TextStyle(fontSize: 16),
                  ),
                  color: Colors.lightBlue,
                  highlightColor: Colors.blueGrey,
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                ),
                margin: EdgeInsets.only(top: 50, bottom: 1),
                color: Colors.lightBlueAccent,
              ),

              //log-out
              Padding(
                padding: EdgeInsets.only(left: 50, right: 50),
                child: RaisedButton(
                  color: Colors.red,
                  onPressed: logoutUser,
                  child: Text(
                    "Logout",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          padding: EdgeInsets.only(left: 15, right: 15),
        )
      ],
    );
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<Null> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    this.setState(() {
      isLoaing = false;
    });
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }
}
