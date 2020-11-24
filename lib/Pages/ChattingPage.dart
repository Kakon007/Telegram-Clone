import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:telegramchatapp/Widgets/FullImageWidget.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String reciverid;
  final String reciverAvater;
  final String reciverName;
  Chat(
      {Key key,
      @required this.reciverid,
      @required this.reciverAvater,
      @required this.reciverName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              backgroundImage: CachedNetworkImageProvider(reciverAvater),
            ),
          )
        ],
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          reciverName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ChatScreen(
        reciverid: reciverid,
        reciverAvater: reciverAvater,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String reciverid;
  final String reciverAvater;
  ChatScreen({
    Key key,
    @required this.reciverid,
    @required this.reciverAvater,
  });

  @override
  State createState() =>
      ChatScreenState(reciverid: reciverid, reciverAvater: reciverAvater);
}

class ChatScreenState extends State<ChatScreen> {
  TextEditingController textEditingController = TextEditingController();
  final ScrollController listscrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  final String reciverid;
  final String reciverAvater;
  bool isDisplaySatickers;
  bool isloading;
  File imageFile;
  String imageUrl;
  String chatId;
  SharedPreferences preferences;
  String id;
  var listMessage;

  ChatScreenState({
    Key key,
    @required this.reciverid,
    @required this.reciverAvater,
  });

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNode.addListener(onFocusChange);
    isDisplaySatickers = false;
    isloading = false;
    chatId = "";
    readLocal();
  }

  readLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id");
    if (id.hashCode <= reciverid.hashCode) {
      chatId = "$id-$reciverid";
    } else {
      chatId = "$reciverid-$id";
    }
    Firestore.instance
        .collection("user")
        .document(id)
        .updateData({"chattingWith": reciverid});
    setState(() {});
  }

  onFocusChange() {
    //hide stickers when keyboard appears
    if (focusNode.hasFocus) {
      setState(() {
        isDisplaySatickers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //willpopScope is a widget that handale back button pressed

    return WillPopScope(
      onWillPop: onBackPress,
      child: Stack(
        children: [
          Column(
            children: [
              //create List of msg
              createListofMessage(),
              //show stickers
              (isDisplaySatickers ? createStickers() : Container()),
              //Input Container
              createInput(),
            ],
          ),
          createLoading(),
        ],
      ),
    );
  }

  Future<bool> onBackPress() {
    if (isDisplaySatickers) {
      setState(() {
        isDisplaySatickers = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  createLoading() {
    return Positioned(child: isloading ? circularProgress() : Container());
  }

  createStickers() {
    return Container(
      child: Column(
        children: [
          //1st row
          Row(
            children: [
              FlatButton(
                onPressed: () => onSendMessage("mimi1", 2),
                child: Image.asset(
                  "images/mimi1.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage("mimi2", 2),
                child: Image.asset(
                  "images/mimi2.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage("mimi3", 2),
                child: Image.asset(
                  "images/mimi3.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          //2nd row
          Row(
            children: [
              FlatButton(
                onPressed: () => onSendMessage("mimi4", 2),
                child: Image.asset(
                  "images/mimi4.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage("mimi5", 2),
                child: Image.asset(
                  "images/mimi5.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage("mimi6", 2),
                child: Image.asset(
                  "images/mimi6.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),

          //3rd row

          Row(
            children: [
              FlatButton(
                onPressed: () => onSendMessage("mimi7", 2),
                child: Image.asset(
                  "images/mimi7.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage("mimi8", 2),
                child: Image.asset(
                  "images/mimi8.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage("mimi9", 2),
                child: Image.asset(
                  "images/mimi9.gif",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(5),
      height: 180,
    );
  }

  void getSticker() {
    focusNode.unfocus();
    setState(() {
      isDisplaySatickers = !isDisplaySatickers;
    });
  }

  void onSendMessage(String contentMsg, int type) {
    //type=0 it's text msg
    //type=1 it's image file
    //type=2 it's sticker emoji file

    if (contentMsg != "") {
      textEditingController.clear();
      var docRef = Firestore.instance
          .collection("message")
          .document(chatId)
          .collection(chatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(docRef, {
          "idFrom": id,
          "idTo": reciverid,
          "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "content": contentMsg,
          "type": type
        });
      });
      listscrollController.animateTo(0.0,
          duration: Duration(microseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: "Error: Message Box is empty");
    }
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      isloading = true;
    }
    uploadImageFile();
  }

  Future uploadImageFile() async {
    //Unique Name For Storing Our image file
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    //Create A reference
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child("Chat Image").child(fileName);

    StorageUploadTask storageUploadTask = storageReference.putFile(imageFile);
    //uplad the image in firestore
    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;
    //get the img URL from Firestore
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isloading = false;
        //Store the img URL in FireStore
        onSendMessage(imageUrl, 1);
      });
    }, onError: (error) {
      setState(() {
        isloading = false;
      });
      Fluttertoast.showToast(msg: "Error: " + error);
    });
  }

  createListofMessage() {
    return Flexible(
      child: (chatId == null)
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.lightBlueAccent),
              ),
            )
          : StreamBuilder(
              stream: Firestore.instance
                  .collection("message")
                  .document(chatId)
                  .collection(chatId)
                  .orderBy("timestamp", descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation(Colors.lightBlueAccent),
                    ),
                  );
                } else {
                  listMessage = snapshot.data.documents;
                  return ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemBuilder: (context, index) =>
                        creatItem(index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listscrollController,
                  );
                }
              },
            ),
    );
  }

  bool islastmsgLeft(int index) {
    if (index > 0 &&
        listMessage != null &&
        listMessage[index - 1]["idFrom"] == id) {
      return true;
    } else {
      return false;
    }
  }

  bool islastmsgRight(int index) {
    if (index > 0 &&
        listMessage != null &&
        listMessage[index - 1]["idFrom"] != id) {
      return true;
    } else {
      return false;
    }
  }

  Widget creatItem(int index, DocumentSnapshot document) {
    //Sender id-right side
    if (document["idFrom"] == id) {
      return Row(
        children: [
          //text
          document["type"] == 0
              ? Container(
                  child: Text(
                    document["content"],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                  width: 200,
                  decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(8)),
                  margin: EdgeInsets.only(
                      bottom: islastmsgRight(index) ? 20.0 : 10.0, right: 10),
                )
              :
              //image
              document["type"] == 1
                  ? Container(
                      child: FlatButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FullPhoto(url: document["content"])));
                        },
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.lightBlueAccent),
                              ),
                              width: 200,
                              height: 200,
                              padding: EdgeInsets.all(70),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                "images/img_not_available.jpeg",
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: document["content"],
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          clipBehavior: Clip.hardEdge,
                        ),
                      ),
                      margin: EdgeInsets.only(
                          bottom: islastmsgRight(index) ? 20.0 : 10.0,
                          right: 10),
                    )
                  :
                  //Sticker
                  Container(
                      child: Image.asset(
                        "image/${document["content"]}.gif",
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: islastmsgRight(index) ? 20.0 : 10.0,
                          right: 10),
                    )
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } //reciver id-left side
    else {
      return Container(
        child: Column(
          children: [
            Row(
              children: [
                islastmsgLeft(index)
                    ? Material(
                        //display reciver profile img
                        child: CachedNetworkImage(
                          imageUrl: reciverAvater,
                          width: 35,
                          height: 35,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.lightBlueAccent),
                            ),
                            width: 35,
                            height: 35,
                            padding: EdgeInsets.all(10),
                          ),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(
                        width: 35,
                      ),
                //display msg
                document["type"] == 0
                    ? Container(
                        child: Text(
                          document["content"],
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                        width: 200,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8)),
                        margin: EdgeInsets.only(left: 10),
                      )
                    :

                    //image
                    document["type"] == 1
                        ? Container(
                            child: FlatButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FullPhoto(
                                            url: document["content"])));
                              },
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.lightBlueAccent),
                                    ),
                                    width: 200,
                                    height: 200,
                                    padding: EdgeInsets.all(70),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Image.asset(
                                      "images/img_not_available.jpeg",
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: document["content"],
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                clipBehavior: Clip.hardEdge,
                              ),
                            ),
                            margin: EdgeInsets.only(left: 10),
                          )
                        :
                        //Sticker
                        Container(
                            child: Image.asset(
                              "image/${document["content"]}.gif",
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: islastmsgRight(index) ? 20.0 : 10.0,
                                right: 10),
                          )
              ],
            ),

            //Msg time
            islastmsgLeft(index)
                ? Container(
                    child: Text(
                      DateFormat("dd MMMM, yyyy - hh:mm:ss").format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document["timestamp"]))),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50, right: 50, bottom: 5),
                  )
                : Container(),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10),
      );
    }
  }

  createInput() {
    return Container(
      child: Row(
        children: [
          Material(
              //pic image icon button

              child: IconButton(
            icon: Icon(Icons.image),
            onPressed: getImage,
            color: Colors.lightBlueAccent,
          )),
          Material(
              //emoji icon button

              child: IconButton(
            icon: Icon(Icons.face),
            onPressed: getSticker,
            color: Colors.lightBlueAccent,
          )),
          Flexible(
            child: Container(
              child: TextField(
                controller: textEditingController,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                    hintText: "Write Here.....",
                    hintStyle: TextStyle(color: Colors.grey)),
                focusNode: focusNode,
              ),
            ),
          ),

          //Send message icon Button

          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: Colors.lightBlueAccent,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
          color: Colors.grey,
          width: 5,
        )),
        color: Colors.white,
      ),
    );
  }
}
