import 'dart:async';
import 'dart:io';

import 'package:enos/constants.dart';
import 'package:enos/models/user.dart';
import 'package:enos/services/firebase_api.dart';
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
      if (image == null) return null;
      return image.path;
    } on PlatformException catch (e) {
      //print('Image access not allowed');
      return null;
    }
  }

  static openImgPicker(BuildContext context, UserModel user) async {
    //general
    bool backSpaceTrigger = false;
    bool isUpdated = false;
    //bool containsImage = false;
    Color saveBtnColor = kDisabledColor, undoBtnColor = kDisabledColor;
    String saveBtnText = "Save All", undoBtnText = "Undo All";

    //username input
    String name = user.username;
    final _formKey = GlobalKey<FormState>();
    final myController = TextEditingController();
    ValueNotifier<bool> toggleProfile = ValueNotifier(false);

    //edit mode selection
    bool isBorderMode = false;
    //bool isImageMode = false;

    //background and border color
    Color color1 = Utils.stringToColor(user.profileBgColor);
    Color color2 = Utils.stringToColor(user.profileBorderColor);
    String imgUrl = null;
    ColorArray colorArrBg = ColorArray(
      colors: ProfilePicture.colors,
      currentBg: color1,
      currentBorder: color2,
      crossCount: 5,
      additionalBtns: [],
    );

    //must be in order
    Widget editSect = colorArrBg;
    ProfilePicture topPic = ProfilePicture(
      name: user.username,
      color1: color1,
      color2: color2,
      width: 105,
      height: 105,
      fontSize: 50,
    );

    Function updateProfile = () {
      //isupdating
      topPic = ProfilePicture(
        name: name,
        image: imgUrl == null ? null : Image.file(File(imgUrl)),
        color1: colorArrBg.currentBg,
        color2: colorArrBg.currentBorder,
        width: 105,
        height: 105,
        fontSize: 50,
      );
      if (!isUpdated) {
        saveBtnColor = kActiveColor;
        undoBtnColor = kRedColor;
      }

      isUpdated = true;
      //toggling color Array
      toggleProfile.value = !toggleProfile.value;
      //updating usermodel
    };

    // Function _setCameraImage = () async {
    //   String url = await EditProfile.pickImg(ImageSource.camera);
    //   if (url != null) {
    //     //containsImage = true;
    //     imgUrl = url;
    //     updateProfile();
    //     return "Success";
    //   }
    //   return null;
    // };
    // Function _setLibraryImage = () async {
    //   String url = await EditProfile.pickImg(ImageSource.gallery);
    //   if (url != null) {
    //     // containsImage = true;
    //     imgUrl = url;
    //     updateProfile();
    //     return "Success";
    //   }
    //   return null;
    // };
    //for just background color click
    Function _removeImage = () {
      imgUrl = null;
      updateProfile();
    };

    Function updateEditSect = () {
      colorArrBg = ColorArray(
        colors: ProfilePicture.colors,
        currentBg: colorArrBg.currentBg,
        currentBorder: colorArrBg.currentBorder,
        borderMode: isBorderMode,
        crossCount: 5,
        updateFunct: isBorderMode ? updateProfile : _removeImage,
        additionalBtns: !isBorderMode
            ? [
                // {
                //   "icon": Icons.camera_alt_outlined,
                //   "onclick": _setCameraImage,
                // },
                // {
                //   "icon": Icons.photo_library_outlined,
                //   "onclick": _setLibraryImage,
                // }
              ]
            : [],
      );

      editSect = colorArrBg;
      toggleProfile.value = !toggleProfile.value;
    };

    //add init parameters for color array
    colorArrBg.updateFunct = _removeImage;
    if (user.profilePic != null) {
      topPic.image = Image.file(File(user.profilePic));
    }
    // if (!isBorderMode) {
    //   colorArrBg.additionalBtns = [
    //     {
    //       "icon": Icons.camera_alt_outlined,
    //       "onclick": _setCameraImage,
    //     },
    //     {
    //       "icon": Icons.photo_library_outlined,
    //       "onclick": _setLibraryImage,
    //     }
    //   ];
    // }

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => GestureDetector(
                  onTap: (() {
                    FocusScopeNode currentFocus = FocusScope.of(context);

                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  }),
                  child: Scaffold(
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
                      builder: (context, value, child) => SingleChildScrollView(
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
                                  onChanged: (newName) {
                                    if (newName.trim().length > 2) {
                                      backSpaceTrigger = true;
                                    }
                                    if (newName.trim().length < 2) {
                                      backSpaceTrigger = false;
                                    }

                                    if (newName.length == 2 &&
                                        !backSpaceTrigger) {
                                      name = newName;
                                      updateProfile();
                                    }
                                  },
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextButton(
                                      style: ButtonStyle(
                                          backgroundColor: !isBorderMode
                                              ? MaterialStateProperty.all<
                                                  Color>(kActiveColor)
                                              : MaterialStateProperty.all<
                                                  Color>(kLightBackgroundColor),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ))),
                                      onPressed: () {
                                        //print("pressed");
                                        if (!isBorderMode) return;
                                        isBorderMode = false;

                                        updateEditSect();
                                      },
                                      child: Text(
                                        "Background",
                                        style: TextStyle(
                                            color: !isBorderMode
                                                ? kBrightTextColor
                                                : Utils.lighten(kActiveColor)),
                                      )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextButton(
                                      style: ButtonStyle(
                                          backgroundColor: isBorderMode
                                              ? MaterialStateProperty.all<
                                                  Color>(kActiveColor)
                                              : MaterialStateProperty.all<
                                                  Color>(kLightBackgroundColor),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ))),
                                      onPressed: () {
                                        if (isBorderMode) return;
                                        isBorderMode = true;
                                        updateEditSect();
                                      },
                                      child: Text(
                                        "Border",
                                        style: TextStyle(
                                            color: isBorderMode
                                                ? kBrightTextColor
                                                : Utils.lighten(kActiveColor)),
                                      )),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: TextButton(
                                //       style: ButtonStyle(
                                //           backgroundColor: isImageMode
                                //               ? MaterialStateProperty.all<
                                //                   Color>(kActiveColor)
                                //               : MaterialStateProperty.all<
                                //                   Color>(kLightBackgroundColor),
                                //           shape: MaterialStateProperty.all<
                                //                   RoundedRectangleBorder>(
                                //               RoundedRectangleBorder(
                                //             borderRadius:
                                //                 BorderRadius.circular(5.0),
                                //           ))),
                                //       onPressed: () {
                                //         if (isImageMode) return;
                                //         isImageMode = true;
                                //         isBorderMode = false;
                                //         updateEditSect();
                                //       },
                                //       child: Text(
                                //         "Image",
                                //         style: TextStyle(
                                //             color: isImageMode
                                //                 ? kBrightTextColor
                                //                 : Utils.lighten(kActiveColor)),
                                //       )),
                                // ),
                              ],
                            ),
                            editSect,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: undoBtnColor),
                                    onPressed: () {
                                      if (undoBtnColor == kDisabledColor)
                                        return;
                                      //orig color index set
                                      colorArrBg.currentBg = color1;
                                      colorArrBg.currentBorder = color2;

                                      //remove username text
                                      myController.clear();
                                      name = user.username;

                                      //remove image
                                      imgUrl = user.profilePic;

                                      updateProfile();

                                      //change buttons
                                      isUpdated = false;
                                      saveBtnColor = kDisabledColor;
                                      undoBtnColor = kDisabledColor;

                                      //set orig colors
                                      updateEditSect();
                                    },
                                    child: Row(children: [
                                      Icon(
                                        Icons.undo,
                                        size: 17,
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(undoBtnText)
                                    ])),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: saveBtnColor),
                                    onPressed: () {
                                      if (saveBtnColor == kDisabledColor ||
                                          !_formKey.currentState.validate())
                                        return;
                                      Utils util = Utils();
                                      saveBtnText = "Save All";
                                      saveBtnColor = kDisabledColor;
                                      undoBtnColor = kDisabledColor;
                                      name = myController.text;

                                      isUpdated = false;
                                      toggleProfile.value =
                                          !toggleProfile.value;

                                      //update database
                                      user.profileBgColor =
                                          Utils.colorToHexString(
                                              colorArrBg.currentBg);
                                      user.profileBorderColor =
                                          Utils.colorToHexString(
                                              colorArrBg.currentBorder);
                                      user.username = myController.text.isEmpty
                                          ? user.username
                                          : myController.text;
                                      user.profilePic = imgUrl;

                                      FirebaseApi.updateUserData(user);
                                      util.showSnackBar(
                                          context, "Profile Updated", false);
                                      Timer(Duration(milliseconds: 1200), () {
                                        util.removeSnackBar();
                                      });
                                    },
                                    child: Text(saveBtnText))
                              ],
                            )
                          ]),
                        ),
                      ),
                    ),
                  ),
                ))));
    return user;
  }
}
