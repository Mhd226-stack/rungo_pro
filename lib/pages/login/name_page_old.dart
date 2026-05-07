import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/responsive.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../NavigatorPages/editprofile.dart';
import 'login.dart';

String name = ''; //name of user

class NamePage extends StatefulWidget {
  const NamePage({Key? key}) : super(key: key);

  @override
  State<NamePage> createState() => _NamePageState();
}

bool isverifyemail = false;
String email = ''; // email of user
String _error = '';
// dynamic proImageFile1;
var pickImageNamePage = false;

class _NamePageState extends State<NamePage> {
  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController emailtext = TextEditingController();
  TextEditingController controller = TextEditingController();
  FocusNode firstNameFn = FocusNode();
  FocusNode lastNameFn = FocusNode();
  FocusNode emailFn = FocusNode();

  @override
  void initState() {
    proImageFile = null;
    profilepicturecontroller = StreamController.broadcast();
    _error = '';

    if (isLoginemail == true) {
      emailtext.text = email;
    }
    super.initState();
  }

  showToast() {
    setState(() {
      showtoast = true;
    });
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        showtoast = false;
      });
    });
  }

  showNewToast() {
    setState(() {
      _showtoast = true;
    });
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _showtoast = false;
      });
    });
  }

  bool showtoast = false;
  bool _showtoast = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      color: page,
      child: Scaffold(
        backgroundColor: page,
        body: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: media.height * 0.02),
                          MyText(
                            text: languages[choosenLanguage]['text_your_name'],
                            size: media.width * twentytwo,
                            fontweight: FontWeight.w700,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          MyText(
                              text: languages[choosenLanguage]
                                  ['text_prob_name'],
                              size: media.width * fourteen,
                              color: textColor.withOpacity(0.5),
                              fontweight: FontWeight.w400),
                          SizedBox(
                            height: Responsive.height(2, context),
                          ),
                          StreamBuilder(
                              stream: profilepicturestream,
                              builder: (context, snapshot) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          pickImageNamePage = true;
                                        });
                                        // print(countries[phcode]);
                                      },
                                      child: Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          Container(
                                            height: media.width * 0.3,
                                            width: media.width * 0.3,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: page,
                                                image: (proImageFile == null)
                                                    ? const DecorationImage(
                                                        image: AssetImage(
                                                          'assets/images/default_profile.png',
                                                        ),
                                                        fit: BoxFit.cover)
                                                    : DecorationImage(
                                                        image: FileImage(
                                                            File(proImageFile)),
                                                        fit: BoxFit.cover)),
                                          ),
                                          Positioned(
                                              child: Container(
                                            height: media.width * 0.08,
                                            width: media.width * 0.08,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: buttonColor),
                                            child: Icon(
                                              Icons.edit,
                                              color: topBar,
                                              size: media.width * 0.05,
                                            ),
                                          ))
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                          SizedBox(
                            height: Responsive.height(3, context),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                    height: media.width * 0.13,
                                    decoration: BoxDecoration(
                                      color: page,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: darkModeBorderColor),
                                    ),
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 15),
                                    child: MyTextField(
                                        focusNode: firstNameFn,
                                        inputAction: TextInputAction.next,
                                        onInputActionComplete: () {
                                          FocusScope.of(context)
                                              .requestFocus(lastNameFn);
                                        },
                                        fontsize: media.width * fourteen,
                                        textController: firstname,
                                        hinttext: languages[choosenLanguage]
                                            ['text_first_name'],
                                        inputType: TextInputType.text,
                                        onTap: (val) {
                                          setState(() {});
                                        })),
                              ),
                              SizedBox(
                                width: media.height * 0.01,
                              ),
                              Expanded(
                                child: Container(
                                    height: media.width * 0.13,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: darkModeBorderColor),
                                    ),
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 15),
                                    child: MyTextField(
                                      focusNode: lastNameFn,
                                      inputAction: TextInputAction.next,
                                      onInputActionComplete: () {
                                        FocusScope.of(context)
                                            .requestFocus(emailFn);
                                      },
                                      hinttext: languages[choosenLanguage]
                                          ['text_last_name'],
                                      inputType: TextInputType.text,
                                      textController: lastname,
                                      onTap: (val) {
                                        setState(() {});
                                      },
                                    )),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: media.height * 0.01,
                          ),
                          Container(
                              height: media.width * 0.13,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: darkModeBorderColor),
                              ),
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15),
                              child: MyTextField(
                                focusNode: emailFn,
                                inputAction: TextInputAction.done,
                                textController: emailtext,
                                readonly:
                                    (isfromomobile == false) ? true : false,
                                hinttext: languages[choosenLanguage]
                                    ['text_enter_email'],
                                shouldCapatalize: false,
                                inputType: TextInputType.emailAddress,
                                onTap: (val) {
                                  setState(() {});
                                },
                              )),
                          SizedBox(
                            height: media.width *
                                ((isfromomobile == false) ? 0.05 : 0),
                          ),
                          (isfromomobile == false)
                              ? Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  height: 50,
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                    color: page,
                                    borderRadius: BorderRadius.circular(14),
                                    border:
                                        Border.all(color: darkModeBorderColor),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (countries.isNotEmpty) {
                                            //dialod box for select country for dial code
                                            await showDialog(
                                                context: context,
                                                builder: (context) {
                                                  var searchVal = '';
                                                  return AlertDialog(
                                                    backgroundColor: page,
                                                    insetPadding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    content: StatefulBuilder(
                                                        builder: (context,
                                                            setState) {
                                                      return Container(
                                                        width:
                                                            media.width * 0.9,
                                                        color: page,
                                                        child: Directionality(
                                                          textDirection:
                                                              (languageDirection ==
                                                                      'rtl')
                                                                  ? TextDirection
                                                                      .rtl
                                                                  : TextDirection
                                                                      .ltr,
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            20,
                                                                        right:
                                                                            20),
                                                                height: 40,
                                                                width: media
                                                                        .width *
                                                                    0.9,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey,
                                                                        width:
                                                                            1.5)),
                                                                child:
                                                                    TextField(
                                                                  decoration: InputDecoration(
                                                                      contentPadding: (languageDirection ==
                                                                              'rtl')
                                                                          ? EdgeInsets.only(
                                                                              bottom: media.width *
                                                                                  0.035)
                                                                          : EdgeInsets.only(
                                                                              bottom: media.width *
                                                                                  0.04),
                                                                      border: InputBorder
                                                                          .none,
                                                                      hintText:
                                                                          languages[choosenLanguage][
                                                                              'text_search'],
                                                                      hintStyle: GoogleFonts.inter(
                                                                          fontSize: media.width *
                                                                              sixteen,
                                                                          color:
                                                                              hintColor)),
                                                                  style: GoogleFonts.inter(
                                                                      fontSize:
                                                                          media.width *
                                                                              sixteen,
                                                                      color:
                                                                          textColor),
                                                                  onChanged:
                                                                      (val) {
                                                                    setState(
                                                                        () {
                                                                      searchVal =
                                                                          val;
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 20),
                                                              Expanded(
                                                                child:
                                                                    SingleChildScrollView(
                                                                  child: Column(
                                                                    children: countries
                                                                        .asMap()
                                                                        .map((i, value) {
                                                                          return MapEntry(
                                                                              i,
                                                                              SizedBox(
                                                                                width: media.width * 0.9,
                                                                                child: (searchVal == '' && countries[i]['flag'] != null)
                                                                                    ? InkWell(
                                                                                        onTap: () {
                                                                                          setState(() {
                                                                                            phcode = i;
                                                                                          });
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: Container(
                                                                                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                                                          color: page,
                                                                                          child: Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            children: [
                                                                                              Row(
                                                                                                children: [
                                                                                                  Image.network(countries[i]['flag']),
                                                                                                  SizedBox(
                                                                                                    width: media.width * 0.02,
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    width: media.width * 0.4,
                                                                                                    child: MyText(
                                                                                                      text: countries[i]['name'],
                                                                                                      size: media.width * sixteen,
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                              MyText(text: countries[i]['dial_code'], size: media.width * sixteen)
                                                                                            ],
                                                                                          ),
                                                                                        ))
                                                                                    : (countries[i]['flag'] != null && countries[i]['name'].toLowerCase().contains(searchVal.toLowerCase()))
                                                                                        ? InkWell(
                                                                                            onTap: () {
                                                                                              setState(() {
                                                                                                phcode = i;
                                                                                              });
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                            child: Container(
                                                                                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                                                              color: page,
                                                                                              child: Row(
                                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                children: [
                                                                                                  Row(
                                                                                                    children: [
                                                                                                      Image.network(countries[i]['flag']),
                                                                                                      SizedBox(
                                                                                                        width: media.width * 0.02,
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                        width: media.width * 0.4,
                                                                                                        child: MyText(text: countries[i]['name'], size: media.width * sixteen),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                  MyText(text: countries[i]['dial_code'], size: media.width * sixteen)
                                                                                                ],
                                                                                              ),
                                                                                            ))
                                                                                        : Container(),
                                                                              ));
                                                                        })
                                                                        .values
                                                                        .toList(),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  );
                                                });
                                          } else {
                                            getCountryCode();
                                          }
                                          setState(() {});
                                        },
                                        //input field
                                        child: Container(
                                          height: 50,
                                          alignment: Alignment.center,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Image.network(
                                                  countries[phcode]['flag']),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Icon(
                                                Icons.arrow_drop_down,
                                                size: 20,
                                                color: textColor,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                height: Responsive.height(
                                                    4, context),
                                                width: 2,
                                                color: darkModeBorderColor,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        width: 1,
                                        height: 55,
                                        color: underline,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.bottomCenter,
                                          height: 50,
                                          child: TextFormField(
                                            textAlign: TextAlign.start,
                                            controller: controller,
                                            onChanged: (val) {
                                              setState(() {
                                                phnumber = controller.text;
                                              });
                                              if (controller.text.length ==
                                                  countries[phcode]
                                                      ['dial_max_length']) {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                              }
                                            },
                                            maxLength: countries[phcode]
                                                ['dial_max_length'],
                                            style: choosenLanguage == 'ar'
                                                ? GoogleFonts.cairo(
                                                    color: textColor,
                                                    fontSize:
                                                        media.width * sixteen,
                                                    letterSpacing: 1)
                                                : GoogleFonts.inter(
                                                    color: textColor,
                                                    fontSize:
                                                        media.width * sixteen,
                                                    letterSpacing: 1),
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              counterText: '',
                                              prefixIcon: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: MyText(
                                                  text: countries[phcode]
                                                          ['dial_code']
                                                      .toString(),
                                                  size: media.width * sixteen,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              hintStyle: choosenLanguage == 'ar'
                                                  ? GoogleFonts.cairo(
                                                      color: textColor
                                                          .withOpacity(0.7),
                                                      fontSize:
                                                          media.width * sixteen,
                                                    )
                                                  : GoogleFonts.inter(
                                                      color: textColor
                                                          .withOpacity(0.7),
                                                      fontSize:
                                                          media.width * sixteen,
                                                    ),
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Container(),
                          SizedBox(
                            height: Responsive.height(7, context),
                          ),
                          if (_error != '')
                            Column(
                              children: [
                                SizedBox(
                                    width: media.width * 0.9,
                                    child: MyText(
                                      text: _error,
                                      color: Colors.red,
                                      size: media.width * fourteen,
                                      textAlign: TextAlign.center,
                                    )),
                                SizedBox(
                                  height: media.width * 0.025,
                                )
                              ],
                            ),
                          SizedBox(
                            height: 10,
                          ),
                          (isfromomobile == true)
                              ? Column(
                                  children: [
                                    Button(
                                        onTap: () async {
                                          if (firstname.text.isNotEmpty &&
                                              emailtext.text.isNotEmpty &&
                                              (proImageFile != null &&
                                                  proImageFile.isNotEmpty)) {
                                            setState(() {
                                              _error = '';
                                            });
                                            loginLoading = true;
                                            valueNotifierLogin
                                                .incrementNotifier();
                                            String pattern =
                                                r"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])*$";
                                            RegExp regex = RegExp(pattern);
                                            if (regex
                                                .hasMatch(emailtext.text)) {
                                              setState(() {
                                                _error = '';
                                              });
                                              FocusScope.of(context).unfocus();
                                              if (lastname.text != '') {
                                                name =
                                                    '${firstname.text} ${lastname.text}';
                                              } else {
                                                name = firstname.text;
                                              }
                                              email = emailtext.text;
                                              var result = await validateEmail(
                                                  emailtext.text);
                                              if (result == 'success') {
                                                isfromomobile = true;
                                                isverifyemail = true;

                                                currentPage = 3;
                                              } else {
                                                setState(() {
                                                  _error = result.toString();
                                                });
                                                // showToast();
                                              }
                                            } else {
                                              // showToast();
                                              setState(() {
                                                _error = languages[
                                                        choosenLanguage]
                                                    ['text_email_validation'];
                                              });
                                              // showToast();
                                            }
                                            loginLoading = false;
                                            valueNotifierLogin
                                                .incrementNotifier();
                                          } else {
                                            showNewToast();
                                          }
                                        },
                                        color: (firstname.text.isNotEmpty &&
                                                emailtext.text.isNotEmpty &&
                                                (proImageFile != null &&
                                                    proImageFile.isNotEmpty))
                                            ? buttonColor
                                            : darkModeSecContainer,
                                        text: languages[choosenLanguage]
                                            ['text_next'])
                                  ],
                                )
                              : Container(
                                  width: media.width * 1 - media.width * 0.08,
                                  alignment: Alignment.center,
                                  child: Button(
                                    onTap: () async {
                                      if (firstname.text.isNotEmpty &&
                                          controller.text.length >=
                                              countries[phcode]
                                                  ['dial_min_length'] &&
                                          (proImageFile != null &&
                                              proImageFile.isNotEmpty)) {
                                        if (lastname.text != '') {
                                          name =
                                              '${firstname.text} ${lastname.text}';
                                        } else {
                                          name = firstname.text;
                                        }
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        loginLoading = true;
                                        valueNotifierLogin.incrementNotifier();
                                        var val = await otpCall();
                                        if (val.value == true) {
                                          phoneAuthCheck = true;
                                          await phoneAuth(countries[phcode]
                                                  ['dial_code'] +
                                              phnumber);
                                          value = 0;
                                          currentPage = 3;
                                        } else {
                                          value = 0;
                                          isverifyemail = true;
                                          phoneAuthCheck = false;
                                          isfromomobile = true;
                                          currentPage = 1;
                                        }
                                        loginLoading = false;
                                        valueNotifierLogin.incrementNotifier();
                                      } else {
                                        showNewToast();
                                      }
                                    },
                                    color: (firstname.text.isNotEmpty &&
                                            controller.text.length >=
                                                countries[phcode]
                                                    ['dial_min_length'] &&
                                            (proImageFile != null &&
                                                proImageFile.isNotEmpty))
                                        ? buttonColor
                                        : darkModeSecContainer,
                                    text: languages[choosenLanguage]
                                        ['text_next'],
                                  ),
                                ),
                          SizedBox(
                            height: media.height * 0.05,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              (_showtoast == true)
                  ? Positioned(
                      bottom: media.height * 0.3,
                      child: Container(
                        padding: EdgeInsets.all(media.width * 0.025),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.transparent.withOpacity(0.6)),
                        child: MyText(
                          text: languages[choosenLanguage]
                              ['text_fill_all_info'],
                          size: media.width * sixteen,
                          color: textColor,
                        ),
                      ))
                  : Container(),
              //pick image bar
              (pickImageNamePage == true)
                  ? Positioned(
                      child: GestureDetector(
                      onTap: () {
                        setState(() {
                          pickImageNamePage = false;
                        });
                      },
                      child: Container(
                        height: media.height * 1,
                        width: media.width * 1,
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.all(media.width * 0.05),
                              width: media.width * 1,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20)),
                                  color: page),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: media.width * 0.02,
                                    width: media.width * 0.25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          media.width * 0.01),
                                      color: white,
                                    ),
                                  ),
                                  SizedBox(
                                    height: media.width * 0.07,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              pickImageFromCamera();
                                            },
                                            child: Container(
                                                height: media.width * 0.16,
                                                width: media.width * 0.2,
                                                decoration: BoxDecoration(
                                                    color: darkModeSecContainer,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Icon(
                                                  Icons.camera_alt_outlined,
                                                  size: media.width * 0.1,
                                                  color: textColor,
                                                )),
                                          ),
                                          SizedBox(
                                            height: media.width * 0.02,
                                          ),
                                          MyText(
                                            text: languages[choosenLanguage]
                                                ['text_camera'],
                                            size: media.width * fifteen,
                                            fontweight: FontWeight.w500,
                                            color: textColor,
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              pickImageFromGallery();
                                            },
                                            child: Container(
                                                height: media.width * 0.16,
                                                width: media.width * 0.2,
                                                decoration: BoxDecoration(
                                                    color: darkModeSecContainer,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Icon(
                                                  Icons.image_outlined,
                                                  color: white,
                                                  size: media.width * 0.1,
                                                )),
                                          ),
                                          SizedBox(
                                            height: media.width * 0.02,
                                          ),
                                          MyText(
                                            text: languages[choosenLanguage]
                                                ['text_gallery'],
                                            size: media.width * fifteen,
                                            fontweight: FontWeight.w500,
                                            color: textColor,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                  : Container(),
              //display toast
              (showtoast == true)
                  ? Positioned(
                      bottom: media.width * 0.1,
                      left: media.width * 0.06,
                      right: media.width * 0.06,
                      child: Container(
                        padding: EdgeInsets.all(media.width * 0.04),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 2.0,
                                  spreadRadius: 2.0,
                                  color: Colors.black.withOpacity(0.2))
                            ],
                            color: verifyDeclined),
                        child: Text(
                          _error,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              fontSize: media.width * fourteen,
                              fontWeight: FontWeight.w600,
                              color: textColor),
                        ),
                      ))
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
