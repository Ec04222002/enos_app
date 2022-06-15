class TickerTileModel {
  final String symbol;
  final String companyName;
  final String price;
  final String percentChange;
  final bool isNft;

  const TickerTileModel(
      {this.symbol = "__",
      this.companyName = "____",
      this.price = "___",
      this.percentChange = "__",
      this.isNft = false});

  static TickerTileModel fromJson(Map<String, dynamic> json) => TickerTileModel(
      symbol: json['symbol'],
      companyName: json['company_name'],
      price: json['price'],
      percentChange: json['percent_change'],
      isNft: json['is_nft']);

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'company_name': companyName,
        'price': price,
        'percent_change': percentChange,
        'is_nft': isNft,
      };
}
