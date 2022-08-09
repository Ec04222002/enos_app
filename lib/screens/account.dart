// account page
import 'package:enos/constants.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:enos/models/user.dart';
import 'package:enos/models/user_tile.dart';
import 'package:enos/models/watchlist.dart';
import 'package:enos/screens/ticker_info.dart';
import 'package:enos/services/auth.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/services/util.dart';
import 'package:enos/widgets/loading.dart';
import 'package:enos/widgets/settings_widget/comments_replies.dart';
import 'package:enos/widgets/settings_widget/edit_profile.dart';
import 'package:enos/widgets/settings_widget/email_notify.dart';
import 'package:enos/widgets/settings_widget/msg_request.dart';
import 'package:enos/widgets/settings_widget/saved_users.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with SingleTickerProviderStateMixin {
  String uid;
  UserModel user;
  String name;
  bool isLoading = true;
  bool init = true;
  dynamic size;
  TabController _tabController;
  TickerTileProvider provider;
  List<Map<String, dynamic>> settingsList;

  Future<void> setInit() async {
    user = await FirebaseApi.getUser(uid);

    //settingsList[1]['onclick'] =
    name = user.username;
    setState(() {
      isLoading = false;
      init = false;
    });
  }

  @override
  void initState() {
    settingsList = [
      {
        "icon": Icons.bookmark_border,
        "title": "Saved Users",
        "trail": SavedUsers(),
        'onclick': openSavedUser,
      },
      {
        "icon": Icons.comment_outlined,
        "title": "Comments and Replies",
        "trail": CommentReply(),
      },
      {
        "icon": Icons.email_outlined,
        "title": "Email Notification",
        "trail": Container(
          height: 0,
          width: 0,
        )
      },
      {
        "icon": Icons.messenger_outline,
        "title": "Message Request",
        "trail": MessageRequest()
      },
      {
        "icon": Icons.edit_outlined,
        "title": "Edit Profile",
        "trail": EditProfile()
      },
      {
        "icon": Icons.logout_outlined,
        "title": "Logout",
        "trail": Container(
          height: 0,
          width: 0,
        ),
        "onclick": logout,
      },
      {
        "icon": Icons.delete_outline,
        "title": "Delete Account",
        "trail": Container(
          height: 0,
          width: 0,
        ),
        "onclick": deleteAccount
      },
    ];
    init = true;
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    provider = Provider.of<TickerTileProvider>(context, listen: false);
    uid = Provider.of<UserField>(context, listen: false).userUid;

    if (init) {
      setInit();
    }
    return isLoading
        ? Loading()
        : Scaffold(
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(
                child: Column(children: [topProfile(), bottomSect()]),
              ),
            ),
          );
  }

  Widget topProfile() {
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      color: kLightBackgroundColor,
      width: size.width,
      height: size.height * 0.20,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Utils.stringToColor(user.profileBorderColor),
              radius: 30,
              child: CircleAvatar(
                  radius: 29,
                  backgroundColor: Utils.stringToColor(user.profileBgColor),
                  child: Center(
                    child: Text(
                      name.substring(0, 1).toUpperCase() +
                          (name.length > 1 ? name.substring(1, 2) : ""),
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 27),
                    ),
                  )),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(13, 0, 0, 5),
              child: RichText(
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 2,
                text: TextSpan(
                    text: name,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 26),
                    children: [
                      TextSpan(
                          text: "\t·\t",
                          style: TextStyle(
                              fontSize: 30,
                              color: kDisabledColor,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                        text: "${Utils.getTimeFromToday(user.createdTime)}",
                        style: TextStyle(
                            color: kDisabledColor,
                            fontSize: 21,
                            fontWeight: FontWeight.w400),
                      )
                    ]),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget bottomSect() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: Container(
          height: size.height * 0.8,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              backgroundColor: kLightBackgroundColor,
              toolbarHeight: 25,
              leading: Container(height: 0),
              flexibleSpace: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TabBar(
                    controller: _tabController,
                    labelPadding: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    indicator: BoxDecoration(
                        // Creates border
                        color: kActiveColor),
                    tabs: [
                      Tab(
                        child: Text(
                          "Watchlist",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Settings",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [watchlist(), setting()],
            ),
          ),
        ),
      ),
    );
  }

  Widget setting() {
    return ListView.separated(
        padding: EdgeInsets.only(top: 8),
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          String title = settingsList[index]['title'];
          IconData icon = settingsList[index]['icon'];
          Widget trail = settingsList[index]['trail'];

          if (title == "Email Notification") {
            return SwitchListTile(
              tileColor: kLightBackgroundColor,
              inactiveTrackColor: kDisabledColor,
              activeTrackColor: kActiveColor,
              inactiveThumbColor: kDarkTextColor,
              activeColor: kDarkTextColor,
              value: user.isEmailNotify,
              onChanged: (value) {
                setState(() {
                  user.isEmailNotify = !user.isEmailNotify;
                  FirebaseApi.updateUserData(user);
                });
              },
              title: Text(
                title,
                style: TextStyle(color: kBrightTextColor),
              ),
              secondary: Icon(
                icon,
                color: kDisabledColor,
                size: 28,
              ),
            );
          }
          return ListTile(
            onTap: settingsList[index]['onclick'],
            leading: Icon(
              icon,
              color: kDisabledColor,
              size: 28,
            ),
            title: Text(
              title,
              style: TextStyle(color: kBrightTextColor),
            ),
            trailing: trail,
            tileColor: kLightBackgroundColor,
          );
        },
        separatorBuilder: (context, index) {
          String title = settingsList[index]['title'];
          if (title == "Message Request" || title == "Logout") {
            return SizedBox(
              height: 8,
            );
          }
          return SizedBox(
            height: 0,
          );
          // return Divider(
          //   color: kDisabledColor,
          //   height: 0,
          //   thickness: 0.1,
          // );
        },
        itemCount: settingsList.length);
  }

  ValueNotifier<bool> toggleStar = ValueNotifier(false);
  Widget watchlist() {
    List<TickerTileModel> tickers = provider.tickers;

    if (tickers.isEmpty) {
      return Center(
        child: Text(
          "No tickers in your watchlist",
          style: TextStyle(color: kDisabledColor, fontSize: 18),
        ),
      );
    }

    return ValueListenableBuilder(
      valueListenable: toggleStar,
      builder: (context, value, child) => ListView.separated(
          physics: BouncingScrollPhysics(),
          // padding: EdgeInsets.only(top: 8),
          itemBuilder: (context, index) {
            print("rebuilding");
            if (index == 0) {
              return Container(
                height: 35,
                child: SwitchListTile(
                    // enableFeedback: false,
                    inactiveTrackColor: kDisabledColor,
                    activeTrackColor: kActiveColor,
                    inactiveThumbColor: kDarkTextColor,
                    activeColor: kDarkTextColor,
                    contentPadding: EdgeInsets.zero,
                    value: provider.isPublic,
                    secondary: GestureDetector(
                        onTap: (() {}),
                        child: Container(
                            child: Text(
                              "Updated ${Utils.getTimeFromToday(provider.lastUpdatedTime)}",
                              style: TextStyle(
                                  color: kDisabledColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            margin: EdgeInsets.zero,
                            color: kDarkBackgroundColor,
                            width: size.width * 0.83)),
                    onChanged: (value) {
                      toggleWatchlist(value);
                    }),
              );
            }
            int tickerIndex = index - 1;

            return ListTile(
              onTap: (() => _showInfo(tickerIndex, tickers[tickerIndex].symbol,
                  tickers[tickerIndex].isSaved)),
              tileColor: kLightBackgroundColor,
              title: Text(
                tickers[tickerIndex].symbol,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: kBrightTextColor,
                    fontSize: 21,
                    fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                tickers[tickerIndex].companyName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: kDisabledColor),
              ),
              trailing: IconButton(
                  onPressed: () {
                    TickerTileModel ticker = tickers[tickerIndex];
                    if (!tickers[tickerIndex].isSaved) {
                      tickers[tickerIndex].isSaved = true;

                      provider.addTicker(
                        ticker.symbol,
                      );
                      toggleStar.value = !toggleStar.value;
                    } else if (!provider.isLoading) {
                      // Utils.showAlertDialog(context,
                      //     "Are you sure you want to remove ${ticker.symbol} from your watchlist?",
                      //     () {
                      //   Navigator.pop(context);
                      // }, () {
                      //   provider.removeTicker(
                      //       provider.symbols.indexOf(ticker.symbol));

                      //   toggleStar.value = !toggleStar.value;
                      //   Navigator.pop(context);
                      // });
                      tickers[tickerIndex].isSaved = false;
                      provider.removeTicker(
                          provider.symbols.indexOf(ticker.symbol));

                      toggleStar.value = !toggleStar.value;
                    }
                  },
                  icon: tickers[tickerIndex].isSaved
                      ? Icon(
                          Icons.star,
                          color: Colors.yellow[400],
                          size: 35,
                        )
                      : Icon(
                          Icons.star_border,
                          color: kDisabledColor,
                          size: 35,
                        )),
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 8,
            );
          },
          itemCount: tickers.length + 1),
    );
  }

  void _showInfo(int index, String symbol, bool isSaved) async {
    Map<String, dynamic> response = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TickerInfo(
            symbol: symbol,
            uid: provider.watchListUid,
            isSaved: isSaved,
            provider: provider,
          ),
        ));
    if (!mounted) return;

    setState(() {});
  }

  void toggleWatchlist(bool value) {
    print("toggling watchlist");
    if (value) {
      Utils.showAlertDialog(
          context, "Are you sure you want set your watchlist public?", () {
        Navigator.pop(context);
      }, () {
        setState(() {
          provider.isPublic = !provider.isPublic;
          FirebaseApi.updateWatchList(Watchlist(
              watchlistUid: provider.watchListUid,
              items: provider.symbols,
              updatedLast: DateTime.now(),
              isPublic: provider.isPublic));
        });
        Navigator.pop(context);
      });
    } else {
      setState(() {
        provider.isPublic = !provider.isPublic;
        FirebaseApi.updateWatchList(Watchlist(
            watchlistUid: provider.watchListUid,
            items: provider.symbols,
            updatedLast: DateTime.now(),
            isPublic: provider.isPublic));
      });
    }
  }

  //onlick functions;
  void logout() {
    Utils.showAlertDialog(
        context, "Are you sure you want to log out of your account?", () {
      Navigator.pop(context);
    }, () {
      if (context.read<GoogleSignInProvider>().user != null) {
        context.read<GoogleSignInProvider>().googleLogOut();
      }
      context.read<AuthService>().signOut();
      Navigator.pop(context);
    });
  }

  void deleteAccount() {
    Utils.showAlertDialog(
        context, "Are you sure you want to delete your account?", () {
      Navigator.pop(context);
    }, () {
      FirebaseApi.deleteUser(uid);
      Navigator.pop(context);
    });
  }

  void openSavedUser() {
    SavedUsers.openSavedUsersPage(context);
  }
}
