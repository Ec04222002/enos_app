
import 'package:enos/constants.dart';
import 'package:enos/models/user.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/widgets/comment_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../models/comment.dart';

class CommentBox extends StatefulWidget {
  final BuildContext context;
  final Comment data;
  final CommentManager manager;
  final Function() notifyParent;
  CommentBox({this.context,this.data, this.manager, @required this.notifyParent}) {
  }

  @override
  State<CommentBox> createState() => _CommentBoxState();
}

class _CommentBoxState extends State<CommentBox> {

   TextEditingController _controller;

  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return box();
  }

   Widget box() {
   return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
     Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
          color: kLightBackgroundColor,
          borderRadius: BorderRadius.circular(12)),
      child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
        Row(
          children: [

           Text(
            widget.data.userUid.length <= 15? '${widget.data.userUid}': '${widget.data.userUid.substring(0,15)}...',
            style: Theme.of(context).textTheme.caption.copyWith(
                fontWeight: FontWeight.w600, color: Colors.white),
           ),
           SizedBox(width: 5,),
           Text(
            '${widget.manager.time}',
            style: Theme.of(context).textTheme.caption.copyWith(
                color: Colors.grey),
           ),
          ],
        ),

        SizedBox(
         height: 4,
        ),
        Text(
         '${widget.data.content}',
         style: Theme.of(context).textTheme.caption.copyWith(
             fontWeight: FontWeight.w300, color: Colors.white),
        ),
         SizedBox(
           height: 10,
         ),
        DefaultTextStyle(
         style: Theme.of(context).textTheme.caption.copyWith(
             color: Colors.white, fontWeight: FontWeight.bold),
         child: Padding(
          padding: EdgeInsets.only(top: 0),
          child:  Row(
           mainAxisAlignment: MainAxisAlignment.start,
           children: [
             widget.manager.userProfilePic,
            Container(
              width: 100,
              color: kLightBackgroundColor,
 //             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
              child: TextField(
                controller: _controller,
                onEditingComplete : () async {
                  UserModel user = widget.manager.user;

                  Comment com = Comment(
                    content: _controller.value.text,
                    userUid: user.userUid,
                    stockUid: widget.data.stockUid,
                    likes: 0,
                    isNested: true,
                    apiComment: false,
                    createdTime: DateTime.now(),
                    replies: [],
                  );

                  String id = await FirebaseApi.updateComment(com);
                  widget.manager.root.replies.add(id);
                  await FirebaseApi.updateComment(widget.manager.root);
                  await widget.manager.loadComments(1);
                  _controller.clear();
                  widget.notifyParent();
                },
                style: TextStyle(fontSize: 11, color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Add a comment...",
                  hintStyle: TextStyle(color: Colors.grey)
                ),
               ),
            ),
            IconButton(onPressed: () async {

            }, icon: Icon(Icons.thumb_up,size: 20,) ,color: Colors.blue),
            Text("${widget.data.likes}"),
            SizedBox(
             width: 24,
            ),

           ],
          ),
         ),
        ),
       ],
      ),
     ),
     Row(
      children: [
       widget.data.viewReply? TextButton(onPressed: () async {
        await widget.manager.loadComments(4);
        widget.notifyParent();
        setState((){});
       },
           child: Text("View More Replies", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold,fontSize: 12),))
           : SizedBox.shrink()
      ],
     )
    ],
   );
  }
}

