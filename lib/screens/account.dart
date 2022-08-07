// account page
import 'package:enos/constants.dart';
import 'package:enos/models/user.dart';
import 'package:enos/services/auth.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/util.dart';
import 'package:enos/widgets/loading.dart';
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
  Future<void> setUser() async {
    print('set user');
    user = await FirebaseApi.getUser(uid);
    name = user.username;
    setState(() {
      isLoading = false;
    });
    init = false;
    print(user.createdTime);
  }

  @override
  void initState() {
    init = true;
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    uid = Provider.of<UserField>(context, listen: false).userUid;
    if (init) {
      setUser();
    }
    return isLoading
        ? Loading()
        : Scaffold(
            body: SingleChildScrollView(
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
        padding: const EdgeInsets.all(13.0),
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
                          fontSize: 25),
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
                        fontSize: 27),
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
                        child: Text("Watchlist"),
                      ),
                      Tab(
                        child: Text("Settings"),
                      )
                    ],
                  )
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [Text("Watchlist"), Text('Settings')],
            ),
          ),
        ),
      ),
    );
  }

  Widget logOutBtn() => ElevatedButton(
      child: Text("Log out"),
      onPressed: () async {
        if (context.read<GoogleSignInProvider>().user != null) {
          context.read<GoogleSignInProvider>().googleLogOut();
        }
        context.read<AuthService>().signOut();
      });
}
