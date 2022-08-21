import 'dart:developer';

import 'package:comment_tree/widgets/comment_tree_widget.dart';
import 'package:comment_tree/widgets/tree_theme_data.dart';
import 'package:enos/constants.dart';
import 'package:enos/models/comment.dart';
import 'package:enos/models/user.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/util.dart';
import 'package:enos/widgets/comment_box.dart';
import 'package:enos/widgets/loading.dart';
import 'package:enos/widgets/profile_pic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentManager extends StatefulWidget {
  Comment root;
  List<Comment> visibleReplies = [];
  List<String> cReplies = [];
  CommentTreeWidget<Comment, Comment> tree;
  String userId;
  UserModel user;
  ProfilePicture userProfilePic;
  Color rootColor1, rootColor2;
  Image rootProfilePic;
  Map<String, Color> color1, color2;
  Map<String, Image> profilePic;
  bool isLoad = false;
  CommentManager(
      {this.root,
      this.user,
      this.rootColor1,
      this.rootColor2,
      this.rootProfilePic,
      this.userProfilePic}) {
    cReplies = [...root.replies];
    color1 = {root.userUid: rootColor1};
    color2 = {root.userUid: rootColor2};
    profilePic = {};
    if (rootProfilePic != null) {
      profilePic[root.userUid] = rootProfilePic;
    }
    if (cReplies.length > 0) root.viewReply = true;

    if (root.apiComment == null) {
      root.apiComment = true;
      FirebaseApi.updateComment(root);
    }
  }

  // void initUser() async{
  //
  // }

  void refresh() {
    if (visibleReplies.length == cReplies.length) {
      loadComments(1);
    } else {}
  }

  void loadComments(int amt) async {
    isLoad = true;
    root.viewReply = false;
    int pos = visibleReplies.length;
    if (pos != 0) {
      visibleReplies[pos - 1].viewReply = false;
    }
    if (pos < cReplies.length) {
      for (int i = 0; i < amt && pos < cReplies.length; i++, pos++) {
        Comment com = await FirebaseApi.getComment(cReplies[pos]);
        visibleReplies.add(com);
        UserModel user2;
        Color c1, c2;
        Image p;
        if (!com.apiComment) {
          user2 = await FirebaseApi.getUser(com.userUid);
          c1 = Utils.stringToColor(user2.profileBgColor);
          c2 = Utils.stringToColor(user2.profileBgColor);
          if (user.profilePic != null) {
            p = Image.network(user2.profilePic);
          }
        } else {
          c1 = Utils.stringToColor(ProfilePicture.getRandomColor());
          c2 = Utils.stringToColor(ProfilePicture.getRandomColor());
        }
        if (!color1.containsKey(com.userUid)) color1[com.userUid] = c1;
        if (!color2.containsKey(com.userUid)) color2[com.userUid] = c2;
        if (!profilePic.containsKey(com.userUid)) profilePic[com.userUid] = p;
      }
    }

    if (pos != root.replies.length) {
      visibleReplies[pos - 1].viewReply = true;
    }
    isLoad = false;
  }

  @override
  State<StatefulWidget> createState() => _CommentManagerState();
}

class _CommentManagerState extends State<CommentManager> {
  @override
  void refresh() {
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Container(
      child: CommentTreeWidget<Comment, Comment>(
        widget.root,
        widget.visibleReplies,
        treeThemeData:
            TreeThemeData(lineColor: kDarkBackgroundColor, lineWidth: 0),
        avatarRoot: (context, data) => PreferredSize(
          child: widget.rootProfilePic != null
              ? ProfilePicture(
                  name: data.userName,
                  image: widget.rootProfilePic,
                  color1: widget.rootColor1,
                  color2: widget.rootColor2,
                )
              : ProfilePicture(
                  name: data.userName,
                  color1: widget.rootColor1,
                  color2: widget.rootColor2,
                ),
          preferredSize: Size.fromRadius(8),
        ),
        avatarChild: (context, data) => PreferredSize(
          child: widget.profilePic[data.userUid] != null
              ? ProfilePicture(
                  name: data.userName,
                  image: widget.profilePic[data.userUid],
                  color1: widget.color1[data.userUid],
                  color2: widget.color2[data.userUid],
                )
              : ProfilePicture(
                  name: data.userName,
                  color1: widget.color1[data.userUid],
                  color2: widget.color2[data.userUid],
                ),
          preferredSize: Size.fromRadius(18),
        ),
        contentChild: (context, data) {
          return CommentBox(
            data: data,
            context: context,
            manager: widget,
            notifyParent: refresh,
          );
        },
        contentRoot: (context, data) {
          return CommentBox(
            data: data,
            context: context,
            manager: widget,
            notifyParent: refresh,
          );
        },
      ),
      padding: EdgeInsets.symmetric(vertical: 12),
    );
  }
}

class CommentSection extends StatefulWidget {
  String userId;
  String symbol;
  String parentId, childId;
  bool overLimit = false;
  int numComments;
  CommentSection(String userId, String symbol, {this.parentId="",this.childId=""}) {
    this.symbol = symbol;
    this.userId = userId;
    this.numComments = 0;

  }

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  bool isLoad;
  TextEditingController _controller;
  List<CommentManager> comments;
  UserModel user;
  int numComments = 0;
  void initState() {
    super.initState();
    comments = [];
    _controller = TextEditingController();
    if (comments.length == 0) loadComments();
  }

  final double inputHeight = 35;
  final double profileWidth = 35;
  final double postBtnWidth = 65;
  double width;
  double height;

  void loadComments() async {
    isLoad = true;
    UserModel user = await FirebaseApi.getUser(widget.userId);
    for(String id in user.comments) {
      Comment com = await FirebaseApi.getComment(id);
       print(com.stockUid);
      // print(widget.symbol);
      // print('kino');
      if(com.stockUid == widget.symbol) {
        this.numComments++;
      }
    }
    this.user = user;
    Image img = null;
    List<Comment> com = await FirebaseApi.getStockComment(widget.symbol);
    if (user.profilePic != null) {
      img = Image.network(user.profilePic);
    }
    ProfilePicture pic = ProfilePicture(
      name: user.username,
      image: img,
      color1: Utils.stringToColor(user.profileBgColor),
      color2: Utils.stringToColor(user.profileBorderColor),
      width: profileWidth,
      height: 25,
      fontSize: 15,
    );

    for(int i = 0; i < com.length; i++) {
      Comment element = com[i];
      if (!element.isNested) {
        Color color1, color2;
        Image profilePic = null;
        if (!element.apiComment) {
          UserModel user2 = await FirebaseApi.getUser(element.userUid);
          color1 = Utils.stringToColor(user2.profileBgColor);
          color2 = Utils.stringToColor(user2.profileBorderColor);
          if (user.profilePic != null) {
            profilePic = Image.network(user2.profilePic);
          }
        } else {
          color1 = Utils.stringToColor(ProfilePicture.getRandomColor());
          color2 = Utils.stringToColor(ProfilePicture.getRandomColor());
        }
        comments.add(CommentManager(
          root: element,
          userProfilePic: pic,
          user: user,
          rootColor1: color1,
          rootColor2: color2,
          rootProfilePic: profilePic,
        ));
      }
    }
   await comments.sort((a, b) {
      if(a.root.likes != b.root.likes)
        return b.root.likes - a.root.likes;
      return b.root.createdTime.compareTo(a.root.createdTime);
    });
   List<CommentManager> first = [];
    for(CommentManager c in comments) {
      if(c.root.userUid == user.userUid) {
        first.add(c);
      }
    }
   await first.sort((a,b) {
      if(a.root.likes != b.root.likes)
        return a.root.likes-b.root.likes;
      return a.root.createdTime.compareTo(b.root.createdTime);
    });
    for(CommentManager c in first) {
      comments.remove(c);
      comments.insert(0, c);
    }
   // print(comments.length);
    for(int i = 0; i < comments.length; i++) {
      CommentManager c = comments[i];
      if(c.root.userUid == user.userUid) {
        numComments++;
      }
      if(c.root.commentUid == widget.parentId) {
          comments.remove(c);
          comments.insert(0, c);
          if(widget.childId != "") {
            c.cReplies.remove(widget.childId);
            c.cReplies.insert(0, widget.childId);
          }
      }
    }
    if(numComments > 5) {
      widget.overLimit = true;
    }
    isLoad = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return isLoad
        ? Loading()
        : ListView.builder(
            itemCount: comments.length + 2,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext c, index) {
              if (index == 0) {
                return SizedBox(
                  height: 5,
                );
              }
              if (index == 1) {
                if (this.user == null || this.numComments >= 5) {
                  return SizedBox.shrink();
                }
                return Container(
                  color: kLightBackgroundColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ProfilePicture(
                        name: user.username,
                        color1: Utils.stringToColor(user.profileBgColor),
                        color2: Utils.stringToColor(user.profileBorderColor),
                        image: user.profilePic != null
                            ? Image.network(user.profilePic)
                            : null,
                        width: profileWidth,
                        height: inputHeight,
                      ),
                      Container(
                        //color: kDisabledColor,
                        // height: inputHeight,
                        //35 = padding ?
                        width: width - postBtnWidth - profileWidth - 35,
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 1,

                          // cursorHeight: inputHeight,
                          decoration: InputDecoration.collapsed(
                            hintText: "Add a comment ...",
                            hintStyle: TextStyle(
                              color: kDisabledColor,
                            ),
                          ),
                          onTap: () {
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);

                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                          },
                          controller: _controller,
                          onChanged: (String s) {
                            setState(() {});
                          },
                          style:
                              TextStyle(fontSize: 15, color: kBrightTextColor),
                        ),
                      ),
                      //       SizedBox(width: 10,),
                      Container(
                        width: postBtnWidth,
                        color: _controller.text == ""
                            ? kDisabledColor
                            : kActiveColor,
                        child: TextButton(
                          onPressed: () async {
                            if (_controller.text != "") {
                              Comment com = Comment(
                                  content: _controller.value.text,
                                  likes: 0,
                                  stockUid: widget.symbol,
                                  userUid: user.userUid,
                                  replies: [],
                                  apiComment: false,
                                  isNested: false,
                                  createdTime: DateTime.now(),
                                  userName: user.username);
                              String id = await FirebaseApi.updateComment(com);
                              ProfilePicture pic = ProfilePicture(
                                name: user.username,
                                image: user.profilePic != null
                                    ? Image.network(user.profilePic)
                                    : null,
                                color1:
                                    Utils.stringToColor(user.profileBgColor),
                                color2: Utils.stringToColor(
                                    user.profileBorderColor),
                                fontSize: 15,
                              );
                              user.comments.add(id);
                              await FirebaseApi.updateUserData(user);
                              comments.insert(
                                  0,
                                  CommentManager(
                                    root: com,
                                    user: user,
                                    rootColor1: Utils.stringToColor(
                                        user.profileBgColor),
                                    rootColor2: Utils.stringToColor(
                                        user.profileBorderColor),
                                    rootProfilePic: user.profilePic != null
                                        ? Image.network(user.profilePic)
                                        : null,
                                    userProfilePic: pic,
                                  ));
                              this.numComments++;
                              _controller.clear();
                              setState(() {});
                            }
                          },
                          child: Text(
                            "POST",
                            style: TextStyle(
                                color: kBrightTextColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
              return comments[index - 2];
            });
  }
}
