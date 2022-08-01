class TickerTileModel {
  final String symbol;
  final String companyName;
  double priceNum;
  String price;
  String percentChange;
  String postPercentChange;
  String priceChange;
  String postPriceChange;
  final double previousClose;
  final List chartDataY;
  final List chartDataX;
  // bool isNft = false;
  //for saving api calls
  final bool isCrypto;
  final bool isPostMarket;
  final String marketName;
  bool isSaved;
  bool isLive;
  TickerTileModel(
      {this.symbol,
      this.companyName,
      this.price,
      this.percentChange,
      this.isPostMarket = false,
      this.postPercentChange,
      this.priceChange,
      this.postPriceChange,
      this.previousClose,
      this.chartDataX,
      this.chartDataY,
      this.marketName,
      this.priceNum,
      this.isCrypto = false,
      this.isLive = true,
      this.isSaved = false});
}
