// account page
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:enos/widgets/settings_widget/msg_request.dart';
import 'package:enos/widgets/settings_widget/saved_users.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  bool isSelf;
  TickerTileProvider provider;
  //if uid passed in then its not self profile
  String uid;
  AccountPage({Key key, this.uid = "", this.provider}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with SingleTickerProviderStateMixin {
  //not always self
  String uid;
  UserModel user;
  String name;
  TickerTileProvider provider;
  bool watchListPublic = true;
  bool isLoading = true, watchlistLoading = true;
  bool isSelfView = true;
  bool showWatchlist = true;
  bool init = true;
  dynamic size;
  TabController _tabController;
  UserModel self;
  List<Map<String, dynamic>> settingsList;
  //tickers used to show tiles
  List<TickerTileModel> _tickers;

  bool initCalled = false, setOtherCalled = false;
  Future<void> setInit() async {
    initCalled = true;
    user = await FirebaseApi.getUser(uid);
    self = await FirebaseApi.getUser(provider.watchListUid);
    //settingsList[1]['onclick'] =
    name = user.username;
    setState(() {
      isLoading = false;
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

  Future<void> setOtherTickers() async {
    setOtherCalled = true;

    //view your own account
    // on users page
    if (viewAccountIsSelf()) {
      _tickers = provider.tickers;
      showWatchlist = true;
    } else {
      DocumentSnapshot<Map<String, dynamic>> watchList =
          await FirebaseApi.getWatchListDoc(uid);
      _tickers = [];
      showWatchlist = watchList.get("is_public");
      if (showWatchlist) {
        _tickers = await TickerTileProvider.getOtherTickers(uid);
        for (int i = 0; i < _tickers.length; ++i) {
          if (provider.symbols.contains(_tickers[i].symbol)) {
            _tickers[i].isSaved = true;
            continue;
          }
          _tickers[i].isSaved = false;
        }
      }
    }

    if (!mounted) return;
    setState(() {
      watchlistLoading = false;
    });
  }

  Widget build(BuildContext context) {
    print("building");
    size = MediaQuery.of(context).size;
    //viewing own accounts page
    if (widget.uid.isEmpty) {
      provider = Provider.of<TickerTileProvider>(context, listen: false);
      uid = Provider.of<UserField>(context, listen: false).userUid;
      _tickers = provider.tickers;

      watchlistLoading = false;
    }
    //view other users watchlist
    if (!setOtherCalled && widget.uid.isNotEmpty) {
      provider = widget.provider;
      uid = widget.uid;
      isSelfView = false;
      setOtherTickers();
    }
    if (!initCalled) {
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

  bool viewAccountIsSelf() {
    return Provider.of<UserField>(context, listen: false).userUid == uid;
  }

  Widget topProfile() {
    ValueNotifier<bool> toggleTopProfile = ValueNotifier(false);
    return ValueListenableBuilder(
      valueListenable: toggleTopProfile,
      builder: (context, value, child) => Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        color: kLightBackgroundColor,
        width: size.width,
        height: size.height * 0.20,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 25, 0, 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Utils.stringToColor(user.profileBorderColor),
                radius: 29,
                child: CircleAvatar(
                    radius: 28,
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
                padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
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
                                fontSize: 28,
                                color: kDisabledColor,
                                fontWeight: FontWeight.bold)),
                        TextSpan(
                          text: viewAccountIsSelf()
                              ? "${Utils.getTimeFromToday(user.createdTime)} (You)"
                              : "${Utils.getTimeFromToday(user.createdTime)}",
                          style: TextStyle(
                              color: kDisabledColor,
                              fontSize: 19,
                              fontWeight: FontWeight.w400),
                        ),
                      ]),
                ),
              ),
              isSelfView
                  ? Container(
                      height: 0,
                    )
                  : Padding(
                      padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
                      child: IconButton(
                          onPressed: () {
                            //removing
                            if (self.userSaved.contains(uid)) {
                              Utils.showAlertDialog(context,
                                  "Are you sure you want to remove @${name}?",
                                  () {
                                Navigator.pop(
                                  context,
                                );
                              }, () {
                                self.userSaved
                                    .removeAt(self.userSaved.indexOf(uid));
                                FirebaseApi.updateUserData(self);
                                toggleTopProfile.value =
                                    !toggleTopProfile.value;
                                Navigator.pop(context);
                              });

                              // user.userSaved
                              //     .removeAt(user.userSaved.indexOf(searchTile.uid));
                              // searchTile.isSaved = false;
                              // FirebaseApi.updateUserData(user);
                              // toggleSave.value = !toggleSave.value;
                            } else {
                              if (self.userSaved.length > 15) {
                                Utils.showAlertDialog(context,
                                    "You have reached your limit of 15 people added.",
                                    () {
                                  Navigator.pop(context);
                                }, null);
                              } else {
                                self.userSaved.add(uid);

                                FirebaseApi.updateUserData(self);
                                toggleTopProfile.value =
                                    !toggleTopProfile.value;
                              }
                            }
                          },
                          icon: self.userSaved.contains(uid)
                              ? Icon(
                                  Icons.bookmark_outlined,
                                  color: kDisabledColor,
                                  size: 32,
                                )
                              : Icon(
                                  Icons.bookmark_border_outlined,
                                  color: kDisabledColor,
                                  size: 32,
                                )),
                    ),
              //self view on account page
              isSelfView
                  ? Container(
                      height: 0,
                    )
                  : Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.pop(context, {"new_user": self});
                                  },
                                  icon: Icon(
                                    Icons.cancel_outlined,
                                    size: 32,
                                    color: Utils.lighten(
                                        kLightBackgroundColor, 0.25),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomSect() {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: isSelfView ? 15 : 0, horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: Container(
          height: size.height * 0.8,
          child: isSelfView ? selfViewAccount() : watchlist(),
        ),
      ),
    );
  }

  Widget selfViewAccount() {
    return Scaffold(
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

  Widget requestWatchlist() {
    ValueNotifier<bool> toggleRequestBtn = ValueNotifier(false);
    String btnTxt = "Request View";
    Color btnColor = kActiveColor;
    return ValueListenableBuilder(
      valueListenable: toggleRequestBtn,
      builder: (context, value, child) => Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$name turned on privacy mode",
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(color: kDisabledColor, fontSize: 15),
              ),
              SizedBox(
                height: 4,
              ),
              TextButton(
                  onPressed: () {
                    btnColor = kDisabledColor;
                    btnTxt = "Submitted";
                    toggleRequestBtn.value = !toggleRequestBtn.value;
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        btnTxt,
                        style: TextStyle(color: kDarkTextColor),
                      ),
                      color: btnColor,
                    ),
                  ))
            ]),
      ),
    );
  }

  Widget watchlist() {
    if (watchlistLoading) {
      return Loading();
    }

    if (!showWatchlist) {
      return requestWatchlist();
    }

    if (_tickers.isEmpty) {
      return Center(
        child: Text(
          isSelfView
              ? "No tickers in your watchlist"
              : "No tickers in $name's watchlist",
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
              if (!isSelfView)
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  margin: EdgeInsets.zero,
                  child: Text(
                    "Updated ${Utils.getTimeFromToday(provider.lastUpdatedTime)}",
                    style: TextStyle(
                        color: kDisabledColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w400),
                  ),
                );
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
              onTap: (() => _showInfo(tickerIndex, _tickers[tickerIndex].symbol,
                  _tickers[tickerIndex].isSaved)),
              tileColor: kLightBackgroundColor,
              title: Text(
                _tickers[tickerIndex].symbol,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: kBrightTextColor,
                    fontSize: 21,
                    fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                _tickers[tickerIndex].companyName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: kDisabledColor),
              ),
              trailing: IconButton(
                  onPressed: () {
                    TickerTileModel ticker = _tickers[tickerIndex];
                    if (!_tickers[tickerIndex].isSaved) {
                      _tickers[tickerIndex].isSaved = true;

                      provider.addTicker(
                        ticker.symbol,
                      );
                      toggleStar.value = !toggleStar.value;
                    } else if (!provider.isLoading) {
                      Utils.showAlertDialog(context,
                          "Are you sure you want to remove ${ticker.symbol} from your watchlist?",
                          () {
                        Navigator.pop(context);
                      }, () {
                        _tickers[tickerIndex].isSaved = false;
                        _tickers.remove(_tickers[tickerIndex]);
                        provider.removeTicker(
                            provider.symbols.indexOf(ticker.symbol));

                        toggleStar.value = !toggleStar.value;
                        Navigator.pop(context);
                      });
                      // _tickers[tickerIndex].isSaved = false;
                      // provider.removeTicker(
                      //     provider.symbols.indexOf(ticker.symbol));

                      // toggleStar.value = !toggleStar.value;
                    }
                  },
                  icon: _tickers[tickerIndex].isSaved
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
          itemCount: _tickers.length + 1),
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

    setState(() {
      if (response['isSaved'] != isSaved) {
        // if (response['isSaved']) {
        //   provider.addTicker(symbol, context: context);
        //   return;
        // }

        provider.removeTicker(provider.symbols.indexOf(symbol));
      }
    });
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
