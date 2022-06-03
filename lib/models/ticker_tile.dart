class TickerTileModel {
  final String tickerName;
  final String companyName;
  final double price;
  final double percentChange;

  TickerTileModel(
      {this.tickerName, this.companyName, this.price, this.percentChange});

  static TickerTileModel fromJson(Map<String, dynamic> json) => TickerTileModel(
        tickerName: json['ticker_name'],
        companyName: json['company_name'],
        price: json['price'],
        percentChange: json['percent_change'],
      );

  Map<String, dynamic> toJson() => {
        'ticker_name': tickerName,
        'company_name': companyName,
        'price': price,
        'percent_change': percentChange,
      };
}
