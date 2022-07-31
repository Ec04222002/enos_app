// ticker/chart page

import 'dart:math';

import 'package:enos/models/ticker_page_info.dart';
import 'package:enos/models/ticker_spec.dart';
import 'package:enos/models/user.dart';
import 'package:enos/services/auth.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/ticker_page_info.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/services/util.dart';
import 'package:enos/widgets/chart_dates_bar.dart';
import 'package:enos/widgets/line_chart.dart';
import 'package:enos/widgets/loading.dart';
import 'package:enos/widgets/pre_ticker_prices.dart';
import 'package:enos/widgets/slider.dart';
import 'package:flutter/material.dart';
import 'package:enos/constants.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class TickerInfo extends StatefulWidget {
  final String symbol;
  final bool isSaved;
  final String uid;
  final TickerTileProvider provider;
  const TickerInfo(
      {this.symbol, this.uid, this.isSaved, this.provider, Key key})
      : super(key: key);

  @override
  State<TickerInfo> createState() => _TickerInfoState();
}

class _TickerInfoState extends State<TickerInfo> {
  TickerPageInfo dataBase = TickerPageInfo();
  bool isLoading = true;
  double initBtnOpacity = 0.75, btnOpacity = 0.75;
  TickerPageModel pageData;
  double previousClose;
  String range = "1d";
  bool chartLoading = false;
  ScrollController scrollController;
  bool showBtn = true;
  bool isStream = false;
  //specs section
  List<String> specsAll = TickerSpecs.existSpecs;
  List<String> specsDisplay = [];
  List<bool> specsEdit = [];
  List<String> specsUsing = [];
  bool isEdit = false;
  List<SlidableController> controllers;
  Map specsData = {};
  final double editButtonHeight = 45;
  final double dataHeight = 47;
  final double toolBarHeight = 33;
  double lastScrollOffset;
  UserModel user;
  bool triggerNewChart = false;
  Utils util = Utils();
  //comment page

  Future<void> init() async {
    print("in init");
    if (!mounted) return;
    pageData =
        await dataBase.getModelData(widget.symbol, widget.isSaved, false, null);
    // scrollController.addListener(() {
    //   double maxScroll = scrollController.position.maxScrollExtent;
    //   double currentScroll = scrollController.position.pixels;
    //   print("maxScroll: $maxScroll");
    //   print(scrollController.position);
    //   print(scrollController.positions);
    //   double delta = 200.0; // or something else..
    //   if (maxScroll - currentScroll <= delta) {
    //     // whatever you determine here
    //     //.. load more
    //   }
    // });
    // lastData = pageData;
    //specs data
    specsData = pageData.specsData;
    user = await FirebaseApi.getUser(widget.uid);
    specsEdit = user.metrics;
    controllers = List.filled(specsAll.length, null);
    _specsDisplayUpdate();
    specsUsing = specsDisplay;
    previousClose = pageData.previousClose;
    setState(() {
      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        print("in post data loadi");
        await dataBase.addPostLoadData(pageData);
        // lastData = pageData;
        if (mounted) {
          setState(() {
            chartLoading = false;
          });
        }
      });
    });
  }

  //sync boolean list (edits) with string list on display
  void _specsDisplayUpdate() {
    this.specsDisplay = [];
    for (int i = 0; i < specsEdit.length; i++) {
      if (specsEdit[i]) {
        this.specsDisplay.add(TickerSpecs.existSpecs[i]);
      }
    }
  }

  //toggle data secion hide <-> show
  void _toggleData() {
    controllers.forEach((element) {
      isEdit ? element.openStartActionPane() : element.close();
    });
  }

  @override
  void initState() {
    super.initState();
    //get all new updates
    init();
  }

  @override
  Widget build(BuildContext bContext) {
    scrollController = ScrollController();
    return isLoading
        ? Loading(
            type: "dot",
            loadText: "Loading" " ${widget.symbol} ....",
          )
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () async {
                  print("returning");

                  // int index = widget.provider.symbols.indexOf(widget.symbol);
                  // TickerTileModel ticker = widget.provider.tickerAt(index);
                  // ticker.percentChange = pageData.percentChange;
                  // ticker.priceChange = pageData.priceChange;
                  // ticker.price = pageData.marketPrice;
                  // ticker.postPercentChange = pageData.postPercentChange;
                  // ticker.postPriceChange = pageData.postPriceChange;
                  Navigator.pop(context, {
                    // "percentChange": pageData.percentChange,
                    // "priceChange": pageData.priceChange,
                    // 'price': pageData.marketPrice,
                    // 'postPercentChange': pageData.postPercentChange,
                    // 'postPriceChange': pageData.postPriceChange,
                    'isSaved': pageData.isSaved,
                  });
                },
                color: kDarkTextColor,
                icon: Icon(Icons.arrow_back_ios),
              ),
              centerTitle: true,
              backgroundColor: kLightBackgroundColor,
              title: Text(
                //${pageInfo.shortName()} * ${tileData.price}
                "${pageData.symbol} * ${pageData.marketName}",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: kBrightTextColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w600),
                maxLines: 2,
              ),
            ),
            floatingActionButton: showBtn
                ? GestureDetector(
                    onLongPress: () {
                      if (!pageData.isCrypto) {
                        if (Utils.isWeekend()) {
                          util.showSnackBar(
                              context, "Market Closed - Weekend", false);
                          return;
                        }
                        if (Utils.isPastPostMarket()) {
                          util.showSnackBar(
                              context, "Market Closed - Past Time", false);
                          return;
                        }
                        if (!pageData.isPostMarket && (Utils.isPostMarket())) {
                          util.showSnackBar(
                              context, "Stock is not post", false);
                          return;
                        }
                      }
                      print("calling for data");
                      triggerNewChart = true;
                      util.showSnackBar(context, "Streaming Data ", true);
                      //print("in long press");
                      setState(() {
                        isStream = true;
                        btnOpacity = 0.3;
                      });
                    },
                    onLongPressEnd: (_) {
                      print("end press");
                      util.removeSnackBar();
                      setState(() {
                        isStream = false;
                        btnOpacity = initBtnOpacity;
                      });
                    },
                    onLongPressCancel: () {
                      print("cancel press");
                      setState(() {
                        isStream = false;
                        btnOpacity = initBtnOpacity;
                      });
                    },
                    onTap: () {
                      print("tap");
                      setState(() {
                        isStream = false;
                        btnOpacity = initBtnOpacity;
                      });
                    },
                    // onTapCancel: () {
                    //   print("tap cancel");
                    //   setState(() {
                    //     isStream = false;
                    //     btnOpacity = initBtnOpacity;
                    //   });
                    // },
                    onTapUp: (_) {
                      print('tap up');
                      setState(() {
                        isStream = false;
                        btnOpacity = initBtnOpacity;
                      });
                    },
                    child: FloatingActionButton(
                      child: Icon(
                        Icons.keyboard_double_arrow_up_outlined,
                        size: 50,
                        color: kDarkTextColor,
                      ),
                      backgroundColor: Utils.lighten(kLightBackgroundColor)
                          .withOpacity(btnOpacity),
                    ),
                  )
                : null,
            body: NotificationListener(
              onNotification: (scrollNotification) {
                //scrollController.offset -> only for vertical;
                //print(scrollController.offset);
                if (lastScrollOffset == null)
                  lastScrollOffset = scrollController.offset;
                if (scrollController.offset == lastScrollOffset) return false;
                print("scrolling");
                if (scrollNotification is ScrollUpdateNotification) {
                  double before = scrollController.position.extentBefore;
                  //reducing setstate calls
                  if (before > 70 && before < 100) {
                    setState(() {
                      print('set state');
                      showBtn = before < 85;
                    });
                  }
                }
                //prevent not-toggling due to quick scroll
                if (scrollNotification is ScrollEndNotification) {
                  print("scroll end");
                  setState(() {
                    showBtn = scrollController.position.extentBefore < 85;
                  });
                }
                lastScrollOffset = scrollController.offset;
                return true;
              },
              child: isStream
                  ? StreamBuilder<TickerPageModel>(
                      initialData: pageData,
                      stream: dataBase.getPageStream(
                          pageData.symbol, pageData.isSaved, pageData),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print("error: ${snapshot.error}");
                          return Center(
                              child:
                                  Text("Sorry, there seems to be an error 😔"));
                        }
                        pageData = snapshot.data;
                        return TickerPage();
                      },
                    )
                  : TickerPage(),
            ),
          );
  }

  Widget TickerPage() {
    return SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: PreTickerInfo(
                data: pageData,
                tickerProvider: widget.provider,
                isStream: isStream,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(6, 8, 6, 0),
              child: LineChartWidget(
                symbol: pageData.symbol,
                pageData: pageData,
                range: range,
                isPreview: false,
                previousClose: previousClose,
                chartLoading: chartLoading,
                triggerNewChart: triggerNewChart,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: DatesBar(onTap: (index) {
                String localRange = TickerPageInfo.chartRangeAndInt[index][0];
                // chartLoading = false;
                setState(() {
                  triggerNewChart = true;
                  range = localRange;
                  previousClose = pageData.previousClose;
                  if (pageData.priceData[localRange] == null) {
                    chartLoading = true;
                    print("loading charts");
                    return;
                  }
                  if (range != '1d') {
                    previousClose =
                        pageData.priceData[localRange]['closePrices'].first;
                  }
                });
                //return 'Success';
              }),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: Container(
                  height: editButtonHeight +
                      dataHeight * specsUsing.length +
                      toolBarHeight,
                  child: DefaultTabController(
                    length: 3,
                    child: Scaffold(
                      appBar: AppBar(
                        automaticallyImplyLeading: false,
                        titleSpacing: 0,
                        toolbarHeight: toolBarHeight,
                        backgroundColor: kLightBackgroundColor,
                        leading: Container(height: 0),
                        flexibleSpace: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TabBar(
                              labelPadding: EdgeInsets.zero,
                              padding: EdgeInsets.zero,
                              indicator: BoxDecoration(
                                  // Creates border
                                  color: kActiveColor),
                              tabs: [
                                Tab(
                                  text: "Analyze",
                                  height: 30,
                                ),
                                Tab(
                                  text: "Comment",
                                  height: 30,
                                ),
                                Tab(
                                  text: "News",
                                  height: 30,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      body: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          specSection(),
                          Text("Comment"),
                          Text("News"),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget editBtn() {
    return Container(
      height: editButtonHeight,
      child: ListTile(
        //visualDensity: VisualDensity(vertical: 0.1),
        trailing: TextButton(
          onPressed: () {
            setState(() {
              isEdit = !isEdit;
              _specsDisplayUpdate();
              specsUsing = specsDisplay;
              if (isEdit) specsUsing = specsAll;
              //done button clicked
              if (!isEdit) {
                _toggleData();
                //save to firebase
                user.metrics = specsEdit;
                FirebaseApi.updateUserData(user);
              }
              //_toggleData();
            });
          },
          child: Text(
            isEdit ? "Done" : "Edit",
            style: TextStyle(color: kActiveColor, fontSize: 15),
          ),
        ),
      ),
    );
  }

  Widget specSection() {
    Widget trailingWidget;
    dynamic specCurrentData;
    return Container(
      color: kLightBackgroundColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.start,
          children: [
            editBtn(),
            ListView.builder(
                padding: EdgeInsets.all(3),
                itemExtent: dataHeight,
                physics: NeverScrollableScrollPhysics(),
                itemCount: specsUsing.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  specCurrentData = specsData[specsUsing[index]];
                  trailingWidget = specsUsing[index].contains("Range") &&
                          specCurrentData != null
                      ? (() {
                          try {
                            Widget slider = SliderWidget(
                              value: specsData['Market Price'].toDouble(),
                              min: double.tryParse(specCurrentData[2]
                                          .replaceAll(",", "")) ==
                                      null
                                  ? specCurrentData[0]
                                  : double.tryParse(
                                      specCurrentData[2].replaceAll(",", "")),
                              max: double.parse(specCurrentData[3]
                                          .replaceAll(",", "")) ==
                                      null
                                  ? specCurrentData[1]
                                  : double.parse(
                                      specCurrentData[3].replaceAll(",", "")),
                            );
                            return slider;
                          } catch (e) {
                            return Text(
                              "__",
                              style: TextStyle(color: kBrightTextColor),
                            );
                          }
                        })()
                      : DefaultTextStyle(
                          style: TextStyle(color: kBrightTextColor),
                          child: Text(
                            (() {
                              if (specCurrentData == null) {
                                return "__";
                              } else if (specsUsing[index] == "Market Price") {
                                return pageData.marketPrice;
                              } else if (specsUsing[index] ==
                                  "Post Market Price") {
                                return pageData.postMarketPrice;
                              }
                              return specCurrentData;
                            }()),
                            style: TextStyle(color: kBrightTextColor),
                          ),
                        );
                  return Slidable(
                    enabled: false,
                    closeOnScroll: false,
                    startActionPane: ActionPane(
                        dragDismissible: false,
                        extentRatio: 0.2,
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            //padding: EdgeInsets.only(top: 0),
                            autoClose: false,
                            onPressed: ((context) {
                              setState(() {
                                int indx = specsAll.indexOf(specsUsing[index]);
                                specsEdit[indx] = !specsEdit[indx];
                              });
                            }),
                            backgroundColor: kLightBackgroundColor,
                            foregroundColor: kDarkTextColor,
                            icon: specsEdit[index]
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          )
                        ]),
                    key: UniqueKey(),
                    child: Builder(builder: (context) {
                      //set new controller only during edit mode
                      // full specs && new context
                      if (isEdit) {
                        controllers[index] = Slidable.of(context);
                        if (index == specsUsing.length - 1) {
                          print("in");
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            print("post");
                            _toggleData();
                          });
                        }
                      }

                      return ListTile(
                        enabled: false,
                        textColor: kDisabledColor,
                        iconColor: kDisabledColor,
                        title: Text(
                          specsUsing[index],
                          style: TextStyle(color: kDisabledColor),
                        ),
                        trailing: isEdit ? Text("") : trailingWidget,
                      );
                    }),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
