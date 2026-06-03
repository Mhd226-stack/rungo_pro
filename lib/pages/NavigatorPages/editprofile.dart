// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/common/responsive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_driver/pages/login/landingpage.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../login/carinformation.dart';
import '../login/profileinformation.dart';
import '../login/uploaddocument.dart';
import '../noInternet/nointernet.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

dynamic proImageFile;

class _EditProfileState extends State<EditProfile> {
  ImagePicker picker = ImagePicker();
  bool _isLoading = false;
  String _error = '';
  bool _pickImage = false;
  String _permission = '';
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();

//get gallery permission
  getGalleryPermission() async {
    dynamic status;
    if (platform == TargetPlatform.android) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        status = await Permission.storage.status;
        if (status != PermissionStatus.granted) {
          status = await Permission.storage.request();
        }

        /// use [Permissions.storage.status]
      } else {
        status = await Permission.photos.status;
        if (status != PermissionStatus.granted) {
          status = await Permission.photos.request();
        }
      }
    } else {
      status = await Permission.photos.status;
      if (status != PermissionStatus.granted) {
        status = await Permission.photos.request();
      }
    }
    return status;
  }

  navigateLogout() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LandingPage()));
  }

//get camera permission
  getCameraPermission() async {
    var status = await Permission.camera.status;
    if (status != PermissionStatus.granted) {
      status = await Permission.camera.request();
    }
    return status;
  }

//pick image from gallery
  pickImageFromGallery() async {
    var permission = await getGalleryPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      setState(() {
        proImageFile = pickedFile?.path;
        _pickImage = false;
      });
    } else {
      setState(() {
        _permission = 'noPhotos';
      });
    }
  }

//pick image from camera
  pickImageFromCamera() async {
    var permission = await getCameraPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      setState(() {
        proImageFile = pickedFile?.path;
        _pickImage = false;
      });
    } else {
      setState(() {
        _permission = 'noCamera';
      });
    }
  }

  @override
  void initState() {
    _error = '';
    proImageFile = null;
    name.text = userDetails['name'];
    email.text = userDetails['email'];
    super.initState();
  }

  pop() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(media.width * 0.05),
              height: media.height * 1,
              width: media.width * 1,
              color: page,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: MediaQuery.of(context).padding.top),
                          Stack(
                            children: [
                              Container(
                                padding:
                                    EdgeInsets.only(bottom: media.width * 0.05),
                                height: media.height * 0.07,
                                width: media.width * 1,
                                alignment: Alignment.center,
                                child: PageTitleTextAdject(
                                  child: MyText(
                                    text: languages[choosenLanguage]
                                        ['text_editprofile'],
                                    size: media.width * eighteen,
                                    fontweight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Positioned(
                                  child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: IosBackButton()))
                            ],
                          ),
                          SizedBox(height: media.width * 0.08),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _pickImage = true;
                              });
                            },
                            child: Stack(
                              children: [
                                Container(
                                  height: media.width * 0.2,
                                  width: media.width * 0.2,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: buttonColor,
                                  ),
                                  child: ClipOval(
                                    child: (userDetails['profile_picture'] != null &&
                                        userDetails['profile_picture'].toString().isNotEmpty)
                                        ? Image.network(
                                      userDetails['profile_picture'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Icon(
                                        Icons.person,
                                        size: media.width * 0.1,
                                        color: Colors.white,
                                      ),
                                    )
                                        : Icon(
                                      Icons.person,
                                      size: media.width * 0.1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Positioned(
                                    right: media.width * 0.04,
                                    bottom: media.width * 0.02,
                                    child: Container(
                                      height: media.width * 0.07,
                                      width: media.width * 0.07,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: buttonColor),
                                      child: Icon(
                                        Icons.edit_outlined,
                                        color: white,
                                        size: media.width * 0.045,
                                      ),
                                    ))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: media.width * 0.05,
                          ),
                          GestureDetector(
                            onTap: () {
                              // print(userDetails);
                            },
                            child: Container(
                              padding: EdgeInsets.all(media.width * 0.04),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: darkModeSecContainer),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      MyText(
                                        text: languages[choosenLanguage]
                                            ['text_profile'],
                                        size: media.width * eighteen,
                                        fontweight: FontWeight.w500,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          var nav = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfileInformation(
                                                          from: 'edit')));
                                          if (nav != null) {
                                            if (nav) {
                                              setState(() {});
                                            }
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: buttonColor,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          padding: EdgeInsets.fromLTRB(
                                              media.width * 0.02,
                                              media.width * 0.005,
                                              media.width * 0.02,
                                              media.width * 0.005),
                                          child: Row(
                                            children: [
                                              MyText(
                                                text: languages[choosenLanguage]
                                                    ['text_edit'],
                                                size: media.width * eleven,
                                                fontweight: FontWeight.w500,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Icon(
                                                Icons.edit,
                                                color: white,
                                                size: media.width * 0.035,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: media.width * 0.02,
                                  ),
                                  ProfileDetails(
                                      heading: languages[choosenLanguage]
                                          ['text_name'],
                                      value: userDetails['name']),
                                  ProfileDetails(
                                      heading: languages[choosenLanguage]
                                          ['text_mobile'],
                                      value: userDetails['mobile']),
                                  ProfileDetails(
                                      heading: languages[choosenLanguage]
                                          ['text_email'],
                                      value: userDetails['email']),
                                  ProfileDetails(
                                      heading: languages[choosenLanguage]
                                          ['text_wok_area'],
                                      value:
                                          userDetails['service_location_name']),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: media.width * 0.05,
                          ),
                          (userDetails['role'] != 'owner')
                              ? Container(
                                  padding: EdgeInsets.all(media.width * 0.04),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: darkModeSecContainer),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Row(
                                              children: [
                                                Flexible(child: MyText(
                                                  text: languages[choosenLanguage]
                                                  ['text_car_info'],
                                                  size: media.width * eighteen,
                                                  fontweight: FontWeight.w500,
                                                  overflow: TextOverflow.ellipsis,
                                                ))
                                              ],
                                            )),
                                          (userDetails['owner_id'] == null)
                                              ? InkWell(
                                                  onTap: () async {
                                                    myServiceId = userDetails[
                                                        'service_location_id'];

                                                    var nav =
                                                        await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        CarInformation(
                                                                          frompage:
                                                                              2,
                                                                        )));
                                                    if (nav != null) {
                                                      if (nav) {
                                                        setState(() {});
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: buttonColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            media.width * 0.02,
                                                            media.width * 0.005,
                                                            media.width * 0.02,
                                                            media.width *
                                                                0.005),
                                                    child: Row(
                                                      children: [
                                                        MyText(
                                                          text: languages[
                                                                  choosenLanguage]
                                                              ['text_edit'],
                                                          size: media.width *
                                                              eleven,
                                                          fontweight:
                                                              FontWeight.w500,
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Icon(
                                                          Icons.edit,
                                                          color: white,
                                                          size: media.width *
                                                              0.035,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                      SizedBox(
                                        height: media.width * 0.02,
                                      ),
                                      (userDetails['owner_id'] != null &&
                                              userDetails[
                                                      'vehicle_type_name'] ==
                                                  null)
                                          ? Row(
                                              children: [
                                                MyText(
                                                  text: languages[
                                                          choosenLanguage][
                                                      'text_no_fleet_assigned'],
                                                  size: media.width * eighteen,
                                                  fontweight: FontWeight.bold,
                                                ),
                                              ],
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 60,
                                                      child: MyText(
                                                          text: languages[
                                                                  choosenLanguage]
                                                              ['text_type'],
                                                          fontweight:
                                                              FontWeight.w500,
                                                          color: hintColor,
                                                          size: media.width *
                                                              fourteen),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          media.width * 0.02,
                                                    ),
                                                    Expanded(
                                                      flex: 40,
                                                      child: Wrap(
                                                        children: [
                                                          if (userDetails[
                                                                  'owner_id'] ==
                                                              null)
                                                            for (int i = 0;
                                                                i <=
                                                                    userDetails['driverVehicleType']['data']
                                                                            .length -
                                                                        1;
                                                                i++)
                                                              MyText(
                                                                text:
                                                                    '${userDetails['driverVehicleType']['data'][i]['vehicletype_name']} ',
                                                                size: media
                                                                        .width *
                                                                    fourteen,
                                                                fontweight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    textColor,
                                                              ),
                                                          if (userDetails[
                                                                  'owner_id'] !=
                                                              null)
                                                            MyText(
                                                              text: userDetails[
                                                                  'vehicle_type_name'],
                                                              size:
                                                                  media.width *
                                                                      sixteen,
                                                              color: textColor,
                                                              fontweight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.02,
                                                ),
                                                ProfileDetails(
                                                    heading: languages[
                                                            choosenLanguage]
                                                        ['text_make_name'],
                                                    value: userDetails[
                                                        'car_make_name']),
                                                ProfileDetails(
                                                    heading: languages[
                                                            choosenLanguage]
                                                        ['text_model_name'],
                                                    value: userDetails[
                                                        'car_model_name']),
                                                ProfileDetails(
                                                    heading: languages[
                                                            choosenLanguage]
                                                        ['text_license'],
                                                    value: userDetails[
                                                        'car_number']),
                                                // ProfileDetails(
                                                //     heading: languages[
                                                //             choosenLanguage]
                                                //         ['text_color'],
                                                //     value: userDetails[
                                                //         'car_color']),
                                              ],
                                            )
                                    ],
                                  ),
                                )
                              : Container(),
                          SizedBox(
                            height: media.width * 0.05,
                          ),
                          Container(
                            padding: EdgeInsets.all(media.width * 0.03),
                            decoration: BoxDecoration(
                              color: darkModeSecContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        MyText(
                                          text: languages[choosenLanguage]
                                              ['text_docs'],
                                          size: media.width * eighteen,
                                          fontweight: FontWeight.w500,
                                        )
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        var nav = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UploadDocument()));
                                        if (nav != null) {
                                          if (nav) {
                                            setState(() {});
                                          }
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: buttonColor,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        padding: EdgeInsets.fromLTRB(
                                            media.width * 0.02,
                                            media.width * 0.005,
                                            media.width * 0.02,
                                            media.width * 0.005),
                                        child: Row(
                                          children: [
                                            MyText(
                                              text: languages[choosenLanguage]
                                                  ['text_edit'],
                                              size: media.width * eleven,
                                              fontweight: FontWeight.w500,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Icon(
                                              Icons.edit,
                                              color: white,
                                              size: media.width * 0.035,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (_error != '')
                    Container(
                      padding: EdgeInsets.only(top: media.width * 0.02),
                      child: MyText(
                        text: _error,
                        size: media.width * twelve,
                        color: Colors.red,
                      ),
                    ),
                  if (proImageFile != null)
                    Container(
                        padding: EdgeInsets.only(top: media.width * 0.02),
                        width: media.width * 0.9,
                        child: Button(
                            onTap: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              dynamic val;

                              val = await updateProfile(
                                userDetails['name'],
                                userDetails['email'],
                                // userDetails['mobile']
                              );

                              if (val == 'success') {
                                proImageFile = null;
                              } else {
                                setState(() {
                                  _error = val.toString();
                                });
                              }
                              setState(() {
                                _isLoading = false;
                              });
                            },
                            text: languages[choosenLanguage]['text_confirm'])),
                  ButtonBottomSpace()
                ],
              ),
            ),

            //pick image popup
            (_pickImage == true)
                ? Positioned(
                    bottom: 0,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _pickImage = false;
                        });
                      },
                      child: Container(
                        height: media.height * 1,
                        width: media.width * 1,
                        color: Colors.transparent.withOpacity(0.6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.all(media.width * 0.05),
                              width: media.width * 1,
                              height: Responsive.height(20, context),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30)),
                                  border: Border.all(
                                    color: darkModeBorderColor,
                                  ),
                                  color: page),
                              child: Column(
                                children: [
                                  Container(
                                    height: media.width * 0.02,
                                    width: media.width * 0.25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          media.width * 0.01),
                                      color: white.withOpacity(0.3),
                                    ),
                                  ),
                                  SizedBox(
                                    height: media.width * 0.1,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          InkWell(
                                              onTap: () {
                                                pickImageFromCamera();
                                              },
                                              child: Icon(
                                                Icons.camera_alt_outlined,
                                                size: media.width * 0.09,
                                                color: textColor,
                                              )),
                                          SizedBox(
                                            height: media.width * 0.02,
                                          ),
                                          MyText(
                                            text: languages[choosenLanguage]
                                                ['text_camera'],
                                            size: media.width * ten,
                                            color: textColor,
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          InkWell(
                                              onTap: () {
                                                pickImageFromGallery();
                                              },
                                              child: Icon(
                                                Icons.image_outlined,
                                                size: media.width * 0.09,
                                                color: textColor,
                                              )),
                                          SizedBox(
                                            height: media.width * 0.02,
                                          ),
                                          MyText(
                                            text: languages[choosenLanguage]
                                                ['text_gallery'],
                                            size: media.width * ten,
                                            color: textColor,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                : Container(),

            //permission denied popup
            (_permission != '')
                ? Positioned(
                    child: Container(
                    height: media.height * 1,
                    width: media.width * 1,
                    color: Colors.transparent.withOpacity(0.6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: media.width * 0.9,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _permission = '';
                                    _pickImage = false;
                                  });
                                },
                                child: Container(
                                  height: media.width * 0.1,
                                  width: media.width * 0.1,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle, color: page),
                                  child: Icon(Icons.cancel_outlined,
                                      color: textColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: media.width * 0.05,
                        ),
                        Container(
                          padding: EdgeInsets.all(media.width * 0.05),
                          width: media.width * 0.9,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: page,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 2.0,
                                    spreadRadius: 2.0,
                                    color: Colors.black.withOpacity(0.2))
                              ]),
                          child: Column(
                            children: [
                              SizedBox(
                                  width: media.width * 0.8,
                                  child: MyText(
                                    text: (_permission == 'noPhotos')
                                        ? languages[choosenLanguage]
                                            ['text_open_photos_setting']
                                        : languages[choosenLanguage]
                                            ['text_open_camera_setting'],
                                    size: media.width * sixteen,
                                    fontweight: FontWeight.w600,
                                  )),
                              SizedBox(height: media.width * 0.05),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                      onTap: () async {
                                        await openAppSettings();
                                      },
                                      child: MyText(
                                        text: languages[choosenLanguage]
                                            ['text_open_settings'],
                                        size: media.width * sixteen,
                                        fontweight: FontWeight.w600,
                                        color: buttonColor,
                                      )),
                                  InkWell(
                                      onTap: () async {
                                        (_permission == 'noCamera')
                                            ? pickImageFromCamera()
                                            : pickImageFromGallery();
                                        setState(() {
                                          _permission = '';
                                        });
                                      },
                                      child: MyText(
                                        text: languages[choosenLanguage]
                                            ['text_done'],
                                        size: media.width * sixteen,
                                        fontweight: FontWeight.w600,
                                        color: buttonColor,
                                      ))
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ))
                : Container(),
            //loader
            (_isLoading == true)
                ? const Positioned(top: 0, child: Loading())
                : Container(),

            //error
            (_error != '')
                ? Positioned(
                    child: Container(
                    height: media.height * 1,
                    width: media.width * 1,
                    color: Colors.transparent.withOpacity(0.6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(media.width * 0.05),
                          width: media.width * 0.9,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: page),
                          child: Column(
                            children: [
                              SizedBox(
                                width: media.width * 0.8,
                                child: MyText(
                                  text: _error.toString(),
                                  textAlign: TextAlign.center,
                                  size: media.width * sixteen,
                                  fontweight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: media.width * 0.05,
                              ),
                              Button(
                                  onTap: () async {
                                    setState(() {
                                      _error = '';
                                    });
                                  },
                                  text: languages[choosenLanguage]['text_ok'])
                            ],
                          ),
                        )
                      ],
                    ),
                  ))
                : Container(),

            //no internet
            (internet == false)
                ? Positioned(
                    top: 0,
                    child: NoInternet(
                      onTap: () {
                        setState(() {
                          internetTrue();
                        });
                      },
                    ))
                : Container(),
          ],
        ),
      ),
    );
  }
}

class ProfileDetails extends StatelessWidget {
  final String heading;
  final String value;
  const ProfileDetails({
    Key? key,
    required this.heading,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 60,
              child: MyText(
                text: heading,
                size: media.width * fourteen,
                fontweight: FontWeight.w500,
                color: hintColor,
              ),
            ),
            Expanded(
              flex: 40,
              child: MyText(
                text: value,
                size: media.width * fourteen,
                fontweight: FontWeight.w500,
                color: textColor,
              ),
            )
          ],
        ),
        SizedBox(
          height: media.width * 0.02,
        ),
      ],
    );
  }
}
