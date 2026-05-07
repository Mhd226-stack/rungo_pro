import 'package:flutter/material.dart';
import 'package:flutter_driver/common/responsive.dart';
import 'package:flutter_driver/pages/onTripPage/map_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loadingpage.dart';
import 'login.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool colorbutton = false;
  @override
  void initState() {
    checkmodule();
    SharedPreferences.getInstance().then((value) {
      value.setString(currentRegScreen, '');
    });
    super.initState();
  }

  checkmodule() {
    if (ownermodule == '0') {
      ischeckownerordriver == 'driver';
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Login()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: page,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: Responsive.height(40, context),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: media.width * fourty,
                      height: media.height * fourty,
                      // animate: false,
                      // repeat: false
                    ),
                  ),
                  SizedBox(width: media.width * twenty),
                  Container(
                    height: media.height * 0.06,
                    width: 1,
                    color: white,
                  ),
                  SizedBox(width: media.width * fifteen),
                  MyText(
                    text: 'Driver',
                    size: media.width * fourty,
                    fontweight: FontWeight.w500,
                    color: textColor,
                  )
                ],
              ),
              SizedBox(
                height: Responsive.height(4, context),
              ),
              SizedBox(
                width: media.width * 0.7,
                child: MyText(
                  textAlign: TextAlign.center,
                  text: languages[choosenLanguage]['text_login_des'],
                  size: media.width * eighteen,
                  fontweight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              SizedBox(
                height: Responsive.height(20, context),
              ),
              // SizedBox(
              //   width: Responsive.width(90, context),
              //   child: Text(
              //     '''Lorem ipsum\nis a placeholder text''',
              //     style: GoogleFonts.inter(
              //         color: white,
              //         fontSize: media.width * twentyeight,
              //         fontWeight: FontWeight.w600),
              //   ),
              // ),
              // SizedBox(
              //   height: Responsive.height(1, context),
              // ),
              // SizedBox(
              //   width: Responsive.width(90, context),
              //   child: Text(
              //     'Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content. Lorem ipsum may ',
              //     style: GoogleFonts.inter(
              //         color: white,
              //         fontSize: media.width * ten,
              //         fontWeight: FontWeight.w500),
              //   ),
              // ),

              Column(
                children: [
                  Button(
                      width: Responsive.width(90, context),
                      borderRadius: 15.0,
                      onTap: () async {
                        ischeckownerordriver = 'driver';
                        await sharefPref!.setBool(isDriver, true);
                        await sharefPref!
                            .setString(currentRegScreen, isLoginScreen);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()));
                      },
                      text: languages[choosenLanguage]['text_login_driver']),
                  SizedBox(
                    height: Responsive.height(3, context),
                  ),
                  Button(
                      width: Responsive.width(90, context),
                      color: darkModeSecContainer,
                      borcolor: Colors.transparent,
                      borderRadius: 15.0,
                      onTap: () async {
                        ischeckownerordriver = 'owner';
                        await sharefPref!.setBool(isDriver, false);
                        await sharefPref!
                            .setString(currentRegScreen, isLoginScreen);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()));
                      },
                      text: languages[choosenLanguage]['text_login_owner'])
                ],
              ),
            ],
          ),
          (showLogoutNotifier == true)
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
                          border: Border.all(color: darkModeBorderColor),
                          borderRadius: BorderRadius.circular(30),
                          color: page,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: Responsive.height(2, context),
                            ),
                            SizedBox(
                                width: media.width * 0.8,
                                child: Text(
                                  languages[choosenLanguage]
                                      ['text_logout_notifier'],
                                  style: GoogleFonts.inter(
                                      fontSize: media.width * sixteen,
                                      color: textColor,
                                      fontWeight: FontWeight.w600),
                                )),
                            SizedBox(height: media.width * 0.1),
                            Button(
                                width: media.width,
                                onTap: () async {
                                  setState(() {
                                    showLogoutNotifier = false;
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
        ],
      ),
    );
  }
}
