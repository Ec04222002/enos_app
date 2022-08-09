import 'package:enos/constants.dart';
import 'package:enos/models/user.dart';
import 'package:enos/models/user_tile.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/services/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavedUsers extends StatelessWidget {
  const SavedUsers({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        iconSize: 22,
        // onPressed: () {
        //   openSavedUsersPage(context);
        // },
        icon: Icon(
          Icons.arrow_forward_ios_outlined,
          color: kDarkTextColor,
        ));
  }

  static openSavedUsersPage(BuildContext context) async {
    TickerTileProvider provider =
        Provider.of<TickerTileProvider>(context, listen: false);
    UserModel user = await FirebaseApi.getUser(provider.watchListUid);
    print(user.userSaved);
    List<String> savedUserId = user.userSaved;
    List<UserSearchTile> userTiles = [];
    ValueNotifier<bool> toggleSave = ValueNotifier(false);
    for (int i = 0; i < savedUserId.length; ++i) {
      UserModel userModel = await FirebaseApi.getUser(savedUserId[i]);
      UserSearchTile userSearchTile =
          UserSearchTile.modelToSearchTile(userModel);
      userSearchTile.isSaved = true;
      userTiles.add(userSearchTile);
    }
    print(savedUserId.length);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Scaffold(
                  appBar: AppBar(
                      backgroundColor: kLightBackgroundColor,
                      centerTitle: true,
                      title: Text(
                        "Saved Users",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      leading: IconButton(
                        color: kDarkTextColor.withOpacity(0.9),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back_ios),
                      )),
                  body: ValueListenableBuilder(
                    valueListenable: toggleSave,
                    builder: (context, value, child) => ListView.separated(
                      itemCount: savedUserId.length,
                      itemBuilder: (context, index) {
                        UserSearchTile userTile = userTiles[index];

                        return ListTile(
                            tileColor: kLightBackgroundColor,
                            leading: userTile.leadWidget,
                            title: Text(
                              "@" + userTile.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: kBrightTextColor,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800),
                            ),
                            trailing: IconButton(
                                onPressed: () {
                                  if (userTile.isSaved) {
                                    // Utils.showAlertDialog(context,
                                    //     "Are you sure you want to remove @${userTile.userName}?",
                                    //     () {
                                    //   Navigator.pop(context);
                                    // }, () {
                                    //   savedUserId.removeAt(
                                    //       savedUserId.indexOf(userTile.uid));
                                    //   user.userSaved = savedUserId;
                                    //   userTile.isSaved = false;
                                    //   FirebaseApi.updateUserData(user);
                                    //   toggleSave.value = !toggleSave.value;
                                    //   Navigator.pop(context);
                                    // });
                                    savedUserId.removeAt(
                                        savedUserId.indexOf(userTile.uid));
                                    user.userSaved = savedUserId;
                                    userTile.isSaved = false;
                                    FirebaseApi.updateUserData(user);
                                    toggleSave.value = !toggleSave.value;
                                  } else {
                                    if (user.userSaved.length > 15) {
                                      Utils.showAlertDialog(context,
                                          "You have reached your limit of 15 people added.",
                                          () {
                                        Navigator.pop(context);
                                      }, null);
                                    } else {
                                      savedUserId.add(userTile.uid);
                                      user.userSaved = savedUserId;
                                      userTile.isSaved = true;
                                      FirebaseApi.updateUserData(user);
                                      toggleSave.value = !toggleSave.value;
                                    }
                                  }
                                  // UserModel newUserModel = recommends[index];
                                  // newUserModel.userSaved = user.userSaved;
                                },
                                icon: userTile.isSaved
                                    ? Icon(
                                        Icons.bookmark_outlined,
                                        color: kDisabledColor,
                                        size: 35,
                                      )
                                    : Icon(
                                        Icons.bookmark_border,
                                        color: kDisabledColor,
                                        size: 35,
                                      )));
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 8,
                        );
                      },
                    ),
                  ),
                )));
  }
}