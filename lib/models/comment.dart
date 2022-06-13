import 'package:enos/services/util.dart';

class CommentField {
  static const createdTime = 'createdTime';
}

class Comment {
  final String commentUid;
  final String stockUid;
  final String userUid;
  final DateTime createdTime;
  final String content;
  final int likes;
  final List<String> replies;

  Comment({
    this.commentUid,
    this.stockUid,
    this.userUid,
    this.createdTime,
    this.content,
    this.likes = 0,
    this.replies,
  });

  static Comment fromJson(Map<String, dynamic> json) => Comment(
      commentUid: json['comment_uid'],
      stockUid: json['stock_uid'],
      userUid: json['user_uid'],
      createdTime: Utils.toDateTime(json['created_time']),
      content: json['content'],
      likes: json['likes'],
      replies: json['replies']);

  Map<String, dynamic> toJson() => {
        'comment_uid': commentUid,
        'stock_uid': stockUid,
        'user_uid': userUid,
        'created_time': Utils.fromDateTimeToJson(createdTime),
        'content': content,
        'likes': likes,
        'replies': replies,
      };
}
