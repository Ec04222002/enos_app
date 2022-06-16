class TickerTileModel {
  final String symbol;
  final String companyName;
  final String price;
  final String percentChange;
  final bool isNft;

  const TickerTileModel(
      {this.symbol,
      this.companyName,
      this.price,
      this.percentChange,
      this.isNft = false});

  static TickerTileModel fromJson(Map<String, dynamic> json) => TickerTileModel(
      symbol: json['symbol'] ?? "__",
      companyName: json['company_name'] ?? "____",
      price: json['price'] ?? "___",
      percentChange: json['percent_change'] ?? "__",
      isNft: json['is_nft']);

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'company_name': companyName,
        'price': price,
        'percent_change': percentChange,
        'is_nft': isNft,
      };
}
