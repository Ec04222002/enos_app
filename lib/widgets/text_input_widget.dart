import 'package:flutter/material.dart';
import 'package:enos/constants.dart';

class TextInputWidget extends StatefulWidget {
  final String text;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  bool obscureText;
  TextInputWidget({
    Key key,
    this.text,
    this.icon,
    this.isPassword,
    this.controller,
    this.obscureText = true,
  }) : super(key: key);

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  void toggle() {
    setState(() {
      widget.obscureText = !widget.obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      enableSuggestions: !widget.isPassword,
      autocorrect: !widget.isPassword,
      cursorColor: Colors.white,
      style: TextStyle(color: kBrightTextColor),
      decoration: InputDecoration(
        suffix: GestureDetector(
          onTap: toggle,
          child: Icon(
            widget.obscureText ? Icons.visibility_off : Icons.visibility,
            color: kDisabledColor.withOpacity(0.6),
          ),
        ),
        prefixIcon: Icon(
          widget.icon,
          color: Colors.white70,
        ),
        labelText: widget.text,
        labelStyle: TextStyle(color: kDisabledColor.withOpacity(0.9)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: kLightBackgroundColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7.0),
            borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
      ),
      keyboardType: widget.isPassword
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress,
    );
  }
}
