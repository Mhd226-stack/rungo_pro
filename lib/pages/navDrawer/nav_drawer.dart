import 'package:flutter/material.dart';
import 'package:flutter_driver/common/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../NavigatorPages/bankdetails.dart';
import '../NavigatorPages/driverdetails.dart';
import '../NavigatorPages/driverearnings.dart';
import '../NavigatorPages/editprofile.dart';
import '../NavigatorPages/history.dart';
import '../NavigatorPages/makecomplaint.dart';
import '../NavigatorPages/managevehicles.dart';
import '../NavigatorPages/myroutebookings.dart';
import '../NavigatorPages/notification.dart';
import '../NavigatorPages/settings.dart';
import '../NavigatorPages/sos.dart';
import '../NavigatorPages/support_page.dart';
import '../NavigatorPages/walletpage.dart';
import '../login/landingpage.dart';
import '../onTripPage/map_page.dart';
import '../login/login.dart';
import 'package:url_launcher/url_launcher.dart';
import '../subscriptionPage/subscription_screen.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({Key? key}) : super(key: key);
  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  // ignore: unused_field
  bool _isLoading = false;
  // ignore: unused_field
  String _error = '';

  themefun() async {
    if (isDarkTheme) {
      isDarkTheme = false;
      page = Colors.white;
      textColor = Colors.black;
      buttonColor = theme;
      loaderColor = theme;
      hintColor = const Color(0xff12121D).withOpacity(0.3);
    } else {
      isDarkTheme = true;
      page = const Color(0xFF3D3D3D);
      textColor = Colors.white.withOpacity(0.9);
      buttonColor = Colors.white;
      loaderColor = Colors.white;
      hintColor = Colors.white.withOpacity(0.3);
    }
    await getDetailsOfDevice();

    pref.setBool('isDarkTheme', isDarkTheme);

    valueNotifierHome.incrementNotifier();
  }

  navigateLogout() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LandingPage()));
  }

  @override
  void initState() {
    if (userDetails['chat_id'] != null && chatStream == null) {
      streamAdminchat();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return ValueListenableBuilder(
        valueListenable: valueNotifierHome.value,
        builder: (context, value, child) {
          return SizedBox(
            width: media.width * 0.8,
            child: Directionality(
              textDirection: (languageDirection == 'rtl')
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Drawer(
                  backgroundColor: page,
                  child: Container(
                    width: media.width * 0.7,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: media.width * 0.07 +
                                        MediaQuery.of(context).padding.top,
                                  ),
                                  SizedBox(
                                    width: media.width * 0.7,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              var val = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const EditProfile()));
                                              if (val) {
                                                setState(() {});
                                              }
                                            },
                                            child: Container(
                                              height: media.width * 0.2,
                                              width: media.width * 0.2,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          userDetails[
                                                              'profile_picture']),
                                                      fit: BoxFit.cover)),
                                            ),
                                          ),
                                          SizedBox(
                                            width: media.width * 0.025,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: media.width * 0.45,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    MyText(
                                                      text: getFirstName(
                                                          userDetails['name']),
                                                      size: media.width *
                                                          eighteen,
                                                      fontweight:
                                                          FontWeight.w500,
                                                      maxLines: 1,
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    InkWell(
                                                      onTap: () async {
                                                        var val = await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const EditProfile()));
                                                        if (val == true) {
                                                          setState(() {});
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            media.width *
                                                                0.015),
                                                        decoration:
                                                            BoxDecoration(
                                                                color:
                                                                    buttonColor,
                                                                shape: BoxShape
                                                                    .circle),
                                                        child: Icon(
                                                            Icons
                                                                .border_color_outlined,
                                                            size: media.width *
                                                                sixteen,
                                                            color: textColor
                                                            // const Color(0xFFFF0000),
                                                            ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              // SizedBox(
                                              //   height: media.width * 0.01,
                                              // ),
                                              // SizedBox(
                                              //   width: media.width * 0.45,
                                              //   child: MyText(
                                              //     text: userDetails['mobile'],
                                              //     size: media.width * fourteen,
                                              //     maxLines: 1,
                                              //   ),
                                              // )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: Responsive.height(2.5, context),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        top: media.width * 0.02),
                                    width: media.width * 0.7,
                                    child: Column(
                                      children: [
                                        // Container(
                                        //   padding: EdgeInsets.only(
                                        //       top: media.width * 0.025),
                                        //   child: Row(
                                        //     children: [
                                        //       MyText(
                                        //         text: languages[choosenLanguage]
                                        //                 ['text_account']
                                        //             .toString()
                                        //             .toUpperCase(),
                                        //         size: media.width * fourteen,
                                        //         fontweight: FontWeight.w700,
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),

                                        (userDetails['role'] != 'owner' &&
                                                userDetails[
                                                        'enable_my_route_booking_feature'] ==
                                                    '1')
                                            ? InkWell(
                                                onTap: () async {
                                                  var nav = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const MyRouteBooking()));
                                                  if (nav != null) {
                                                    if (nav) {
                                                      setState(() {});
                                                    }
                                                  }
                                                },
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              media.width *
                                                                  0.01,
                                                              media.width *
                                                                  0.025,
                                                              media.width *
                                                                  0.025,
                                                              media.width *
                                                                  0.025),
                                                      child: Row(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/myroute.png',
                                                            fit: BoxFit.contain,
                                                            width: media.width *
                                                                0.06,
                                                            color: textColor
                                                                .withOpacity(
                                                                    0.8),
                                                          ),
                                                          SizedBox(
                                                            width: media.width *
                                                                0.025,
                                                          ),
                                                          SizedBox(
                                                            width: media.width *
                                                                0.45,
                                                            child: Text(
                                                              languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_my_route'],
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts.inter(
                                                                  fontSize: media
                                                                          .width *
                                                                      sixteen,
                                                                  color: textColor
                                                                      .withOpacity(
                                                                          0.8)),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),

                                                    // SizedBox(width: media.width*0.05,),
                                                    if (userDetails[
                                                            'my_route_address'] !=
                                                        null)
                                                      InkWell(
                                                        onTap: () async {
                                                          setState(() {
                                                            _isLoading = true;
                                                          });
                                                          var dist = calculateDistance(
                                                              center.latitude,
                                                              center.longitude,
                                                              double.parse(userDetails[
                                                                      'my_route_lat']
                                                                  .toString()),
                                                              double.parse(userDetails[
                                                                      'my_route_lng']
                                                                  .toString()));

                                                          if (dist > 5000.0 ||
                                                              userDetails[
                                                                      'enable_my_route_booking'] ==
                                                                  "1") {
                                                            var val = await enableMyRouteBookings(
                                                                center.latitude,
                                                                center
                                                                    .longitude);
                                                            if (val ==
                                                                'logout') {
                                                              navigateLogout();
                                                            } else if (val !=
                                                                'success') {
                                                              setState(() {
                                                                _error = val;
                                                              });
                                                            }
                                                          } else {
                                                            _error = languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_myroute_warning'];
                                                          }

                                                          setState(() {
                                                            _isLoading = false;
                                                          });
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets.only(
                                                              left:
                                                                  media.width *
                                                                      0.005,
                                                              right:
                                                                  media.width *
                                                                      0.005),
                                                          height: media.width *
                                                              0.05,
                                                          width:
                                                              media.width * 0.1,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius: BorderRadius
                                                                .circular(media
                                                                        .width *
                                                                    0.025),
                                                            color: (userDetails[
                                                                        'enable_my_route_booking'] ==
                                                                    '1')
                                                                ? Colors.green
                                                                    .withOpacity(
                                                                        0.4)
                                                                : Colors.grey
                                                                    .withOpacity(
                                                                        0.6),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: (userDetails[
                                                                        'enable_my_route_booking'] ==
                                                                    '1')
                                                                ? MainAxisAlignment
                                                                    .end
                                                                : MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                height: media
                                                                        .width *
                                                                    0.045,
                                                                width: media
                                                                        .width *
                                                                    0.045,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: (userDetails[
                                                                              'enable_my_route_booking'] ==
                                                                          '1')
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .grey,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                        NavMenu(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const History()));
                                          },
                                          text: languages[choosenLanguage]
                                              ['text_trips'],
                                          image:
                                              'assets/images/menu_item/trips.png',
                                        ),
                                        //Notifications

                                        (userDetails['role'] != 'owner')
                                            ? ValueListenableBuilder(
                                                valueListenable:
                                                    valueNotifierNotification
                                                        .value,
                                                builder:
                                                    (context, value, child) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const NotificationPage()));
                                                      setState(() {
                                                        userDetails[
                                                            'notifications_count'] = 0;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.only(
                                                          top: media.width *
                                                              0.025),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Image.asset(
                                                                'assets/images/menu_item/notifications.png',
                                                                fit: BoxFit
                                                                    .contain,
                                                                width: media
                                                                        .width *
                                                                    twentythree,
                                                                height: media
                                                                        .width *
                                                                    twentythree,
                                                                color:
                                                                    textColor,
                                                              ),
                                                              SizedBox(
                                                                width: media
                                                                        .width *
                                                                    0.03,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  SizedBox(
                                                                    width: (userDetails['notifications_count'] ==
                                                                            0)
                                                                        ? media.width *
                                                                            0.45
                                                                        : media.width *
                                                                            0.45,
                                                                    child:
                                                                        MyText(
                                                                      text: languages[choosenLanguage]
                                                                              [
                                                                              'text_notification']
                                                                          .toString(),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      size: media
                                                                              .width *
                                                                          sixteen,
                                                                      color: textColor
                                                                          .withOpacity(
                                                                              0.8),
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      // Icon(
                                                                      //   Icons
                                                                      //       .arrow_right_sharp,
                                                                      //   size: media.width *
                                                                      //       0.08,
                                                                      //   color:
                                                                      //       textColor,
                                                                      // ),
                                                                      SizedBox(
                                                                        height: media.width *
                                                                            0.08,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      (userDetails['notifications_count'] ==
                                                                              0)
                                                                          ? Container()
                                                                          : Container(
                                                                              height: 20,
                                                                              width: 20,
                                                                              alignment: Alignment.center,
                                                                              decoration: BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                color: buttonColor,
                                                                              ),
                                                                              child: Text(
                                                                                userDetails['notifications_count'].toString(),
                                                                                style: GoogleFonts.inter(fontSize: media.width * fourteen, color: (isDarkTheme) ? Colors.black : buttonText),
                                                                              ),
                                                                            ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                          // Container(
                                                          //   alignment: Alignment
                                                          //       .centerRight,
                                                          //   padding:
                                                          //       EdgeInsets.only(
                                                          //     top: media.width *
                                                          //         0.01,
                                                          //     left:
                                                          //         media.width *
                                                          //             0.09,
                                                          //   ),
                                                          //   child: Container(
                                                          //     color: textColor
                                                          //         .withOpacity(
                                                          //             0.1),
                                                          //     height: 1,
                                                          //   ),
                                                          // )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                })
                                            : Container(),

                                        //wallet page

                                        userDetails['owner_id'] == null &&
                                                userDetails[
                                                        'show_wallet_feature_on_mobile_app'] ==
                                                    '1'
                                            ? NavMenu(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const WalletPage()));
                                                },
                                                text: languages[choosenLanguage]
                                                    ['text_enable_wallet'],
                                                image:
                                                    'assets/images/menu_item/wallet.png',
                                              )
                                            : Container(),

                                        //Earnings
                                        NavMenu(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const DriverEarnings()));
                                          },
                                          text: languages[choosenLanguage]
                                              ['text_earnings'],
                                          image:
                                              'assets/images/menu_item/earning.png',
                                        ),

                                        //manage vehicle

                                        userDetails['role'] == 'owner'
                                            ? NavMenu(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const ManageVehicles()));
                                                },
                                                text: languages[choosenLanguage]
                                                    ['text_manage_vehicle'],
                                                image:
                                                    'assets/images/updateVehicleInfo.png',
                                              )
                                            : Container(),

                                        //manage Driver
                                        userDetails['role'] == 'owner'
                                            ? NavMenu(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const DriverList()));
                                                },
                                                text: languages[choosenLanguage]
                                                    ['text_manage_drivers'],
                                                image:
                                                    'assets/images/menu_item/manage_driver.png',
                                              )
                                            : Container(),

                                        //bank details
                                        userDetails['owner_id'] == null &&
                                                userDetails[
                                                        'show_bank_info_feature_on_mobile_app'] ==
                                                    "1"
                                            ? NavMenu(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const BankDetails()));
                                                },
                                                text: languages[choosenLanguage]
                                                    ['text_updateBank'],
                                                image:
                                                    'assets/images/menu_item/bank_info.png',
                                              )
                                            : Container(),

                                        //sos
                                        userDetails['role'] != 'owner'
                                            ? NavMenu(
                                                onTap: () async {
                                                  var nav = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const Sos()));
                                                  if (nav) {
                                                    setState(() {});
                                                  }
                                                },
                                                text: languages[choosenLanguage]
                                                    ['text_sos'],
                                                image:
                                                    'assets/images/menu_item/sos_menu_item.png',
                                              )
                                            : Container(),

                                        //Make Complaint
                                        NavMenu(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MakeComplaint(
                                                            fromPage: 2)));
                                          },
                                          text: languages[choosenLanguage]
                                              ['text_make_complaints'],
                                          image:
                                              'assets/images/menu_item/feedback.png',
                                        ),

                                        // Container(
                                        //   padding: EdgeInsets.only(
                                        //       top: media.width * 0.03),
                                        //   child: Row(
                                        //     children: [
                                        //       MyText(
                                        //         text: languages[choosenLanguage]
                                        //                 ['text_general']
                                        //             .toString()
                                        //             .toUpperCase(),
                                        //         size: media.width * fourteen,
                                        //         fontweight: FontWeight.w700,
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),

                                        // Settings

                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const Settings()));
                                          },
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                top: media.width * 0.025),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      'assets/images/menu_item/settings.png',
                                                      fit: BoxFit.contain,
                                                      width: media.width *
                                                          twentythree,
                                                      height: media.width *
                                                          twentythree,
                                                      color: textColor,
                                                    ),
                                                    SizedBox(
                                                      width: media.width * 0.03,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                          width: media.width *
                                                              0.45,
                                                          child: MyText(
                                                            text: languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_settings'],
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            size: media.width *
                                                                sixteen,
                                                            color: textColor
                                                                .withOpacity(
                                                                    0.8),
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            // Icon(
                                                            //   Icons
                                                            //       .arrow_right_sharp,
                                                            //   size:
                                                            //       media.width *
                                                            //           0.08,
                                                            //   color: textColor,
                                                            // ),
                                                            SizedBox(
                                                              height:
                                                                  media.width *
                                                                      0.08,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Support
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const Support()));
                                          },
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                top: media.width * 0.025),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      'assets/images/menu_item/support.png',
                                                      fit: BoxFit.contain,
                                                      width: media.width *
                                                          twentythree,
                                                      height: media.width *
                                                          twentythree,
                                                      color: textColor,
                                                    ),
                                                    SizedBox(
                                                      width: media.width * 0.03,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                          width: media.width *
                                                              0.45,
                                                          child: MyText(
                                                            text: languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_support_menu'],
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            size: media.width *
                                                                sixteen,
                                                            color: textColor
                                                                .withOpacity(
                                                                    0.8),
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            // Icon(
                                                            //   Icons
                                                            //       .arrow_right_sharp,
                                                            //   size:
                                                            //       media.width *
                                                            //           0.08,
                                                            //   color: textColor,
                                                            // ),
                                                            SizedBox(
                                                              height:
                                                                  media.width *
                                                                      0.08,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        //referral page
                                        // userDetails['owner_id'] == null &&
                                        //         userDetails['role'] == 'driver'
                                        //     ? NavMenu(
                                        //         onTap: () {
                                        //           Navigator.push(
                                        //               context,
                                        //               MaterialPageRoute(
                                        //                   builder: (context) =>
                                        //                       const ReferralPage()));
                                        //         },
                                        //         text: languages[choosenLanguage]
                                        //             ['text_enable_referal'],
                                        //         image:
                                        //             'assets/images/menu_item/referal.png',
                                        //       )
                                        //     : Container(),

                                        Visibility(
                                          visible: false,
                                          child: InkWell(
                                            onTap: () async {
                                              themefun();
                                            },
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      isDarkTheme
                                                          ? Icons
                                                              .brightness_4_outlined
                                                          : Icons
                                                              .brightness_3_rounded,
                                                      size: media.width * 0.075,
                                                      color: textColor
                                                          .withOpacity(0.8),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          media.width * 0.025,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                            width: media.width *
                                                                0.46,
                                                            child: Text(
                                                              languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_select_theme'],
                                                              style: GoogleFonts.inter(
                                                                  fontSize: media
                                                                          .width *
                                                                      sixteen,
                                                                  color: textColor
                                                                      .withOpacity(
                                                                          0.8)),
                                                            )),
                                                        SizedBox(
                                                          width: 3,
                                                          child: Switch(
                                                              value:
                                                                  isDarkTheme,
                                                              onChanged:
                                                                  (toggle) async {
                                                                themefun();
                                                              }),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: media.width * 0.03,
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  padding: EdgeInsets.only(
                                                    top: media.width * 0.01,
                                                    left: media.width * 0.09,
                                                  ),
                                                  child: Container(
                                                    color: textColor
                                                        .withOpacity(0.1),
                                                    height: 1,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        //SizedBox(height: media.width * 0.04),
                                      //Button(
                                      // width: Responsive.width(60, context),
                                    //onTap: () {
                                      // Navigator.pop(context);
                                    // Navigator.push(
                                    //   context,
                                      //MaterialPageRoute(
                                    //   builder: (context) => const SubscriptionScreen()),
                                      //  );
                                      //   },
                                        //  text: 'Mon abonnement'),
                                        SizedBox(height: media.width * 0.04),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: Responsive.width(4, context),
                                            vertical: Responsive.height(1.5, context),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              // Facebook
                                              InkWell(
                                                onTap: () async {
                                                  const url = 'https://www.facebook.com/share/1BV6eUru7i/';
                                                  if (await canLaunch(url)) await launch(url);
                                                },
                                                child: Image.asset(
                                                  'assets/images/facebook.png',
                                                  width: media.width * 0.07,
                                                  height: media.width * 0.07,
                                                ),
                                              ),
                                              // TikTok
                                              InkWell(
                                                onTap: () async {
                                                  const url = 'https://www.tiktok.com/@rungobf?_r=1&_t=ZN-979VIqyVZLi';
                                                  if (await canLaunch(url)) await launch(url);
                                                },
                                                child: Image.asset(
                                                  'assets/images/tiktok.png',
                                                  width: media.width * 0.07,
                                                  height: media.width * 0.07,
                                                ),
                                              ),
                                              // Instagram
                                              InkWell(
                                                onTap: () async {
                                                  const url = 'https://www.instagram.com/run.go226?igsh=Nm5yZGI0YnJoMjJn';
                                                  if (await canLaunch(url)) await launch(url);
                                                },
                                                child: Image.asset(
                                                  'assets/images/instagram.png',
                                                  width: media.width * 0.07,
                                                  height: media.width * 0.07,
                                                ),
                                              ),
                                              // YouTube
                                              InkWell(
                                                onTap: () async {
                                                  const url = 'https://www.youtube.com/@RungoBurkina';
                                                  if (await canLaunch(url)) await launch(url);
                                                },
                                                child: Image.asset(
                                                  'assets/images/youtube.png',
                                                  width: media.width * 0.07,
                                                  height: media.width * 0.07,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: media.width * 0.08,
                                        ),
                                        Button(
                                            width: Responsive.width(60, context),
                                            onTap: () async {
                                              var result = await userLogout();
                                              if (result == 'success') {
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => const Login()),
                                                      (route) => false,
                                                );
                                              }
                                            },
                                            text: languages[choosenLanguage]['text_sign_out']),
                                        SizedBox(height: media.width * 0.1),
                                        //logout
                                      ],
                                    ),
                                  )
                                ]),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          );
        });
  }
}
