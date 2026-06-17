import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_driver/common/responsive.dart';
import 'package:flutter_driver/pages/loadingPage/loadingpage.dart';
import 'package:flutter_driver/pages/onTripPage/map_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../noInternet/nointernet.dart';
import 'login.dart';
import 'namepage.dart';
import 'requiredinformation.dart';

class Otp extends StatefulWidget {
  final dynamic from;

  const Otp({Key? key, this.from}) : super(key: key);

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> with TickerProviderStateMixin {
  String otpNumber = ''; //otp number

  final _pinPutController2 = TextEditingController();
  dynamic aController;
  bool _resend = false;
  String _error = '';

  String get timerString {
    Duration duration = aController.duration * aController.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    aController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60));
    aController.reverse(
        from: aController.value == 0.0 ? 60.0 : aController.value);
    isfromomobile = true;
    otpFalse();
    SharedPreferences.getInstance().then((value) {
      value.setString(currentRegScreen, isOTPScreen);
    });
    super.initState();
  }

  @override
  void dispose() {
    _error = '';
    aController.dispose();
    super.dispose();
  }

//navigate
  navigate(verify) {
    if (verify == true) {
      if (userDetails['uploaded_document'] == false) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const RequiredInformation()),
                (route) => false);
      } else if (userDetails['uploaded_document'] == true &&
          userDetails['approve'] == false) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const RequiredInformation(),
            ),
                (route) => false);
      } else if (userDetails['uploaded_document'] == true &&
          userDetails['approve'] == true) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Maps()),
                (route) => false);
      }
    } else if (verify == false) {
      if (isverifyemail == true) {
        currentPage = 3;
      } else {
        currentPage = 2;
      }
      valueNotifierLogin.incrementNotifier();
    } else {
      _error = verify.toString();
    }
    loginLoading = false;
    valueNotifierLogin.incrementNotifier();
  }

  otpFalse() async {
    if (phoneAuthCheck == false) {
      if (isverifyemail == false) {
        // Ne rien faire — attendre que l'utilisateur entre le vrai OTP Firebase
        // L'OTP sera vérifié quand l'utilisateur clique sur "Vérifier"
      } else {
        emaillogin();
      }
    }
  }

  normallogin() async {
    var verify = await verifyUser(phnumber);
    navigate(verify);
  }

  emaillogin() async {
    var verify = await verifyUser(phnumber);
    if (verify == false) {
      // Ne pas hardcoder l'OTP — attendre que l'utilisateur entre le vrai code
      setState(() {
        _pinPutController2.text = '';
        otpNumber = '';
      });
    } else {
      setState(() {
        _pinPutController2.text = '';
        _error = languages[choosenLanguage]['text_mobile_already_taken'];
      });
    }
  }

//auto verify otp

  verifyOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      // Sign the user in (or link) with the credential
      await FirebaseAuth.instance.signInWithCredential(credentials);

      var verify = await verifyUser(phnumber);
      credentials = null;
      navigate(verify);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'invalid-verification-code') {
        setState(() {
          _pinPutController2.clear();
          _error = languages[choosenLanguage]['text_otp_error'];
        });
      }
    }
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

  bool showtoast = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      color: page,
      child: Stack(
        children: [
          Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: media.height * 0.07,
              ),
              Expanded(
                child: AnimatedBuilder(
                    animation: aController,
                    builder: (context, child) {
                      if (timerString == "0:00") {
                        _resend = true;
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                // Container(
                                //   width: media.width * 0.9,
                                //   alignment: Alignment.center,
                                //   child: SizedBox(
                                //     height: 55,
                                //     width: 55,
                                //     child: CustomPaint(
                                //         // ignore: sort_child_properties_last
                                //         child: Center(
                                //           child: MyText(
                                //             text: timerString,
                                //             size: media.width * fourteen,
                                //             fontweight: FontWeight.bold,
                                //           ),
                                //         ),
                                //         painter: CustomTimerPainter(
                                //             animation: aController,
                                //             backgroundColor: buttonColor,
                                //             color: const Color(0xffEDF0F4))),
                                //   ),
                                // ),

                                SizedBox(
                                  child: MyText(
                                    // ignore: prefer_interpolation_to_compose_strings
                                    text: languages[choosenLanguage]
                                    ['text_otp_code'],
                                    size: media.width * twenty,
                                    fontweight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: Responsive.height(2, context),
                                ),
                                (isfromomobile == true)
                                    ? MyText(
                                  // ignore: prefer_interpolation_to_compose_strings
                                  text:
                                  '''${languages[choosenLanguage]['text_enter_otp_at']}
${countries[phcode]['dial_code']} $phnumber''',
                                  size: media.width * fourteen,
                                  textAlign: TextAlign.center,
                                  color: textColor.withOpacity(0.5),
                                )
                                    : MyText(
                                  // ignore: prefer_interpolation_to_compose_strings
                                  text:
                                  '${languages[choosenLanguage]['text_enter_otp_at']} $email',
                                  size: media.width * fourteen,
                                  textAlign: TextAlign.center,
                                  color: textColor.withOpacity(0.5),
                                ),
                                SizedBox(
                                  height: Responsive.height(3, context),
                                ),
                                Pinput(
                                  length: 6,
                                  // FIX 2 : utiliser val directement au lieu de _pinPutController2.text
                                  onChanged: (val) {
                                    otpNumber = val;
                                  },
                                  // onSubmitted: (String val) {},
                                  controller: _pinPutController2,
                                  defaultPinTheme: PinTheme(
                                    width: media.width * 0.15,
                                    height: media.width * 0.13,
                                    textStyle: GoogleFonts.inter(
                                        fontSize: media.width * fourteen,
                                        fontWeight: FontWeight.w500,
                                        color: white),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: darkModeSecContainer,
                                        border: Border.all(
                                            color: darkModeBorderColor)),
                                  ),
                                ),
                                SizedBox(
                                  height: Responsive.height(3, context),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MyText(
                                      text: 'You can resend the code in ',
                                      size: media.width * ten,
                                      fontweight: FontWeight.w300,
                                    ),
                                    MyText(
                                      text: '$timerString ',
                                      size: media.width * ten,
                                      fontweight: FontWeight.w300,
                                      color: buttonColor,
                                    ),
                                    MyText(
                                      text: 'seconds',
                                      size: media.width * ten,
                                      fontweight: FontWeight.w300,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: Responsive.height(1, context),
                                ),
                                TextButton(
                                    onPressed: () async {
                                      if (timerString == "0:00") {
                                        loginLoading = true;
                                        valueNotifierLogin.incrementNotifier();
                                        if (isfromomobile == true) {
                                          var verify =
                                          await verifyUser(phnumber);
                                          // if (verify == false) {
                                          setState(() {
                                            _error = '';
                                            _pinPutController2.text = '';
                                            _resend = false;
                                          });
                                          phoneAuth(countries[phcode]
                                          ['dial_code'] +
                                              phnumber);
                                          aController.reverse(
                                              from: aController.value == 0.0
                                                  ? 60.0
                                                  : aController.value);
                                          // } else {
                                          //   setState(() {
                                          //     _pinPutController2.text = '';

                                          //     _error = languages[
                                          //             choosenLanguage]
                                          //         ['text_mobile_already_taken'];
                                          //   });
                                          // }
                                        } else {
                                          // var verify = await verifyUser(email);
                                          // if (verify == false) {
                                          setState(() {
                                            loginLoading = true;
                                          });
                                          phoneAuthCheck = true;
                                          await sendOTPtoEmail(email);
                                          aController.reverse(
                                              from: aController.value == 0.0
                                                  ? 60.0
                                                  : aController.value);

                                          setState(() {
                                            loginLoading = false;
                                          });

                                        }
                                      }
                                      loginLoading = false;
                                      valueNotifierLogin.incrementNotifier();
                                    },
                                    child: MyText(
                                      text: languages[choosenLanguage]
                                      ['text_resend_otp'],
                                      size: media.width * thirteen,
                                      fontweight: FontWeight.w500,
                                      color: (_resend == false)
                                          ? textColor.withOpacity(0.4)
                                          : textColor,
                                    )),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: media.height * 0.05,
                          ),
                        ],
                      );
                    }),
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
              (isfromomobile == true)
                  ? Container(
                alignment: Alignment.center,
                child: Button(
                  onTap: () async {
                    if (_pinPutController2.text.length == 6) {
                      setState(() {
                        loginLoading = true;
                        _error = '';
                      });

                      valueNotifierLogin.incrementNotifier();
                      if (phoneAuthCheck == false) {
                        value = 0;
                        var verify = await verifyUser(phnumber);
                        navigate(verify);
                      } else {
                        try {
                          PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                              verificationId: verId,
                              smsCode: otpNumber);

                          await FirebaseAuth.instance
                              .signInWithCredential(credential);

                          value = 0;
                          var verify = await verifyUser(phnumber);
                          navigate(verify);

                        } on FirebaseAuthException catch (error) {
                          setState(() {
                            loginLoading = false;
                            _pinPutController2.clear();
                            otpNumber = '';
                            _error = error.message ?? languages[choosenLanguage]['text_otp_error'];
                          });
                        }
                      }

                      loginLoading = false;
                      valueNotifierLogin.incrementNotifier();
                    }
                  },
                  text: languages[choosenLanguage]['text_verify'],
                ),
              )
                  : Container(
                alignment: Alignment.center,
                child: Button(
                    onTap: () async {
                      if (_pinPutController2.text.length == 6) {
                        setState(() {
                          _error = '';
                        });
                        loginLoading = true;

                        valueNotifierLogin.incrementNotifier();
                        var result = await emailVerify(email, otpNumber);

                        if (result == 'success') {
                          isfromomobile = false;
                          _error = '';
                          value = 1;
                          var verify = await verifyUser(email);
                          navigate(verify);
                        } else {
                          setState(() {
                            _pinPutController2.clear();
                            otpNumber = '';
                            _error = languages[choosenLanguage]['text_otp_error'];
                          });
                        }
                      }
                      loginLoading = false;
                      valueNotifierLogin.incrementNotifier();
                    },
                    text: languages[choosenLanguage]['text_verify']),
              ),
              ButtonBottomSpace(
                height: 5,
              )
            ],
          ),
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
                      color: Colors.red),
                ),
              ))
              : Container()
        ],
      ),
    );
  }
}

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(CustomTimerPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}