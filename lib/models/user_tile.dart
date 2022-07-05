import 'package:enos/models/user.dart';
import 'package:enos/services/util.dart';
import 'package:enos/widgets/profile_pic.dart';
import 'package:flutter/cupertino.dart';

class UserSearchTile {
  final String userName;
  final leadWidget;
  final String uid;
  bool isSaved;
  UserSearchTile(
      {this.userName, this.leadWidget, this.uid, this.isSaved = false});

  static UserSearchTile modelToSearchTile(UserModel model) {
    String searchUserName = model.username;
    if (searchUserName.length > 10) {
      searchUserName = searchUserName.substring(0, 10);
    }

    // var leadWidget = model.profilePic != null
    //     ? ProfilePicture(image: model.profilePic, name: searchUserName)
    //     : ProfilePicture(image: null, name: searchUserName);
    var leadWidget = ProfilePicture(
      image: null,
      name: searchUserName,
      color1: Utils.stringToColor(model.profileBgColor),
      color2: Utils.stringToColor(model.profileBorderColor),
    );
    return UserSearchTile(
      userName: searchUserName,
      leadWidget: leadWidget,
      uid: model.userUid,
    );
  }
}
