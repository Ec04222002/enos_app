class TickerTileModel {
  final String tickerName;
  final bool isNft;
  const TickerTileModel({this.tickerName, this.isNft = false});
  // final String companyName;
  // final double price;
  // final double percentChange;

  // const TickerTileModel(
  //     {this.tickerName, this.companyName, this.price, this.percentChange});

  // static TickerTileModel fromJson(Map<String, dynamic> json) => TickerTileModel(
  //       tickerName: json['ticker_name'],
  //       companyName: json['company_name'],
  //       price: json['price'],
  //       percentChange: json['percent_change'],
  //     );

  // Map<String, dynamic> toJson() => {
  //       'ticker_name': tickerName,
  //       'company_name': companyName,
  //       'price': price,
  //       'percent_change': percentChange,
  //     };

  Map<String, dynamic> toJson() => {
        'ticker_name': tickerName,
        'is_nft': isNft,
      };
  static TickerTileModel fromJson(Map<String, dynamic> json) => TickerTileModel(
        tickerName: json['ticker_name'],
        isNft: json['is_nft'],
      );
}
