import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/common/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loadingpage.dart';
import 'requiredinformation.dart';

class AggreementPage extends StatefulWidget {
  const AggreementPage({Key? key}) : super(key: key);

  @override
  State<AggreementPage> createState() => _AggreementPageState();
}

class _AggreementPageState extends State<AggreementPage> {
  //navigate
  navigate() {
    carInformationCompleted = false;
    documentCompleted = false;
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const RequiredInformation()));
  }

  bool ischeck = false;
  // ignore: unused_field
  // String _error = '';

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      value.setString(currentRegScreen, isAgrementScreen);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      color: page,
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: media.height * 0.01,
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 0, bottom: 15),
                    child: MyText(
                      text: languages[choosenLanguage]['text_accept_head'],
                      size: media.width * twentytwo,
                      fontweight: FontWeight.bold,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    height: media.width * 0.3,
                    width: media.width * 0.37,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/image_done.png'),
                            fit: BoxFit.contain)),
                  ),
                  SizedBox(
                    height: Responsive.height(4, context),
                  ),
                  SizedBox(
                      width: media.width * 0.9,
                      child: RichText(
                        text: TextSpan(
                          // text: 'Hello ',
                          style: choosenLanguage == 'ar'
                              ? GoogleFonts.cairo(
                                  color: textColor,
                                  fontSize: media.width * fourteen,
                                )
                              : GoogleFonts.inter(
                                  color: textColor,
                                  fontSize: media.width * fourteen,
                                ),
                          children: [
                            TextSpan(
                                text: languages[choosenLanguage]
                                    ['text_agree_text1']),
                            TextSpan(
                                text: languages[choosenLanguage]
                                    ['text_terms_of_use'],
                                style: choosenLanguage == 'ar'
                                    ? GoogleFonts.cairo(
                                        color: buttonColor,
                                        fontSize: media.width * fourteen,
                                      )
                                    : GoogleFonts.inter(
                                        color: buttonColor,
                                        fontSize: media.width * fourteen,
                                      ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    openBrowser('https://rungobf.com/terms');
                                  }),
                            TextSpan(
                                text: languages[choosenLanguage]
                                    ['text_agree_text2']),
                            TextSpan(
                                text: languages[choosenLanguage]
                                    ['text_privacy'],
                                style: choosenLanguage == 'ar'
                                    ? GoogleFonts.cairo(
                                        color: buttonColor,
                                        fontSize: media.width * fourteen,
                                      )
                                    : GoogleFonts.inter(
                                        color: buttonColor,
                                        fontSize: media.width * fourteen,
                                      ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    openBrowser('https://rungobf.com/fr/privacy/');
                                  }),
                          ],
                        ),
                      )),
                  GestureDetector(
                    onTap: () {
                      if (ischeck == false) {
                        setState(() {
                          ischeck = true;
                        });
                      } else {
                        setState(() {
                          ischeck = false;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.only(top: 15, bottom: 15),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: media.width * 0.055,
                            width: media.width * 0.055,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: ischeck ? white : Colors.transparent,
                                border: ischeck
                                    ? null
                                    : Border.all(color: buttonColor, width: 2)),
                            child: ischeck == false
                                ? null
                                : Icon(
                                    Icons.done,
                                    size: media.width * 0.04,
                                    color: buttonColor,
                                  ),
                          ),
                          SizedBox(
                            width: media.width * 0.02,
                          ),
                          MyText(
                            text: languages[choosenLanguage]['text_iagree'],
                            size: media.width * sixteen,
                            fontweight: FontWeight.w400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
            ischeck == true
                ? Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: Button(
                        onTap: () async {
                          // _error = '';

                          navigate();
                        },
                        text: languages[choosenLanguage]['text_next']),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: Button(
                        onTap: () async {},
                        text: languages[choosenLanguage]['text_next'],
                        color: darkModeSecContainer,
                        textcolor: textColor),
                  ),
            ButtonBottomSpace(
              height: 4,
            )
          ],
        ),
      ),
    );
  }
}
