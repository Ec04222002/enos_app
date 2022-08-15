import 'package:enos/services/util.dart';

class UserField {
  final String userUid;

  UserField({this.userUid});
}

class UserModel {
  final String userUid;
  final DateTime createdTime;
  final String profilePic;
  final String username;
  List<bool> metrics;
  List<String> userSaved;
  List<String> comments;
  List<String> likedComments;
  final String profileBgColor;
  final String profileBorderColor;
  final String email;
  UserModel(
      {this.userUid,
      this.email,
      this.createdTime,
      this.profilePic,
      this.username,
      this.comments,
      this.likedComments,
      this.metrics,
      this.userSaved,
      this.profileBgColor,
      this.profileBorderColor});
  static UserModel fromJson(Map<String, dynamic> json) {
    List<bool> metrics = [];
    json['metrics'].forEach((metric) {
      metrics.add(metric.toString() == "true");
    });
    List<String> userSaved = [];
    json['user_saved'].forEach((user) {
      userSaved.add(user.toString());
    });

    List<String> comments = [];
    json['comments'].forEach((comment) {
      comments.add(comment.toString());
    });
    List<String> likedComments = [];
    json['liked_comments'].forEach((comment) {
      likedComments.add(comment.toString());
    });

    return UserModel(
      email: json['email'],
      comments: comments,
      likedComments: likedComments,
      userUid: json['user_uid'],
      createdTime: Utils.toDateTime(json['created_time']),
      profilePic: json['profile_pic'],
      username: json['username'],
      metrics: metrics,
      userSaved: userSaved,
      profileBgColor: json['profile_bg_color'],
      profileBorderColor: json['profile_border_color'],
    );
  }

  Map<String, dynamic> toJson() => {
        "email": email,
        'user_uid': userUid,
        'created_time': Utils.fromDateTimeToJson(createdTime),
        'profile_pic': profilePic,
        'username': username,
        'comments': comments,
        'liked_comments': likedComments,
        'metrics': metrics,
        'user_saved': userSaved,
        'profile_bg_color': profileBgColor,
        'profile_border_color': profileBorderColor,
      };
}
