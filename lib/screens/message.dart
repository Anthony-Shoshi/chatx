import 'dart:io';
import 'package:intl/intl.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
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
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class MessageScreen extends StatefulWidget {
  final String chatWithName, chatWithUserName, chatWithUserProfile, userId;
  const MessageScreen(
      {Key? key,
      required this.chatWithUserName,
      required this.chatWithUserProfile,
      required this.chatWithName,
      required this.userId})
      : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  TextEditingController _message = TextEditingController();
  Stream? messages, userStatus, typingStatus;
  late String myUID;
  String? myName;
  String? myUserName;
  String? myProfile;
  String? myEmail;
  String? chatRoomID;
  String messageID = "";
  bool _showEmoji = false;
  FocusNode inputNode = FocusNode();

  @override
  void initState() {
    super.initState();
    getMyInfo();
  }

  getMyInfo() async {
    myUID = await SharedPrefManager().getUserID();
    myName = await SharedPrefManager().getUserDisplayName();
    myUserName = await SharedPrefManager().getUserName();
    myEmail = await SharedPrefManager().getUserEmail();
    myProfile = await SharedPrefManager().getUserProfile();
    chatRoomID = getChatIDByName(
      myUserName!,
      widget.chatWithUserName,
    );

    getUserStatus();
    //getTypingStatus();
    getMessages();
  }

  // getTypingStatus() async {
  //   typingStatus = await DatabaseManager().getUserStatus(chatRoomID!);
  //   setState(() {});
  // }

  getChatIDByName(String a, String b) {
    if (a.codeUnitAt(0) > b.codeUnitAt(0)) {
      return "$a\_$b";
    } else {
      return "$b\_$a";
    }
  }

  getUserStatus() async {
    userStatus = await DatabaseManager().getUserStatus(widget.userId);
    setState(() {});
  }

  _onEmojiSelected(Emoji emoji) async {
    _message
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _message.text.length));
    Map<String, dynamic> typingStatus = {};
    if (_message.text.length > 0) {
      typingStatus = {
        '${myUserName}_typing': true,
      };
    } else {
      typingStatus = {
        '${myUserName}_typing': false,
      };
    }
    await DatabaseManager().updateTypingStatus(chatRoomID!, typingStatus);
  }

  _onBackspacePressed() {
    _message
      ..text = _message.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: _message.text.length),
      );
  }

  Widget typingWidget() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatRoomID)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          var typingData = snapshot.data;
          return typingData!['${widget.chatWithUserName}_typing']
              ? DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        WavyAnimatedText('Typing . . .'),
                      ],
                      isRepeatingAnimation: true,
                    ),
                  ),
                )
              : Container();
        } else
          return Container();
      },
    );
  }

  Widget appBarWidget() {
    return StreamBuilder(
      stream: userStatus,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot data = (snapshot.data as QuerySnapshot).docs[0];
          return Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    bottom: -2.0,
                    right: 0.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        height: 10.0,
                        width: 10.0,
                        color: data['status'] == 'Online'
                            ? Colors.green[300]
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 20.0,
                    backgroundImage:
                        NetworkImage("${widget.chatWithUserProfile}"),
                    backgroundColor: Colors.transparent,
                  ),
                ],
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
          );
        } else
          return Container();
      },
    );
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
        }).then((value) {
          Map<String, dynamic> typingStatus = {
            '${myUserName}_typing': false,
          };
          DatabaseManager().updateTypingStatus(chatRoomID!, typingStatus);
        });
      });
    }
  }

  void _onTextChanged(String value) async {
    Map<String, dynamic> typingStatus = {};
    if (value != "") {
      typingStatus = {
        '${myUserName}_typing': true,
      };
    } else {
      typingStatus = {
        '${myUserName}_typing': false,
      };
    }
    await DatabaseManager().updateTypingStatus(chatRoomID!, typingStatus);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_showEmoji) {
          setState(() {
            _showEmoji = false;
          });
        } else {
          Navigator.pop(context);
        }
        Map<String, dynamic> typingStatus = {
          "isTyping": false,
        };
        await DatabaseManager().updateTypingStatus(myUID, typingStatus);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: appBarWidget(),
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

                                    //parsing date time from firebase
                                    final dateTime = DateTime.parse(
                                        data['message_time']
                                            .toDate()
                                            .toString());

                                    //init variable
                                    DateFormat format;

                                    //Compare date time
                                    DateTime date = DateTime.now();

                                    bool isToday = false;

                                    if (date.day == dateTime.day &&
                                        date.month == dateTime.month &&
                                        date.year == dateTime.year) {
                                      format = DateFormat('hh:mm a');
                                      isToday = true;
                                    } else {
                                      format =
                                          DateFormat('d MMM, y AT hh:mm a');
                                      isToday = false;
                                    }

                                    final clockString = format.format(dateTime);
                                    return Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 10.0),
                                      child: Container(
                                        padding:
                                            EdgeInsets.all(AppSizes.font18),
                                        decoration: BoxDecoration(
                                          color: data['sendBy'] == myUserName
                                              ? Colors.yellow[200]
                                              : Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft:
                                                data['sendBy'] == myUserName
                                                    ? Radius.circular(24)
                                                    : Radius.circular(24),
                                            topRight:
                                                data['sendBy'] == myUserName
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
                                            isToday
                                                ? Text(
                                                    "Today AT $clockString",
                                                    style: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black),
                                                    textAlign: data['sendBy'] ==
                                                            myUserName
                                                        ? TextAlign.right
                                                        : TextAlign.left,
                                                  )
                                                : Text(
                                                    "$clockString",
                                                    style: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black),
                                                    textAlign: data['sendBy'] ==
                                                            myUserName
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
            typingWidget(),
            Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              color: Colors.grey[300],
              child: Row(
                children: [
                  !_showEmoji
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              _showEmoji = !_showEmoji;
                            });
                            FocusScope.of(context).unfocus();
                          },
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                          ),
                        )
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              _showEmoji = false;
                            });
                            FocusScope.of(context).requestFocus(inputNode);
                          },
                          icon: Icon(
                            Icons.keyboard_alt_outlined,
                          ),
                        ),
                  Expanded(
                    child: TextField(
                      onChanged: _onTextChanged,
                      focusNode: inputNode,
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
                    icon: Icon(
                      Icons.send,
                    ),
                  ),
                ],
              ),
            ),
            Offstage(
              offstage: !_showEmoji,
              child: SizedBox(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (Category category, Emoji emoji) {
                    _onEmojiSelected(emoji);
                  },
                  onBackspacePressed: _onBackspacePressed,
                  config: Config(
                      columns: 7,
                      // Issue: https://github.com/flutter/flutter/issues/28894
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      verticalSpacing: 0,
                      horizontalSpacing: 0,
                      initCategory: Category.RECENT,
                      bgColor: const Color(0xFFF2F2F2),
                      indicatorColor: Colors.blue,
                      iconColor: Colors.grey,
                      iconColorSelected: Colors.blue,
                      progressIndicatorColor: Colors.blue,
                      backspaceColor: Colors.blue,
                      showRecentsTab: true,
                      recentsLimit: 28,
                      noRecentsText: 'No Recents',
                      noRecentsStyle:
                          const TextStyle(fontSize: 20, color: Colors.black26),
                      tabIndicatorAnimDuration: kTabScrollDuration,
                      categoryIcons: const CategoryIcons(),
                      buttonMode: ButtonMode.MATERIAL),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
