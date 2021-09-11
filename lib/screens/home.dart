import 'package:chatx/constants/colors.dart';
import 'package:chatx/helpers/shared_pref_manager.dart';
import 'package:chatx/screens/message.dart';
import 'package:chatx/screens/sign_up.dart';
import 'package:chatx/services/authentication.dart';
import 'package:chatx/services/database.dart';
import 'package:chatx/utils/app_sizes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stream? recommendedUsers, currentMessages;
  String? myName;
  String? myUserName;
  String? myEmail;
  String? myProfile;
  String? chatRoomID;

  @override
  void initState() {
    onInitLoad();
    super.initState();
  }

  onInitLoad() async {
    getMyInfo();
    getRecUsers();
  }

  getRecUsers() async {
    myUserName = await SharedPrefManager().getUserName();
    recommendedUsers = await DatabaseManager().getRecommendedUsers(myUserName);
    setState(() {});
  }

  Future<void> _pullRefresh() async {
    onInitLoad();
  }

  getMyInfo() async {
    myUserName = await SharedPrefManager().getUserName();
    myEmail = await SharedPrefManager().getUserEmail();
    myProfile = await SharedPrefManager().getUserProfile();
    currentMessages = await DatabaseManager().getCurrentMessages(myUserName);
    setState(() {});
  }

  String getChatRoomID(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$a\_$b";
    } else {
      return "$b\_$a";
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("ChatX"),
        actions: [
          IconButton(
            onPressed: () async {
              await Authentication().signOut().then((value) {
                Get.offAll(() => SignUpScreen());
              });
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: Padding(
          padding: EdgeInsets.all(AppSizes.font15),
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: AppSizes.font10),
                child: Text(
                  "Recommended users",
                  style: TextStyle(
                    color: BLAKISH,
                  ),
                ),
              ),
              Container(
                height: screenWidth / 3.5,
                child: StreamBuilder(
                  stream: recommendedUsers,
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? ((snapshot.data as QuerySnapshot).docs.length != 0)
                            ? ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: (snapshot.data as QuerySnapshot)
                                    .docs
                                    .length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot user =
                                      (snapshot.data as QuerySnapshot)
                                          .docs[index];
                                  return GestureDetector(
                                    onTap: () {
                                      chatRoomID = getChatRoomID(
                                          myUserName!, user['user_name']);
                                      Map<String, dynamic> chatRoomInfo = {
                                        'users': [myUserName, user['user_name']]
                                      };
                                      DatabaseManager()
                                          .createChatRoom(
                                              chatRoomID, chatRoomInfo)
                                          .then(
                                            (value) => Get.to(
                                              () => MessageScreen(
                                                chatWithUserName:
                                                    user['user_name'],
                                                chatWithUserProfile:
                                                    user['profile_url'],
                                                chatWithName: user['name'],
                                              ),
                                            ),
                                          );
                                    },
                                    child: Container(
                                      width: screenHeight / 10,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 5.0,
                                          vertical: 10.0,
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 60.0,
                                              width: 60.0,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      user['profile_url']),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Text(
                                                user['user_name'],
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                })
                            : Container(
                                padding: EdgeInsets.all(AppSizes.font10),
                                child: Center(
                                  child: Text("No Users"),
                                ),
                              )
                        : Center(
                            child: CircularProgressIndicator(),
                          );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: AppSizes.font10),
                child: Text(
                  "Recent messages",
                  style: TextStyle(
                    color: BLAKISH,
                  ),
                ),
              ),
              Container(
                child: StreamBuilder(
                  stream: currentMessages,
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? ((snapshot.data as QuerySnapshot).docs.length != 0)
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: (snapshot.data as QuerySnapshot)
                                    .docs
                                    .length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot currentMessage =
                                      (snapshot.data as QuerySnapshot)
                                          .docs[index];

                                  return RecentMessageTile(
                                    myUserName: myUserName,
                                    lastMessage: currentMessage['lastMessage'],
                                    lastMessageTime: timeago.format(
                                      currentMessage['lastMessageTime']
                                          .toDate(),
                                    ),
                                    chatRoomID: currentMessage.id,
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentMessageTile extends StatefulWidget {
  const RecentMessageTile({
    Key? key,
    required this.myUserName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.chatRoomID,
  }) : super(key: key);

  final String? myUserName;
  final String lastMessage;
  final lastMessageTime;
  final String chatRoomID;

  @override
  _RecentMessageTileState createState() => _RecentMessageTileState();
}

class _RecentMessageTileState extends State<RecentMessageTile> {
  String? chatWithUserName;
  String? chatWithName;
  String chatWithUserProfile = "";

  getUserInfo() async {
    chatWithUserName = widget.chatRoomID
        .replaceAll(widget.myUserName!, "")
        .replaceAll("_", "");
    QuerySnapshot data = await DatabaseManager().getUserInfo(chatWithUserName!);
    chatWithName = data.docs[0]['name'];
    chatWithUserProfile = data.docs[0]['profile_url'];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => MessageScreen(
            chatWithName: chatWithName!,
            chatWithUserName: chatWithUserName!,
            chatWithUserProfile: chatWithUserProfile,
          ),
        );
      },
      child: Container(
        child: Card(
          elevation: 2,
          child: ListTile(
            leading: chatWithUserProfile != ""
                ? CircleAvatar(
                    radius: 30.0,
                    backgroundImage: NetworkImage("$chatWithUserProfile"),
                    backgroundColor: Colors.transparent,
                  )
                : CircleAvatar(
                    radius: 30.0,
                    backgroundColor: BLAKISH,
                  ),
            title: Text(chatWithName ?? "Loading . . ."),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "${widget.lastMessage}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    "${widget.lastMessageTime}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
