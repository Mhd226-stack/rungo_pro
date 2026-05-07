import 'package:flutter/material.dart';
import 'package:flutter_driver/common/responsive.dart';
import 'package:flutter_driver/pages/onTripPage/map_page.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import 'carinformation.dart';
import 'namepage.dart';
import 'ownerregister.dart';
import 'profileinformation.dart';
import 'uploaddocument.dart';

class RequiredInformation extends StatefulWidget {
  const RequiredInformation({Key? key}) : super(key: key);

  @override
  State<RequiredInformation> createState() => _RequiredInformationState();
}

bool profileCompleted = false;
bool carInformationCompleted = false;
bool documentCompleted = false;

class _RequiredInformationState extends State<RequiredInformation> {
  bool showPopAlert = false;
  @override
  void initState() {
    setState(() {
      profileCompleted = true;
    });
    super.initState();
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
            ValueListenableBuilder(
                valueListenable: valueNotifierHome.value,
                builder: (context, value, child) {
                  if (userDetails['approve'] == true) {
                    Future.delayed(const Duration(milliseconds: 0), () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const Maps()),
                          (route) => false);
                    });
                  }
                  return Container(
                    padding: EdgeInsets.only(
                        left: media.width * 0.05, right: media.width * 0.05),
                    height: media.height * 1,
                    width: media.width * 1,
                    color: page,
                    child: Column(
                      children: [
                        SizedBox(
                          height: media.width * 0.05 +
                              MediaQuery.of(context).padding.top,
                        ),
                        Stack(
                          children: [
                            Container(
                              width: media.width * 1,
                              height: media.height * 0.04,
                              alignment: Alignment.bottomCenter,
                              child: PageTitleTextAdject(
                                child: MyText(
                                    text: languages[choosenLanguage]
                                        ['text_register'],
                                    fontweight: FontWeight.w600,
                                    size: media.width * twentythree),
                              ),
                            ),
                            if (userDetails.isEmpty)
                              Positioned(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            showPopAlert = true;
                                          });
                                        },
                                        child: IosBackButton()),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        SizedBox(
                          height: media.width * 0.05,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: Responsive.height(1.5, context),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      child: MyText(
                                        text: (" ${languages[choosenLanguage]['text_welcome']}"
                                            " ${userDetails.isEmpty ? name.toString().split(' ')[0] : userDetails['name']}"),
                                        size: media.width * twelve,
                                      ),
                                    ),
                                  ],
                                ),
                                // SizedBox(
                                //   height: media.width * 0.02,
                                // ),
                                // Row(
                                //   children: [
                                //     SizedBox(
                                //       width: 10,
                                //     ),
                                //     SizedBox(
                                //       child: MyText(
                                //         text: languages[choosenLanguage]
                                //             ['text_reqinfo'],
                                //         size: media.width * fourteen,
                                //         fontweight: FontWeight.bold,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                SizedBox(
                                  height: media.width * 0.02,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 14,
                                    ),
                                    SizedBox(
                                      width: media.width * 0.8,
                                      child: MyText(
                                        text: languages[choosenLanguage]
                                            ['text_become_captain'],
                                        size: media.width * twelve,
                                      ),
                                    ),
                                  ],
                                ),
                                documentCompleted == true ||
                                        userDetails['uploaded_document'] == true
                                    ? SizedBox()
                                    : SizedBox(
                                        height: media.width * 0.1,
                                      ),
                                if (documentCompleted == true ||
                                    userDetails['uploaded_document'] == true)
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: media.width * 0.04,
                                      ),
                                      Container(
                                        width: Responsive.width(90, context),
                                        height: 1,
                                        color: darkModeBorderColor,
                                      ),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              (userDetails['declined_reason'] ==
                                                      null)
                                                  ? Image.asset(
                                                      'assets/images/proposal_approval.png',
                                                      width:
                                                          media.width * 0.045,
                                                      height:
                                                          media.width * 0.045,
                                                    )
                                                  : Icon(
                                                      Icons.info,
                                                      size: media.width * 0.045,
                                                      color: Colors.red,
                                                    ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              SizedBox(
                                                width: media.width * 0.7,
                                                child: (userDetails[
                                                            'declined_reason'] ==
                                                        null)
                                                    ? MyText(
                                                        text: languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_waiting_approval'],
                                                        size: media.width *
                                                            eighteen,
                                                        fontweight:
                                                            FontWeight.w500,
                                                      )
                                                    : MyText(
                                                        text: languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_account_declined'],
                                                        size: media.width *
                                                            eighteen,
                                                        fontweight:
                                                            FontWeight.w500,
                                                      ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: media.width * 0.02,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: media.width * 0.055),
                                            child: SizedBox(
                                              width: media.width * 0.9,
                                              child: MyText(
                                                  text:
                                                      languages[choosenLanguage]
                                                          ['text_eva_profile'],
                                                  size: media.width * ten),
                                            ),
                                          ),
                                          SizedBox(
                                            height: media.width * 0.02,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: media.width * 0.055),
                                            child: SizedBox(
                                              width: media.width * 0.9,
                                              child: MyText(
                                                  text: (userDetails[
                                                              'declined_reason'] ==
                                                          null)
                                                      ? languages[
                                                              choosenLanguage]
                                                          ['text_order_to']
                                                      : languages[
                                                              choosenLanguage]
                                                          ['text_kindly_reup'],
                                                  size: media.width * ten),
                                            ),
                                          ),
                                          SizedBox(
                                            height: media.width * 0.02,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: media.width * 0.055),
                                            child: SizedBox(
                                              width: media.width * 0.9,
                                              child: MyText(
                                                text: (userDetails[
                                                            'declined_reason'] ==
                                                        null)
                                                    ? languages[choosenLanguage]
                                                        ['text_this_step']
                                                    : "${languages[choosenLanguage]['text_declined_reason']}"
                                                        " - "
                                                        "${userDetails['declined_reason']}",
                                                size: media.width * ten,
                                                color: Color(0xffEB001B),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: media.width * 0.05,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                Container(
                                  width: media.width * 0.9,
                                  color: page,
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            color: profileCompleted == true ||
                                                    userDetails.isNotEmpty
                                                ? white.withOpacity(0.1)
                                                : darkModeSecContainer,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: InkWell(
                                          onTap: () async {
                                            if (profileCompleted != true &&
                                                userDetails.isEmpty) {
                                              var nav = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProfileInformation()));
                                              if (nav != null) {
                                                if (nav) {
                                                  setState(() {});
                                                }
                                              }
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/person_icon.png',
                                                    height: media.width * 0.05,
                                                    width: media.width * 0.05,
                                                    fit: BoxFit.contain,
                                                  ),
                                                  SizedBox(
                                                    width: media.width * 0.016,
                                                  ),
                                                  Column(
                                                    children: [
                                                      SizedBox(
                                                        width:
                                                            media.width * 0.65,
                                                        child: MyText(
                                                          text: languages[
                                                                  choosenLanguage]
                                                              ['text_profile'],
                                                          size: media.width *
                                                              seventeen,
                                                          fontweight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            media.width * 0.015,
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            media.width * 0.65,
                                                        child: MyText(
                                                          text: languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_profile_para'],
                                                          size:
                                                              media.width * ten,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: Responsive.height(
                                                    4, context),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  if (profileCompleted ==
                                                          true ||
                                                      userDetails.isNotEmpty)
                                                    Image.asset(
                                                      'assets/images/done_icon.png',
                                                      height:
                                                          media.width * 0.05,
                                                      width: media.width * 0.05,
                                                      fit: BoxFit.contain,
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.02,
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            color: carInformationCompleted ==
                                                        true ||
                                                    userDetails.isNotEmpty
                                                ? white.withOpacity(0.1)
                                                : darkModeSecContainer,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: InkWell(
                                          onTap: () async {
                                            if (profileCompleted == true) {
                                              if (carInformationCompleted !=
                                                      true &&
                                                  userDetails.isEmpty) {
                                                // ignore: prefer_typing_uninitialized_variables
                                                var nav;
                                                if (ischeckownerordriver ==
                                                    'driver') {
                                                  nav = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CarInformation(
                                                                  frompage:
                                                                      1)));
                                                } else {
                                                  nav = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const OwnersRegister()));
                                                }
                                                if (nav != null) {
                                                  if (nav) {
                                                    setState(() {});
                                                  }
                                                }
                                              }
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/car_information.png',
                                                    height: media.width * 0.05,
                                                    width: media.width * 0.05,
                                                    fit: BoxFit.contain,
                                                  ),
                                                  SizedBox(
                                                    width: media.width * 0.016,
                                                  ),
                                                  Column(
                                                    children: [
                                                      SizedBox(
                                                        width:
                                                            media.width * 0.65,
                                                        child: MyText(
                                                          text: (ischeckownerordriver ==
                                                                  'driver')
                                                              ? languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_car_info']
                                                              : 'Company Information',
                                                          size: media.width *
                                                              seventeen,
                                                          fontweight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            media.width * 0.015,
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            media.width * 0.65,
                                                        child: MyText(
                                                          text: languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_car_info_para'],
                                                          size:
                                                              media.width * ten,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: media.width * 0.016,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: Responsive.height(
                                                    2.5, context),
                                              ),
                                              if (carInformationCompleted ==
                                                      true ||
                                                  userDetails.isNotEmpty)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Image.asset(
                                                      'assets/images/done_icon.png',
                                                      height:
                                                          media.width * 0.05,
                                                      width: media.width * 0.05,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.02,
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            color: (documentCompleted == true ||
                                                    (userDetails[
                                                                'uploaded_document'] ==
                                                            true &&
                                                        userDetails[
                                                                'declined_reason'] ==
                                                            null))
                                                ? white.withOpacity(0.1)
                                                : darkModeSecContainer,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: InkWell(
                                          onTap: () async {
                                            if (carInformationCompleted ||
                                                userDetails.isNotEmpty) {
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
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/document_icon.png',
                                                    height: media.width * 0.05,
                                                    width: media.width * 0.05,
                                                    fit: BoxFit.contain,
                                                  ),
                                                  SizedBox(
                                                    width: media.width * 0.016,
                                                  ),
                                                  Column(
                                                    children: [
                                                      SizedBox(
                                                        width:
                                                            media.width * 0.65,
                                                        child: MyText(
                                                          text: languages[
                                                                  choosenLanguage]
                                                              ['text_docs'],
                                                          size: media.width *
                                                              seventeen,
                                                          fontweight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            media.width * 0.015,
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            media.width * 0.65,
                                                        child: MyText(
                                                          text: languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_upload_pho_lic'],
                                                          size:
                                                              media.width * ten,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: media.width * 0.016,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: Responsive.height(
                                                    4, context),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  (documentCompleted == true ||
                                                          (userDetails[
                                                                      'uploaded_document'] ==
                                                                  true &&
                                                              userDetails[
                                                                      'declined_reason'] ==
                                                                  null))
                                                      ? Image.asset(
                                                          'assets/images/done_icon.png',
                                                          height: media.width *
                                                              0.05,
                                                          width: media.width *
                                                              0.05,
                                                          fit: BoxFit.contain,
                                                        )
                                                      : (userDetails[
                                                                  'declined_reason'] !=
                                                              null)
                                                          ? Image.asset(
                                                              'assets/images/cancel_icon.png',
                                                              height:
                                                                  media.width *
                                                                      0.05,
                                                              width:
                                                                  media.width *
                                                                      0.05,
                                                              fit: BoxFit
                                                                  .contain,
                                                            )
                                                          : SizedBox()
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // if (documentCompleted == true ||
                                //     userDetails['uploaded_document'] == true)
                                //   Stack(
                                //     children: [
                                //       (userDetails['declined_reason'] == null)
                                //           ? Positioned(
                                //               left: media.width * 0.1,
                                //               right: media.width * 0.1,
                                //               top: media.width * 0.05,
                                //               bottom: media.width * 0.05,
                                //               child: Container(
                                //                 height: media.width * 0.2,
                                //                 width: media.width * 0.3,
                                //                 decoration: const BoxDecoration(
                                //                     image: DecorationImage(
                                //                         opacity: 0.3,
                                //                         image: AssetImage(
                                //                             'assets/images/wait.png'),
                                //                         fit: BoxFit.contain)),
                                //               ))
                                //           : Container(),
                                //     ],
                                //   )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            showPopAlert == true
                ? Positioned(
                    top: 0,
                    child: Container(
                      height: media.height * 1,
                      width: media.width * 1,
                      color: Colors.transparent.withOpacity(0.6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(media.width * 0.05),
                                width: media.width * 0.9,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: darkModeBorderColor),
                                    borderRadius: BorderRadius.circular(30),
                                    color: page),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: Responsive.height(1, context),
                                    ),
                                    Text(
                                      languages[choosenLanguage]
                                          ['text_sure_to_exit'],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                          fontSize: media.width * sixteen,
                                          color: textColor,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      height: media.width * 0.08,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: Button(
                                              onTap: () async {
                                                setState(() {
                                                  Navigator.pop(context);
                                                });
                                              },
                                              text: languages[choosenLanguage]
                                                  ['text_confirm']),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Button(
                                              color: darkModeSecContainer,
                                              onTap: () async {
                                                setState(() {
                                                  showPopAlert = false;
                                                  // _isLoading = true;
                                                });
                                              },
                                              text: languages[choosenLanguage]
                                                  ['text_cancel']),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ))
                : Container(),
          ],
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_driver/common/responsive.dart';
// import 'package:flutter_driver/pages/onTripPage/map_page.dart';
// import '../../functions/functions.dart';
// import '../../styles/styles.dart';
// import '../../translation/translation.dart';
// import '../../widgets/widgets.dart';
// import 'carinformation.dart';
// import 'namepage.dart';
// import 'ownerregister.dart';
// import 'profileinformation.dart';
// import 'uploaddocument.dart';

// class RequiredInformation extends StatefulWidget {
//   const RequiredInformation({Key? key}) : super(key: key);

//   @override
//   State<RequiredInformation> createState() => _RequiredInformationState();
// }

// bool profileCompleted = false;
// bool carInformationCompleted = false;
// bool documentCompleted = false;

// class _RequiredInformationState extends State<RequiredInformation> {
//   @override
//   void initState() {
//     setState(() {
//       profileCompleted = true;
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var media = MediaQuery.of(context).size;
//     return Material(
//       child: Directionality(
//         textDirection: (languageDirection == 'rtl')
//             ? TextDirection.rtl
//             : TextDirection.ltr,
//         child: ValueListenableBuilder(
//             valueListenable: valueNotifierHome.value,
//             builder: (context, value, child) {
//               if (userDetails['approve'] == true) {
//                 Future.delayed(const Duration(milliseconds: 0), () {
//                   Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(builder: (context) => const Maps()),
//                       (route) => false);
//                 });
//               }
//               return Container(
//                 padding: EdgeInsets.only(
//                     left: media.width * 0.05, right: media.width * 0.05),
//                 height: media.height * 1,
//                 width: media.width * 1,
//                 color: page,
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       height: media.width * 0.05 +
//                           MediaQuery.of(context).padding.top,
//                     ),
//                     Stack(
//                       children: [
//                         Container(
//                           width: media.width * 1,
//                           height: media.height * 0.04,
//                           alignment: Alignment.bottomCenter,
//                           child: MyText(
//                               text: languages[choosenLanguage]['text_register'],
//                               fontweight: FontWeight.w600,
//                               size: media.width * twentythree),
//                         ),
//                         if (userDetails.isEmpty)
//                           Positioned(
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 InkWell(
//                                     onTap: () {
//                                       Navigator.pop(context);
//                                     },
//                                     child: IosBackButton()),
//                               ],
//                             ),
//                           ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: media.width * 0.05,
//                     ),
//                     Expanded(
//                       child: SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             SizedBox(
//                               height: Responsive.height(1.5, context),
//                             ),
//                             Row(
//                               children: [
//                                 SizedBox(
//                                   width: 10,
//                                 ),
//                                 SizedBox(
//                                   child: MyText(
//                                     text: (" ${languages[choosenLanguage]['text_welcome']}"
//                                         " ${userDetails.isEmpty ? name.toString().split(' ')[0] : userDetails['name']}"),
//                                     size: media.width * twelve,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             // SizedBox(
//                             //   height: media.width * 0.02,
//                             // ),
//                             // Row(
//                             //   children: [
//                             //     SizedBox(
//                             //       width: 10,
//                             //     ),
//                             //     SizedBox(
//                             //       child: MyText(
//                             //         text: languages[choosenLanguage]
//                             //             ['text_reqinfo'],
//                             //         size: media.width * fourteen,
//                             //         fontweight: FontWeight.bold,
//                             //       ),
//                             //     ),
//                             //   ],
//                             // ),
//                             SizedBox(
//                               height: media.width * 0.02,
//                             ),
//                             Row(
//                               children: [
//                                 SizedBox(
//                                   width: 14,
//                                 ),
//                                 SizedBox(
//                                   child: MyText(
//                                     text: languages[choosenLanguage]
//                                         ['text_become_captain'],
//                                     size: media.width * twelve,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(
//                               height: media.width * 0.05,
//                             ),
//                             Container(
//                               width: media.width * 0.9,
//                               color: page,
//                               child: Column(
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.all(15),
//                                     decoration: BoxDecoration(
//                                         color: profileCompleted == true ||
//                                                 userDetails.isNotEmpty
//                                             ? white.withOpacity(0.1)
//                                             : darkModeSecContainer,
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     child: InkWell(
//                                       onTap: () async {
//                                         if (profileCompleted != true &&
//                                             userDetails.isEmpty) {
//                                           var nav = await Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       ProfileInformation()));
//                                           if (nav != null) {
//                                             if (nav) {
//                                               setState(() {});
//                                             }
//                                           }
//                                         }
//                                       },
//                                       child: Column(
//                                         children: [
//                                           Row(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Image.asset(
//                                                 'assets/images/person_icon.png',
//                                                 height: media.width * 0.05,
//                                                 width: media.width * 0.05,
//                                                 fit: BoxFit.contain,
//                                               ),
//                                               SizedBox(
//                                                 width: media.width * 0.016,
//                                               ),
//                                               Column(
//                                                 children: [
//                                                   SizedBox(
//                                                     width: media.width * 0.65,
//                                                     child: MyText(
//                                                       text: languages[
//                                                               choosenLanguage]
//                                                           ['text_profile'],
//                                                       size: media.width *
//                                                           seventeen,
//                                                       fontweight:
//                                                           FontWeight.w500,
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                     height: media.width * 0.015,
//                                                   ),
//                                                   SizedBox(
//                                                     width: media.width * 0.65,
//                                                     child: MyText(
//                                                       text: languages[
//                                                               choosenLanguage]
//                                                           ['text_profile_para'],
//                                                       size: media.width * ten,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(
//                                             height:
//                                                 Responsive.height(4, context),
//                                           ),
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.end,
//                                             children: [
//                                               if (profileCompleted == true ||
//                                                   userDetails.isNotEmpty)
//                                                 Image.asset(
//                                                   'assets/images/done_icon.png',
//                                                   height: media.width * 0.05,
//                                                   width: media.width * 0.05,
//                                                   fit: BoxFit.contain,
//                                                 ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: media.width * 0.02,
//                                   ),
//                                   Container(
//                                     padding: EdgeInsets.all(15),
//                                     decoration: BoxDecoration(
//                                         color:
//                                             carInformationCompleted == true ||
//                                                     userDetails.isNotEmpty
//                                                 ? white.withOpacity(0.1)
//                                                 : darkModeSecContainer,
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     child: InkWell(
//                                       onTap: () async {
//                                         if (profileCompleted == true) {
//                                           if (carInformationCompleted != true &&
//                                               userDetails.isEmpty) {
//                                             // ignore: prefer_typing_uninitialized_variables
//                                             var nav;
//                                             if (ischeckownerordriver ==
//                                                 'driver') {
//                                               nav = await Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           CarInformation(
//                                                               frompage: 1)));
//                                             } else {
//                                               nav = await Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           const OwnersRegister()));
//                                             }
//                                             if (nav != null) {
//                                               if (nav) {
//                                                 setState(() {});
//                                               }
//                                             }
//                                           }
//                                         }
//                                       },
//                                       child: Column(
//                                         children: [
//                                           Row(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Image.asset(
//                                                 'assets/images/car_information.png',
//                                                 height: media.width * 0.05,
//                                                 width: media.width * 0.05,
//                                                 fit: BoxFit.contain,
//                                               ),
//                                               SizedBox(
//                                                 width: media.width * 0.016,
//                                               ),
//                                               Column(
//                                                 children: [
//                                                   SizedBox(
//                                                     width: media.width * 0.65,
//                                                     child: MyText(
//                                                       text: (ischeckownerordriver ==
//                                                               'driver')
//                                                           ? languages[
//                                                                   choosenLanguage]
//                                                               ['text_car_info']
//                                                           : 'Company Information',
//                                                       size: media.width *
//                                                           seventeen,
//                                                       fontweight:
//                                                           FontWeight.w500,
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                     height: media.width * 0.015,
//                                                   ),
//                                                   SizedBox(
//                                                     width: media.width * 0.65,
//                                                     child: MyText(
//                                                       text: languages[
//                                                               choosenLanguage][
//                                                           'text_car_info_para'],
//                                                       size: media.width * ten,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               SizedBox(
//                                                 width: media.width * 0.016,
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(
//                                             height:
//                                                 Responsive.height(2.5, context),
//                                           ),
//                                           if (carInformationCompleted == true ||
//                                               userDetails.isNotEmpty)
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.end,
//                                               children: [
//                                                 Image.asset(
//                                                   'assets/images/done_icon.png',
//                                                   height: media.width * 0.05,
//                                                   width: media.width * 0.05,
//                                                   fit: BoxFit.contain,
//                                                 ),
//                                               ],
//                                             ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: media.width * 0.02,
//                                   ),
//                                   Container(
//                                     padding: EdgeInsets.all(15),
//                                     decoration: BoxDecoration(
//                                         color: (documentCompleted == true ||
//                                                 (userDetails[
//                                                             'uploaded_document'] ==
//                                                         true &&
//                                                     userDetails[
//                                                             'declined_reason'] ==
//                                                         null))
//                                             ? white.withOpacity(0.1)
//                                             : darkModeSecContainer,
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     child: InkWell(
//                                       onTap: () async {
//                                         if (carInformationCompleted ||
//                                             userDetails.isNotEmpty) {
//                                           var nav = await Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       UploadDocument()));
//                                           if (nav != null) {
//                                             if (nav) {
//                                               setState(() {});
//                                             }
//                                           }
//                                         }
//                                       },
//                                       child: Column(
//                                         children: [
//                                           Row(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Image.asset(
//                                                 'assets/images/document_icon.png',
//                                                 height: media.width * 0.05,
//                                                 width: media.width * 0.05,
//                                                 fit: BoxFit.contain,
//                                               ),
//                                               SizedBox(
//                                                 width: media.width * 0.016,
//                                               ),
//                                               Column(
//                                                 children: [
//                                                   SizedBox(
//                                                     width: media.width * 0.65,
//                                                     child: MyText(
//                                                       text: languages[
//                                                               choosenLanguage]
//                                                           ['text_docs'],
//                                                       size: media.width *
//                                                           seventeen,
//                                                       fontweight:
//                                                           FontWeight.w500,
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                     height: media.width * 0.015,
//                                                   ),
//                                                   SizedBox(
//                                                     width: media.width * 0.65,
//                                                     child: MyText(
//                                                       text: languages[
//                                                               choosenLanguage][
//                                                           'text_upload_pho_lic'],
//                                                       size: media.width * ten,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               SizedBox(
//                                                 width: media.width * 0.016,
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(
//                                             height:
//                                                 Responsive.height(4, context),
//                                           ),
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.end,
//                                             children: [
//                                               (documentCompleted == true ||
//                                                       (userDetails[
//                                                                   'uploaded_document'] ==
//                                                               true &&
//                                                           userDetails[
//                                                                   'declined_reason'] ==
//                                                               null))
//                                                   ? Image.asset(
//                                                       'assets/images/done_icon.png',
//                                                       height:
//                                                           media.width * 0.05,
//                                                       width: media.width * 0.05,
//                                                       fit: BoxFit.contain,
//                                                     )
//                                                   : (userDetails[
//                                                               'declined_reason'] !=
//                                                           null)
//                                                       ? Image.asset(
//                                                           'assets/images/cancel_icon.png',
//                                                           height: media.width *
//                                                               0.05,
//                                                           width: media.width *
//                                                               0.05,
//                                                           fit: BoxFit.contain,
//                                                         )
//                                                       : SizedBox()
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             if (documentCompleted == true ||
//                                 userDetails['uploaded_document'] == true)
//                               Stack(
//                                 children: [
//                                   (userDetails['declined_reason'] == null)
//                                       ? Positioned(
//                                           left: media.width * 0.1,
//                                           right: media.width * 0.1,
//                                           top: media.width * 0.05,
//                                           bottom: media.width * 0.05,
//                                           child: Container(
//                                             height: media.width * 0.2,
//                                             width: media.width * 0.3,
//                                             decoration: const BoxDecoration(
//                                                 image: DecorationImage(
//                                                     opacity: 0.3,
//                                                     image: AssetImage(
//                                                         'assets/images/wait.png'),
//                                                     fit: BoxFit.contain)),
//                                           ))
//                                       : Container(),
//                                   Column(
//                                     children: [
//                                       SizedBox(
//                                         height: media.width * 0.05,
//                                       ),
//                                       Row(
//                                         children: [
//                                           (userDetails['declined_reason'] ==
//                                                   null)
//                                               ? Image.asset(
//                                                   'assets/images/proposal-approval.png',
//                                                   width: media.width * 0.045,
//                                                   height: media.width * 0.045,
//                                                 )
//                                               : Icon(
//                                                   Icons.info,
//                                                   size: media.width * 0.045,
//                                                   color: Colors.red,
//                                                 ),
//                                           const SizedBox(
//                                             width: 5,
//                                           ),
//                                           SizedBox(
//                                             width: media.width * 0.7,
//                                             child: (userDetails[
//                                                         'declined_reason'] ==
//                                                     null)
//                                                 ? MyText(
//                                                     text: languages[
//                                                             choosenLanguage][
//                                                         'text_waiting_approval'],
//                                                     size:
//                                                         media.width * fourteen,
//                                                     fontweight: FontWeight.bold,
//                                                   )
//                                                 : MyText(
//                                                     text: languages[
//                                                             choosenLanguage][
//                                                         'text_account_declined'],
//                                                     size:
//                                                         media.width * fourteen,
//                                                     fontweight: FontWeight.bold,
//                                                   ),
//                                           ),
//                                         ],
//                                       ),
//                                       SizedBox(
//                                         height: media.width * 0.04,
//                                       ),
//                                       SizedBox(
//                                         width: media.width * 0.9,
//                                         child: MyText(
//                                             text: languages[choosenLanguage]
//                                                 ['text_eva_profile'],
//                                             size: media.width * twelve),
//                                       ),
//                                       SizedBox(
//                                         height: media.width * 0.02,
//                                       ),
//                                       SizedBox(
//                                         width: media.width * 0.9,
//                                         child: MyText(
//                                             text: (userDetails[
//                                                         'declined_reason'] ==
//                                                     null)
//                                                 ? languages[choosenLanguage]
//                                                     ['text_order_to']
//                                                 : languages[choosenLanguage]
//                                                     ['text_kindly_reup'],
//                                             size: media.width * fourteen),
//                                       ),
//                                       SizedBox(
//                                         height: media.width * 0.04,
//                                       ),
//                                       SizedBox(
//                                         width: media.width * 0.9,
//                                         child: MyText(
//                                           text: (userDetails[
//                                                       'declined_reason'] ==
//                                                   null)
//                                               ? languages[choosenLanguage]
//                                                   ['text_this_step']
//                                               : "${languages[choosenLanguage]['text_declined_reason']}"
//                                                   " - "
//                                                   "${userDetails['declined_reason']}",
//                                           size: media.width * fourteen,
//                                           color: verifyDeclined,
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ],
//                               )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//       ),
//     );
//   }
// }
