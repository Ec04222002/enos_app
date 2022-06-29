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
  final bool isEmailNotify;
  final List<bool> metrics;
  List<String> userSaved;

  UserModel(
      {this.userUid,
      this.createdTime,
      this.profilePic,
      this.username,
      this.isEmailNotify = true,
      this.metrics,
      this.userSaved});
  static UserModel fromJson(Map<String, dynamic> json) {
    List<bool> metrics = [];
    json['metrics'].forEach((metric) {
      metrics.add(metrics.toString() == "true");
    });
    List<String> userSaved = [];
    json['user_saved'].forEach((user) {
      userSaved.add(user.toString());
    });
    return UserModel(
        userUid: json['user_uid'],
        createdTime: Utils.toDateTime(json['created_time']),
        profilePic: json['profile_pic'],
        username: json['username'],
        isEmailNotify: json['is_email_notify'],
        metrics: metrics,
        userSaved: userSaved);
  }

  Map<String, dynamic> toJson() => {
        'user_uid': userUid,
        'created_time': Utils.fromDateTimeToJson(createdTime),
        'profile_pic': profilePic,
        'username': username,
        'is_email_notify': isEmailNotify,
        'metrics': metrics,
        'user_saved': userSaved,
      };
}
