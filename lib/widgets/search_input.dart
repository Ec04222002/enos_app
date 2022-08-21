import 'package:flutter/material.dart';
import 'package:enos/constants.dart';
import 'package:cool_dropdown/cool_dropdown.dart';

class SearchInput extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final String hintText;
  Map<String, dynamic> passBack;
  Function setMarketName;
  SearchInput(
      {Key key,
      @required this.text,
      @required this.setMarketName,
      @required this.onChanged,
      @required this.hintText,
      this.passBack = const {}})
      : super(key: key);

  @override
  _SearchInputState createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  final controller = TextEditingController();
  bool isMainPage;
  List items = [
    {'label': "NASDAQ", 'value': "NASDAQ"},
    {'label': "NYSE", 'value': "NYSE"},
    {'label': "INDEX", 'value': "INDEX"},
    {'label': "OTCBB", 'value': "OTCBB"},
    {'label': "CRYPTO", 'value': "CRYPTO"},
    {"label": "USERS", 'value': "USERS"}
  ];

  @override
  void initState() {
    super.initState();
    isMainPage = widget.hintText == "Search Stocks or Users";
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: Colors.grey.withOpacity(0.8), fontSize: 14);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isMainPage
            ? Container(
                width: 0,
              )
            : IconButton(
                onPressed: () => Navigator.pop(context, widget.passBack),
                color: kDarkTextColor,
                icon: Icon(Icons.arrow_back_ios),
              ),
        Container(
          height: 38,
          width: MediaQuery.of(context).size.width / 1.26,
          margin: isMainPage
              ? EdgeInsets.fromLTRB(0, 12, 0, 12)
              : EdgeInsets.fromLTRB(0, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: kBrightTextColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          child: TextField(
            autofocus: (isMainPage) ? false : true,
            controller: controller,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 4),
              icon: Icon(
                Icons.search,
                size: 27,
                color: kDisabledColor,
              ),
              suffixIcon: CoolDropdown(
                resultPadding: EdgeInsets.all(5),
                resultAlign: Alignment.center,
                resultBD: BoxDecoration(
                    color: kDarkTextColor,
                    border: Border(
                        left: BorderSide(color: kDisabledColor, width: 1.0))),
                resultTS: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.withOpacity(0.8),
                    fontWeight: FontWeight.w600),
                resultWidth: 95,
                dropdownWidth: 90,
                selectedItemPadding: EdgeInsets.zero,
                dropdownPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                dropdownList: items,
                dropdownItemBottomGap: 0,
                dropdownItemGap: 0,
                dropdownItemPadding: EdgeInsets.zero,
                dropdownAlign: "center",
                dropdownHeight: 310,
                selectedItemBD: BoxDecoration(
                    color: kDarkTextColor,
                    borderRadius: BorderRadius.circular(5)),
                selectedItemTS: TextStyle(color: Colors.grey, fontSize: 18),
                unselectedItemTS: TextStyle(color: Colors.grey, fontSize: 18),
                onChange: (item) {
                  widget.setMarketName(item['value']);
                },
                defaultValue: items[0],
              ),
              hintText: widget.hintText,
              hintStyle: style,
              border: InputBorder.none,
            ),
            style: style,
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}

// widget.text.isNotEmpty
//                   ? GestureDetector(
//                       child: Icon(Icons.close, color: style.color),
//                       onTap: () {
//                         controller.clear();
//                         widget.onChanged('');
//                         FocusScope.of(context).requestFocus(FocusNode());
//                       },
//                     )
//                   : null,


