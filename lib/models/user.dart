import 'package:enos/services/util.dart';

class UserModelField {
  static const createdTime = 'createdTime';
}

class UserModel {
  final String userUid;

  final DateTime createdTime;
  final String profilePic;
  final String username;
  final bool isEmailNotify;
  final List<bool> metrics;
  final String watchListUid;

  UserModel(
      {this.userUid,
      this.createdTime,
      this.profilePic,
      this.username,
      this.isEmailNotify = true,
      this.metrics,
      this.watchListUid});

  static UserModel fromJson(Map<String, dynamic> json) => UserModel(
        userUid: json['user_uid'],
        createdTime: toDateTime(json['created_time']),
        profilePic: json['profile_pic'],
        username: json['username'],
        isEmailNotify: json['is_email_notify'],
        metrics: json['metrics'],
        watchListUid: json['watchlist_uid'],
      );

  Map<String, dynamic> toJson() => {
        'user_uid': userUid,
        'created_time': fromDateTimeToJson(createdTime),
        'profile_pic': profilePic,
        'username': username,
        'is_email_notify': isEmailNotify,
        'metrics': metrics,
        'watchlist_uid': watchListUid,
      };
}
