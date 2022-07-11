import 'package:enos/models/ticker_page_info.dart';
import 'package:enos/services/ticker_page_info.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/services/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:enos/constants.dart';

class PreTickerInfo extends StatefulWidget {
  final TickerPageModel data;
  final TickerTileProvider tickerProvider;
  const PreTickerInfo({this.data, this.tickerProvider, Key key})
      : super(key: key);

  @override
  State<PreTickerInfo> createState() => _PreTickerInfoState();
}

class _PreTickerInfoState extends State<PreTickerInfo> {
  TickerTileProvider provider;
  TickerPageModel data;
  Color preMarketColor, postMarketColor;
  String preMarketPrefix, preMarketSuffix, preMarketPercentSuffix;
  String postMarketPrefix, postMarketSuffix, postMarketPercentSuffix;

  @override
  Widget build(BuildContext context) {
    data = widget.data;
    provider = widget.tickerProvider;
    preMarketColor = data.priceChange[0] != "-" ? kGreenColor : kRedColor;
    preMarketPrefix = preMarketColor == kGreenColor ? "+" : "";
    preMarketPercentSuffix =
        data.percentChange[data.percentChange.length - 1] != "%" ? "%" : "";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.symbol,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              data.marketPrice,
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
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
            (Utils.isPostMarket() || Utils.isPastPostMarket())
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
                            "At Close: ${Utils.formatEpoch(data.closeTime, false)}",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        CupertinoButton(
                            minSize: double.minPositive,
                            padding: EdgeInsets.only(left: 4),
                            onPressed: _showBottomModal,
                            child: Icon(
                              Icons.info_outline,
                              size: 20,
                              color: kActiveColor,
                            )),
                      ],
                    ),
                  )
                : Container(
                    width: 0,
                  ),
          ],
        ),
        Container(
          height: 145,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () async {
                      if (!data.isSaved) {
                        if (provider.symbols.length >= 10) {
                          Utils.showAlertDialog(context,
                              "You have reached your limit of 10 tickers added.",
                              () {
                            Navigator.pop(context);
                          }, null);
                        } else {
                          setState(() {
                            data.isSaved = true;
                          });
                          await provider.addTicker(data.symbol);
                        }
                      } else {
                        Utils.showAlertDialog(context,
                            "Are you sure you want to remove ${data.symbol} from your watchlist?",
                            () {
                          Navigator.pop(context);
                        }, () async {
                          setState(() {
                            data.isSaved = false;
                          });
                          await provider.removeTicker(
                              provider.symbols.indexOf(data.symbol));
                          Navigator.pop(context);
                        });
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
                          )),
                (data.isPostMarket &&
                        !data.isCrypto &&
                        (Utils.isPostMarket() || Utils.isPastPostMarket()))
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

  void _showBottomModal() {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Container(
              color: kLightBackgroundColor,
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
        Text(
          data.postMarketPrice,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 15,
        ),
        Text(
          "$postMarketPrefix${data.postPriceChange} (${data.postPercentChange}$postMarketPercentSuffix)",
          style: TextStyle(
              color: postMarketColor,
              fontSize: 14,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 4,
        ),
        Utils.isPastPostMarket()
            ? Text(
                "Post Close: ${Utils.formatEpoch(data.postCloseTime, true)}",
                style: TextStyle(fontSize: 13),
              )
            : Container(
                width: 0,
              )
      ],
    );
  }
}
