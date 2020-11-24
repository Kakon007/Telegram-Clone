import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telegramchatapp/Pages/ChattingPage.dart';
import 'package:telegramchatapp/main.dart';
import 'package:telegramchatapp/models/user.dart';
import 'package:telegramchatapp/Pages/AccountSettingsPage.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;
  HomeScreen({this.currentUserId});
  @override
  State createState() => HomeScreenState(currentUserId: currentUserId);
}

class HomeScreenState extends State<HomeScreen> {
  HomeScreenState({Key key, @required this.currentUserId});
  TextEditingController searchTexteditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResult;
  final String currentUserId;

  homePageHeader() {
    return AppBar(
      automaticallyImplyLeading: false, //removing the autoBack Button
      actions: [
        IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Settings()));
            })
      ],
      backgroundColor: Colors.lightBlue,
      title: Container(
        margin: EdgeInsets.only(bottom: 4),
        child: TextFormField(
          controller: searchTexteditingController,
          style: TextStyle(fontSize: 18, color: Colors.white),
          decoration: InputDecoration(
              hintText: "Search Here....",
              hintStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              filled: true,
              prefixIcon: Icon(
                Icons.person_pin,
                color: Colors.white,
                size: 30,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  emptySearchbar();
                },
              )),
          onFieldSubmitted: controlSearching,
        ),
      ),
    );
  }

  controlSearching(String userName) {
    //Using this query we can find All User of that name

    Future<QuerySnapshot> allFoundUsers = Firestore.instance
        .collection("user")
        .where("nickname", isGreaterThanOrEqualTo: userName)
        .getDocuments();

    setState(() {
      futureSearchResult = allFoundUsers;
    });
  }

  emptySearchbar() {
    searchTexteditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homePageHeader(),
      body: futureSearchResult == null
          ? displayNouserResult()
          : displayUserFound(),
    );
  }

  displayUserFound() {
    return FutureBuilder(
      future: futureSearchResult,
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchUserResult = [];
        dataSnapshot.data.documents.forEach((document) {
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser);

          if (currentUserId != document["id"]) {
            searchUserResult.add(userResult);
          }
        });
        return ListView(
          children: searchUserResult,
        );
      },
    );
  }

  displayNouserResult() {
    return Container(
      child: Center(
        child: ListView(
          children: [
            Icon(
              Icons.group,
              color: Colors.lightBlueAccent,
              size: 200,
            ),
            Text(
              "Search Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 50,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}

class UserResult extends StatelessWidget {
  final User eachUser;
  UserResult(this.eachUser);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            GestureDetector(
              onTap: sendUserToChatPage(context),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage:
                      CachedNetworkImageProvider(eachUser.photoUrl),
                ),
                title: Text(
                  eachUser.nickname,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "Joined: " +
                      DateFormat("dd MMMM, yyyy- hh:mm:ss").format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(eachUser.createdAt))),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontStyle: FontStyle.italic),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  sendUserToChatPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
                reciverid: eachUser.id,
                reciverAvater: eachUser.photoUrl,
                reciverName: eachUser.nickname)));
  }
}
