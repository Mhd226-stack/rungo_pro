import 'package:flutter/material.dart';
import 'package:flutter_driver/common/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import 'dart:math' as math;
import '../loadingPage/loading.dart';
import '../loadingPage/loadingpage.dart';
import '../noInternet/nointernet.dart';
import 'agreement.dart';
import 'namepage.dart';
import 'otp_page.dart';
import '../onTripPage/map_page.dart';
import 'requiredinformation.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

String phnumber = '';
List pages = [1, 2, 3, 4];
int currentPage = 0;
bool loginLoading = true;
var value = 0;
bool isfromomobile = true;
bool isLoginemail = false;

class _LoginState extends State<Login> with TickerProviderStateMixin {
  TextEditingController controller = TextEditingController();
  dynamic aController;
  String _error = '';

  String get timerString {
    Duration duration = aController.duration * aController.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  bool terms = true;

  @override
  void initState() {
    controller.text = '';
    aController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60));
    countryCode();
    regProcessNavigation();
    super.initState();
  }

  regProcessNavigation() {
    String getCurrentRegScreen = sharefPref!.getString(currentRegScreen) ?? '';
    if (getCurrentRegScreen == isLoginScreen) {
      currentPage = 0;
    } else if (getCurrentRegScreen == isOTPScreen) {
      currentPage = 0;
    } else if (getCurrentRegScreen == isNameScreen) {
      currentPage = 2;
    } else if (getCurrentRegScreen == isAgrementScreen) {
      currentPage = 2;
    }
  }

  countryCode() async {
    isverifyemail = false;
    isLoginemail = false;
    isfromomobile = true;
    var result = await getCountryCode();
    if (result == 'success') {
      setState(() {
        loginLoading = false;
      });
    } else {
      setState(() {
        loginLoading = false;
      });
    }
  }

  navigate() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Otp()));
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          ValueListenableBuilder(
              valueListenable: valueNotifierLogin.value,
              builder: (context, value, child) {
                return SingleChildScrollView(
                  child: Container(
                    color: page,
                    padding: EdgeInsets.only(
                        left: media.width * 0.05,
                        right: media.width * 0.05),
                    width: media.width * 1,
                    height: media.height * 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: media.height * 0.09),
                        InkWell(
                            onTap: () {
                              if (currentPage == 0) {
                                SharedPreferences.getInstance().then((value) {
                                  value.setString(currentRegScreen, '');
                                  Navigator.pop(context);
                                });
                              } else if (currentPage == 2) {
                                setState(() {
                                  controller.text = '';
                                  currentPage = 0;
                                  isverifyemail = false;
                                  isLoginemail = false;
                                  isfromomobile = true;
                                });
                              } else if (currentPage == 1) {
                                setState(() {
                                  currentPage = currentPage - 1;
                                });
                              } else {
                                setState(() {
                                  currentPage = currentPage - 1;
                                });
                              }
                            },
                            child: (ownermodule == '0' && currentPage == 0)
                                ? Container()
                                : IosBackButton()),
                        SizedBox(height: media.height * 0.05),
                        (countries.isNotEmpty && currentPage == 0)
                            ? Builder(builder: (context) {
                          SharedPreferences.getInstance().then((value) {
                            value.setString(
                                currentRegScreen, isLoginScreen);
                          });
                          return Column(
                            children: [
                              Center(
                                child: Image(
                                    image: AssetImage(
                                        'assets/images/no_ride.png'),
                                    width: media.width * 0.6),
                              ),
                              SizedBox(height: 15),
                              Center(
                                child: MyText(
                                  text: languages[choosenLanguage]['text_what_mobilenum'],
                                  size: media.width * twentytwo,
                                  fontweight: FontWeight.bold,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: media.height * 0.03),
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                    10, 0, 10, 0),
                                height: 50,
                                width: media.width * 0.9,
                                decoration: BoxDecoration(
                                  color: darkModeSecContainer,
                                  borderRadius:
                                  BorderRadius.circular(3000.0),
                                  border: Border.all(
                                      color: darkModeBorderColor),
                                ),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        if (countries.isNotEmpty) {
                                          await showDialog(
                                              context: context,
                                              builder: (context) {
                                                var searchVal = '';
                                                return AlertDialog(
                                                  backgroundColor: page,
                                                  insetPadding:
                                                  const EdgeInsets
                                                      .all(10),
                                                  content: StatefulBuilder(
                                                      builder: (context,
                                                          setState) {
                                                        return Container(
                                                          width:
                                                          media.width * 0.9,
                                                          color: page,
                                                          child: Directionality(
                                                            textDirection: (languageDirection ==
                                                                'rtl')
                                                                ? TextDirection
                                                                .rtl
                                                                : TextDirection
                                                                .ltr,
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      left: 20,
                                                                      right:
                                                                      20),
                                                                  width: media
                                                                      .width *
                                                                      0.9,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                      BorderRadius.circular(
                                                                          3000.0),
                                                                      border: Border.all(
                                                                          color:
                                                                          darkModeBorderColor,
                                                                          width:
                                                                          1.5)),
                                                                  child:
                                                                  TextField(
                                                                    decoration: InputDecoration(
                                                                        border:
                                                                        InputBorder.none,
                                                                        hintText: languages[choosenLanguage]
                                                                        [
                                                                        'text_search'],
                                                                        hintStyle: GoogleFonts.inter(
                                                                            fontSize: media.width * sixteen,
                                                                            color: hintColor)),
                                                                    style: GoogleFonts.inter(
                                                                        fontSize: media
                                                                            .width *
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
                                                                    child:
                                                                    Column(
                                                                      children: countries
                                                                          .asMap()
                                                                          .map((i,
                                                                          value) {
                                                                        return MapEntry(
                                                                            i,
                                                                            SizedBox(
                                                                              width: media.width * 0.9,
                                                                              child: (searchVal == '' && countries[i]['flag'] != null)
                                                                                  ? InkWell(
                                                                                  onTap: () async {
                                                                                    setState(() {
                                                                                      phcode = i;
                                                                                    });
                                                                                    await sharefPref!.setInt(phcodeForRedirect, i);
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
                                                                                            SizedBox(width: media.width * 0.02),
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
                                                                                  onTap: () async {
                                                                                    setState(() {
                                                                                      phcode = i;
                                                                                    });
                                                                                    await sharefPref!.setInt(phcodeForRedirect, i);
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
                                                                                            SizedBox(width: media.width * 0.02),
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
                                      child: Container(
                                        height: 50,
                                        alignment: Alignment.center,
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(width: 5),
                                            SizedBox(width: 5),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              size: 20,
                                              color: textColor,
                                            ),
                                            SizedBox(width: 5),
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
                                        alignment: Alignment.centerLeft,
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
                                          keyboardType:
                                          TextInputType.phone,
                                          decoration: InputDecoration(
                                            counterText: '',
                                            prefix: MyText(
                                                  text: countries[phcode]['dial_code'].toString(),
                                                  size: media.width * sixteen,
                                                  textAlign: TextAlign.center,
                                                ),
                                            hintStyle: choosenLanguage ==
                                                'ar'
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
                                            enabledBorder:
                                            InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: media.height * 0.02),
                              MyText(
                                text: languages[choosenLanguage]
                                ['text_you_get_otp'],
                                size: media.width * twelve,
                                fontweight: FontWeight.w300,
                                color: textColor.withOpacity(0.5),
                              ),
                              SizedBox(height: media.height * 0.02),
                              Container(
                                width: Responsive.width(100, context),
                                height: 2,
                                color: darkModeBorderColor,
                              ),
                              SizedBox(
                                  height: Responsive.height(2, context)),
                              (controller.text.length >=
                                  countries[phcode]['dial_min_length'])
                                  ? Container(
                                width: media.width * 1 -
                                    media.width * 0.08,
                                alignment: Alignment.center,
                                child: Button(
                                  borderRadius: 3000.0,
                                  onTap: () async {
                                    if (controller.text.length >=
                                        countries[phcode]
                                        ['dial_min_length']) {
                                      _error = '';
                                      FocusManager
                                          .instance.primaryFocus
                                          ?.unfocus();
                                      setState(() {
                                        loginLoading = true;
                                      });
                                      var val = await otpCall();
                                      if (val.value == true) {
                                        phoneAuthCheck = true;
                                        await phoneAuth(
                                            countries[phcode]
                                            ['dial_code'] +
                                                phnumber);
                                        value = 0;
                                        currentPage = 1;
                                        loginLoading = false;
                                        setState(() {});
                                      } else if (val.value ==
                                          false) {
                                        phoneAuthCheck = false;
                                        currentPage = 1;
                                        loginLoading = false;
                                        setState(() {});
                                      }
                                      await sharefPref!.setString(
                                          countryForPageRedirect,
                                          countries[phcode]
                                          ['dial_code']
                                              .toString()
                                              .substring(1));
                                      await sharefPref!.setString(
                                          phoneForPageRedirect,
                                          phnumber);
                                    }
                                  },
                                  text: languages[choosenLanguage]
                                  ['text_continue'],
                                ),
                              )
                                  : Container(),
                              SizedBox(
                                  height: Responsive.height(2, context)),
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
                                    SizedBox(height: media.width * 0.025)
                                  ],
                                ),
                              SizedBox(height: Responsive.height(2, context)),
// Séparateur
                              Row(
                                children: [
                                  Expanded(child: Container(height: 1, color: darkModeBorderColor)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: MyText(
                                      text: 'OU',
                                      size: media.width * twelve,
                                      color: textColor.withOpacity(0.5),
                                    ),
                                  ),
                                  Expanded(child: Container(height: 1, color: darkModeBorderColor)),
                                ],
                              ),
                              SizedBox(height: Responsive.height(2, context)),
// Bouton Google
                              InkWell(
                                onTap: () async {
                                  setState(() { loginLoading = true; });
                                  var result = await signInWithGoogle();
                                  if (result == true) {
                                    // Utilisateur existant → Maps
                                    await getUserDetails();
                                    await getSubscriptionStatus();
                                    if (userDetails['uploaded_document'] == false ||
                                        userDetails['approve'] == false) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => const RequiredInformation()),
                                            (route) => false,
                                      );
                                    } else {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => const Maps()),
                                            (route) => false,
                                      );
                                    }
                                  } else if (result == false) {
                                    // Nouvel utilisateur → NamePage
                                    currentPage = 2;
                                  } else if (result != 'cancelled') {
                                    setState(() {
                                      _error = result.toString();
                                    });
                                  }
                                  setState(() { loginLoading = false; });
                                },
                                child: Container(
                                  height: 50,
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                    color: darkModeSecContainer,
                                    borderRadius: BorderRadius.circular(3000.0),
                                    border: Border.all(color: darkModeBorderColor),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/google.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                      SizedBox(width: 10),
                                      MyText(
                                        text: 'Continuer avec Google',
                                        size: media.width * fourteen,
                                        fontweight: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        })
                            : (currentPage == 1)
                            ? const Expanded(child: Otp())
                            : (currentPage == 2)
                            ? const Expanded(child: NamePage())
                            : (currentPage == 3)
                            ? const Expanded(child: AggreementPage())
                            : Container(),
                      ],
                    ),
                  ),
                );
              }),
          (internet == false)
              ? Positioned(
              top: 0,
              child: NoInternet(onTap: () {
                setState(() {
                  loginLoading = true;
                  internet = true;
                  countryCode();
                });
              }))
              : Container(),
          (loginLoading == true)
              ? const Positioned(top: 0, child: Loading())
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