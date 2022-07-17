class TickerTileModel {
  final String symbol;
  final String companyName;
  final String price;
  final String percentChange;
  final String postPercentChange;
  final String priceChange;
  final String postPriceChange;
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
      this.isCrypto = false,
      this.isLive = true,
      this.isSaved = false});
}
