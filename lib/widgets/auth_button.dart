import 'package:flutter/material.dart';
import 'package:enos/services/util.dart';

class AuthButton extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  final Widget leadIcon;
  final String text;
  final Function onTap;

  const AuthButton(
      {Key key,
      this.backgroundColor,
      this.textColor,
      this.leadIcon,
      this.text,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)),
      child: ElevatedButton(
        onPressed: onTap,
        child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                leadIcon == null ? Container() : leadIcon,
                text == null
                    ? Text('')
                    : Text(text,
                        style: Theme.of(context).textTheme.headline1.copyWith(
                            color: textColor, fontSize: 19, letterSpacing: 0.5))
              ],
            )),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return darken(backgroundColor, 0.2);
            }
            return backgroundColor;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(7))),
        ),
      ),
    );
  }
}
