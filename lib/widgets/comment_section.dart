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
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

//link manager to comment section
FocusNode focusNode = FocusNode();

ValueNotifier textBoxNotifier = ValueNotifier(false);
bool isReply = false;
String hintText = "Add a comment ...";
String btnText = 'Post';

Comment curComment = null;
CommentManager curManager = null;
CommentBox curBox = null;

String currentText = "";

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

    // if (root.apiComment == null) {
    //   root.apiComment = true;
    //   FirebaseApi.updateComment(root);
    // }
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
        print(com);
        visibleReplies.add(com);
        UserModel user2;
        Color c1, c2;
        Image p;
        if (!com.apiComment) {
          user2 = await FirebaseApi.getUser(com.userUid);
          if (com.userName != user2.username) {
            com.userName = user2.username;
            await FirebaseApi.updateComment(com);
          }
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

    if (pos != cReplies.length) {
      visibleReplies[pos - 1].viewReply = true;
    }
    isLoad = false;
  }

  @override
  State<StatefulWidget> createState() => _CommentManagerState();
}

class _CommentManagerState extends State<CommentManager> {
  void refresh() {
    setState(() {});
  }

  void replyClicked(Comment replyComment, CommentBox box) {
    // isReply = true;
    hintText = "Reply to ${replyComment.userName}";
    btnText = "Reply";
    FocusScopeNode currentFocus = FocusScope.of(context);
    currentFocus.requestFocus(focusNode);

    focusNode.addListener(() {
      //print("toggling");
      //print(focusNode.hasFocus);
      //print(currentText);
      if (!focusNode.hasFocus && currentText.trim().isEmpty) {
        hintText = "Add a comment ...";
        btnText = "Post";
      }
      textBoxNotifier.value = !textBoxNotifier.value;
    });
    curComment = replyComment;
    curBox = box;
    textBoxNotifier.value = !textBoxNotifier.value;
  }

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
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
          CommentBox box = CommentBox(
            data: data,
            context: context,
            manager: widget,
            notifyParent: refresh,
          );
          box.replyClicked = () {
            // print(widget.root.commentUid);
            // print(widget.root.parentUid);
            replyClicked(data, box);
          };
          return box;
        },
        contentRoot: (context, data) {
          CommentBox box = CommentBox(
            data: data,
            context: context,
            manager: widget,
            notifyParent: refresh,
          );
          // print(widget.root.commentUid);
          // print(widget.root.parentUid);
          box.replyClicked = () {
            replyClicked(data, box);
          };
          return box;
        },
      ),
      padding: EdgeInsets.symmetric(vertical: 12),
    );
  }
}

class CommentSection extends StatefulWidget {
  static String global = "";
  String userId;
  String symbol;
  String parentId, selfId;
  bool overLimit = false;
  int numComments;
  bool isSelfScroll;
  Function onFinishLoad;

  CommentSection(
      String userId, String symbol, this.isSelfScroll, this.onFinishLoad,
      {this.parentId = "", this.selfId = ""}) {
    this.symbol = symbol;
    this.userId = userId;
    this.numComments = 0;
  }

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection>
    with SingleTickerProviderStateMixin {
  bool isLoad;
  TextEditingController _controller;
  List<CommentManager> comments;
  UserModel user;
  int numComments = 0;
  final scrollController = ScrollController();
  bool isScrollUp = true;
  int highlightIndex;
  AnimationController _animeController;
  Animation lightUpAnimation;
  bool animationComplete = false;
  @override
  void dispose() {
    _animeController.dispose();
    _controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animeController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1100))
          ..addListener(() {
            setState(() {});
          });
    lightUpAnimation = new Tween(begin: 0.0, end: 1.0).animate(
        new CurvedAnimation(
            parent: _animeController, curve: Curves.easeInQuint));
    _animeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            animationComplete = true;
          });
        });
      }
    });

    // Setup the listener.
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        isScrollUp = true;
        //print("scrolling up");
        return;
      }
      //print("scrolling down");
      isScrollUp = false;
      // //print("not at top end");
      // setState(() {
      //   widget.atTop = false;
      // });
    });

    comments = [];
    _controller = TextEditingController();
    if (comments.length == 0) loadComments();

    // print(comments);
    super.initState();
  }

  final double inputHeight = 35;
  final double profileWidth = 35;
  final double postBtnWidth = 65;

  final double commentProfileH = 28, commentProfileW = 28;
  final double commentProfileFontSize = 14;
  double width;
  double height;
  void loadComments() async {
    isLoad = true;
    UserModel user = await FirebaseApi.getUser(widget.userId);
    //  for(String id in user.comments) {
    //    Comment com = await FirebaseApi.getComment(id);
    // //    //print(com.stockUid);
    //    // //print(widget.symbol);
    //    // //print('kino');
    //    if(com.stockUid == widget.symbol) {
    //      this.numComments++;
    //    }
    //  }
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
    // print(widget.parentId);
    for (int i = 0; i < com.length; i++) {
      Comment element = com[i];

      if (element.userUid == user.userUid) this.numComments++;
      if (!element.isNested) {
        Color color1, color2;
        Image profilePic = null;
        if (!element.apiComment) {
          UserModel user2 = await FirebaseApi.getUser(element.userUid);
          // if (element.userName != user2.username) {
          //   element.userName = user2.username;
          //   await FirebaseApi.updateComment(element);
          // }

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
      bool one = a.root.userUid == user.userUid;
      bool two = b.root.userUid == user.userUid;

      if (one == two) {
        if (a.root.likes != b.root.likes) return b.root.likes - a.root.likes;
        return b.root.createdTime.compareTo(a.root.createdTime);
      }
      if (two) return 1;
      return -1;
    });
    // List<CommentManager> first = [];
    //  for(CommentManager c in comments) {
    //    if(c.root.userUid == user.userUid) {
    //      first.add(c);
    //    }
    //  }
    // await first.sort((a,b) {
    //    if(a.root.likes != b.root.likes)
    //      return a.root.likes-b.root.likes;
    //    return a.root.createdTime.compareTo(b.root.createdTime);
    //  });
    //  for(CommentManager c in first) {
    //    comments.remove(c);
    //    comments.insert(0, c);
    //  }

    //putting clicked on reply on top
    // for (int i = 0; i < comments.length; i++) {
    //   CommentManager c = comments[i];
    //   if (c.root.commentUid == widget.parentId) {
    //     // comments.remove(c);
    //     // comments.insert(0, c);
    //     if (widget.selfId != "") {
    //       c.cReplies.remove(widget.selfId);
    //       c.cReplies.insert(0, widget.selfId);
    //     }
    //   }
    // }

    if (widget.selfId != null && widget.selfId.isNotEmpty) {
//for main comments

      if (widget.parentId == null || widget.parentId.trim().isEmpty) {
        print("no parent");
        highlightIndex = comments
            .indexWhere((element) => element.root.commentUid == widget.selfId);
      }
      //for replies
      else {
        print(widget.parentId);

        highlightIndex = comments.indexWhere(
            (element) => element.root.commentUid == widget.parentId);
      }
      print("highlightindex: $highlightIndex");
    }

    // highlightIndex = comments
    //     .indexWhere((element) => element.root.commentUid == widget.parentId);

    // print(highlightIndex);
    isLoad = false;
    if (widget.onFinishLoad != null) widget.onFinishLoad();
    _animeController.forward();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print("rebuilding");
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return isLoad
        ? Loading()
        : NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                if (notification.metrics.extentBefore == 0 && !isScrollUp) {
                  if (widget.isSelfScroll) {
                    setState(() {
                      widget.isSelfScroll = false;
                    });
                  }
                  // //print(
                  //     "scrolling articles down -> hit top edge, moving page ");
                }
              }
              return false;
            },
            child: ListView.builder(
                controller: scrollController,
                itemCount: comments.length + 2,
                scrollDirection: Axis.vertical,
                physics: widget.isSelfScroll
                    ? ClampingScrollPhysics()
                    : NeverScrollableScrollPhysics(),
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
                      child: ValueListenableBuilder(
                        valueListenable: textBoxNotifier,
                        builder: (context, _, child) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ProfilePicture(
                              name: user.username,
                              color1: Utils.stringToColor(user.profileBgColor),
                              color2:
                                  Utils.stringToColor(user.profileBorderColor),
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
                                focusNode: focusNode,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                minLines: 1,

                                // cursorHeight: inputHeight,
                                decoration: InputDecoration.collapsed(
                                  hintText: hintText,
                                  hintStyle: TextStyle(
                                    color: kDisabledColor,
                                  ),
                                ),
                                onTap: () {
                                  if (currentText.isNotEmpty) {
                                    return;
                                  }
                                  hintText = "Add a comment ...";
                                  btnText = "Post";
                                  textBoxNotifier.value =
                                      !textBoxNotifier.value;
                                },
                                controller: _controller,
                                onChanged: (String s) {
                                  print("onchange");
                                  currentText = s;

                                  if (currentText.trim().length > 1) {
                                    return;
                                  }

                                  textBoxNotifier.value =
                                      !textBoxNotifier.value;
                                },
                                style: TextStyle(
                                    fontSize: 15, color: kBrightTextColor),
                              ),
                            ),

                            //       SizedBox(width: 10,),
                            Container(
                              width: postBtnWidth,
                              color: _controller.text.isEmpty
                                  ? kDisabledColor
                                  : kActiveColor,
                              child: TextButton(
                                onPressed: () async {
                                  if (_controller.text.trim() != "") {
                                    if (btnText == "Reply") {
                                      print("replying");
                                      CommentSection.global = _controller.text;
                                      curBox.addReply();
                                      CommentSection.global = "";
                                      _controller.clear();
                                      currentText = "";
                                      // Comment parent = curComment.parentUid != null? FirebaseApi.getComment(curComment.parentUid)
                                      // : curComment;
                                      //     Comment com = Comment(
                                      //         content:
                                      //             "@${curComment.userName} ${_controller.value.text}",
                                      //         userUid: user.userUid,
                                      //         stockUid: curComment.stockUid,
                                      //         likes: 0,
                                      //         isNested: true,
                                      //         apiComment: false,
                                      //         createdTime: DateTime.now(),
                                      //         replies: [],
                                      //         userName: user.username,
                                      //         parentUid: parent.commentUid);
                                      //
                                      //     String id = await FirebaseApi.updateComment(com);
                                      //     parent.replies.add(id);
                                      //      curManager.cReplies.add(id);
                                      //      if(parent != curComment)
                                      //        curComment.replies.add(id);
                                      //      await FirebaseApi.updateComment(
                                      //          parent);
                                      //      await FirebaseApi.updateComment(curComment);
                                      //   //   await curManager.loadComments(1);
                                      //      user.comments.add(id);
                                      //      await FirebaseApi.updateUserData(user);
                                      //      _controller.clear();
                                      //      setState(() {});
                                      focusNode.unfocus();
                                      return;
                                    }
                                    // add general comment
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
                                    String id =
                                        await FirebaseApi.addComment(com);
                                    ProfilePicture pic = ProfilePicture(
                                      name: user.username,
                                      image: user.profilePic != null
                                          ? Image.network(user.profilePic)
                                          : null,
                                      color1: Utils.stringToColor(
                                          user.profileBgColor),
                                      color2: Utils.stringToColor(
                                          user.profileBorderColor),
                                      width: commentProfileW,
                                      height: commentProfileH,
                                      fontSize: commentProfileFontSize,
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
                                          rootProfilePic: user.profilePic !=
                                                  null
                                              ? Image.network(user.profilePic)
                                              : null,
                                          userProfilePic: pic,
                                        ));
                                    this.numComments++;
                                    _controller.clear();
                                    setState(() {});
                                    currentText = "";
                                    focusNode.unfocus();
                                  }
                                },
                                child: Text(
                                  btnText,
                                  style: TextStyle(
                                      color: kBrightTextColor,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                  return (index - 2) == highlightIndex && !animationComplete
                      ? AnimatedBuilder(
                          animation: _animeController,
                          builder: (context, child) => Container(
                              decoration: BoxDecoration(
                                // shape: BoxShape.rectangle,
                                // borderRadius:
                                //     BorderRadius.all(Radius.circular(12)),
                                border: Border.all(
                                    color: kActiveColor
                                        .withOpacity(lightUpAnimation.value),
                                    width: 3),
                              ),
                              child: comments[index - 2]))
                      : comments[index - 2];
                }),
          );
  }
}
