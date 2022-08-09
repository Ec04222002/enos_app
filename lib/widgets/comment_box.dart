
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
  String time;
  CommentBox({this.context,this.data, this.manager, @required this.notifyParent}) {
    Duration diff = DateTime.now().difference(data.createdTime);
    if (diff.inMinutes < 1) {
      time = "${diff.inSeconds} seconds ago";
    } else if (diff.inHours < 1) {
      time = "${diff.inMinutes} minutes ago";
    } else if (diff.inDays < 1) {
      time = "${diff.inHours} hours ago";
    } else {
      time = "${diff.inDays} days ago";
    }
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
            widget.data.userName.length <= 15? '${widget.data.userName}': '${widget.data.userName.substring(0,15)}...',
            style: Theme.of(context).textTheme.caption.copyWith(
                fontWeight: FontWeight.w600, color: Colors.white),
           ),
           SizedBox(width: 5,),
           Text(
            '${widget.time}',
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
              width: 90,
              color: kLightBackgroundColor,
 //             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                onChanged: (String s) {
                  setState((){});
                },
                onEditingComplete : () async {
                },
                style: TextStyle(fontSize: 11, color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Add a comment...",
                  hintStyle: TextStyle(color: Colors.grey)
                ),
               ),
            ),
             Container(
               width: 46,
               height: 40,
               child: TextButton(
                 onPressed: () async{
                   if(_controller.text != "") {
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
                         userName: user.username
                     );

                     String id = await FirebaseApi.updateComment(com);
                     widget.manager.root.replies.add(id);
                     await FirebaseApi.updateComment(widget.manager.root);
                     await widget.manager.loadComments(1);
                     user.comments.add(id);
                     await FirebaseApi.updateUserData(user);
                     _controller.clear();
                     widget.notifyParent();
                     setState((){});
                   }
                 },
                 child: Text(
                   "Submit",
                   style: TextStyle(color: _controller.text == ""? kDisabledColor : kActiveColor,fontSize: 9),
                 ),
               ),
             ),
            IconButton(
                onPressed: () async {
              UserModel user = widget.manager.user;
              if(user.likedComments.contains(widget.data.commentUid)) {
                user.likedComments.remove(widget.data.commentUid);
                widget.data.likes--;
              } else {
                user.likedComments.add(widget.data.commentUid);
                widget.data.likes++;
              }
              await FirebaseApi.updateUserData(user);
              await FirebaseApi.updateComment(widget.data);
              widget.notifyParent();
            },
                icon: Icon(Icons.thumb_up,size: 15,) ,color: widget.manager.user.likedComments == null ||  widget.manager.user.likedComments.contains(widget.data.commentUid)?Colors.blue:Colors.white),
            Text("${widget.data.likes}", style: TextStyle(fontSize: 9),),
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

