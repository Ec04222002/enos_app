import 'package:comment_tree/widgets/comment_tree_widget.dart';
import 'package:comment_tree/widgets/tree_theme_data.dart';
import 'package:enos/constants.dart';
import 'package:enos/models/comment.dart';
import 'package:enos/models/user.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/util.dart';
import 'package:enos/widgets/comment_box.dart';
import 'package:enos/widgets/profile_pic.dart';import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentManager extends StatefulWidget {
  Comment root;
  List<Comment> visibleReplies=[];
  String time;
  CommentTreeWidget<Comment,Comment> tree;
  String userId;
  UserModel user;
  ProfilePicture userProfilePic;
  Color rootColor1, rootColor2;
  Image rootProfilePic;
  Map<String,Color> color1, color2;
  Map<String,Image> profilePic;
  CommentManager({this.root,this.user, this.rootColor1, this.rootColor2, this.rootProfilePic, this.userProfilePic}) {
    color1 = {root.userUid :rootColor1};
    color2 = {root.userUid :rootColor2};
    profilePic = {};
    if(rootProfilePic != null) {
      profilePic[root.userUid] = rootProfilePic;
    }
    if(root.replies.length > 0)
      root.viewReply = true;
    Duration diff = DateTime.now().difference(root.createdTime);
    if(diff.inMinutes < 1) {
      time = "${diff.inSeconds} seconds ago";
    } else if(diff.inHours < 1) {
      time = "${diff.inMinutes} minutes ago";
    } else if(diff.inDays < 1){
      time = "${diff.inHours} hours ago";
    } else {
      time = "${diff.inDays} days ago";
    }


    if(root.apiComment == null) {
      root.apiComment = true;
      FirebaseApi.updateComment(root);
    }
  }

  // void initUser() async{
  //
  // }


  void loadComments(int amt) async{
    root.viewReply = false;
    int pos = visibleReplies.length;
    if(pos != 0) {
      visibleReplies[pos-1].viewReply = false;
    }
    if(pos < root.replies.length) {
      for(int i = 0; i < amt && pos < root.replies.length; i++, pos++) {
        Comment com = await FirebaseApi.getComment(root.replies[pos]);
        visibleReplies.add(com);
        UserModel user2;
        Color c1, c2;
        Image p;
        if(!com.apiComment) {
          user2 = await FirebaseApi.getUser(com.userUid);
          c1 = Utils.stringToColor(user2.profileBgColor);
          c2 = Utils.stringToColor(user2.profileBgColor);
          if(user.profilePic != null) {
            p = Image.network(user2.profilePic);
          }
        } else {
          c1 = Utils.stringToColor(ProfilePicture.getRandomColor());
          c2 = Utils.stringToColor(ProfilePicture.getRandomColor());
        }
        if(!color1.containsKey(com.userUid))
          color1[com.userUid] = c1;
        if(!color2.containsKey(com.userUid))
          color2[com.userUid] = c2;
        if(!profilePic.containsKey(com.userUid))
          profilePic[com.userUid] = p;

      }
    }

    if(pos != root.replies.length) {
      visibleReplies[pos-1].viewReply = true;
    }
  }

  @override
  State<StatefulWidget> createState() => _CommentManagerState();
}

class _CommentManagerState extends State<CommentManager> {  @override

  void refresh() {
    setState((){});
  }

  Widget build(BuildContext context) {
    return  Container(
      child: CommentTreeWidget<Comment, Comment>(
        widget.root, widget.visibleReplies,
        treeThemeData:
        TreeThemeData(lineColor: Colors.green[500], lineWidth: 0),
        avatarRoot: (context, data) => PreferredSize(
            child: widget.rootProfilePic != null? ProfilePicture(name: data.userUid, image: widget.rootProfilePic, color1: widget.rootColor1, color2: widget.rootColor2,)
                : ProfilePicture(name: data.userUid, color1: widget.rootColor1, color2: widget.rootColor2,),
          preferredSize: Size.fromRadius(18),
        ),
        avatarChild: (context, data) => PreferredSize(
          child: widget.profilePic[data.userUid] != null? ProfilePicture(name: data.userUid, image: widget.profilePic[data.userUid],color1: widget.color1[data.userUid],color2: widget.color2[data.userUid],)
          : ProfilePicture(name: data.userUid, color1: widget.color1[data.userUid],color2: widget.color2[data.userUid],),
          preferredSize: Size.fromRadius(18),
        ),
        contentChild: (context, data) {
          return CommentBox(data: data,context: context,manager: widget,notifyParent: refresh,);
        },
        contentRoot: (context, data) {
          return CommentBox(data: data,context: context,manager: widget,notifyParent: refresh,);
        },
      ),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }
}


class CommentSection extends StatefulWidget {
  List<CommentManager> comments;
    String userId;
    CommentSection(List<Comment> com, String userId) {
      comments = [];
      loadComments(userId, com);
    }

    void loadComments(String userId, List<Comment> com) async {
      UserModel user = await FirebaseApi.getUser(userId);
      Image img = null;
      if(user.profilePic != null) {
        img = Image.network(user.profilePic);
      }
      ProfilePicture pic = ProfilePicture(name: user.userUid, image: img,
        color1: Utils.stringToColor(user.profileBgColor), color2: Utils.stringToColor(user.profileBorderColor),
      width: 25, height: 25, fontSize: 15,);
      com.forEach((element) async {
        Color color1, color2;
        Image profilePic = null;
        if(!element.apiComment) {
          UserModel user2 = await FirebaseApi.getUser(element.userUid);
          color1 = Utils.stringToColor(user2.profileBgColor);
          color2 = Utils.stringToColor(user2.profileBorderColor);
          if(user.profilePic != null) {
            profilePic = Image.network(user2.profilePic);
          }
        } else {
          color1 = Utils.stringToColor(ProfilePicture.getRandomColor());
          color2 = Utils.stringToColor(ProfilePicture.getRandomColor());
        }
        comments.add(CommentManager(root: element, userProfilePic: pic, user: user,rootColor1: color1,rootColor2: color2,rootProfilePic: profilePic,));
      });
    }
  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  @override


  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.comments.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext c, index) {
          return widget.comments[index];
        }
    );
  }
}


