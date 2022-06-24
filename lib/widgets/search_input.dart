import 'package:flutter/material.dart';
import 'package:enos/constants.dart';

class SearchInput extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final String hintText;

  const SearchInput({
    Key key,
    @required this.text,
    @required this.onChanged,
    @required this.hintText,
  }) : super(key: key);

  @override
  _SearchInputState createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final styleActive = TextStyle(color: Colors.black, fontSize: 15);
    final styleHint =
        TextStyle(color: Colors.grey.withOpacity(0.9), fontSize: 15);
    final style = widget.text.isEmpty ? styleHint : styleActive;

    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          color: kDarkTextColor,
          icon: Icon(Icons.arrow_back_ios),
        ),
        Container(
          height: 38,
          width: MediaQuery.of(context).size.width / 1.35,
          margin: const EdgeInsets.fromLTRB(0, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: kBrightTextColor,
            border: Border.all(color: Colors.transparent),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              icon: Icon(Icons.search, size: 30, color: Colors.grey),
              suffixIcon: widget.text.isNotEmpty
                  ? GestureDetector(
                      child: Icon(Icons.close, color: style.color),
                      onTap: () {
                        controller.clear();
                        widget.onChanged('');
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    )
                  : null,
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
