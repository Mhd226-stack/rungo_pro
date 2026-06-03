import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/pages/onTripPage/map_page.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';
import 'package:http/http.dart' as http;
import '../../widgets/widgets.dart';
import '../language/languages.dart';
import '../login/landingpage.dart';
import '../login/login.dart';
import '../login/requiredinformation.dart';
import '../noInternet/nointernet.dart';
import 'loading.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

dynamic package;
SharedPreferences? sharefPref;

const isLoginScreen = "isLoginScreen";
const currentRegScreen = 'currentRegScreen';
const isOTPScreen = "isOTPScreen";
const phoneForPageRedirect = 'phoneForPageRedirect';
const countryForPageRedirect = 'countryForPageRedirect';
const phcodeForRedirect = 'phcodeForRedirect';
const isNameScreen = "isNameScreen";
const isAgrementScreen = "isPolicyScreen";
const isDriver = 'isDriver';

class _LoadingPageState extends State<LoadingPage> with TickerProviderStateMixin {
  String dot = '.';
  bool updateAvailable = false;
  dynamic _package;
  dynamic _version;
  bool _error = false;
  bool _isLoading = false;

  late AnimationController _lottieController;
  late AnimationController _splashController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  var demopage = TextEditingController();

  //navigate
  navigate() {
    if (userDetails['uploaded_document'] == true &&
        userDetails['approve'] == true) {
      //status approved

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Maps()),
              (route) => false);
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const RequiredInformation()));
    }
  }

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);

    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _scaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _splashController, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _splashController.forward();
    });

    getLanguageDone();
    getOwnermodule();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _splashController.dispose(); // ✅ ajouté
    super.dispose();
  }

  getData() async {
    for (var i = 0; _error == true; i++) {
      await getLanguageDone();
    }
  }

//get language json and data saved in local (bearer token , choosen language) and find users current status
  getLanguageDone() async {
    _package = await PackageInfo.fromPlatform();
    try {
      if (platform == TargetPlatform.android || platform == null) {
        _version = await FirebaseDatabase.instance
            .ref()
            .child('driver_android_version')
            .get();
      } else {
        _version = await FirebaseDatabase.instance
            .ref()
            .child('driver_ios_version')
            .get();
      }
      _error = false;
      if (_version.value != null) {
        var version = _version.value.toString().split('.');
        var package = _package.version.toString().split('.');

        for (var i = 0; i < version.length || i < package.length; i++) {
          if (i < version.length && i < package.length) {
            if (int.parse(package[i]) < int.parse(version[i])) {
              setState(() {
                updateAvailable = true;
              });
              break;
            } else if (int.parse(package[i]) > int.parse(version[i])) {
              setState(() {
                updateAvailable = false;
              });
              break;
            }
          } else if (i >= version.length && i < package.length) {
            setState(() {
              updateAvailable = false;
            });
            break;
          } else if (i < version.length && i >= package.length) {
            setState(() {
              updateAvailable = true;
            });
            break;
          }
        }
      }
      sharefPref = await SharedPreferences.getInstance();
      bool isLoginAsDriver = sharefPref!.getBool(isDriver) ?? true;
      isLoginAsDriver
          ? ischeckownerordriver = 'driver'
          : ischeckownerordriver = 'owner';
      String getCurrentRegScreen =
          sharefPref!.getString(currentRegScreen) ?? '';
      debugPrint('Current registration screen: $getCurrentRegScreen');

      if (updateAvailable == false) {
        await getDetailsOfDevice();
        if (internet == true) {
          var val = await getLocalData();

          //if user is login and check waiting for approval status and send accordingly
          if (val == '3') {
            navigate();
          } else if (getCurrentRegScreen == 'isLoginScreen') {
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Login()));
            });
          } else if (getCurrentRegScreen != '') {
            // En cours d'inscription → continuer l'inscription
            Future.delayed(const Duration(seconds: 1), () {
              if (ownermodule == '1') {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LandingPage()));
              } else {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Login()));
              }
            });
          } else if (choosenLanguage == '') {
            // ignore: use_build_context_synchronously
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Languages()));
          } else if (val == '2') {
            Future.delayed(const Duration(seconds: 1), () {
              if (ownermodule == '1') {
                Future.delayed(const Duration(seconds: 1), () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LandingPage()));
                });
              } else {
                ischeckownerordriver = 'driver';
                Future.delayed(const Duration(seconds: 1), () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const Login()));
                });
              }
            });
          } else {
            Future.delayed(const Duration(seconds: 1), () {
              //choose language page
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Languages()));
            });
          }
          setState(() {});
        }
      }
    } catch (e) {
      if (internet == true) {
        if (_error == false) {
          setState(() {
            _error = true;
          });
          getData();
        }
      } else {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      child: Scaffold(
        body: Stack(
          children: [
            // Container(
            //   height: media.height * 1,
            //   width: media.width * 1,
            //   decoration: BoxDecoration(color: page
            //       // color: Color(0xff000000),
            //       ),
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Container(
            //         padding: EdgeInsets.all(media.width * 0.01),
            //         width: media.width * 0.5,
            //         height: media.width * 0.6,
            //         decoration: const BoxDecoration(
            //             image: DecorationImage(
            //                 image: AssetImage('assets/images/logo.png'),
            //                 fit: BoxFit.contain)),
            //       ),
            //     ],
            //   ),
            // ),
            Container(
              height: media.height * 1,
              width: media.width * 1,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC244),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/connect.json',
                    controller: _lottieController,
                    width: media.width * 0.7,
                    height: media.height * 0.45,
                    fit: BoxFit.contain,
                    onLoaded: (composition) {
                      _lottieController
                        ..duration = composition.duration
                        ..repeat();
                    },
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'RUN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 6,
                              ),
                            ),
                            TextSpan(
                              text: 'GO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 6,
                              ),
                            ),
                            TextSpan(
                              text: '  PRO',
                              style: TextStyle(
                                color: Colors.deepOrange,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),

            //update available

            (updateAvailable == true)
                ? Positioned(
                top: 0,
                child: Container(
                  height: media.height * 1,
                  width: media.width * 1,
                  color: Colors.black.withValues(alpha: 0.6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: media.width * 0.9,
                          padding: EdgeInsets.all(media.width * 0.05),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: page,
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                  width: media.width * 0.8,
                                  child: MyText(
                                    text:
                                    'New version of this app is available in store, please update the app for continue using',
                                    size: media.width * sixteen,
                                    fontweight: FontWeight.w600,
                                  )),
                              SizedBox(
                                height: media.width * 0.05,
                              ),
                              Button(
                                  onTap: () async {
                                    if (platform ==
                                        TargetPlatform.android) {
                                      openBrowser(
                                          'https://play.google.com/store/apps/details?id=${_package.packageName}');
                                    } else {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      var response = await http.get(Uri.parse(
                                          'http://itunes.apple.com/lookup?bundleId=${_package.packageName}'));
                                      if (response.statusCode == 200) {
                                        openBrowser(jsonDecode(
                                            response.body)['results'][0]
                                        ['trackViewUrl']);
                                      }

                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  },
                                  text: 'Update')
                            ],
                          ))
                    ],
                  ),
                ))
                : Container(),
            //internet is not connected
            (internet == false)
                ? Positioned(
                top: 0,
                child: NoInternet(
                  onTap: () {
                    //try again
                    setState(() {
                      internetTrue();
                      getLanguageDone();
                    });
                  },

                ))
                : Container(),

            //loader
            (_isLoading == true && internet == true)
                ? const Positioned(top: 0, child: Loading())
                : Container(),
          ],
        ),
      ),
    );
  }
}