import 'dart:io';

import 'package:enos/constants.dart';
import 'package:enos/models/user.dart';
import 'package:enos/services/util.dart';
import 'package:enos/widgets/color_array.dart';
import 'package:enos/widgets/profile_pic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        iconSize: 22,
        onPressed: () {},
        icon: Icon(
          Icons.arrow_forward_ios_outlined,
          color: kDarkTextColor,
        ));
  }

  static Future pickImg(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      return File(image.path);
    } on PlatformException catch (e) {
      print('Image access not allowed');
    }
  }

  static openImgPicker(BuildContext context, UserModel user) {
    final _formKey = GlobalKey<FormState>();
    final myController = TextEditingController();
    ValueNotifier<bool> toggleProfile = ValueNotifier(false);
    bool isBorderMode = false, isImageMode = false;
    //background border image
    String name = user.username;
    Color color1 = Utils.stringToColor(user.profileBgColor);
    Color color2 = Utils.stringToColor(user.profileBorderColor);
    String imgUrl = null;
    ProfilePicture topPic = ProfilePicture(
      name: user.username,
      color1: color1,
      color2: color2,
      width: 105,
      height: 105,
      fontSize: 50,
    );

    ColorArray colorArrBg = ColorArray(
      colors: ProfilePicture.colors,
      currentBg: color1,
      currentBorder: color2,
    );
    Widget editSect = colorArrBg;

    Function updateProfile = () {
      topPic = ProfilePicture(
        name: name,
        image: imgUrl == null ? null : Image.file(File(imgUrl)),
        color1: colorArrBg.currentBg,
        color2: colorArrBg.currentBorder,
        width: 105,
        height: 105,
        fontSize: 50,
      );
      //toggling color Array
      toggleProfile.value = !toggleProfile.value;
      //updating usermodel
    };
    Function updateEditSect = () {
      if (isImageMode) {
        editSect = Container();
        toggleProfile.value = !toggleProfile.value;
        return;
      }
      colorArrBg = ColorArray(
        colors: ProfilePicture.colors,
        currentBg: colorArrBg.currentBg,
        currentBorder: colorArrBg.currentBorder,
        borderMode: isBorderMode,
        updateFunct: updateProfile,
      );
      editSect = colorArrBg;
      toggleProfile.value = !toggleProfile.value;
    };

    colorArrBg.updateFunct = updateProfile;
    if (user.profilePic != null)
      topPic.image = Image.file(File(user.profilePic));

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => Scaffold(
                  appBar: AppBar(
                      backgroundColor: kLightBackgroundColor,
                      centerTitle: true,
                      title: Text(
                        "Edit Profile",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      leading: IconButton(
                        color: kDarkTextColor.withOpacity(0.9),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back_ios),
                      )),
                  body: ValueListenableBuilder(
                    valueListenable: toggleProfile,
                    builder: (context, value, child) => Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(children: [
                          topPic,
                          Form(
                            key: _formKey,
                            child: Container(
                              padding: EdgeInsets.only(top: 10),
                              width: MediaQuery.of(context).size.width * 0.55,
                              child: TextFormField(
                                validator: (value) {
                                  if (value.length == 1) {
                                    return 'Please enter a minimium of 2 chars';
                                  }
                                  return null;
                                },
                                textAlign: TextAlign.center,
                                controller: myController,
                                decoration: InputDecoration(
                                    counterStyle:
                                        TextStyle(color: kDisabledColor),
                                    labelStyle: TextStyle(
                                      color: kDarkTextColor,
                                    ),
                                    label: Align(
                                        alignment: Alignment.center,
                                        child: Text(user.username)),
                                    filled: true,
                                    fillColor: kLightBackgroundColor,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 5),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    )),
                                style: TextStyle(color: kDarkTextColor),
                                maxLines: 1,
                                maxLength: 14,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextButton(
                                    style: ButtonStyle(
                                        backgroundColor: !isBorderMode &&
                                                !isImageMode
                                            ? MaterialStateProperty.all<Color>(
                                                kActiveColor)
                                            : MaterialStateProperty.all<Color>(
                                                kLightBackgroundColor),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ))),
                                    onPressed: () {
                                      print("pressed");
                                      if (!isBorderMode && !isImageMode) return;
                                      isBorderMode = false;
                                      isImageMode = false;
                                      updateEditSect();
                                    },
                                    child: Text(
                                      "Background Color",
                                      style: TextStyle(
                                          color: !isBorderMode && !isImageMode
                                              ? kBrightTextColor
                                              : Utils.lighten(kActiveColor)),
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextButton(
                                    style: ButtonStyle(
                                        backgroundColor: isBorderMode
                                            ? MaterialStateProperty.all<Color>(
                                                kActiveColor)
                                            : MaterialStateProperty.all<Color>(
                                                kLightBackgroundColor),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ))),
                                    onPressed: () {
                                      if (isBorderMode) return;
                                      isBorderMode = true;
                                      isImageMode = false;
                                      updateEditSect();
                                    },
                                    child: Text(
                                      "Border Color",
                                      style: TextStyle(
                                          color: isBorderMode
                                              ? kBrightTextColor
                                              : Utils.lighten(kActiveColor)),
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextButton(
                                    style: ButtonStyle(
                                        backgroundColor: isImageMode
                                            ? MaterialStateProperty.all<Color>(
                                                kActiveColor)
                                            : MaterialStateProperty.all<Color>(
                                                kLightBackgroundColor),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ))),
                                    onPressed: () {
                                      if (isImageMode) return;
                                      isImageMode = true;
                                      isBorderMode = false;
                                      updateEditSect();
                                    },
                                    child: Text(
                                      "Image",
                                      style: TextStyle(
                                          color: isImageMode
                                              ? kBrightTextColor
                                              : Utils.lighten(kActiveColor)),
                                    )),
                              ),
                            ],
                          ),
                          editSect
                        ]),
                      ),
                    ),
                  ),
                ))));
  }
}
