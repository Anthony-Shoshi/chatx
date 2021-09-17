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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Stream? recommendedUsers, currentMessages;
  String? myID;
  String? myName;
  String? myUserName;
  String? myEmail;
  String? myProfile;
  String? chatRoomID;
  String? chatWithName;
  String? chatWithUserName;
  String? chatWithUserProfile;
  String? chatWithUserID;

  @override
  void initState() {
    onInitLoad();
    WidgetsBinding.instance!.addObserver(this);
    String mid = Authentication().getCurrentUser().uid;
    Map<String, dynamic> statusInfo = {
      'status': 'Online',
    };
    DatabaseManager().updateOnlineStatus(mid, statusInfo);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    String mid = Authentication().getCurrentUser().uid;
    Map<String, dynamic> statusInfo = {};
    if (state == AppLifecycleState.resumed) {
      statusInfo = {
        'status': 'Online',
      };
    } else {
      statusInfo = {
        'status': 'Offline',
      };
    }

    DatabaseManager().updateOnlineStatus(mid, statusInfo);
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
    myID = await SharedPrefManager().getUserID();
    myName = await SharedPrefManager().getUserDisplayName();
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
                height: screenSize / 7.5,
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
                                    onTap: () async {
                                      chatRoomID = getChatRoomID(
                                          myUserName!, user['user_name']);
                                      QuerySnapshot data =
                                          await DatabaseManager()
                                              .getUserInfo(user['user_name']);
                                      chatWithName = data.docs[0]['name'];
                                      chatWithUserName =
                                          data.docs[0]['user_name'];
                                      chatWithUserProfile =
                                          data.docs[0]['profile_url'];
                                      chatWithUserID = data.docs[0]['user_id'];

                                      Map<String, dynamic> chatRoomInfo = {
                                        'users': [
                                          myUserName,
                                          user['user_name'],
                                        ],
                                        'from_user': [
                                          myName,
                                          myProfile,
                                          myUserName,
                                          myID,
                                        ],
                                        'to_user': [
                                          chatWithName,
                                          chatWithUserProfile,
                                          chatWithUserName,
                                          chatWithUserID,
                                        ],
                                        '${myUserName}_typing': false,
                                        '${chatWithUserName}_typing': false,
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
                                                userId: user['user_id'],
                                              ),
                                            ),
                                          );
                                    },
                                    child: Container(
                                      width: screenSize / 11,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 5.0,
                                          vertical: 10.0,
                                        ),
                                        child: Column(
                                          children: [
                                            Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Container(
                                                  height: screenSize / 15,
                                                  width: screenSize / 15,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          user['profile_url']),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                ),
                                                Positioned(
                                                  right: -5.0,
                                                  bottom: -3.0,
                                                  child: Container(
                                                    height: 10.0,
                                                    width: 10.0,
                                                    decoration: BoxDecoration(
                                                      color: user['status'] ==
                                                              'Online'
                                                          ? Colors.green[400]
                                                          : Colors.grey[400],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                  ),
                                                ),
                                              ],
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

                                  // return RecentMessageTile(
                                  //   myUserName: myUserName,
                                  //   lastMessage: currentMessage['lastMessage'],
                                  // lastMessageTime: timeago.format(
                                  //   currentMessage['lastMessageTime']
                                  //       .toDate(),
                                  //   ),
                                  //   chatRoomID: currentMessage.id,
                                  // );
                                  return GestureDetector(
                                    onTap: () {
                                      Get.to(
                                        () => currentMessage['to_user'][2] !=
                                                myUserName
                                            ? MessageScreen(
                                                chatWithName:
                                                    currentMessage['to_user']
                                                        [0]!,
                                                chatWithUserName:
                                                    currentMessage['to_user']
                                                        [2]!,
                                                chatWithUserProfile:
                                                    currentMessage['to_user']
                                                        [1],
                                                userId:
                                                    currentMessage['to_user']
                                                        [3],
                                              )
                                            : MessageScreen(
                                                chatWithName:
                                                    currentMessage['from_user']
                                                        [0]!,
                                                chatWithUserName:
                                                    currentMessage['from_user']
                                                        [2]!,
                                                chatWithUserProfile:
                                                    currentMessage['from_user']
                                                        [1],
                                                userId:
                                                    currentMessage['from_user']
                                                        [3],
                                              ),
                                      );
                                    },
                                    child: Container(
                                      child: Card(
                                        elevation: 2,
                                        child: currentMessage['to_user'][2] !=
                                                myUserName
                                            ? ListTile(
                                                leading: chatWithUserProfile !=
                                                        ""
                                                    ? CircleAvatar(
                                                        radius: 30.0,
                                                        backgroundImage:
                                                            NetworkImage(
                                                                "${currentMessage['to_user'][1]}"),
                                                        backgroundColor:
                                                            Colors.transparent,
                                                      )
                                                    : CircleAvatar(
                                                        radius: 30.0,
                                                        backgroundColor:
                                                            BLAKISH,
                                                      ),
                                                title: Text(
                                                    "${currentMessage['to_user'][0]}"),
                                                subtitle: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        "${currentMessage['lastMessage']}",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        "${timeago.format(currentMessage['lastMessageTime'].toDate())}",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : ListTile(
                                                leading: chatWithUserProfile !=
                                                        ""
                                                    ? CircleAvatar(
                                                        radius: 30.0,
                                                        backgroundImage:
                                                            NetworkImage(
                                                                "${currentMessage['from_user'][1]}"),
                                                        backgroundColor:
                                                            Colors.transparent,
                                                      )
                                                    : CircleAvatar(
                                                        radius: 30.0,
                                                        backgroundColor:
                                                            BLAKISH,
                                                      ),
                                                title: Text(
                                                    "${currentMessage['from_user'][0]}"),
                                                subtitle: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        "${currentMessage['lastMessage']}",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        "${timeago.format(currentMessage['lastMessageTime'].toDate())}",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
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

// class RecentMessageTile extends StatefulWidget {
//   const RecentMessageTile({
//     Key? key,
//     required this.myUserName,
//     required this.lastMessage,
//     required this.lastMessageTime,
//     required this.chatRoomID,
//   }) : super(key: key);

//   final String? myUserName;
//   final String lastMessage;
//   final lastMessageTime;
//   final String chatRoomID;

//   @override
//   _RecentMessageTileState createState() => _RecentMessageTileState();
// }

// class _RecentMessageTileState extends State<RecentMessageTile> {
//   String? chatWithUserName;
//   String? chatWithName;
//   String chatWithUserProfile = "";

// getUserInfo() async {
//   chatWithUserName = widget.chatRoomID
//       .replaceAll(widget.myUserName!, "")
//       .replaceAll("_", "");
//   QuerySnapshot data = await DatabaseManager().getUserInfo(chatWithUserName!);
//   chatWithName = data.docs[0]['name'];
//   chatWithUserProfile = data.docs[0]['profile_url'];
//   setState(() {});
// }

//   @override
//   void initState() {
//     super.initState();
//     getUserInfo();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Get.to(
//           () => MessageScreen(
//             chatWithName: chatWithName!,
//             chatWithUserName: chatWithUserName!,
//             chatWithUserProfile: chatWithUserProfile,
//           ),
//         );
//       },
//       child: Container(
//         child: Card(
//           elevation: 2,
//           child: ListTile(
//             leading: chatWithUserProfile != ""
//                 ? CircleAvatar(
//                     radius: 30.0,
//                     backgroundImage: NetworkImage("$chatWithUserProfile"),
//                     backgroundColor: Colors.transparent,
//                   )
//                 : CircleAvatar(
//                     radius: 30.0,
//                     backgroundColor: BLAKISH,
//                   ),
//             title: Text(chatWithName ?? "Loading . . ."),
//             subtitle: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Flexible(
//                   child: Text(
//                     "${widget.lastMessage}",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 Flexible(
//                   child: Text(
//                     "${widget.lastMessageTime}",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
