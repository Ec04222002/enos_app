// ticker/chart page

import 'package:enos/models/article.dart';
import 'package:enos/models/ticker_page_info.dart';
import 'package:enos/models/ticker_spec.dart';
import 'package:enos/models/user.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/ticker_page_info.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/services/util.dart';
import 'package:enos/widgets/chart_dates_bar.dart';
import 'package:enos/widgets/comment_section.dart';
import 'package:enos/widgets/line_chart.dart';
import 'package:enos/widgets/loading.dart';
import 'package:enos/widgets/pre_ticker_prices.dart';
import 'package:enos/widgets/slider.dart';
import 'package:flutter/material.dart';
import 'package:enos/constants.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TickerInfo extends StatefulWidget {
  final String symbol;
  final bool isSaved;
  final String uid;
  final TickerTileProvider provider;
  final String parentId, childId;
  const TickerInfo(
      {this.symbol,
      this.uid,
      this.isSaved,
      this.provider,
      Key key,
      this.parentId,
      this.childId})
      : super(key: key);

  @override
  State<TickerInfo> createState() => _TickerInfoState();
}

class _TickerInfoState extends State<TickerInfo>
    with SingleTickerProviderStateMixin {
  TickerPageInfo dataBase = TickerPageInfo();
  bool isLoading = true, chartLoading = false;
  double initBtnOpacity = 0.75, btnOpacity = 0.75;
  TickerPageModel pageData;
  double previousClose;
  String range = "1d";
  bool previewLoaded = false, newsLoaded = false;

  TabController _tabController;
  final List<Tab> myTabs = <Tab>[
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
  ];
  int currentTabIndex = 0;
  final ScrollController pageScrollController = ScrollController();
  bool isSelfScroll = false;
  bool showBtn = true;
  bool isStream = false;
  UserModel user;

  final sectScrollController = ScrollController();
  bool isScrollUp = true;
  //specs section
  List<String> specsAll = TickerSpecs.existSpecs;
  List<String> specsDisplay = [];
  List<bool> specsEdit = [];
  List<String> specsUsing = [];
  bool isEdit = false;
  List<SlidableController> controllers;
  Map specsData = {};

  double sectHeight;
  final double editButtonHeight = 45;
  final double dataHeight = 47;
  final double toolBarHeight = 33;
  double lastScrollOffset;
  ValueNotifier<bool> toggleSpec = ValueNotifier(false);
  //animation
  bool triggerNewChart = false;
  bool isGreenAnime;
  bool isChangePost;
  Utils util = Utils();
  dynamic lastPrice;
  String lastPriceStr;
  int indexOfChange;
  //comment page
  @override
  void dispose() {
    sectScrollController.dispose();
    pageScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> init() async {
    _tabController = new TabController(vsync: this, length: myTabs.length);
    if (widget.parentId != null || widget.childId != null) {
      print("to comment section");
      _tabController.index = 1;
      showBtn = false;
    }
    sectHeight =
        editButtonHeight + dataHeight * specsUsing.length + toolBarHeight;
    _tabController.addListener(() {
      FocusScope.of(context).unfocus();

      setState(() {
        currentTabIndex = _tabController.index;
      });
    });

    sectScrollController.addListener(() {
      if (sectScrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        isScrollUp = true;
        ////print("scrolling up");
        return;
      }
      ////print("scrolling down");
      isScrollUp = false;
    });

    if (!mounted) return;
    pageData =
        await dataBase.getModelData(widget.symbol, widget.isSaved, false, null);
    lastPrice = pageData.marketPriceNum;
    lastPriceStr = pageData.marketPrice;
    isChangePost = false;
    if (pageData.isPostMarket && Utils.isPostMarket()) {
      lastPrice = pageData.postMarketPriceNum;
      lastPriceStr = pageData.postMarketPrice;
      isChangePost = true;
    }
    specsData = pageData.specsData;
    user = await FirebaseApi.getUser(widget.uid);
    specsEdit = user.metrics;
    controllers = List.filled(specsAll.length, null);
    _specsDisplayUpdate();
    specsUsing = specsDisplay;
    previousClose = pageData.previousClose;
    if (!mounted) return;
    setState(() {
      isLoading = false;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await dataBase.addPostLoadData(pageData);
        // lastData = pageData;

        if (mounted) {
          setState(() {
            previewLoaded = true;
            chartLoading = false;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await dataBase.addPostPostLoadData(pageData);
              if (!mounted) return;
              setState(() {
                newsLoaded = true;
              });
            });
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
      if (isEdit) {
        element.openStartActionPane();
      } else {
        element.close();
      }
      //isEdit ? element.openStartActionPane() : element.close();
    });
  }

  @override
  void initState() {
    super.initState();
    //get all new updates
    init();
  }

  AppBar appBar;
  @override
  Widget build(BuildContext bContext) {
    if (isLoading)
      return Loading(
        type: "dot",
        loadText: "Loading" " ${widget.symbol} ....",
      );
    appBar = AppBar(
      leading: IconButton(
        onPressed: () async {
          Navigator.pop(context, {
            'isSaved': pageData.isSaved,
          });
        },
        color: kDarkTextColor,
        icon: Icon(Icons.arrow_back_ios),
      ),
      centerTitle: true,
      backgroundColor: kLightBackgroundColor,
      title: Text(
        "${pageData.symbol} · ${pageData.marketName}",
        textAlign: TextAlign.center,
        style: TextStyle(
            color: kBrightTextColor, fontSize: 17, fontWeight: FontWeight.w600),
        maxLines: 2,
      ),
    );
    return Scaffold(
      appBar: appBar,
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
                    util.showSnackBar(context, "Stock is not post", false);
                    return;
                  }
                }
                ////print("calling for data");
                triggerNewChart = true;
                util.showSnackBar(context, "Streaming Data ", true);
                ////print("in long press");
                setState(() {
                  isStream = true;
                  btnOpacity = 0.3;
                });
              },
              onLongPressEnd: (_) {
                //print("end press");
                util.removeSnackBar();
                setState(() {
                  isStream = false;
                  btnOpacity = initBtnOpacity;
                });
              },
              onLongPressCancel: () {
                //print("cancel press");
                setState(() {
                  isStream = false;
                  btnOpacity = initBtnOpacity;
                });
              },
              onTap: () {
                //print("tap");
                setState(() {
                  isStream = false;
                  btnOpacity = initBtnOpacity;
                });
              },
              onTapUp: (_) {
                //print('tap up');
                setState(() {
                  isStream = false;
                  btnOpacity = initBtnOpacity;
                });
              },
              child: FloatingActionButton(
                onPressed: () {},
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
          //reducing calls
          if (lastScrollOffset == null)
            lastScrollOffset = pageScrollController.offset;
          if (pageScrollController.offset == lastScrollOffset) return false;

          if (scrollNotification is ScrollUpdateNotification) {
            double before = pageScrollController.position.extentBefore;
            double after = pageScrollController.position.extentAfter;

            if (after == 0) {
              if (!isSelfScroll) {
                setState(() {
                  isSelfScroll = true;
                  //print("self scrolling true");
                });
              }
              //print("page scrolled to top sect end -> self scrolling starts");
            } else {
              if (isSelfScroll) {
                setState(() {
                  //print("not self scrolling");
                  isSelfScroll = false;
                });
              }
              //print("page not scrolled to top sect end -> no self scrolling");
            }
            //reducing setstate calls
            if (before < 85) {
              if (!showBtn) {
                //showBtn = true;
                setState(() {
                  //print("setting state");
                  showBtn = true;
                });
              }
            } else {
              if (showBtn) {
                setState(() {
                  //print("setting state 2");
                  showBtn = false;
                });
              }
            }
          }
          lastScrollOffset = pageScrollController.offset;
          return true;
        },
        child: isStream
            ? StreamBuilder<TickerPageModel>(
                initialData: pageData,
                stream: dataBase.getPageStream(
                    pageData.symbol, pageData.isSaved, pageData),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return TickerPage();
                    default:
                      if (snapshot.hasError) {
                        //print("error: ${snapshot.error}");
                        return Center(
                            child:
                                Text("Sorry, there seems to be an error 😔"));
                      }
                      isGreenAnime = null;
                      isChangePost = false;
                      double priceToCheck;
                      String priceToCheckStr;
                      if (pageData.isPostMarket && Utils.isPostMarket()) {
                        isChangePost = true;
                        indexOfChange = Utils.findFirstChange(
                            lastPriceStr, snapshot.data.postMarketPrice);
                        priceToCheck = snapshot.data.postMarketPriceNum;
                        priceToCheckStr = snapshot.data.postMarketPrice;
                      } else {
                        indexOfChange = Utils.findFirstChange(
                            lastPriceStr, snapshot.data.marketPrice);
                        priceToCheck = snapshot.data.postMarketPriceNum;
                        priceToCheckStr = snapshot.data.marketPrice;
                      }

                      if (priceToCheck != lastPrice)
                        isGreenAnime = priceToCheck > lastPrice;

                      lastPrice = priceToCheck;
                      lastPriceStr = priceToCheckStr;
                      pageData = snapshot.data;
                      return TickerPage();
                  }
                })
            : TickerPage(),
      ),
    );
  }

  void setSectHeight() {
    switch (currentTabIndex) {
      case 0:
        sectHeight =
            editButtonHeight + dataHeight * specsUsing.length + toolBarHeight;
        if (isEdit) {
          sectHeight = MediaQuery.of(context).size.height -
              toolBarHeight -
              appBar.preferredSize.height;
          // isSelfScroll = false;
        }
        break;
      case 1:
      case 2:
        sectHeight = MediaQuery.of(context).size.height -
            toolBarHeight -
            appBar.preferredSize.height;
        break;
      default:
    }
  }

  Widget TickerPage() {
    setSectHeight();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
          controller: pageScrollController,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: PreTickerInfo(
                    data: pageData,
                    tickerProvider: widget.provider,
                    isStream: isStream,
                    isGreenAnime: isGreenAnime,
                    isChangePost: isChangePost,
                    indexOfChange: indexOfChange),
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
                      //print("loading charts");
                      return;
                    }
                    if (range != '1d') {
                      dynamic closePrice =
                          pageData.priceData[localRange]['closePrices'];

                      previousClose =
                          closePrice == null ? null : closePrice.first;
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
                    height: sectHeight,
                    child: Scaffold(
                      appBar: AppBar(
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        titleSpacing: 0,
                        toolbarHeight: toolBarHeight,
                        backgroundColor: kLightBackgroundColor,
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
                              tabs: myTabs,
                            )
                          ],
                        ),
                      ),
                      body: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: new TabBarView(
                          controller: _tabController,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            specSection(),
                            _addNotifer(CommentSection(
                              widget.provider.watchListUid,
                              pageData.symbol,
                              isSelfScroll,
                              widget.parentId != null || widget.childId != null
                                  ? () {
                                      if (pageScrollController.hasClients) {
                                        pageScrollController.jumpTo(
                                            pageScrollController
                                                    .position.maxScrollExtent -
                                                10);
                                      }
                                    }
                                  : () {},
                              // commentHighlightUid: widget.parentId,
                              parentId: widget.parentId,
                              selfId: widget.childId,
                            )),
                            newSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _addNotifer(Widget child) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          if (notification.metrics.extentBefore == 0 && !isScrollUp) {
            if (isSelfScroll) {
              setState(() {
                //print('self scrol false - page going down');
                isSelfScroll = false;
              });
            }
          }
        }
        return false;
      },
      child: child,
    );
  }

  Widget newSection() {
    if (newsLoaded) {
      return ArticleViewer(
        pageData.articles,
        "",
        false,
        isSelfScroll: isSelfScroll,
      );
    } else if (previewLoaded) {
      return Stack(children: [
        Opacity(
          opacity: 0.6,
          child: IgnorePointer(
            child: ArticleViewer(
              pageData.articles,
              "",
              false,
              isSelfScroll: isSelfScroll,
            ),
          ),
        ),
        Loading(size: 50, bgColor: Colors.transparent),
      ]);
    }
    return Loading(
      size: 50,
      bgColor: kLightBackgroundColor,
    );
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
              //edit btn clicked
              if (isEdit) {
                isSelfScroll = false;
                specsUsing = specsAll;
              }
              //done btn clicked
              else {
                specsUsing = specsDisplay;
                _toggleData();
                user.metrics = specsEdit;
                FirebaseApi.updateUserData(user);
              }
              // _toggleData();
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
    ValueNotifier<bool> showVisibleIcon = ValueNotifier(false);
    return ValueListenableBuilder(
      valueListenable: toggleSpec,
      builder: (context, _, child) {
        return Container(
          color: kLightBackgroundColor,
          child: _addNotifer(
            SingleChildScrollView(
              controller: sectScrollController,
              physics: isSelfScroll
                  ? ClampingScrollPhysics()
                  : NeverScrollableScrollPhysics(),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  editBtn(),
                  ListView.builder(
                      //controller: sectScrollController,
                      padding: EdgeInsets.all(3),
                      itemExtent: dataHeight,
                      physics: isSelfScroll
                          ? ClampingScrollPhysics()
                          : NeverScrollableScrollPhysics(),
                      itemCount: specsUsing.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        specCurrentData = specsData[specsUsing[index]];
                        trailingWidget = specsUsing[index].contains("Range") &&
                                specCurrentData != null
                            ? (() {
                                try {
                                  double min = double.tryParse(
                                      specCurrentData[2].replaceAll(",", ""));
                                  double max = double.tryParse(
                                      specCurrentData[3].replaceAll(",", ""));
                                  double value =
                                      specsData['Market Price'].toDouble();
                                  if (min == null) {
                                    min = specCurrentData[0];
                                  }
                                  if (max == null) {
                                    max = specCurrentData[1];
                                  }
                                  if (value > max || value < min) {
                                    max = Utils.roundDouble(
                                        specCurrentData[1], 7);
                                    min = Utils.roundDouble(
                                        specCurrentData[0], 7);
                                  }
                                  Widget slider = SliderWidget(
                                      value: value, min: min, max: max);
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
                                    } else if (specsUsing[index] ==
                                        "Market Price") {
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
                              motion: ScrollMotion(),
                              children: [
                                ValueListenableBuilder<bool>(
                                  valueListenable: showVisibleIcon,
                                  builder: (context, _, child) {
                                    return SlidableAction(
                                      //padding: EdgeInsets.only(top: 0),
                                      autoClose: false,
                                      onPressed: ((context) {
                                        int indx =
                                            specsAll.indexOf(specsUsing[index]);
                                        specsEdit[indx] = !specsEdit[indx];
                                        showVisibleIcon.value =
                                            !showVisibleIcon.value;
                                      }),
                                      backgroundColor: kLightBackgroundColor,
                                      foregroundColor: kDarkTextColor,
                                      icon: specsEdit[index]
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    );
                                  },
                                )
                              ]),
                          key: UniqueKey(),
                          child: Builder(builder: (context) {
                            //set new controller only during edit mode
                            // full specs && new context
                            if (isEdit) {
                              controllers[index] = Slidable.of(context);
                              if (index == specsUsing.length - 1) {
                                //print("in");
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  // //print("post");
                                  _toggleData();
                                });
                              }
                            }

                            return ListTile(
                              // onTap: isEdit
                              //     ? () {
                              //         setState(() {
                              //           int indx =
                              //               specsAll.indexOf(specsUsing[index]);
                              //           specsEdit[indx] = !specsEdit[indx];
                              //         });
                              //       }
                              //     : () {},
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
          ),
        );
      },
    );
  }
}
