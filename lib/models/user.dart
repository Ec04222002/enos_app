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
  final List<String> userSaved;

  UserModel(
      {this.userUid,
      this.createdTime,
      this.profilePic,
      this.username,
      this.isEmailNotify = true,
      this.metrics,
      this.userSaved});
  static UserModel fromJson(Map<String, dynamic> json) => UserModel(
      userUid: json['user_uid'],
      createdTime: Utils.toDateTime(json['created_time']),
      profilePic: json['profile_pic'],
      username: json['username'],
      isEmailNotify: json['is_email_notify'],
      metrics: json['metrics'],
      userSaved: json['user_saved']);

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
