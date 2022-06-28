import 'package:enos/models/user.dart';
import 'package:enos/services/util.dart';
import 'package:flutter/cupertino.dart';

class UserSearchTile {
  final String userName;
  final leadWidget;
  final String uid;
  bool isSaved;
  UserSearchTile(
      {this.userName, this.leadWidget, this.uid, this.isSaved = false});

  static UserSearchTile modelToSearchTile(UserModel model) {
    String userName = model.username;
    String searchUserName = userName.substring(0, userName.indexOf('@'));
    if (searchUserName.length > 6) {
      searchUserName = searchUserName.substring(0, 6);
    }

    var leadWidget;
    if (model.profilePic != null) {
      leadWidget = Container();
    } else {
      leadWidget = Utils.createProfilePicWidget(searchUserName);
    }
    return UserSearchTile(
      userName: searchUserName,
      leadWidget: leadWidget,
      uid: model.userUid,
    );
  }
}
