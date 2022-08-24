import 'package:enos/constants.dart';
import 'package:enos/models/user.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/util.dart';
import 'package:enos/widgets/comment_section.dart';

import 'package:flutter/material.dart';
import '../models/comment.dart';

class CommentBox extends StatefulWidget {
  final BuildContext context;
  final Comment data;
  final CommentManager manager;
  final Function notifyParent;
  Function replyClicked;
  Function addComment;
  String time;
  CommentBox(
      {this.context,
      this.data,
      this.manager,
      @required this.notifyParent,
      this.replyClicked}) {
    time = Utils.getTimeFromToday(data.createdTime);
    addComment = addReply;
  }
  void addReply() async {
    print('yo');
    print(manager);
    UserModel user = manager.user;
    //update main
    Comment reply = Comment(
        content: "@${data.userName} ${CommentSection.global}",
        userUid: user.userUid,
        stockUid: data.stockUid,
        likes: 0,
        isNested: true,
        apiComment: false,
        createdTime: DateTime.now(),
        replies: [],
        userName: user.username,
        parentUid: manager.root.commentUid);

    String id = await FirebaseApi.addReply(manager.root.commentUid, reply);

    manager.root.replies.add(id);
    //print(manager.root.replies);
    manager.cReplies.add(id);
    //print(manager.root.replies);
    //for replying to reply
    if (data.commentUid != manager.root.commentUid) {
      print("updating ");
      data.replies.add(id);
      await FirebaseApi.updateComment(data);
    }
    //data.replies.add(id);
    //print(manager.root.replies);

    await FirebaseApi.updateComment(manager.root);

    await manager.loadComments(1);
    user.comments.add(id);
    await FirebaseApi.updateUserData(user);
    notifyParent();
  }

  @override
  State<CommentBox> createState() => _CommentBoxState();
}

class _CommentBoxState extends State<CommentBox> {
  TextEditingController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  double width;
  double height;
  final double profileWidth = 35;
  final double postBtnWidth = 65;
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return box();
  }

  Widget box() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(8, 5, 3, 2),
          decoration: BoxDecoration(
              color: kLightBackgroundColor,
              borderRadius: BorderRadius.circular(3)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.data.userName.length <= 15
                        ? '${widget.data.userName}'
                        : '${widget.data.userName.substring(0, 15)}...',
                    style: Theme.of(context).textTheme.caption.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: kDisabledColor),
                  ),
                  Text(
                    ' · ${widget.time}',
                    style: Theme.of(context).textTheme.caption.copyWith(
                          color: kDisabledColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                '${widget.data.content}',
                style: Theme.of(context).textTheme.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: kBrightTextColor,
                    fontSize: 14),
              ),
              SizedBox(
                height: 8,
              ),
              DefaultTextStyle(
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                child: Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // widget.manager.userProfilePic,
                      // Container(
                      //   width: 90,
                      //   color: kLightBackgroundColor,
                      //   //             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                      //   child: TextField(
                      //     controller: _controller,
                      //     minLines: 1,
                      //     maxLines: null,
                      //     onChanged: (String s) {
                      //       setState(() {});
                      //     },
                      //     onEditingComplete: () async {},
                      //     style:
                      //         TextStyle(fontSize: 12, color: kBrightTextColor),
                      //     decoration: InputDecoration(
                      //         hintText: "Reply ... ",
                      //         hintStyle: TextStyle(color: Colors.grey)),
                      //   ),
                      // ),
                      // Container(
                      //   width: 100,
                      //   // height: 40,
                      //   child: TextButton(
                      //     onPressed: () async {
                      //       if (_controller.text != "") {
                      //         UserModel user = widget.manager.user;

                      //         Comment com = Comment(
                      //             content:
                      //                 "@${widget.data.userName} ${_controller.value.text}",
                      //             userUid: user.userUid,
                      //             stockUid: widget.data.stockUid,
                      //             likes: 0,
                      //             isNested: true,
                      //             apiComment: false,
                      //             createdTime: DateTime.now(),
                      //             replies: [],
                      //             userName: user.username,
                      //             parentUid: widget.manager.root.commentUid);

                      //         String id = await FirebaseApi.updateComment(com);
                      //         widget.manager.root.replies.add(id);
                      //         widget.manager.cReplies.add(id);
                      //         widget.data.replies.add(id);
                      //         await FirebaseApi.updateComment(
                      //             widget.manager.root);
                      //         await FirebaseApi.updateComment(widget.data);
                      //         await widget.manager.loadComments(1);
                      //         user.comments.add(id);
                      //         await FirebaseApi.updateUserData(user);
                      //         _controller.clear();
                      //         widget.notifyParent();
                      //         setState(() {});
                      //       }
                      //     },
                      //     child: Text(
                      //       "POST",
                      //       style: TextStyle(
                      //           color: _controller.text == ""
                      //               ? kDisabledColor
                      //               : kActiveColor,
                      //           fontSize: 12),
                      //     ),
                      //   ),
                      // ),
                      // IconButton(
                      //     onPressed: () async {
                      //       UserModel user = widget.manager.user;
                      //       if (user.likedComments
                      //           .contains(widget.data.commentUid)) {
                      //         user.likedComments.remove(widget.data.commentUid);
                      //         widget.data.likes--;
                      //       } else {
                      //         user.likedComments.add(widget.data.commentUid);
                      //         widget.data.likes++;
                      //       }
                      //       await FirebaseApi.updateUserData(user);
                      //       await FirebaseApi.updateComment(widget.data);
                      //       widget.notifyParent();
                      //     },
                      //     icon: Column(
                      //       children: [
                      //         widget.manager.user.likedComments == null ||
                      //                 widget.manager.user.likedComments
                      //                     .contains(widget.data.commentUid)
                      //             ? Icon(
                      //                 Icons.thumb_up,
                      //                 size: 20,
                      //               )
                      //             : Icon(
                      //                 Icons.thumb_up_alt_outlined,
                      //                 size: 20,
                      //               ),
                      //         // SizedBox(
                      //         //   width: 4,
                      //         // ),
                      //         Text(
                      //           "${widget.data.likes}",
                      //           style: TextStyle(fontSize: 13),
                      //         )
                      //       ],
                      //     ),
                      // color: kDarkTextColor),
                      TextButton.icon(
                          onPressed: () async {
                            UserModel user = widget.manager.user;
                            if (user.likedComments
                                .contains(widget.data.commentUid)) {
                              user.likedComments.remove(widget.data.commentUid);
                              widget.data.likes--;
                            } else {
                              user.likedComments.add(widget.data.commentUid);
                              widget.data.likes++;
                            }
                            await FirebaseApi.updateUserData(user);
                            await FirebaseApi.addComment(widget.data);
                            widget.notifyParent();
                          },
                          icon: widget.manager.user.likedComments == null ||
                                  widget.manager.user.likedComments
                                      .contains(widget.data.commentUid)
                              ? Icon(
                                  Icons.thumb_up,
                                  size: 20,
                                )
                              : Icon(
                                  Icons.thumb_up_alt_outlined,
                                  size: 20,
                                ),
                          label: Text(
                            "${widget.data.likes}",
                            style: TextStyle(fontSize: 13),
                          )),
                      SizedBox(
                        width: 5,
                      ),
                      TextButton.icon(
                          onPressed: () {
                            widget.replyClicked();
                          },
                          icon: Icon(Icons.reply),
                          label: Text(
                            "Reply",
                            style: TextStyle(fontSize: 13),
                          ))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            !widget.manager.isLoad && widget.data.viewReply
                ? TextButton(
                    onPressed: () async {
                      widget.manager.isLoad = true;
                      setState(() {});
                      await widget.manager.loadComments(4);
                      widget.notifyParent();
                    },
                    child: Text(
                      "View More Replies",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ))
                : widget.data.viewReply
                    ? CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 10,
                      )
                    : SizedBox.shrink()
          ],
        )
      ],
    );
  }

  void viewReply() async {
    await widget.manager.loadComments(4);
    Future.delayed(Duration(milliseconds: 100), () {
      widget.notifyParent();
      setState(() {});
    });
  }
}
