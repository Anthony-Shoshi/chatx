import 'package:chatx/constants/colors.dart';
import 'package:chatx/helpers/shared_pref_manager.dart';
import 'package:chatx/screens/sign_up.dart';
import 'package:chatx/services/authentication.dart';
import 'package:chatx/services/database.dart';
import 'package:chatx/utils/app_sizes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:random_string/random_string.dart';

class MessageScreen extends StatefulWidget {
  final String chatWithName, chatWithUserName, chatWithUserProfile;
  const MessageScreen(
      {Key? key,
      required this.chatWithUserName,
      required this.chatWithUserProfile,
      required this.chatWithName})
      : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  TextEditingController _message = TextEditingController();
  Stream? messages;
  String? myName;
  String? myUserName;
  String? myProfile;
  String? myEmail;
  String? chatRoomID;
  String messageID = "";

  @override
  void initState() {
    super.initState();
    getMyInfo();
  }

  getMyInfo() async {
    myName = await SharedPrefManager().getUserDisplayName();
    myUserName = await SharedPrefManager().getUserName();
    myEmail = await SharedPrefManager().getUserEmail();
    myProfile = await SharedPrefManager().getUserProfile();
    chatRoomID = getChatIDByName(
      myUserName!,
      widget.chatWithUserName,
    );

    getMessages();
  }

  getChatIDByName(String a, String b) {
    if (a.codeUnitAt(0) > b.codeUnitAt(0)) {
      return "$a\_$b";
    } else {
      return "$b\_$a";
    }
  }

  getMessages() async {
    messages = await DatabaseManager().getMessages(chatRoomID);
    setState(() {});
  }

  void sendMessage() {
    if (_message.text != "") {
      String message = _message.text;
      String lastMessage = message;
      var lastMessageTime = DateTime.now();

      Map<String, dynamic> messageInfo = {
        'sendBy': myUserName,
        'profile_url': myProfile,
        'message': message,
        'message_time': lastMessageTime,
      };

      if (messageID == "") {
        messageID = randomAlphaNumeric(12);
      }

      DatabaseManager()
          .addMessage(chatRoomID, messageID, messageInfo)
          .then((value) {
        Map<String, dynamic> lastMessageInfo = {
          'lastMessage': lastMessage,
          'lastMessageSendBy': myUserName,
          'lastMessageTime': lastMessageTime,
        };
        DatabaseManager()
            .updateLastMessage(chatRoomID, lastMessageInfo)
            .then((value) {
          messageID = "";
          _message.text = "";
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage("${widget.chatWithUserProfile}"),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(
              width: 5.0,
            ),
            Flexible(
              child: Text(
                "${widget.chatWithName}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.snackbar('Sorry', 'Please try to call later');
            },
            icon: Icon(Icons.call),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    PRIMARY_COLOR.withOpacity(0.5),
                    SECONDARY_COLOR.withOpacity(1),
                  ],
                ),
              ),
              child: StreamBuilder(
                  stream: messages,
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? ((snapshot.data as QuerySnapshot).docs.length != 0)
                            ? ListView.builder(
                                shrinkWrap: true,
                                reverse: true,
                                itemCount: (snapshot.data as QuerySnapshot)
                                    .docs
                                    .length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot data =
                                      (snapshot.data as QuerySnapshot)
                                          .docs[index];
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 10.0),
                                    child: Container(
                                      padding: EdgeInsets.all(AppSizes.font18),
                                      decoration: BoxDecoration(
                                        color: data['sendBy'] == myUserName
                                            ? Colors.yellow[200]
                                            : Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: data['sendBy'] == myUserName
                                              ? Radius.circular(24)
                                              : Radius.circular(24),
                                          topRight: data['sendBy'] == myUserName
                                              ? Radius.circular(24)
                                              : Radius.circular(24),
                                          bottomLeft:
                                              data['sendBy'] == myUserName
                                                  ? Radius.circular(24.0)
                                                  : Radius.circular(0),
                                          bottomRight:
                                              data['sendBy'] == myUserName
                                                  ? Radius.circular(0)
                                                  : Radius.circular(24),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            "${data['message']}",
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                            textAlign:
                                                data['sendBy'] == myUserName
                                                    ? TextAlign.right
                                                    : TextAlign.left,
                                          ),
                                          SizedBox(height: 5.0),
                                          Text(
                                            "${DateTime.parse(data['message_time'].toDate().toString())}",
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.black),
                                            textAlign:
                                                data['sendBy'] == myUserName
                                                    ? TextAlign.right
                                                    : TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                })
                            : Container(
                                padding: EdgeInsets.all(AppSizes.font10),
                                child: Center(
                                  child: Text("No Messages"),
                                ),
                              )
                        : Center(
                            child: CircularProgressIndicator(),
                          );
                  }),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            color: Colors.grey,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _message,
                    decoration: InputDecoration(
                      hintText: 'Type a message . . .',
                      hintStyle: TextStyle(
                        color: Colors.black,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    sendMessage();
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
