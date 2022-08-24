import 'package:enos/services/util.dart';

class CommentField {
  static const createdTime = 'createdTime';
}

class Comment {
  String commentUid;
  String parentUid;
  final String stockUid;
  final String userUid;
  final DateTime createdTime;
  final String content;
  int likes;
  List<dynamic> replies;
  final bool isNested;
  bool apiComment;
  bool viewReply;
  String userName;
  String replyUser;
  Comment(
      {this.commentUid,
      this.stockUid,
      this.userUid,
      this.createdTime,
      this.content,
      this.likes = 0,
      this.replies,
      this.isNested,
      this.apiComment,
      this.viewReply = false,
      this.userName = "",
      parentUid});

  static Comment fromJson(Map<String, dynamic> json) {
    //print(json['parentUid']);
    return Comment(
      commentUid: json['comment_uid'],
      stockUid: json['stock_uid'],
      userUid: json['user_uid'],
      createdTime: Utils.toDateTime(json['created_time']),
      content: json['content'],
      likes: json['likes'],
      replies: json['replies'],
      isNested: json['isNested'],
      apiComment: json['apiComment'],
      userName: json['userName'],
      parentUid: json['parentUid'].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'comment_uid': commentUid,
        'stock_uid': stockUid,
        'user_uid': userUid,
        'created_time': Utils.fromDateTimeToJson(createdTime),
        'content': content,
        'likes': likes,
        'replies': replies,
        'isNested': isNested,
        'apiComment': apiComment,
        'userName': userName,
        'parentUid': parentUid
      };
  @override
  String toString() {
    return 'Comment{commentUid: $commentUid, stockUid: $stockUid, userUid: $userUid, createdTime: $createdTime, content: $content, likes: $likes, replies: $replies, isNested: $isNested, apiComment: $apiComment, parentUid: $parentUid}';
  }
}
