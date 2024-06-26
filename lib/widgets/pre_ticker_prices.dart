import 'package:enos/models/ticker_page_info.dart';
import 'package:enos/services/ticker_page_info.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/services/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:enos/constants.dart';
import 'package:intl/intl.dart';

class PreTickerInfo extends StatefulWidget {
  final TickerPageModel data;
  final TickerTileProvider tickerProvider;
  final bool isStream;
  final bool isGreenAnime;
  final bool isChangePost;
  final int indexOfChange;
  const PreTickerInfo(
      {this.isGreenAnime,
      this.data,
      this.tickerProvider,
      this.isStream,
      this.isChangePost,
      this.indexOfChange,
      Key key})
      : super(key: key);

  @override
  State<PreTickerInfo> createState() => _PreTickerInfoState();
}

class _PreTickerInfoState extends State<PreTickerInfo>
    with TickerProviderStateMixin {
  TickerTileProvider provider;
  TickerPageInfo dataBase = TickerPageInfo();
  TickerPageModel data;
  Color preMarketColor, postMarketColor;
  String preMarketPrefix, preMarketSuffix, preMarketPercentSuffix;
  String postMarketPrefix, postMarketSuffix, postMarketPercentSuffix;
  Color textColor = kBrightTextColor;

  Widget preTickerInfoWidget() {
    ValueNotifier<bool> toggleStar = ValueNotifier(false);
    if (widget.isGreenAnime == null || !widget.isStream) {
      textColor = kBrightTextColor;
    } else if (widget.isGreenAnime) {
      textColor = kGreenColor;
    } else {
      textColor = kRedColor;
    }
    preMarketColor = data.priceChange[0] != "-" ? kGreenColor : kRedColor;
    preMarketPrefix = preMarketColor == kGreenColor ? "+" : "";
    preMarketPercentSuffix =
        data.percentChange[data.percentChange.length - 1] != "%" ? "%" : "";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 235,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                maxLines: 2,
                text: TextSpan(
                  text: data.shortName,
                  style: TextStyle(
                      fontSize: data.shortName.length > 15 ? 17 : 21,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              RichText(
                maxLines: 1,
                text: TextSpan(
                  children: <TextSpan>[
                    !widget.isChangePost &&
                            widget.indexOfChange != -1 &&
                            widget.indexOfChange != null
                        ? TextSpan(
                            text: data.marketPrice
                                .substring(widget.indexOfChange),
                            style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.w600,
                                color: textColor))
                        : TextSpan(text: ""),
                    TextSpan(
                        text: "\t\tUSD",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600))
                  ],
                  text: !widget.isChangePost &&
                          widget.indexOfChange != -1 &&
                          widget.indexOfChange != null
                      ? data.marketPrice.substring(0, widget.indexOfChange)
                      : data.marketPrice,
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                "$preMarketPrefix${data.priceChange} (${data.percentChange}$preMarketPercentSuffix)",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: preMarketColor),
              ),
              SizedBox(
                height: 4,
              ),
              ((Utils.isPostMarket() ||
                          Utils.isPastPostMarket() ||
                          Utils.isWeekend()) &&
                      !data.isCrypto)
                  ? Container(
                      height: 21,
                      //width: 240,
                      child: Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            // width: 100,
                            child: Text(
                              "At Close: ${Utils.formatEpoch(epoch: data.closeTime, isJustTime: false)}",
                              style: TextStyle(fontSize: 12.5),
                            ),
                          ),
                          CupertinoButton(
                              minSize: double.minPositive,
                              padding: EdgeInsets.zero,
                              onPressed: _showBottomModal,
                              child: Icon(
                                Icons.info_outline,
                                size: 19,
                                color: kActiveColor,
                              )),
                        ],
                      ),
                    )
                  : Container(
                      height: 21,
                      child: Text(
                        "Current:\t${DateFormat('E, MMM d, yyyy, hh:mm aaa').format(DateTime.now())}",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
            ],
          ),
        ),
        Container(
          height: data.shortName.length > 15 ? 140 : 145,
          child: Padding(
            padding: EdgeInsets.only(
                bottom:
                    (Utils.isPastPostMarket() || Utils.isWeekend()) ? 15 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder(
                  valueListenable: toggleStar,
                  builder: ((context, value, child) => IconButton(
                      onPressed: () {
                        if (!data.isSaved) {
                          if (provider.symbols.length >= 10) {
                            Utils.showAlertDialog(context,
                                "You have reached your limit of 10 tickers added.",
                                () {
                              Navigator.pop(context);
                            }, null);
                          } else {
                            data.isSaved = true;

                            toggleStar.value = !toggleStar.value;
                          }
                        } else if (!provider.isLoading) {
                          Utils.showAlertDialog(context,
                              "Are you sure you want to remove ${data.symbol} from your watchlist?",
                              () {
                            Navigator.pop(context);
                          }, () {
                            data.isSaved = false;

                            provider.removeTicker(
                                provider.symbols.indexOf(data.symbol));
                            toggleStar.value = !toggleStar.value;
                            Navigator.pop(context);
                          });

                          // data.isSaved = false;

                          // toggleStar.value = !toggleStar.value;
                        }
                      },
                      icon: data.isSaved
                          ? Icon(
                              Icons.star,
                              color: Colors.yellow[400],
                              size: 38,
                            )
                          : Icon(
                              Icons.star_border,
                              color: kDisabledColor,
                              size: 38,
                            ))),
                ),
                (data.isPostMarket &&
                        !data.isCrypto &&
                        (Utils.isPostMarket() ||
                            Utils.isPastPostMarket() ||
                            Utils.isWeekend()))
                    ? postPriceWidget()
                    : Container(
                        width: 0,
                      ),
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    data = widget.data;
    provider = widget.tickerProvider;
    return preTickerInfoWidget();
  }

  void _showBottomModal() {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Container(
              color: kDarkBackgroundColor,
              height: 115,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: RichText(
                    text: TextSpan(
                  text: "INFO: ",
                  style: TextStyle(
                      color: kActiveColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 15),
                  children: const <TextSpan>[
                    TextSpan(
                        text:
                            "\tThe times displayed on Enos are respective to your current timezone. The U.S. stock market, including NYSE and Nasdaq, has regular trading hours from 9:30 a.m. to 4 p.m. ET, and post-market trading hours from 4 p.m. to 8 p.m. ET",
                        style: TextStyle(
                            color: kDarkTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 15))
                  ],
                )),
              ));
        });
  }

  Widget postPriceWidget() {
    postMarketColor = data.postPriceChange[0] != '-' ? kGreenColor : kRedColor;
    postMarketPrefix = postMarketColor == kGreenColor ? "+" : "";
    postMarketPercentSuffix =
        data.postPercentChange[data.postPercentChange.length - 1] != "%"
            ? "%"
            : "";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        (widget.indexOfChange != -1 && widget.indexOfChange != null)
            ? RichText(
                text: TextSpan(
                  text: data.postMarketPrice.substring(0, widget.indexOfChange),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  children: <TextSpan>[
                    TextSpan(
                        text: data.postMarketPrice
                            .substring(widget.indexOfChange),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: textColor))
                  ],
                ),
              )
            : Text(
                data.postMarketPrice,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
        SizedBox(
          height: 8,
        ),
        Text(
          "$postMarketPrefix${data.postPriceChange} (${data.postPercentChange}$postMarketPercentSuffix)",
          style: TextStyle(
              color: postMarketColor,
              fontSize: 13.5,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 5,
        ),
        Utils.isPastPostMarket() || Utils.isWeekend()
            ? Text(
                "Post Close: ${Utils.formatEpoch(epoch: data.postCloseTime, isJustTime: true)}",
                style: TextStyle(fontSize: 12.5),
              )
            : Container(
                width: 0,
                height: 23,
              )
      ],
    );
  }
}
